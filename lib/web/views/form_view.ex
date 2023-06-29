defmodule Web.FormView do
  @moduledoc """
  Helper functions for dealing with forms
  """
  use Web, :view

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
        label(form, field, class: "form-label col") do
          [text, content_tag(:span, " *", class: "required")]
        end

      false ->
        label(form, field, text, class: "form-label col")
    end
  end

  @doc """
  Generate a text field, styled properly
  """
  def text_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    text_opts = Keyword.take(opts, [:value, :rows, :placeholder, :limit, :required])

    char_limit_label =
      if text_opts[:limit] do
        chars_remaining = text_opts[:limit] - String.length(input_value(form, field) || "")
        base_classes = "char-limit-label ms-1"

        [label_content, label_classes] =
          if chars_remaining >= 0 do
            ["#{chars_remaining} characters remaining", base_classes]
          else
            ["#{abs(chars_remaining)} characters over limit", base_classes <> " is-invalid"]
          end

        content_tag(:span, label_content, class: label_classes)
      else
        ""
      end

    classes =
      if text_opts[:limit] do
        form_control_classes(form, field) <> " char-limit-input"
      else
        form_control_classes(form, field)
      end

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label_field(form, field, opts),
        # remove  class: "col"
        content_tag(:div) do
          [
            text_input(form, field, Keyword.merge([class: classes], text_opts)),
            char_limit_label,
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  def currency_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    text_opts = Keyword.take(opts, [:value, :rows, :placeholder, :required])

    classes = form_control_classes(form, field)

    currency_opts = [
      data: [
        inputmask:
          "'alias': 'currency', 'digits': '0', 'prefix': '$', 'rightAlign': false, 'greedy' : false"
      ]
    ]

    args = Keyword.merge([class: classes], currency_opts)

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label_field(form, field, opts),
        content_tag(:div, class: "col") do
          [
            text_input(form, field, Keyword.merge(args, text_opts)),
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  @doc """
  Generate an email field, styled properly
  """
  def email_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    text_opts = Keyword.take(opts, [:value, :rows, :placeholder, :required])

    classes = form_control_classes(form, field)

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label_field(form, field, opts),
        content_tag(:div, class: "col") do
          [
            email_input(form, field, Keyword.merge([class: classes], text_opts)),
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  @doc """
  Generate a datetime field, styled properly
  """
  def datetime_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    text_opts = Keyword.take(opts, [:value, :rows])

    classes = form_control_classes(form, field)

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label(form, field, class: "col-md-4"),
        content_tag(:div, class: "col-md-8") do
          [
            datetime_select(form, field, Keyword.merge([class: classes], text_opts)),
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

    classes = form_control_classes(form, field)

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label(form, field, class: "col-md-4"),
        content_tag(:div, class: "col-md-8") do
          [
            password_input(form, field, Keyword.merge([class: classes], text_opts)),
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

    classes = form_control_classes(form, field)

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label(form, field, class: "col-md-4"),
        content_tag(:div, class: "col-md-8") do
          [
            number_input(form, field, Keyword.merge([class: classes], number_opts)),
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  @doc """
  Generate a select field, styled properly
  """
  def select_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    select_opts = Keyword.take(opts, [:prompt, :required])

    classes = form_control_classes(form, field)

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label_field(form, field, opts),
        content_tag(:div, class: "col") do
          [
            select(
              form,
              field,
              opts[:collection],
              Keyword.merge([class: "js-select #{opts[:class]} #{classes}"], select_opts)
            ),
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  @doc """
  Generate a multiselect field, styled properly
  """
  def multiselect_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    select_opts = Keyword.take(opts, [:prompt, :selected, :required])

    classes = form_control_classes(form, field)

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label_field(form, field, opts),
        content_tag(:div, class: "col") do
          [
            multiple_select(
              form,
              field,
              opts[:collection],
              Keyword.merge([class: "js-multiselect #{classes}"], select_opts)
            ),
            error_tag(form, field),
            Keyword.get(opts, :do, "")
          ]
        end
      ]
    end
  end

  @doc """
  Generate a textarea field, styled properly. Adds rich text support
  """
  def rt_textarea_field(form, field, opts \\ []) do
    opts = Keyword.merge([class: form_group_classes(form, field)], opts)

    char_limited_tags =
      if opts[:limit] do
        [
          content_tag(:span, "",
            id: "#{form.id}_#{Atom.to_string(field)}_chars-remaining",
            class: "char-limit-label ms-1"
          ),
          content_tag(:span, "",
            id: "#{form.id}_#{Atom.to_string(field)}_char-limit-text",
            class: "char-limit-label ms-1"
          ),
          hidden_input(form, String.to_existing_atom(Atom.to_string(field) <> "_length"))
        ]
      else
        ""
      end

    classes =
      if opts[:limit] do
        "rt-textarea rt_char-limited"
      else
        "rt-textarea"
      end

    content_tag(:div, opts) do
      [
        content_tag(:div, "",
          class: classes,
          data: [input: form.id <> "_" <> Atom.to_string(field), limit: opts[:limit]]
        ),
        char_limited_tags,
        hidden_input(form, field, class: form_control_classes(form, field)),
        hidden_input(form, String.to_existing_atom(Atom.to_string(field) <> "_delta")),
        error_tag(form, field)
      ]
    end
  end

  def rt_textarea_field_alt(form, field, opts \\ []) do
    content_tag(:div, class: form_group_classes(form, field)) do
      [
        content_tag(:div, "",
          class: "rt-textarea",
          data: [input: Atom.to_string(field)]
        ),
        hidden_input(
          form,
          field,
          Keyword.merge([class: form_control_classes(form, field)], opts)
        ),
        hidden_input(form, String.to_existing_atom(Atom.to_string(field) <> "_delta")),
        error_tag(form, field)
      ]
    end
  end

  @doc """
  Generate a textarea field, styled properly
  """
  def textarea_field(form, field, opts \\ [], dopts \\ []) do
    opts = Keyword.merge(opts, dopts)
    textarea_opts = Keyword.take(opts, [:value, :rows, :limit, :required, :maxlength])

    char_limit_label =
      if textarea_opts[:limit] do
        chars_remaining = textarea_opts[:limit] - String.length(input_value(form, field) || "")
        base_classes = "char-limit-label ms-1"

        [label_content, label_classes] =
          if chars_remaining >= 0 do
            ["#{chars_remaining} characters remaining", base_classes]
          else
            ["#{abs(chars_remaining)} characters over limit", base_classes <> " is-invalid"]
          end

        content_tag(:p, label_content, class: label_classes)
      else
        ""
      end

    classes =
      if textarea_opts[:limit] do
        form_control_classes(form, field) <> " char-limit-input"
      else
        form_control_classes(form, field)
      end

    label =
      if opts[:label] === false do
        ""
      else
        label_field(form, field, opts)
      end

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label,
        content_tag(:div, class: "col") do
          [
            textarea(form, field, Keyword.merge([class: classes], textarea_opts)),
            char_limit_label,
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

    content_tag(:div, class: "checkbox mb-3") do
      content_tag(:div, class: "col-md-8 col-md-offset-4") do
        [
          label(form, field, class: "col-md-4") do
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

    classes = form_control_file_classes(form, field)

    label =
      cond do
        opts[:label] ->
          label(form, field, opts[:label], class: "col-md-4")

        opts[:label] === false ->
          ""

        true ->
          label(form, field, class: "col-md-4")
      end

    class =
      if opts[:class] do
        opts[:class]
      else
        "col-md-8"
      end

    content_tag(:div, class: form_group_classes(form, field)) do
      [
        label,
        content_tag(:div, class: class) do
          [
            file_input(form, field, class: classes),
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
        "mb-3 is-invalid"

      false ->
        "mb-3"
    end
  end

  def nested_form_group_classes(form, children, field, index) do
    fields_data = Map.get(form.source.changes, children)
    current_field = if fields_data, do: Enum.at(fields_data, index), else: nil

    case !is_nil(current_field) and Keyword.has_key?(current_field.errors, field) and index != -1 do
      true ->
        "form-group nested-form-group is-invalid"

      false ->
        "form-group nested-form-group"
    end
  end

  def form_control_classes(form, field) do
    case Keyword.has_key?(form.errors, field) do
      true ->
        "form-control is-invalid"

      false ->
        "form-control"
    end
  end

  def form_control_file_classes(form, field) do
    case Keyword.has_key?(form.errors, field) do
      true ->
        "form-control-file is-invalid"

      false ->
        "form-control-file"
    end
  end

  def nested_form_control_classes(form, children, field, index) do
    fields_data = Map.get(form.source.changes, children)

    fields_data =
      if fields_data do
        Enum.filter(fields_data, fn child ->
          child.action !== :replace
        end)
      else
        []
      end

    current_field = if fields_data, do: Enum.at(fields_data, index), else: nil

    case !is_nil(current_field) and Keyword.has_key?(current_field.errors, field) and index != -1 do
      true ->
        "form-control nested-form-control is-invalid"

      false ->
        "form-control nested-form-control"
    end
  end

  def dynamic_nested_fields(form, children, fields) do
    children_name = Atom.to_string(children)

    capitalized_children_name =
      children_name
      |> String.split("_")
      |> Enum.map_join(
        " ",
        fn word ->
          String.capitalize(word)
        end
      )

    content_tag(:div, class: "col dynamic-nested-form") do
      [
        content_tag(:div, class: "nested-items") do
          inputs_for(form, children, [skip_hidden: true], fn child ->
            [
              content_tag :div, class: "form-collection", data: [index: child.index] do
                [
                  Enum.map(Enum.with_index(fields), fn field_with_index ->
                    {field, index} = field_with_index
                    classes = nested_form_control_classes(form, children, field, child.index)

                    content_tag(:div,
                      class: nested_form_group_classes(form, children, field, child.index)
                    ) do
                      [
                        Enum.map(child.hidden, fn {k, v} ->
                          hidden_input(child, k, value: v)
                        end),
                        label(child, field, class: "col-md-4"),
                        content_tag(:div, class: "row") do
                          [
                            content_tag(:div, class: "col-md-10") do
                              [
                                text_input(child, field, class: classes),
                                error_tag(child, field)
                              ]
                            end,
                            content_tag(:div, class: "col-md-2") do
                              if index < 1 do
                                content_tag(:div, "Remove",
                                  class: "remove-nested-section btn btn-link"
                                )
                              end
                            end
                          ]
                        end
                      ]
                    end
                  end)
                ]
              end
            ]
          end)
        end,
        content_tag(:div, "Add #{capitalized_children_name}",
          class: "add-nested-section btn btn-primary",
          data: [parent: form.name, child: children_name]
        ),
        content_tag(:div, class: "col dynamic-nested-form-template d-none") do
          [
            content_tag(:div, class: "form-collection") do
              [
                Enum.map(Enum.with_index(fields), fn field_with_index ->
                  {field, index} = field_with_index

                  content_tag(:div,
                    class: nested_form_group_classes(form, children, field, -1),
                    data: [field: field]
                  ) do
                    [
                      label(:template, field, class: "col-md-4 template-label"),
                      content_tag(:div, class: "row") do
                        [
                          content_tag(:div, class: "col-md-10") do
                            text_input(:template, field, class: "form-control template-input")
                          end,
                          content_tag(:div, class: "col-md-2") do
                            if index < 1 do
                              content_tag(:div, "Remove",
                                class: "remove-nested-section btn btn-link"
                              )
                            end
                          end
                        ]
                      end
                    ]
                  end
                end)
              ]
            end
          ]
        end
      ]
    end
  end

  # def nested_inputs(form, field, sub_field) do
  #   inputs_for(form, field, [], fn fp ->
  #     text_input(fp, sub_field)
  #   end)
  # end

  # def phase_dynamic_nested_fields(form) do
  #   content_tag(:div, class: "col dynamic-nested-form") do
  #     [
  #       content_tag(:div, class: "nested-items") do
  #         inputs_for(form, :phases, fn child ->
  #           [
  #             content_tag :div, class: "form-collection", data: [index: child.index] do
  #               [
  #                 content_tag(:div,
  #                   class: nested_form_group_classes(form, :phases, field, child.index)
  #                 ) do
  #                   [
  #                     label(child, :title, class: "col-md-4"),
  #                     content_tag(:div, class: "row") do
  #                       [
  #                         content_tag(:div, class: "col-md-10") do
  #                           [
  #                             text_input(child, field, class: classes),
  #                             error_tag(child, field)
  #                           ]
  #                         end,
  #                         content_tag(:div, class: "col-md-2") do
  #                           content_tag(:div, "Remove",
  #                             class: "remove-nested-section btn btn-link"
  #                           )
  #                         end
  #                       ]
  #                     end
  #                   ]
  #                 end
  #               end)
  #             ]
  #           ]
  #         end)
  #       end,
  #       content_tag(:div, "Add phase")
  #         class: "add-nested-section btn btn-primary",
  #         data: [parent: form.name, child: :phases]
  #       ),
  #       content_tag(:div, class: "col dynamic-nested-form-template d-none") do
  #         [
  #           content_tag(:div, class: "form-collection") do
  #             [
  #               Enum.map(Enum.with_index(fields), fn field_with_index ->
  #                 {field, index} = field_with_index

  #                 content_tag(:div,
  #                   class: nested_form_group_classes(form, children, field, -1),
  #                   data: [field: field]
  #                 ) do
  #                   [
  #                     label(:template, field, class: "col-md-4 template-label"),
  #                     content_tag(:div, class: "row") do
  #                       [
  #                         content_tag(:div, class: "col-md-10") do
  #                           text_input(:template, field, class: "form-control template-input")
  #                         end,
  #                         content_tag(:div, class: "col-md-2") do
  #                           if index < 1 do
  #                             content_tag(:div, "Remove",
  #                               class: "remove-nested-section btn btn-link"
  #                             )
  #                           end
  #                         end
  #                       ]
  #                     end
  #                   ]
  #                 end
  #               end)
  #             ]
  #           end
  #         ]
  #       end
  #     ]
  #   end
  # end

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
