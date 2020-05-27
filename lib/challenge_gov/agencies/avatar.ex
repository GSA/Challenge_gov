defmodule ChallengeGov.Agencies.Avatar do
  @moduledoc """
  Handles uploading avatar's for an agency
  """

  alias ChallengeGov.Agencies.Agency
  alias ChallengeGov.Images
  alias ChallengeGov.Repo
  alias Stein.Storage

  @doc """
  Get the storage path for a agency's avatar
  """
  def avatar_path(size, key, extension), do: "/agencies/#{size}-#{key}#{extension}"

  def avatar_path(agency = %Agency{}, size) do
    avatar_path(size, agency.avatar_key, agency.avatar_extension)
  end

  @doc """
  Upload an avatar if the key is present
  """
  def maybe_upload_avatar(agency, params) do
    params =
      Enum.into(params, %{}, fn {key, value} ->
        {to_string(key), value}
      end)

    case Map.has_key?(params, "avatar") do
      true ->
        upload_avatar(agency, Map.get(params, "avatar"))

      false ->
        {:ok, agency}
    end
  end

  def upload_avatar(agency, file) do
    file = Storage.prep_file(file)

    key = UUID.uuid4()
    path = avatar_path("original", key, file.extension)
    changeset = Agency.avatar_changeset(agency, key, file.extension)

    with :ok <- upload(file, path),
         {:ok, agency} <- Repo.update(changeset) do
      generate_thumbnail(agency, file)
    else
      {:error, :invalid_extension} ->
        agency
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:avatar, "must be a jpg, png, or gif")
        |> Ecto.Changeset.apply_action(:update)

      {:error, _reason} ->
        agency
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:avatar, "had an issue uploading")
        |> Ecto.Changeset.apply_action(:update)
    end
  end

  defp upload(file, path) do
    Storage.upload(file, path, extensions: [".jpg", ".jpeg", ".png", ".gif"])
  end

  def generate_thumbnail(agency, file) do
    path = avatar_path(agency, "thumbnail")

    case Images.convert(file, extname: file.extension, thumbnail: "600x600") do
      {:ok, temp_path} ->
        upload(%{path: temp_path}, path)
        File.rm(temp_path)
        {:ok, agency}

      {:error, :convert} ->
        {:ok, agency}
    end
  end
end
