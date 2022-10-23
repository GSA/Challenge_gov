defmodule ChallengeGov.Accounts.User do
  @moduledoc """
  User schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Challenges.ChallengeManager
  alias ChallengeGov.SupportingDocuments.Document
  alias ChallengeGov.Submissions
  alias ChallengeGov.Submissions.Submission
  alias ChallengeGov.Agencies.Member
  alias ChallengeGov.Messages.MessageContextStatus

  @type t :: %__MODULE__{}

  @roles [
    %{id: "super_admin", label: "Super Admin", rank: 1},
    %{id: "admin", label: "Admin", rank: 2},
    %{id: "challenge_manager", label: "Challenge Manager", rank: 3},
    %{id: "solver", label: "Solver", rank: 4}
  ]

  @doc """
  pending - newly created account is awaiting approval by an admin
  active - account is able to login and perform actions on the platform
  suspended - account is set to this by an admin and can no longer log in. Has access to old data when restored
  revoked - account is set to this by an admin and can no longer log in. Doesn't have access to old data when restored
  deactivated - account is set to this after 90 days of no activity and can no longer log in. Has access to old data when restored
  decertified - account is set to this every 365 days and can no longer log in. Has access to old data when restored
  """
  @statuses [
    "pending",
    "active",
    "suspended",
    "revoked",
    "deactivated",
    "decertified"
  ]

  schema "users" do
    # Associations
    has_many(:challenges, Challenge)
    has_many(:challenge_managers, ChallengeManager)
    has_many(:challenge_manager_challenges, through: [:challenge_managers, :challenge])
    has_many(:members, Member)
    has_many(:supporting_documents, Document)
    has_many(:submissions, Submission, foreign_key: :submitter_id)
    has_many(:managed_submissions, {"managed_submissions", Submission}, foreign_key: :manager_id)
    has_many(:submission_documents, Submissions.Document)
    has_many(:message_context_statuses, MessageContextStatus)

    # Fields
    field(:role, :string, read_after_writes: true)
    field(:status, :string, default: "pending")
    field(:finalized, :boolean, default: true)
    field(:display, :boolean, default: true)

    field(:email, :string)
    field(:email_confirmation, :string, virtual: true)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:token, Ecto.UUID)
    field(:jwt_token, :string)

    field(:email_verification_token, :string)
    field(:email_verified_at, :utc_datetime)

    field(:password_reset_token, Ecto.UUID)
    field(:password_reset_expires_at, :utc_datetime)

    field(:first_name, :string)
    field(:last_name, :string)
    field(:phone_number, :string)

    field(:avatar_key, Ecto.UUID)
    field(:avatar_extension, :string)

    field(:terms_of_use, :utc_datetime)
    field(:privacy_guidelines, :utc_datetime)
    field(:agency_id, :integer)

    field(:last_active, :utc_datetime)
    field(:active_session, :boolean)

    field(:renewal_request, :string)

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :email,
      :first_name,
      :last_name,
      :phone_number,
      :role,
      :token,
      :terms_of_use,
      :privacy_guidelines,
      :agency_id,
      :status,
      :active_session,
      :renewal_request
    ])
    |> validate_required([:email])
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> validate_inclusion(:status, @statuses)
    |> unique_constraint(:email, name: :users_lower_email_index)
  end

  def timestamp(struct, params) do
    utc_datetime = DateTime.utc_now()
    put_change(struct, params, DateTime.truncate(utc_datetime, :second))
  end

  def terms_changeset(struct, params) do
    struct
    |> cast(params, [
      :agency_id,
      :first_name,
      :last_name,
      :terms_of_use,
      :privacy_guidelines,
      :status
    ])
    |> timestamp(:terms_of_use)
    |> timestamp(:privacy_guidelines)
  end

  def password_changeset(struct, params) do
    struct
    |> cast(params, [:password, :password_confirmation])
    |> validate_required([:password])
    |> validate_confirmation(:password)
    |> Stein.Accounts.hash_password()
    |> validate_required([:password_hash])
  end

  def create_changeset(struct, params = %{"email_confirmation" => _}) do
    struct
    |> changeset(params)
    |> cast(params, [:email_confirmation])
    |> put_change(:status, "active")
    |> validate_confirmation(:email, message: "emails must match")
  end

  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> put_change(:email_verification_token, UUID.uuid4())
  end

  def invite_changeset(struct, params) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> unique_constraint(:email, name: :users_lower_email_index)
    |> put_change(:finalized, false)
    |> put_change(:token, UUID.uuid4())
    |> put_change(:email_verification_token, UUID.uuid4())
    |> put_change(:first_name, "")
    |> put_change(:last_name, "")
    |> put_change(:password, UUID.uuid4())
    |> Stein.Accounts.hash_password()
  end

  def finalize_invite_changeset(struct, params) do
    struct
    |> cast(params, [:first_name, :last_name, :phone_number])
    |> validate_required([:first_name, :last_name])
    |> password_changeset(params)
    |> put_change(:finalized, true)
    |> put_change(:email_verified_at, DateTime.truncate(Timex.now(), :second))
    |> put_change(:email_verification_token, nil)
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> validate_required([:email])
    |> maybe_reset_verification()
  end

  def last_active_changeset(struct) do
    struct
    |> change()
    |> timestamp(:last_active)
  end

  def active_session_changeset(struct, status, jwt_token) do
    struct
    |> change()
    |> put_change(:active_session, status)
    |> put_change(:jwt_token, jwt_token)
  end

  def avatar_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:avatar_key, key)
    |> put_change(:avatar_extension, extension)
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

  def roles, do: @roles

  def statuses, do: @statuses
end
