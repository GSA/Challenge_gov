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

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :title,
      :date
    ])
  end

  def save_changeset(struct, params, start_date) do
    struct
    |> changeset(params)
    |> validate_required([
      :title,
      :date
    ])
    |> validate_date_after_start(params, start_date)
  end

  def draft_changeset(struct, params) do
    struct
    |> changeset(params)
  end

  defp validate_date_after_start(struct, %{"date" => date}, start_date) do
    with {:ok, date} <- Timex.parse(date, "{ISO:Extended}"),
         1 <- Timex.compare(date, start_date) do
      struct
    else
      tc when tc == -1 or tc == 0 ->
        add_error(struct, :date, "must be after challenge start date")

      _error ->
        add_error(struct, :date, "is invalid")
    end
  end

  defp validate_date_after_start(struct, _params, _start_date), do: struct
end
