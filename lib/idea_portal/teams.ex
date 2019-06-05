defmodule IdeaPortal.Teams do
  @moduledoc """
  Teams context
  """

  alias IdeaPortal.Repo
  alias IdeaPortal.Teams.Member
  alias IdeaPortal.Teams.Team
  alias Stein.Pagination

  import Ecto.Query

  @doc """
  New team changeset
  """
  def new(), do: Team.create_changeset(%Team{}, %{})

  @doc """
  Edit team changeset
  """
  def edit(team), do: Team.create_changeset(team, %{})

  @doc """
  Get all accounts
  """
  def all(opts \\ []) do
    opts = Enum.into(opts, %{})

    query =
      Team
      |> where([t], is_nil(t.deleted_at))
      |> preload(:members)

    Pagination.paginate(Repo, query, opts)
  end

  @doc """
  Get an individual team
  """
  def get(id) do
    team =
      Team
      |> where([t], t.id == ^id and is_nil(t.deleted_at))
      |> Repo.one()

    case team do
      nil ->
        {:error, :not_found}

      team ->
        team = Repo.preload(team, members: :user)
        {:ok, team}
    end
  end

  @doc """
  Check if a user is the member of any team
  """
  def member_of_team?(user) do
    user = Repo.preload(user, :members)
    !Enum.empty?(user.members)
  end

  @doc """
  Create a new team

  Adds the user to the team, fails if the user is already part of a team
  """
  def create(%{email_verified_at: nil}, _params) do
    %Team{}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:base, "you must verify your email first")
    |> Ecto.Changeset.apply_action(:insert)
  end

  def create(user, params) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:team, Team.create_changeset(%Team{}, params))
      |> Ecto.Multi.run(:member, fn _repo, %{team: team} ->
        %Member{}
        |> Member.create_changeset(user, team)
        |> Repo.insert()
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{team: team}} ->
        {:ok, team}

      {:error, :team, changeset, _changes} ->
        {:error, changeset}

      {:error, :member, _changeset, _changes} ->
        %Team{}
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:base, "already a member of a team")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  @doc """
  Update a team
  """
  def update(team, params) do
    team
    |> Team.update_changeset(params)
    |> Repo.update()
  end

  @doc """
  Soft delete a team

  Marks as deleted by setting the timestamp
  """
  def delete(team) do
    now = DateTime.truncate(Timex.now(), :second)

    team
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:deleted_at, now)
    |> Repo.update()
  end
end
