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
  end
end
