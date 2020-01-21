defmodule ChallengeGov.Teams do
  @moduledoc """
  Teams context
  """

  alias ChallengeGov.Emails
  alias ChallengeGov.Mailer
  alias ChallengeGov.Repo
  alias ChallengeGov.Teams.Avatar
  alias ChallengeGov.Teams.Member
  alias ChallengeGov.Teams.Team
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
      |> preload(members: ^member_query())

    Pagination.paginate(Repo, query, opts)
  end

  @doc """
  Get an individual team
  """
  def get(id) do
    team =
      Team
      |> where([t], t.id == ^id and is_nil(t.deleted_at))
      |> preload(members: ^member_query())
      |> Repo.one()

    case team do
      nil ->
        {:error, :not_found}

      team ->
        team = Repo.preload(team, members: :user)
        {:ok, team}
    end
  end

  defp member_query() do
    from m in Member,
      join: u in assoc(m, :user),
      where: u.display == true,
      where: m.status == "accepted",
      preload: [user: [:challenges]]
  end

  @doc """
  Check if a user is the member of any team
  """
  def member_of_team?(user) do
    user = Repo.preload(user, members: from(m in Member, where: m.status == "accepted"))

    !Enum.empty?(user.members)
  end

  @doc """
  Create a new team

  Adds the user to the team, fails if the user is already part of a team
  """
  def create(%{email_verified_at: nil}, _params) do
    %Team{}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:base, "You must verify your email first")
    |> Ecto.Changeset.apply_action(:insert)
  end

  def create(user, params) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:team, Team.create_changeset(%Team{}, params))
      |> Ecto.Multi.run(:avatar, fn _repo, %{team: team} ->
        Avatar.maybe_upload_avatar(team, params)
      end)
      |> Ecto.Multi.run(:member, fn _repo, %{avatar: team} ->
        %Member{}
        |> Member.create_changeset(user, team)
        |> Ecto.Changeset.put_change(:status, "accepted")
        |> Repo.insert()
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{avatar: team}} ->
        {:ok, team}

      {:error, :team, changeset, _changes} ->
        {:error, changeset}

      {:error, :member, _changeset, _changes} ->
        %Team{}
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:base, "You are already a member of a team")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  @doc """
  Update a team
  """
  def update(team, params) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:team, Team.update_changeset(team, params))
      |> Ecto.Multi.run(:avatar, fn _repo, %{team: team} ->
        Avatar.maybe_upload_avatar(team, params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{avatar: team}} ->
        {:ok, team}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Soft delete a team

  Marks as deleted by setting the timestamp
  """
  def delete(team) do
    now = DateTime.truncate(Timex.now(), :second)

    changeset =
      team
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:deleted_at, now)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:team, changeset)
      |> Ecto.Multi.run(:archive_members, &archive_members/2)
      |> Repo.transaction()

    case result do
      {:ok, %{team: team}} ->
        {:ok, team}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  defp archive_members(repo, %{team: team}) do
    result =
      Member
      |> where([m], m.team_id == ^team.id)
      |> repo.update_all(set: [status: "archived"])

    {:ok, result}
  end

  @doc """
  Check if a user is a full member of the team
  """
  def member?(team, user) do
    !is_nil(Repo.get_by(Member, team_id: team.id, user_id: user.id, status: "accepted"))
  end

  @doc """
  Invite a new member to a team
  """
  def invite_member(team, inviter, invitee) do
    changeset = Member.create_changeset(%Member{}, invitee, team)

    case Repo.insert(changeset) do
      {:ok, member} ->
        invitee
        |> Emails.team_invitation(team, inviter)
        |> Mailer.deliver_later()

        {:ok, member}

      {:error, changeset} ->
        better_invitation_error(changeset)
    end
  end

  defp better_invitation_error(changeset) do
    case Keyword.has_key?(changeset.errors, :user_id) do
      true ->
        {_message, validation} = changeset.errors[:user_id]

        case validation[:constraint] == :unique do
          true ->
            {:error, :already_member}

          false ->
            {:error, changeset}
        end

      false ->
        {:error, changeset}
    end
  end

  defp find_invited_member(team, invitee) do
    case Repo.get_by(Member, team_id: team.id, user_id: invitee.id, status: "invited") do
      nil ->
        {:error, :not_found}

      member ->
        {:ok, member}
    end
  end

  @doc """
  Accept an invite for a team
  """
  def accept_invite(team, invitee) do
    with {:ok, member} <- find_invited_member(team, invitee) do
      {:ok, %{member: member}} =
        Ecto.Multi.new()
        |> Ecto.Multi.update(:member, Member.accept_invite_changeset(member))
        |> Ecto.Multi.run(:clear_invites, &clear_invites/2)
        |> Repo.transaction()

      {:ok, member}
    end
  end

  defp clear_invites(repo, %{member: member}) do
    result =
      Member
      |> where([m], m.user_id == ^member.user_id)
      |> where([m], m.team_id != ^member.team_id)
      |> repo.update_all(set: [status: "rejected"])

    {:ok, result}
  end

  @doc """
  Reject an invite
  """
  def reject_invite(team, invitee) do
    with {:ok, member} <- find_invited_member(team, invitee) do
      member
      |> Member.reject_invite_changeset()
      |> Repo.update()
    end
  end
end
