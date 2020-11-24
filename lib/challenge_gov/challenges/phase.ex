defmodule ChallengeGov.Challenges.Phase do
  @moduledoc """
  Challenge phase schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Solutions.Solution

  @type t :: %__MODULE__{}

  schema "phases" do
    belongs_to(:challenge, Challenge)
    has_many(:all_solutions, Solution)
    has_many(:solutions, Solution, where: [status: "submitted"])

    field(:uuid, Ecto.UUID, autogenerate: true)
    field(:title, :string)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    field(:open_to_submissions, :boolean)
    field(:judging_criteria, :string)
    field(:judging_criteria_delta, :string)
    field(:how_to_enter, :string)
    field(:how_to_enter_delta, :string)

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
      :how_to_enter_delta
    ])
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
    |> validate_length(:judging_criteria, max: 4000)
  end

  def how_to_enter_changeset(struct, params) do
    struct
    |> save_changeset(params)
    |> validate_required([
      :how_to_enter
    ])
    |> force_change(:how_to_enter, params["how_to_enter"] || struct.how_to_enter)
    |> validate_length(:how_to_enter, max: 4000)
  end
end
