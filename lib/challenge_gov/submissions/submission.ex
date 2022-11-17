defmodule ChallengeGov.Submissions.Submission do
  @moduledoc """
  Submission schema
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Waffle.Ecto.Schema

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Challenges.Phase
  alias ChallengeGov.Submissions.Document
  alias ChallengeGov.Submissions.SubmissionInvite
  alias ChallengeGov.Submissions.SubmissionPdf, as: PdfUploader

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
    field(:document_objects, :map, virtual: true)

    # Fields
    field :pdf_reference, PdfUploader.Type
    field(:title, :string)
    field(:brief_description, :string)
    field(:brief_description_delta, :string)
    field(:brief_description_length, :integer, virtual: true)
    field(:description, :string)
    field(:description_delta, :string)
    field(:external_url, :string)
    field(:status, :string)
    field(:judging_status, :string, default: "not_selected")
    field(:terms_accepted, :boolean, default: nil)
    field(:review_verified, :boolean, default: nil)

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
        :brief_description_length,
        :description,
        :description_delta,
        :external_url,
        :terms_accepted,
        :review_verified,
        :submitter_id,
        :manager_id
      ]
    )
  end

  def pdf_changeset(submission = %__MODULE__{}, params) do
    cast_attachments(submission, params, [:pdf_reference])
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
    |> validate_review_verify(params)
    |> validate_terms(params)
    |> validate_required([
      :title,
      :brief_description,
      :description
    ])
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
    |> validate_review_verify(params)
    |> validate_terms(params)
    |> validate_required([
      :title,
      :brief_description,
      :description
    ])
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

    struct = validate_terms(struct)

    struct = validate_review_verify(struct)

    struct
  end

  defp validate_terms(struct) do
    ta = get_field(struct, :terms_accepted)

    cond do
      is_nil(ta) ->
        struct

      !!ta ->
        struct

      true ->
        add_error(struct, :terms_accepted, "must be accepted")
    end
  end

  defp validate_terms(struct, params) do
    ta = params["terms_accepted"]

    cond do
      is_nil(ta) ->
        struct

      ta === "true" ->
        struct

      true ->
        add_error(struct, :terms_accepted, "must be accepted")
    end
  end

  defp validate_review_verify(struct) do
    rv = get_field(struct, :review_verified)
    manager_id = get_field(struct, :manager_id)

    cond do
      is_nil(manager_id) ->
        struct

      is_nil(rv) ->
        struct

      !!manager_id and !!rv ->
        struct

      true ->
        add_error(struct, :review_verified, "must verify this submission")
    end
  end

  defp validate_review_verify(struct, params) do
    rv = params["review_verified"]
    manager_id_changes = params["manager_id"]
    manager_id_struct = get_field(struct, :manager_id)

    cond do
      is_nil(manager_id_changes) and is_nil(manager_id_struct) ->
        struct

      is_nil(rv) ->
        struct

      (!!manager_id_struct or !!manager_id_changes) and rv === "true" ->
        struct

      true ->
        add_error(struct, :review_verified, "must verify this submission")
    end
  end

  defp is_blank?(string) do
    is_nil(string) or String.trim(string) === ""
  end
end
