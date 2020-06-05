defmodule ChallengeGov.Challenges.TimelineEvent do
  @moduledoc """
  Challenge timeline event schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  embedded_schema do
    field(:title, :string)
    field(:date, :utc_datetime)

    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :title,
      :date
    ])
  end

  def save_changeset(struct, params) do
    struct
    |> changeset(params)
    |> validate_required([
      :title,
      :date
    ])
  end

  def draft_changeset(struct, params) do
    struct
    |> changeset(params)
  end
end
