defmodule ChallengeGov.Challenges.Phase do
  @moduledoc """
  Challenge phase schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  embedded_schema do
    field(:title, :string)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    field(:open_to_submissions, :boolean, default: false)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :title,
      :start_date,
      :end_date,
      :open_to_submissions
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
      :title
    ])
  end
end
