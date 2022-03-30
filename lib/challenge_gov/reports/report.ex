defmodule ChallengeGov.Reports.Report do
  @moduledoc """
  Reportschema
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}
  schema "" do
    field :year, :integer, virtual: true
    field :month, :integer, virtual: true
    field :day, :integer, virtual: true
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:year, :month, :day])
    |> validate_required([:year])
    |> validate_dates(params)
  end

  # Custom validation of days/month
  defp validate_dates(struct, params) do
    %{"year" => year, "month" => month, "day" => day} = params
    days_in_month = Timex.days_in_month(year, month)

    if day do
      case day > days_in_month do
        true ->
          struct
          |> add_error(:day, "is invalid for selected month")

        false ->
          struct
      end
    else
      struct
    end
  end
end
