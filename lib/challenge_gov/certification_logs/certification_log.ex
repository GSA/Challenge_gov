defmodule ChallengeGov.CertificationLogs.CertificationLog do
  @moduledoc """
  Certification Log schema
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias ChallengeGov.Accounts.User

  @type t :: %__MODULE__{}

  schema "certification_log" do
    belongs_to(:approver, User)
    belongs_to(:user, User)

    field(:approver_role, :string)
    field(:approver_identifier, :string)
    field(:approver_remote_ip, :string)
    field(:user_role, :string)
    field(:user_identifier, :string)
    field(:user_remote_ip, :string)
    field(:requested_at, :utc_datetime)
    field(:certified_at, :utc_datetime)
    field(:expires_at, :utc_datetime)
    field(:denied_at, :utc_datetime)

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :approver_id,
      :approver_role,
      :approver_identifier,
      :approver_remote_ip,
      :user_id,
      :user_role,
      :user_identifier,
      :user_remote_ip,
      :requested_at,
      :certified_at,
      :expires_at,
      :denied_at
    ])
    |> unique_constraint([:approver_id, :user_id])
  end
end
