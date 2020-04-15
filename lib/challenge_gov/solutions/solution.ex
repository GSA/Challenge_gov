defmodule ChallengeGov.Solutions.Solution do
  @moduledoc """
  Solution schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Challenges.Challenge

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
      :submitter_id,
      :challenge_id,
      :title,
      :brief_description,
      :description,
      :external_url
    ])
    |> validate_required([
      :submitter_id,
      :challenge_id
    ])
  end

  def submit_changeset(struct, params) do
    struct
    |> changeset(params)
    |> put_change(:status, "submitted")
    |> validate_inclusion(:status, status_ids())
    |> validate_required([
      :title,
      :brief_description,
      :description,
      :external_url
    ])
  end

  def draft_changeset(struct, params) do
    struct
    |> changeset(params)
    |> put_change(:status, "draft")
    |> validate_inclusion(:status, status_ids())
  end

  def delete_changeset(struct) do
    now = DateTime.truncate(Timex.now(), :second)

    struct
    |> change()
    |> put_change(:deleted_at, now)
  end
end
