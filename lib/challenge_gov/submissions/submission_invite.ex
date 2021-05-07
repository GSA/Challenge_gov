defmodule ChallengeGov.Submissions.SubmissionInvite do
  @moduledoc """
  Submission invites schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Submissions.Submission

  @type t :: %__MODULE__{}

  @statuses [
    "pending",
    "accepted",
    "revoked"
  ]

  schema "submission_invites" do
    # Associations
    belongs_to(:submission, Submission)

    # Fields
    field(:message, :string)
    field(:message_delta, :string)

    field(:status, :string, default: "pending")

    # Meta Timestamps
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :message,
      :message_delta
    ])
    |> validate_required([
      :message,
      :message_delta
    ])
    |> validate_inclusion(:status, @statuses)
  end

  def create_changeset(struct, params, submission) do
    struct
    |> changeset(params)
    |> put_change(:submission, submission)
    |> foreign_key_constraint(:submission_id)
    |> unique_constraint(:submission_id)
  end

  def reinvite_changeset(struct, params) do
    struct
    |> changeset(params)
    |> put_change(:status, "pending")
  end

  def accept_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "accepted")
  end

  def revoke_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "revoked")
  end
end
