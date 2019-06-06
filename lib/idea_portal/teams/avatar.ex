defmodule IdeaPortal.Teams.Avatar do
  @moduledoc """
  Handles uploading avatar's for a team
  """

  alias IdeaPortal.Teams.Team
  alias IdeaPortal.Images
  alias IdeaPortal.Repo
  alias Stein.Storage

  @doc """
  Get the storage path for a team's avatar
  """
  def avatar_path(size, key, extension), do: "/teams/#{size}-#{key}#{extension}"

  def avatar_path(team = %Team{}, size) do
    avatar_path(size, team.avatar_key, team.avatar_extension)
  end

  @doc """
  Upload an avatar if the key is present
  """
  def maybe_upload_avatar(team, params) do
    params =
      Enum.into(params, %{}, fn {key, value} ->
        {to_string(key), value}
      end)

    case Map.has_key?(params, "avatar") do
      true ->
        upload_avatar(team, Map.get(params, "avatar"))

      false ->
        {:ok, team}
    end
  end

  def upload_avatar(team, file) do
    file = Storage.prep_file(file)

    key = UUID.uuid4()
    path = avatar_path("original", key, file.extension)
    changeset = Team.avatar_changeset(team, key, file.extension)

    with :ok <- upload(file, path),
         {:ok, team} <- Repo.update(changeset) do
      generate_thumbnail(team, file)
    else
      {:error, :invalid_extension} ->
        team
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:avatar, "must be a jpg, png, or gif")
        |> Ecto.Changeset.apply_action(:update)

      {:error, _reason} ->
        team
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:avatar, "had an issue uploading")
        |> Ecto.Changeset.apply_action(:update)
    end
  end

  defp upload(file, path) do
    Storage.upload(file, path, extensions: [".jpg", ".jpeg", ".png", ".gif"], public: true)
  end

  def generate_thumbnail(team, file) do
    path = avatar_path(team, "thumbnail")

    case Images.convert(file, extname: file.extension, thumbnail: "600x600") do
      {:ok, temp_path} ->
        upload(%{path: temp_path}, path)
        File.rm(temp_path)

        {:ok, team}

      {:error, :convert} ->
        {:ok, team}
    end
  end
end
