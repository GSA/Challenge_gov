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
    "accessed_site",
    "session_duration"
  ]

  schema "security_log" do
    belongs_to(:user, User)
    field(:type, :string)
    field(:data, :map)

    timestamps()
  end

  def changeset(struct, user, type, data) do
    struct
    |> change()
    |> put_change(:user_id, user.id)
    |> put_change(:type, type)
    |> put_change(:data, data)
    |> validate_inclusion(:type, @types)
    |> foreign_key_constraint(:user_id)
  end

  def types, do: @types
end
