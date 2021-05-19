defmodule ChallengeGov.Submissions.Submission do
  @moduledoc """
  Submission schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Challenges.Phase
  alias ChallengeGov.Submissions.Document
  alias ChallengeGov.Submissions.SubmissionInvite

  @type t :: %__MODULE__{}

  @statuses [
    %{id: "draft", label: "Draft"},
    %{id: "submitted", label: "Submitted"}
  ]

  @judging_statuses [
    "not_selected",
    "selected",
    "qualified",
    "winner"
  ]

  def statuses(), do: @statuses

  def status_ids() do
    Enum.map(@statuses, & &1.id)
  end

  def judging_statuses, do: @judging_statuses

  schema "submissions" do
    # Associations
    belongs_to(:submitter, User)
    belongs_to(:challenge, Challenge)
    belongs_to(:phase, Phase)
    belongs_to(:manager, User)
    has_one(:invite, SubmissionInvite)
    has_many(:documents, Document)
    field(:document_ids, :map, virtual: true)

    # Fields
    field(:title, :string)
    field(:brief_description, :string)
    field(:brief_description_delta, :string)
    field(:description, :string)
    field(:description_delta, :string)
    field(:external_url, :string)
    field(:status, :string)
    field(:judging_status, :string, default: "not_selected")
    field(:terms_accepted, :boolean, default: false)
    field(:review_verified, :boolean, default: false)

    # Meta Timestamps
    field(:deleted_at, :utc_datetime)
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(
      params,
      [
        :title,
        :brief_description,
        :brief_description_delta,
        :description,
        :description_delta,
        :external_url,
        :terms_accepted,
        :review_verified,
        :manager_id
      ]
    )
  end

  def draft_changeset(struct, params, user, challenge, phase) do
    struct
    |> changeset(params)
    |> put_change(:submitter_id, user.id)
    |> put_change(:challenge_id, challenge.id)
    |> put_change(:phase_id, phase.id)
    |> put_change(:manager_id, params["manager_id"])
    |> put_change(:status, "draft")
    |> foreign_key_constraint(:submitter)
    |> foreign_key_constraint(:challenge)
    |> foreign_key_constraint(:phase)
    |> foreign_key_constraint(:manager)
    |> validate_inclusion(:status, status_ids())
    |> validate_length(:brief_description, max: 500)
  end

  def review_changeset(struct, params, user, challenge, phase) do
    struct
    |> changeset(params)
    |> put_change(:submitter_id, user.id)
    |> put_change(:challenge_id, challenge.id)
    |> put_change(:phase_id, phase.id)
    |> put_change(:manager_id, params["manager_id"])
    |> put_change(:status, "draft")
    |> foreign_key_constraint(:submitter)
    |> foreign_key_constraint(:challenge)
    |> foreign_key_constraint(:phase)
    |> foreign_key_constraint(:manager)
    |> validate_inclusion(:status, status_ids())
    |> validate_required([
      :title,
      :brief_description,
      :description
    ])
    |> validate_length(:brief_description, max: 500)
  end

  def update_draft_changeset(struct, params) do
    struct
    |> changeset(params)
    |> put_change(:status, "draft")
    |> foreign_key_constraint(:submitter)
    |> foreign_key_constraint(:challenge)
    |> foreign_key_constraint(:phase)
    |> foreign_key_constraint(:manager)
    |> validate_inclusion(:status, status_ids())
    |> validate_length(:brief_description, max: 500)
  end

  def update_review_changeset(struct, params) do
    struct
    |> changeset(params)
    |> put_change(:status, "draft")
    |> foreign_key_constraint(:submitter)
    |> foreign_key_constraint(:challenge)
    |> foreign_key_constraint(:phase)
    |> foreign_key_constraint(:manager)
    |> validate_inclusion(:status, status_ids())
    |> validate_required([
      :title,
      :brief_description,
      :description
    ])
    |> validate_length(:brief_description, max: 500)
  end

  def submit_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "submitted")
    |> validate_required_fields
    |> validate_inclusion(:status, status_ids())
  end

  def judging_status_changeset(struct, judging_status) do
    struct
    |> change()
    |> put_change(:judging_status, judging_status)
    |> validate_required_fields
    |> validate_inclusion(:judging_status, judging_statuses())
  end

  def delete_changeset(struct) do
    now = DateTime.truncate(Timex.now(), :second)

    struct
    |> change()
    |> put_change(:deleted_at, now)
  end

  defp validate_required_fields(struct) do
    %{title: t, brief_description: bd, description: d} = struct.data

    struct = if is_blank?(t), do: add_error(struct, :title, "can't be blank"), else: struct

    struct =
      if is_blank?(bd), do: add_error(struct, :brief_description, "can't be blank"), else: struct

    struct = if is_blank?(d), do: add_error(struct, :description, "can't be blank"), else: struct

    struct
  end

  defp is_blank?(string) do
    is_nil(string) or String.trim(string) === ""
  end
end
