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

    field(:password_reset_token, Ecto.UUID)
    field(:password_reset_expires_at, :utc_datetime)

    field(:first_name, :string)
    field(:last_name, :string)
    field(:phone_number, :string)

    has_many(:challenges, Challenge)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :email,
      :first_name,
      :last_name,
      :phone_number
    ])
    |> validate_required([:email, :first_name, :last_name])
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> unique_constraint(:email, name: :users_lower_email_index)
  end

  def password_changeset(struct, params) do
    struct
    |> cast(params, [:password, :password_confirmation])
    |> validate_required([:password])
    |> validate_confirmation(:password)
    |> Stein.Accounts.hash_password()
    |> validate_required([:password_hash])
  end

  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> password_changeset(params)
    |> put_change(:token, UUID.uuid4())
    |> put_change(:email_verification_token, UUID.uuid4())
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> password_changeset(params)
    |> maybe_reset_verification()
  end

  def maybe_reset_verification(struct) do
    case get_change(struct, :email) do
      nil ->
        struct

      _ ->
        struct
        |> put_change(:email_verification_token, UUID.uuid4())
        |> put_change(:email_verified_at, nil)
    end
  end
end
