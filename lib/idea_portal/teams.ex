defmodule IdeaPortal.Teams do
  @moduledoc """
  Teams context
  """

  alias IdeaPortal.Repo
  alias IdeaPortal.Teams.Member
  alias IdeaPortal.Teams.Team
  alias Stein.Pagination

  @doc """
  New team changeset
  """
  def new(), do: Team.create_changeset(%Team{}, %{})

  @doc """
  Get all accounts
  """
  def all(opts \\ []) do
    opts = Enum.into(opts, %{})
    Pagination.paginate(Repo, Team, opts)
  end

  @doc """
  Get an individual team
  """
  def get(id) do
    case Repo.get(Team, id) do
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
end
