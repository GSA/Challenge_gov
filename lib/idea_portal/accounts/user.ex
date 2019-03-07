defmodule IdeaPortal.Accounts.User do
  @moduledoc """
  User schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "users" do
    field(:email, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    field(:first_name, :string)
    field(:last_name, :string)
    field(:phone_number, :string)

    timestamps()
  end

  def create_changeset(struct, params) do
    struct
    |> cast(params, [:email, :password, :password_confirmation, :first_name, :last_name, :phone_number])
    |> validate_required([:email, :first_name, :last_name])
    |> validate_confirmation(:password)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> Stein.Accounts.hash_password()
    |> validate_required([:password_hash])
    |> unique_constraint(:email, name: :users_lower_email_index)
  end
end
