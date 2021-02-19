defmodule ChallengeGov.Agencies.Member do
  @moduledoc """
  Agency member schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Agencies.Agency

  @type t :: %__MODULE__{}

  schema "agency_members" do
    belongs_to(:user, User)
    belongs_to(:agency, Agency)

    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(struct, user, agency) do
    struct
    |> change()
    |> put_change(:user_id, user.id)
    |> put_change(:agency_id, agency.id)
    |> unique_constraint(:user_id)
    |> unique_constraint(:user_id, name: :agency_members_agency_id_user_id_index)
  end

  def accept_invite_changeset(struct) do
    struct
    |> change()
    |> unique_constraint(:user_id)
    |> unique_constraint(:user_id, name: :agency_members_agency_id_user_id_index)
  end

  def reject_invite_changeset(struct) do
    struct
    |> change()
    |> unique_constraint(:user_id)
    |> unique_constraint(:user_id, name: :team_members_team_id_user_id_index)
  end
end
