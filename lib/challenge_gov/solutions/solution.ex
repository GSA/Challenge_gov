defmodule ChallengeGov.Solutions.Solution do
  @moduledoc """
  Solution schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Solutions.Document

  @type t :: %__MODULE__{}

  @statuses [
    %{id: "draft", label: "Draft"},
    %{id: "submitted", label: "Submitted"}
  ]

  def statuses(), do: @statuses

  def status_ids() do
    Enum.map(@statuses, & &1.id)
  end

  schema "solutions" do
    # Associations
    belongs_to(:submitter, User)
    belongs_to(:challenge, Challenge)
    has_many(:documents, Document)

    # Fields
    field(:title, :string)
    field(:brief_description, :string)
    field(:description, :string)
    field(:external_url, :string)
    field(:status, :string)

    # Meta Timestamps
    field(:deleted_at, :utc_datetime)
    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :title,
      :brief_description,
      :description,
      :external_url
    ])
  end

  def draft_changeset(struct, params, user, challenge) do
    struct
    |> changeset(params)
    |> put_change(:submitter_id, user.id)
    |> put_change(:challenge_id, challenge.id)
    |> put_change(:status, "draft")
    |> foreign_key_constraint(:submitter)
    |> foreign_key_constraint(:challenge)
    |> validate_inclusion(:status, status_ids())
    |> validate_length(:brief_description, max: 500)
  end

  def review_changeset(struct, params, user, challenge) do
    struct
    |> changeset(params)
    |> put_change(:submitter_id, user.id)
    |> put_change(:challenge_id, challenge.id)
    |> put_change(:status, "draft")
    |> foreign_key_constraint(:submitter)
    |> foreign_key_constraint(:challenge)
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
    |> validate_inclusion(:status, status_ids())
    |> validate_length(:brief_description, max: 500)
  end

  def update_review_changeset(struct, params) do
    struct
    |> changeset(params)
    |> put_change(:status, "draft")
    |> foreign_key_constraint(:submitter)
    |> foreign_key_constraint(:challenge)
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
