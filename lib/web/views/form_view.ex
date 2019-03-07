defmodule Web.FormView do
  @moduledoc """
  Helper functions for dealing with forms
  """

  @doc """
  If the field is included in form errors, reutrn the correct error class
  """
  def error_class(form, field) do
    if Keyword.has_key?(form.errors, field) do
      "is-invalid"
    end
  end
end
