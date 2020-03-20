defmodule ChallengeGov.SecurityLogs.SecurityLog do
  @moduledoc """
  Security Log schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User

  @type t :: %__MODULE__{}

  @types [
    "status_change",
    "login",
    "accessed_site",
    "session_duration"
  ]

  schema "security_logs" do
    belongs_to(:user_id, User)
    field(:type, :string)
    field(:data, :map)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :user_id,
      :type,
      :data
    ])
    |> validate_inclusion(:type, @types)
    |> foreign_key_constraint(:user_id)
  end

  def types, do: @types
end
