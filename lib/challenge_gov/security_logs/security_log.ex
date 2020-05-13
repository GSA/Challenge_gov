defmodule ChallengeGov.SecurityLogs.SecurityLog do
  @moduledoc """
  Security Log schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User

  @type t :: %__MODULE__{}

  @actions [
    "status_change",
    "account_update",
    "role_change",
    "accessed_site",
    "session_duration",
    "create",
    "read",
    "update",
    "delete",
    "submit",
    "renewal_request"
  ]

  schema "security_log" do
    belongs_to(:originator, User)
    field(:action, :string)
    field(:details, :map)
    field(:originator_role, :string)
    field(:originator_identifier, :string)
    field(:originator_remote_ip, :string)
    field(:target_id, :integer)
    field(:target_type, :string)
    field(:target_identifier, :string)
    field(:logged_at, :utc_datetime)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :action,
      :details,
      :originator_id,
      :originator_role,
      :originator_identifier,
      :originator_remote_ip,
      :target_id,
      :target_type,
      :target_identifier
    ])
    |> put_change(:logged_at, DateTime.truncate(DateTime.utc_now(), :second))
    |> validate_inclusion(:action, @actions)
    |> unique_constraint(:originator_id)
  end

  def actions, do: @actions
end
