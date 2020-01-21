defmodule ChallengeGov.Accounts.Avatar do
  @moduledoc """
  Handles uploading avatar's for a user
  """

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Images
  alias ChallengeGov.Repo
  alias Stein.Storage

  @doc """
  Get the storage path for a user's avatar
  """
  def avatar_path(size, key, extension), do: "/avatars/#{size}-#{key}#{extension}"

  def avatar_path(user = %User{}, size) do
    avatar_path(size, user.avatar_key, user.avatar_extension)
  end

  @doc """
  Upload an avatar if the key is present
  """
  def maybe_upload_avatar(user, params) do
    params =
      Enum.into(params, %{}, fn {key, value} ->
        {to_string(key), value}
      end)

    case Map.has_key?(params, "avatar") do
      true ->
        upload_avatar(user, Map.get(params, "avatar"))

      false ->
        {:ok, user}
    end
  end

  def upload_avatar(user, file) do
    file = Storage.prep_file(file)

    key = UUID.uuid4()
    path = avatar_path("original", key, file.extension)
    changeset = User.avatar_changeset(user, key, file.extension)

    with :ok <- upload(file, path),
         {:ok, user} <- Repo.update(changeset) do
      generate_thumbnail(user, file)
    else
      {:error, :invalid_extension} ->
        user
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:avatar, "must be a jpg, png, or gif")
        |> Ecto.Changeset.apply_action(:update)

      {:error, _reason} ->
        user
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:avatar, "had an issue uploading")
        |> Ecto.Changeset.apply_action(:update)
    end
  end

  defp upload(file, path) do
    Storage.upload(file, path, extensions: [".jpg", ".jpeg", ".png", ".gif"])
  end

  def generate_thumbnail(user, file) do
    path = avatar_path(user, "thumbnail")

    case Images.convert(file, extname: file.extension, thumbnail: "600x600") do
      {:ok, temp_path} ->
        upload(%{path: temp_path}, path)
        File.rm(temp_path)

        {:ok, user}

      {:error, :convert} ->
        {:ok, user}
    end
  end
end
