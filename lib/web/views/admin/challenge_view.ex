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
    if action == :edit and (Accounts.is_admin?(user) or Accounts.is_super_admin?(user)) do
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

  def progress_bar(conn, _current_section, challenge, action) do
    Enum.map(Challenges.sections(), fn section ->
      if action == :new || action == :create do
        content_tag(:span, section.label, class: "btn btn-link btn-xs")
      else
        link(section.label,
          to: Routes.admin_challenge_path(conn, :edit, challenge.id, section.id),
          class: "btn btn-link btn-xs"
        )
      end
    end)
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

  def next_section(section), do: Challenges.next_section(section)
  def prev_section(section), do: Challenges.prev_section(section)
end
