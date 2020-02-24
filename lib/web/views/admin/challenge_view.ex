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
end
