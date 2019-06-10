defmodule IdeaPortal.Teams.Member do
  @moduledoc """
  Team member schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  alias IdeaPortal.Accounts.User
  alias IdeaPortal.Teams.Team

  schema "team_members" do
    field(:status, :string, default: "invited")

    belongs_to(:user, User)
    belongs_to(:team, Team)

    timestamps()
  end

  def create_changeset(struct, user, team) do
    struct
    |> change()
    |> put_change(:user_id, user.id)
    |> put_change(:team_id, team.id)
    |> unique_constraint(:user_id)
    |> unique_constraint(:user_id, name: :team_members_team_id_user_id_index)
  end

  def accept_invite_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "accepted")
    |> unique_constraint(:user_id)
    |> unique_constraint(:user_id, name: :team_members_team_id_user_id_index)
  end

  def reject_invite_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "rejected")
    |> unique_constraint(:user_id)
    |> unique_constraint(:user_id, name: :team_members_team_id_user_id_index)
  end
end
