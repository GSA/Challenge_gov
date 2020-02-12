defmodule ChallengeGov.Challenges.WinnerImage do
  @moduledoc """
  Handles uploading winner images for a challenge
  """

  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Images
  alias ChallengeGov.Repo
  alias Stein.Storage

  @doc """
  Get the storage path for a challenge's winner_image
  """
  def winner_image_path(size, key, extension), do: "/challenges/#{size}-#{key}#{extension}"

  def winner_image_path(challenge = %Challenge{}, size) do
    winner_image_path(size, challenge.winner_image_key, challenge.winner_image_extension)
  end

  @doc """
  Upload a winner_image if the key is present
  """
  def maybe_upload_winner_image(challenge, params) do
    params =
      Enum.into(params, %{}, fn {key, value} ->
        {to_string(key), value}
      end)

    case Map.has_key?(params, "winner_image") do
      true ->
        upload_winner_image(challenge, Map.get(params, "winner_image"))

      false ->
        {:ok, challenge}
    end
  end

  def upload_winner_image(challenge, file) do
    file = Storage.prep_file(file)

    key = UUID.uuid4()
    path = winner_image_path("original", key, file.extension)
    changeset = Challenge.winner_image_changeset(challenge, key, file.extension)

    with :ok <- upload(file, path),
         {:ok, challenge} <- Repo.update(changeset) do
      generate_thumbnail(challenge, file)
    else
      {:error, :invalid_extension} ->
        challenge
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:winner_image, "must be a jpg, png, or gif")
        |> Ecto.Changeset.apply_action(:update)

      {:error, _reason} ->
        challenge
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:winner_image, "had an issue uploading")
        |> Ecto.Changeset.apply_action(:update)
    end
  end

  defp upload(file, path) do
    Storage.upload(file, path, extensions: [".jpg", ".jpeg", ".png", ".gif"])
  end

  def generate_thumbnail(challenge, file) do
    path = winner_image_path(challenge, "thumbnail")

    case Images.convert(file, extname: file.extension, thumbnail: "600x600") do
      {:ok, temp_path} ->
        upload(%{path: temp_path}, path)
        File.rm(temp_path)

        {:ok, challenge}

      {:error, :convert} ->
        {:ok, challenge}
    end
  end
end
