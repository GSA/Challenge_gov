defmodule Web.Admin.ChallengeView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias ChallengeGov.Agencies
  alias ChallengeGov.Challenges
  alias ChallengeGov.SupportingDocuments
  alias Web.Admin.FormView
  alias Web.SharedView
  alias Web.ChallengeView

  def name_link(conn, challenge) do
    link(challenge.title, to: Routes.admin_challenge_path(conn, :show, challenge.id))
  end

  # TODO: Refactor to be more generic
  # Example: Take a path with existing query params and append sort after and no longer need to pass filter
  def sortable_header(conn, sort, filter, column, label) do
    {sort_icon, sort_values} =
      case Map.get(sort, column) do
        "asc" ->
          {"fa-sort-up", Map.put(%{}, column, :desc)}

        "desc" ->
          {"fa-sort-down", %{}}

        _ ->
          {"fa-sort", Map.put(%{}, column, :asc)}
      end

    content_tag :th do
      content_tag :div do
        [
          link(label,
            to: Routes.admin_challenge_path(conn, :index, filter: filter, sort: sort_values),
            style: "margin-right: 1rem"
          ),
          content_tag(:i, "", class: "fa " <> sort_icon)
        ]
      end
    end
  end

  def challenge_edit_link(conn, challenge) do
    route =
      if challenge.status == "draft" do
        Routes.admin_challenge_path(
          conn,
          :edit,
          challenge.id,
          challenge.last_section || Enum.at(Challenges.sections(), 0).id
        )
      else
        Routes.admin_challenge_path(conn, :edit, challenge.id)
      end

    link("Edit", to: route, class: "btn btn-default btn-xs")
  end

  @doc """
  Only shows challenge owner field if the person is an admin and a challenge is being edited
  """
  def challenge_owner_field(form, user, action) do
    if (action == :edit or action == :update) and Accounts.has_admin_access?(user) do
      content_tag :div, class: FormView.form_group_classes(form, :user_id) do
        [
          label(form, :user_id, class: "col-md-4") do
            [
              "Owner ",
              content_tag(:span, "*", class: "required")
            ]
          end,
          content_tag(:div, class: "col-md-8") do
            select(
              form,
              :user_id,
              Enum.map(Accounts.all_for_select(), &{"#{&1.first_name} #{&1.last_name}", &1.id}),
              class: "form-control js-select"
            )
          end
        ]
      end
    end
  end

  @doc """
  Only shows challenge owners multiselect if the person is an admin and a challenge is being edited
  """
  def challenge_owners_field(form, user, changeset, action) do
    if (action == :edit or action == :update) and Accounts.has_admin_access?(user) do
      content_tag :div, class: FormView.form_group_classes(form, :challenge_owners) do
        [
          label(form, :challenge_owners, class: "col-md-4") do
            [
              "Challenge Owners ",
              content_tag(:span, "*", class: "required")
            ]
          end,
          content_tag(:div, class: "col-md-8") do
            [
              multiple_select(
                form,
                :challenge_owners,
                Enum.map(
                  Accounts.all_for_select(),
                  &{"#{&1.first_name} #{&1.last_name} (#{&1.email})", &1.id}
                ),
                selected: Enum.map(changeset.data.challenge_owner_users, & &1.id),
                class: "form-control js-multiselect"
              ),
              error_tag(form, :challenge_owners)
            ]
          end
        ]
      end
    else
      hidden_challenge_owners_field(form, changeset)
    end
  end

  # TODO: Change how these three associations work when no params are passed
  @doc """
  Hidden challenge owner field to keep existing challenge owners from being wiped if none are passed
  """
  def hidden_challenge_owners_field(form, changeset) do
    multiple_select(
      form,
      :challenge_owners,
      Enum.map(
        Accounts.all_for_select(),
        &{"#{&1.first_name} #{&1.last_name} (#{&1.email})", &1.id}
      ),
      selected: Enum.map(changeset.data.challenge_owner_users, & &1.id),
      style: "display: none;"
    )
  end

  @doc """
  Hidden federal partners field to keep existing federal partners from being wiped if none are passed
  """
  def hidden_federal_partners_field(form, changeset) do
    multiple_select(
      form,
      :federal_partners,
      Enum.map(Agencies.all_for_select(), &{&1.name, &1.id}),
      selected: Enum.map(changeset.data.federal_partner_agencies, & &1.id),
      style: "display: none;"
    )
  end

  @doc """
  Hidden non federal partners field to keep existing non federal partnerss from being wiped if none are passed
  """
  def hidden_non_federal_partners_field(form, _changeset) do
    content_tag :div, style: "display: none;" do
      Web.Admin.FormView.dynamic_nested_fields(form, :non_federal_partners, [:name])
    end
  end

  @doc """
  Only shows challenge status field if the person is an admin and a challenge is being edited
  """
  def challenge_status_field(form, user, action) do
    if (action == :edit or action == :update) and Accounts.has_admin_access?(user) do
      content_tag :div, class: FormView.form_group_classes(form, :user_id) do
        [
          label(form, :status, class: "col-md-4") do
            [
              "Status ",
              content_tag(:span, "*", class: "required")
            ]
          end,
          content_tag(:div, class: "col-md-8") do
            select(
              form,
              :status,
              Challenges.statuses(),
              class: "form-control js-select"
            )
          end
        ]
      end
    end
  end

  def progress_bar(conn, current_section, challenge, action) do
    sections = Challenges.sections()
    current_section_index = Challenges.section_index(current_section)

    base_classes = "btn btn-link"

    content_tag :div, class: "challenge-progressbar" do
      Enum.map(sections, fn section ->
        cond do
          section.id == current_section ->
            content_tag(:span, section.label, class: base_classes <> " current-section")

          action == :new || action == :create ->
            content_tag(:span, section.label,
              class: base_classes,
              disabled: true,
              aria: [disabled: true]
            )

          Challenges.section_index(section.id) < current_section_index ->
            link(section.label,
              to: Routes.admin_challenge_path(conn, :edit, challenge.id, section.id),
              class: base_classes <> " completed-section"
            )

          true ->
            content_tag(:span, section.label,
              class: base_classes,
              disabled: true,
              aria: [disabled: true]
            )
        end
      end)
    end
  end

  def back_button(conn, challenge) do
    if challenge.id do
      submit("Back", name: "action", value: "back", class: "btn btn-primary")
    else
      link("Back", to: Routes.admin_challenge_path(conn, :index), class: "btn btn-primary")
    end
  end

  def save_draft_button() do
    submit("Save Draft", name: "action", value: "save_draft", class: "btn btn-primary pull-right")
  end

  def submit_button(section) do
    if section == Enum.at(Challenges.sections(), -1).id do
      submit("Submit", name: "action", value: "next", class: "btn btn-primary pull-right")
    else
      submit("Next", name: "action", value: "next", class: "btn btn-primary pull-right")
    end
  end

  def default_enter_action(action) do
    submit("",
      name: "action",
      value: action,
      tabindex: -1,
      style:
        "overflow: visible !important; height: 0 !important; width: 0 !important; margin: 0 !important; border: 0 !important; padding: 0 !important; display: block !important;"
    )
  end

  def next_section(section), do: Challenges.next_section(section)
  def prev_section(section), do: Challenges.prev_section(section)
end
