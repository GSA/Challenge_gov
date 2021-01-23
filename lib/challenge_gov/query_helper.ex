defmodule ChallengeGov.QueryHelper do
  @moduledoc """
  Query helpers (for challenges + solutions)
  """

  def order_on_attribute(query, sort_columns) do
    columns_to_sort =
      Enum.reduce(sort_columns, [], fn {column, direction}, acc ->
        column = String.to_atom(column)

        case direction do
          "asc" ->
            acc ++ [asc_nulls_last: column]

          "desc" ->
            acc ++ [desc_nulls_last: column]

          _ ->
            []
        end
      end)

    order_by(query, [c], ^columns_to_sort)
  end
end
