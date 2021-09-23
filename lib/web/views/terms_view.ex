defmodule Web.TermsView do
  use Web, :view

  alias ChallengeGov.Agencies
  alias ChallengeGov.Security

  def challenge_manager_fields(f, user) do
    if user.data.role == "challenge_manager" do
      [
        content_tag(:div, class: "input") do
          [
            label(f, :agency_id, "Agency Name*", class: "label-text"),
            select(f, :agency_id, Enum.map(Agencies.all_for_select(), &{&1.name, &1.id}),
              required: true,
              placeholder: "Agency Name",
              class: "form-control fc-input"
            )
          ]
        end
      ]
    end
  end

  def challenge_manager_assumed_content(user) do
    case Security.assume_challenge_manager?(user.email) do
      true ->
        [
          content_tag(:div, class: "page-center") do
            [
              content_tag(:p, "You have been registered as a Challenge Manager and
              will be able to create Challenges to go live on Challenge.gov."),
              content_tag(:p) do
                [
                  "If this is not correct please contact ",
                  content_tag(:a, "team@challenge.gov", href: "mailto:team@challenge.gov")
                ]
              end
            ]
          end
        ]

      false ->
        ""
    end
  end
end
