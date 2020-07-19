defmodule Web.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field = :base) do
    errors = Enum.map(Keyword.get_values(form.errors, field), &translate_error/1)

    case Enum.empty?(errors) do
      true ->
        []

      false ->
        content_tag(:span, class: "help-block invalid-feedback") do
          errors
        end
    end
  end

  def error_tag(form, field) do
    errors = Enum.map(Keyword.get_values(form.errors, field), &translate_error/1)

    case Enum.empty?(errors) do
      true ->
        []

      false ->
        content_tag(:span, class: "help-block invalid-feedback") do
          [String.replace(String.capitalize(to_string(field)), "_", " "), " ", errors]
        end
    end
  end

  def error_tag(form, field, class) do
    errors = Enum.map(Keyword.get_values(form.errors, field), &translate_error/1)

    case Enum.empty?(errors) do
      true ->
        []

      false ->
        content_tag(:span, class: class) do
          errors
        end
    end
  end

  def all_errors(%{errors: errors}) when is_list(errors) and length(errors) > 0 do
    content_tag(:ul, class: "callout callout-danger", style: "list-style: none") do
      Enum.map(errors, fn {error_key, {error_msg, _}} ->
        content_tag(:li, "#{humanize(error_key)} #{error_msg}")
      end)
    end
  end

  def all_errors(_), do: nil

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(Web.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(Web.Gettext, "errors", msg, opts)
    end
  end
end
