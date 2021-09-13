defmodule ChallengeGov.PhaseWinners do
  @moduledoc """
  Context for winners
  """

  import Ecto.Query

  alias Ecto.Multi
  alias Stein.Storage
  alias ChallengeGov.Repo

  alias ChallengeGov.Winners
  alias ChallengeGov.PhaseWinners.PhaseWinner
  alias ChallengeGov.PhaseWinners.Winner

  def get(id) do
    PhaseWinner
    |> preload([:winners])
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, :no_phase_winner}

      phase_winner ->
        {:ok, phase_winner}
    end
  end

  def get_by_phase_id(phase_id) do
    PhaseWinner
    |> preload([:winners, :phase])
    |> Repo.get_by(phase_id: phase_id)
    |> case do
      nil ->
        {:error, :no_phase_winner}

      phase_winner ->
        {:ok, phase_winner}
    end
  end

  def create(phase) do
    %PhaseWinner{}
    |> PhaseWinner.create_changeset(phase, %{})
    |> Repo.insert()
  end

  def create(phase, %{"phase_winner" => phase_winner_params}) do
    %PhaseWinner{}
    |> PhaseWinner.create_changeset(phase, phase_winner_params)
    |> Repo.insert()
  end

  def edit(phase_winner), do: PhaseWinner.update_changeset(phase_winner)

  def update(phase_winner, %{"phase_winner" => phase_winner_params}) do
    Multi.new()
    |> Multi.update(
      :phase_winner,
      PhaseWinner.update_changeset(phase_winner, phase_winner_params)
    )
    |> Multi.run(:maybe_remove_overview_image, fn _repo, %{phase_winner: phase_winner} ->
      maybe_remove_overview_image(phase_winner, phase_winner_params)
    end)
    |> handle_winners(phase_winner, phase_winner_params)
    |> Repo.transaction()
    |> case do
      {:ok, %{phase_winner: phase_winner}} ->
        {:ok, phase_winner}

      {:error, _, _, _} ->
        {:error, :something_went_wrong}
    end
  end

  # Associations
  defp handle_winners(multi, phase_winner, %{"winners" => winners}) do
    winners
    |> Enum.reduce(multi, fn {index, winner_params}, multi ->
      winner_params = Map.merge(winner_params, %{"phase_winner_id" => phase_winner.id})

      %{"id" => id} = winner_params

      multi
      |> Multi.run({:winner, index, :get}, fn _repo, _changes ->
        maybe_get_winner(id)
      end)
      |> Multi.insert_or_update({:winner, index, :update}, fn changes ->
        winner = Map.get(changes, {:winner, index, :get})

        Winner.changeset(winner, winner_params)
      end)
      |> Multi.run({:winner, index, :maybe_handle_images}, fn _repo, changes ->
        winner = Map.get(changes, {:winner, index, :update})

        maybe_handle_winner_images(winner, winner_params)
      end)
      |> Multi.run({:winner, index, :maybe_handle_removal}, fn _repo, changes ->
        winner = Map.get(changes, {:winner, index, :update})

        maybe_handle_winner_removal(winner, winner_params)
      end)
    end)
  end

  defp handle_winners(multi, _phase_winner, _phase_winner_params), do: multi

  defp maybe_get_winner(""), do: {:ok, %Winner{}}
  defp maybe_get_winner(id), do: {:ok, Repo.get(Winner, id) || %Winner{}}

  defp maybe_handle_winner_images(winner, %{"remove_image" => "true", "image" => image}) do
    {:ok, winner} = Winners.remove_image(winner)
    Winners.upload_image(winner, image)
  end

  defp maybe_handle_winner_images(winner, %{"remove_image" => "true"}) do
    Winners.remove_image(winner)
  end

  defp maybe_handle_winner_images(winner, %{"image" => image}) do
    Winners.upload_image(winner, image)
  end

  defp maybe_handle_winner_images(winner, _winner_params), do: {:ok, winner}

  defp maybe_handle_winner_removal(winner, %{"remove" => "true"}) do
    Winners.delete(winner)
  end

  defp maybe_handle_winner_removal(winner, _winner_params), do: {:ok, winner}

  # Uploads
  def overview_image_path(_phase_winner, nil, nil), do: nil

  def overview_image_path(phase_winner, key, extension),
    do: "/phase_winners/#{phase_winner.id}/overview_image_#{key}#{extension}"

  def overview_image_path(phase_winner) do
    overview_image_path(
      phase_winner,
      phase_winner.overview_image_key,
      phase_winner.overview_image_extension
    )
  end

  def upload_overview_image(phase_winner, overview_image) do
    file = Storage.prep_file(overview_image)
    key = UUID.uuid4()
    path = overview_image_path(phase_winner, key, file.extension)
    meta = [{:content_disposition, ~s{attachment; filename="#{file.filename}"}}]

    allowed_extensions = [".jpg", ".jpeg", ".png", ".gif"]

    case Storage.upload(file, path, meta: meta, extensions: allowed_extensions) do
      :ok ->
        {:ok, key, file.extension}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_remove_overview_image(phase_winner, %{"remove_overview_image" => "true"}),
    do: remove_overview_image(phase_winner)

  defp maybe_remove_overview_image(phase_winner, _phase_winner_params), do: {:ok, phase_winner}

  defp remove_overview_image(phase_winner) do
    case Storage.delete(overview_image_path(phase_winner)) do
      :ok ->
        phase_winner
        |> PhaseWinner.overview_image_changeset(nil, nil)
        |> Repo.update()

      {:error, _reason} ->
        phase_winner
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:overview_image, "There was an issue removing this image")
        |> Repo.update()
    end
  end
end
