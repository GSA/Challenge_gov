defmodule IdeaPortal.Accounts.User do
  @moduledoc """
  User schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias IdeaPortal.Challenges.Challenge

  @type t :: %__MODULE__{}

  schema "users" do
    field(:role, :string, read_after_writes: true)

    field(:email, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:token, Ecto.UUID)

    field(:email_verification_token, :string)
    field(:email_verified_at, :utc_datetime)

    field(:first_name, :string)
    field(:last_name, :string)
    field(:phone_number, :string)

    has_many(:challenges, Challenge)

    timestamps()
  end

  def create_changeset(struct, params) do
    struct
    |> cast(params, [
      :email,
      :password,
      :password_confirmation,
      :first_name,
      :last_name,
      :phone_number
    ])
    |> validate_required([:email, :first_name, :last_name])
    |> validate_confirmation(:password)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> Stein.Accounts.hash_password()
    |> validate_required([:password_hash])
    |> put_change(:token, UUID.uuid4())
    |> put_change(:email_verification_token, UUID.uuid4())
    |> unique_constraint(:email, name: :users_lower_email_index)
  end
end
