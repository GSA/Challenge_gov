defmodule Web.Admin.FormView do
  use Web, :view

  def multi_checkbox(field, grouping, value, filter),
    do: Web.FormView.multi_checkbox(field, grouping, value, filter)

  def label_text(field, opts) do
    case Keyword.has_key?(opts, :label) do
      true ->
        opts[:label]

      false ->
        field
        |> to_string()
        |> String.replace("_", " ")
        |> String.capitalize()
    end
  end

  def label_field(form, field, opts) do
    text = label_text(field, opts)

    case Keyword.get(opts, :required, false) do
      true ->
        label(form, field, class: "col-md-4") do
          [text, content_tag(:span, "*", class: "required")]
        end

      false ->
        label(form, field, text, class: "col-md-4")
    end
  end

  @doc """
  Generate a text field, styled properly
  """
  def text_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    text_opts = Keyword.take(opts, [:value, :rows])

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label_field(form, field, opts),
        content_tag(:div, class: "col-md-8") do
          [
            text_input(form, field, Keyword.merge([class: "form-control"], text_opts)),
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  @doc """
  Generate a text field, styled properly
  """
  def password_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    text_opts = Keyword.take(opts, [:value, :rows])

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label_field(form, field, opts),
        content_tag(:div, class: "col-md-8") do
          [
            password_input(form, field, Keyword.merge([class: "form-control"], text_opts)),
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  @doc """
  Generate a number field, styled properly
  """
  def number_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    number_opts = Keyword.take(opts, [:placeholder, :min, :max])

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label_field(form, field, opts),
        content_tag(:div, class: "col-md-8") do
          [
            number_input(form, field, Keyword.merge([class: "form-control"], number_opts)),
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  @doc """
  Generate a textarea field, styled properly
  """
  def textarea_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    textarea_opts = Keyword.take(opts, [:value, :rows])

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label_field(form, field, opts),
        content_tag(:div, class: "col-md-8") do
          [
            textarea(form, field, Keyword.merge([class: "form-control"], textarea_opts)),
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  @doc """
  Generate a checkbox field, styled properly
  """
  def checkbox_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)

    content_tag(:div, class: "checkbox form-group") do
      content_tag(:div, class: "col-md-8 col-md-offset-4") do
        [
          label(form, field) do
            [checkbox(form, field), " ", opts[:label]]
          end,
          error_tag(form, field),
          Keyword.get(opts, :do, "")
        ]
      end
    end
  end

  @doc """
  Generate a file field, styled properly
  """
  def file_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label(form, field, class: "col-md-4"),
        content_tag(:div, class: "col-md-8") do
          [
            file_input(form, field, class: "form-control"),
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  def form_group_classes(form, field) do
    case Keyword.has_key?(form.errors, field) do
      true ->
        "form-group has-error"

      false ->
        "form-group"
    end
  end
end
