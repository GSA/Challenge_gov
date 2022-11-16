defmodule ChallengeGov.Challenges.Phase do
  @moduledoc """
  Challenge phase schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Submissions.Submission
  alias ChallengeGov.PhaseWinners.PhaseWinner

  @type t :: %__MODULE__{}

  schema "phases" do
    belongs_to(:challenge, Challenge)
    has_many(:all_submissions, Submission)
    has_many(:submissions, Submission, where: [status: "submitted"])
    has_one(:winners, PhaseWinner)

    field(:uuid, Ecto.UUID, autogenerate: true)
    field(:title, :string)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    field(:open_to_submissions, :boolean)
    field(:judging_criteria, :string)
    field(:judging_criteria_delta, :string)
    field(:judging_criteria_length, :integer, virtual: true)
    field(:how_to_enter, :string)
    field(:how_to_enter_delta, :string)
    field(:how_to_enter_length, :integer, virtual: true)

    field(:delete_phase, :boolean, virtual: true)

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :title,
      :start_date,
      :end_date,
      :open_to_submissions,
      :judging_criteria,
      :judging_criteria_delta,
      :how_to_enter,
      :how_to_enter_delta,
      :delete_phase
    ])
    |> mark_for_delete()
  end

  def save_changeset(struct, params) do
    struct
    |> changeset(params)
    |> validate_required([
      :start_date,
      :end_date
    ])
  end

  def draft_changeset(struct, params) do
    struct
    |> changeset(params)
  end

  def multi_phase_changeset(struct, params) do
    struct
    |> save_changeset(params)
    |> validate_required([
      :title,
      :open_to_submissions
    ])
  end

  def judging_changeset(struct, params) do
    struct
    |> save_changeset(params)
    |> validate_required([
      :judging_criteria
    ])
    |> force_change(:judging_criteria, params["judging_criteria"] || struct.judging_criteria)
  end

  def how_to_enter_changeset(struct, params) do
    struct
    |> save_changeset(params)
    |> validate_required([
      :how_to_enter
    ])
    |> force_change(:how_to_enter, params["how_to_enter"] || struct.how_to_enter)
  end

  defp mark_for_delete(changeset) do
    if get_change(changeset, :delete_phase) do
      %{changeset | action: :delete}
      |> foreign_key_constraint(:id, name: :solutions_phase_id_fkey, message: "has submissions")
    else
      changeset
    end
  end
end
