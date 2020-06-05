defmodule ChallengeGov.Challenges.ResourceBanner do
  @moduledoc """
  Handles uploading resource banner for a challenge
  """

  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Images
  alias ChallengeGov.Repo
  alias Stein.Storage

  @doc """
  Get the storage path for a challenge's resource_banner
  """
  def resource_banner_path(size, key, extension), do: "/challenges/#{size}-#{key}#{extension}"

  def resource_banner_path(challenge = %Challenge{}, size) do
    resource_banner_path(size, challenge.resource_banner_key, challenge.resource_banner_extension)
  end

  @doc """
  Upload a resource_banner if the key is present
  """
  def maybe_upload_resource_banner(challenge, params) do
    params =
      Enum.into(params, %{}, fn {key, value} ->
        {to_string(key), value}
      end)

    case Map.has_key?(params, "resource_banner") do
      true ->
        upload_resource_banner(challenge, Map.get(params, "resource_banner"))

      false ->
        {:ok, challenge}
    end
  end

  def upload_resource_banner(challenge, file) do
    file = Storage.prep_file(file)

    key = UUID.uuid4()
    path = resource_banner_path("original", key, file.extension)
    changeset = Challenge.resource_banner_changeset(challenge, key, file.extension)

    with :ok <- upload(file, path),
         {:ok, challenge} <- Repo.update(changeset) do
      generate_thumbnail(challenge, file)
    else
      {:error, :invalid_extension} ->
        challenge
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:resource_banner, "must be a jpg, png, or gif")
        |> Ecto.Changeset.apply_action(:update)

      {:error, _reason} ->
        challenge
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:resource_banner, "had an issue uploading")
        |> Ecto.Changeset.apply_action(:update)
    end
  end

  defp upload(file, path) do
    Storage.upload(file, path, extensions: [".jpg", ".jpeg", ".png", ".gif"])
  end

  def generate_thumbnail(challenge, file) do
    path = resource_banner_path(challenge, "thumbnail")

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
