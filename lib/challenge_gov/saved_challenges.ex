defmodule ChallengeGov.SavedChallenges do
  @moduledoc """
  Context for saved challenges
  """
  alias ChallengeGov.Repo
  alias ChallengeGov.Challenges
  alias ChallengeGov.SavedChallenges.SavedChallenge
  alias Stein.Filter

  import Ecto.Query

  @behaviour Stein.Filter

  def all(user, opts \\ []) do
    SavedChallenge
    |> base_preload
    |> where([sc], sc.user_id == ^user.id)
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.paginate(opts[:page], opts[:per])
  end

  def get(id) do
    SavedChallenge
    |> base_preload
    |> where([sc], sc.id == ^id)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      saved_challenge ->
        {:ok, saved_challenge}
    end
  end

  def create(user, challenge) do
    if is_nil(challenge.deleted_at) and Challenges.is_public?(challenge) do
      %SavedChallenge{}
      |> SavedChallenge.changeset(user, challenge)
      |> Repo.insert()
    else
      {:error, :not_saved}
    end
  end

  def delete(user, saved_challenge) do
    if user.id === saved_challenge.user_id do
      Repo.delete(saved_challenge)
    else
      {:error, :not_allowed}
    end
  end

  def check_owner(user, saved_challenge) do
    if user.id === saved_challenge.user_id do
      {:ok, saved_challenge}
    else
      {:error, :wrong_owner}
    end
  end

  defp base_preload(saved_challenge) do
    preload(saved_challenge, [:user, challenge: [:agency]])
  end

  @impl true
  def filter_on_attribute({"user_id", value}, query) do
    where(query, [sc], sc.user_id == ^value)
  end
end
