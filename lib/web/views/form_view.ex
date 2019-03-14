defmodule Web.FormView do
  use Phoenix.HTML

  @moduledoc """
  Helper functions for dealing with forms
  """

  @doc """
  Checkbox helper for multiple checkbox situations
  """
  def multi_checkbox(field, grouping, value, filter) do
    checkbox(:filter, "#{grouping}_#{field}",
      name: "filter[#{grouping}][]",
      checked: filter["#{grouping}"] != nil and value in filter["#{grouping}"],
      hidden_input: false,
      checked_value: value
    )
  end

  @doc """
  If the field is included in form errors, reutrn the correct error class
  """
  def error_class(form, field) do
    if Keyword.has_key?(form.errors, field) do
      "is-invalid"
    end
  end
end
