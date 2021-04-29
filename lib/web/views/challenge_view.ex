defmodule Web.ChallengeView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias ChallengeGov.Agencies
  alias ChallengeGov.Challenges
  alias ChallengeGov.Challenges.Logo
  alias ChallengeGov.Challenges.WinnerImage
  alias ChallengeGov.Challenges.ResourceBanner
  alias ChallengeGov.SupportingDocuments
  alias Stein.Storage
  alias Web.AgencyView
  alias Web.FormView
  alias Web.SharedView

  def name_link(conn, challenge) do
    link(challenge.title, to: Routes.challenge_path(conn, :show, challenge.id))
  end

  def public_name_link(conn, challenge) do
    link(challenge.title, to: Routes.public_challenge_details_path(conn, :index, challenge.id))
  end

  def public_name_link_url(conn, challenge) do
    link(challenge.title, to: Routes.public_challenge_details_url(conn, :index, challenge.id))
  end

  def challenge_owners_list(challenge) do
    challenge.challenge_owner_users
    |> Enum.map(&"#{&1.first_name} #{&1.last_name} (#{&1.email})")
    |> Enum.join(", ")
  end

  def federal_partners_list(challenge) do
    challenge.federal_partners
    |> Enum.map(&agency_name(&1))
    |> Enum.join(", ")
  end

  def non_federal_partners_list(challenge) do
    challenge.non_federal_partners
    |> Enum.map(& &1.name)
    |> Enum.join(", ")
  end

  def custom_url(challenge) do
    "http://www.challenge.gov/challenge/#{challenge.custom_url}"
  end

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
      link(to: Routes.challenge_path(conn, :index, filter: filter, sort: sort_values)) do
        content_tag :div do
          [
            content_tag(:span, label),
            content_tag(:i, "", class: "fa " <> sort_icon)
          ]
        end
      end
    end
  end

  def status_display_name(challenge) do
    [
      Challenges.status_label(challenge.status),
      status_auto_publish_date(challenge),
      published_sub_status_display(challenge, true)
    ]
  end

  defp status_auto_publish_date(%{status: "approved", auto_publish_date: auto_publish_date})
       when not is_nil(auto_publish_date),
       do: " (Publishes #{SharedView.readable_datetime(auto_publish_date)})"

  defp status_auto_publish_date(_), do: ""

  def published_sub_status_display(challenge, attached \\ false)

  def published_sub_status_display(challenge = %{status: "published"}, attached) do
    sub_status =
      cond do
        Challenges.is_archived_new?(challenge) -> "archived"
        Challenges.is_closed?(challenge) -> "closed"
        Challenges.is_open?(challenge) -> "open"
        true -> ""
      end

    [if(attached and sub_status !== "", do: ", ", else: ""), sub_status]
  end

  def published_sub_status_display(_challenge, _attached), do: ""

  def challenge_solutions_link(conn, challenge, user, opts \\ []) do
    if (user.role == "challenge_owner" or
          Accounts.has_admin_access?(user)) and length(challenge.phases) > 0 do
      link_location =
        if length(challenge.phases) > 1,
          do: Routes.challenge_phase_path(conn, :index, challenge.id),
          else:
            Routes.challenge_phase_path(
              conn,
              :show,
              challenge.id,
              Enum.at(challenge.phases, 0).id
            )

      link(
        opts[:label] || "View submissions",
        Keyword.merge(
          [
            to: link_location
          ],
          opts
        )
      )
    end
  end

  def challenge_edit_link(conn, challenge, opts \\ []) do
    route =
      if challenge.status == "draft" do
        Routes.challenge_path(
          conn,
          :edit,
          challenge.id,
          challenge.last_section || Enum.at(Challenges.sections(), 0).id
        )
      else
        Routes.challenge_path(conn, :edit, challenge.id)
      end

    link("Edit", Keyword.merge([to: route], opts))
  end

  def challenge_full_edit_link(conn, challenge, user, opts \\ []) do
    if Accounts.has_admin_access?(user) do
      link(
        "Full Edit",
        Keyword.merge([to: Routes.challenge_path(conn, :edit, challenge.id)], opts)
      )
    end
  end

  def challenge_delete_link(conn, challenge, user, opts \\ []) do
    if (user.role == "challenge_owner" and challenge.status == "draft") or
         Accounts.has_admin_access?(user) do
      link(
        opts[:label] || "Delete",
        Keyword.merge(
          [
            to: Routes.challenge_path(conn, :delete, challenge.id),
            method: :delete,
            data: [confirm: "Are you sure you want to delete this challenge?"]
          ],
          opts
        )
      )
    end
  end

  def challenge_rejection_message(challenge) do
    if challenge.status == "edits_requested" and challenge.rejection_message do
      content_tag :div, class: "row position-sticky sticky-top" do
        content_tag :div, class: "col-md-12" do
          content_tag :div, class: "card card-danger" do
            [
              content_tag(:div, class: "card-header") do
                "Edits have been requested for this challenge. Please review your challenge and make any necessary edits prior to re-submitting."
              end,
              content_tag(:div, class: "card-body") do
                challenge.rejection_message
              end
            ]
          end
        end
      end
    end
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

  def wizard_challenge_owners_field(form, user, changeset) do
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
              selected: initial_challenge_owners(form, user, changeset),
              class: "form-control js-multiselect",
              disabled: !Accounts.has_admin_access?(user)
            ),
            error_tag(form, :challenge_owners)
          ]
        end
      ]
    end
  end

  defp initial_challenge_owners(form, user, changeset) do
    if Accounts.is_challenge_owner?(user) and Enum.empty?(form.data.challenge_owners) do
      user.id
    else
      Enum.map(changeset.data.challenge_owner_users, & &1.id)
    end
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
      Web.FormView.dynamic_nested_fields(form, :non_federal_partners, [:name])
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
              Enum.map(Challenges.statuses(), &{&1.label, &1.id}),
              class: "form-control js-select"
            )
          end
        ]
      end
    end
  end

  def existing_phase_data_boolean(form) do
    content_tag(
      :div,
      Enum.any?(form.data.phases, &(!is_nil(&1.judging_criteria) || !is_nil(&1.how_to_enter))),
      id: "existing-phase-data-boolean",
      style: "display: none;"
    )
  end

  def documents_for_section(documents, section) do
    Enum.filter(documents, fn document ->
      document.section === section
    end)
  end

  def progress_bar(conn, current_section, challenge, action) do
    sections = Challenges.sections()
    current_section_index = Challenges.section_index(current_section)

    progressbar_width = current_section_index / length(sections) * 110

    base_classes = ""

    content_tag :div, class: "challenge-progressbar container" do
      content_tag :div, class: "row" do
        [
          content_tag :div, class: "col-12" do
            content_tag(:div, class: "progress eqrs-progress") do
              content_tag(:div, "",
                class: "progress-bar progress-bar--success",
                style: "width: #{progressbar_width}%",
                role: "progressbar"
              )
            end
          end,
          Enum.map(Enum.with_index(sections), fn {section, index} ->
            content_tag :div, class: "button-container col" do
              [
                cond do
                  section.id == current_section ->
                    link(index + 1, to: "#", class: base_classes <> " btn-not-completed_hasFocus")

                  action == :new || action == :create ->
                    link(index + 1,
                      to: "#",
                      class: base_classes <> " btn-disabled",
                      disabled: true,
                      aria: [disabled: true]
                    )

                  Challenges.section_index(section.id) < current_section_index ->
                    link(index + 1,
                      to: Routes.challenge_path(conn, :edit, challenge.id, section.id),
                      class: base_classes <> " btn-completed"
                    )

                  true ->
                    link(index + 1,
                      to: "#",
                      class: base_classes <> " btn-disabled",
                      disabled: true,
                      aria: [disabled: true]
                    )
                end,
                content_tag(:p, section.label, class: "section__title")
              ]
            end
          end)
        ]
      end
    end
  end

  def back_button(conn, challenge, section) do
    if section != Enum.at(Challenges.sections(), 0).id do
      if challenge.id do
        submit("Back", name: "action", value: "back", class: "btn btn-link", formnovalidate: true)
      else
        link("Back",
          to: Routes.challenge_path(conn, :index),
          class: "btn btn-link",
          formnovalidate: true
        )
      end
    end
  end

  def save_and_return_to_review_button(_conn, _challenge) do
    submit("Save and return to review",
      name: "action",
      value: "return_to_review",
      class: "usa-button"
    )
  end

  def save_draft_button(section) do
    if section != Enum.at(Challenges.sections(), -1).id do
      submit("Save Draft",
        name: "action",
        value: "save_draft",
        class: "btn btn-link float-right",
        formnovalidate: true
      )
    end
  end

  def preview_challenge_button(conn, challenge, section) do
    if section == Enum.at(Challenges.sections(), -1).id do
      link("Preview",
        to: Routes.public_preview_path(conn, :index, challenge.uuid),
        class: "usa-button float-right",
        target: "_blank"
      )
    end
  end

  def submit_button(section) do
    if section == Enum.at(Challenges.sections(), -1).id do
      submit("Submit", name: "action", value: "submit", class: "usa-button float-right")
    else
      submit("Next", name: "action", value: "next", class: "usa-button float-right")
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

  def remove_update_button(conn, challenge = %{announcement: announcement})
      when not is_nil(announcement),
      do:
        link("Remove update",
          to: Routes.challenge_path(conn, :remove_announcement, challenge.id),
          method: :post,
          class: "btn btn-outline-danger",
          data: [confirm: "Are you sure you want to remove this update?"]
        )

  def remove_update_button(_conn, _challenge), do: nil

  def logo_img(challenge, opts \\ []) do
    case is_nil(challenge.logo_key) do
      true ->
        AgencyView.avatar_img(challenge.agency, opts)

      false ->
        url = Storage.url(Logo.logo_path(challenge, "thumbnail"), signed: [expires_in: 3600])
        opts = Keyword.merge([alt: "Challenge Logo"], opts)
        img_tag(url, opts)
    end
  end

  def logo_url(challenge) do
    case is_nil(challenge.logo_key) do
      true ->
        Routes.static_url(Web.Endpoint, "/images/challenge-logo-2_1.svg")

      false ->
        Storage.url(Logo.logo_path(challenge, "original"), signed: [expires_in: 3600])
    end
  end

  def resource_banner_img(challenge, opts \\ []) do
    case is_nil(challenge.resource_banner_key) do
      true ->
        nil

      false ->
        url =
          Storage.url(ResourceBanner.resource_banner_path(challenge, "thumbnail"),
            signed: [expires_in: 3600]
          )

        opts = Keyword.merge([alt: "Challenge resource banner"], opts)
        img_tag(url, opts)
    end
  end

  def resource_banner_url(challenge) do
    case is_nil(challenge.resource_banner_key) do
      true ->
        nil

      false ->
        Storage.url(ResourceBanner.resource_banner_path(challenge, "original"),
          signed: [expires_in: 3600]
        )
    end
  end

  def types(%{primary_type: primary_type, types: types, other_type: other_type}) do
    primary_type = primary_type || ""
    types = types || []
    other_type = other_type || ""

    [[primary_type], types, [other_type]]
    |> Enum.concat()
    |> Enum.filter(fn type -> type !== "" end)
    |> Enum.join(", ")
  end

  def agency(%{sub_agency: sub_agency}) when not is_nil(sub_agency), do: sub_agency
  def agency(%{agency: agency}) when not is_nil(agency), do: agency
  def agency(_challenge), do: nil

  def agency_name(%{agency: %{name: an}, sub_agency: %{name: san}}), do: "#{an} - #{san}"
  def agency_name(%{agency: %{name: name}}), do: name
  def agency_name(_challenge), do: ""

  def agency_logo(%{sub_agency: sub_agency = %{avatar_key: avatar_key}})
      when not is_nil(avatar_key),
      do: AgencyView.avatar_url(sub_agency)

  def agency_logo(%{agency: agency = %{avatar_key: avatar_key}}) when not is_nil(avatar_key),
    do: AgencyView.avatar_url(agency)

  def agency_logo(_challenge),
    do: Routes.static_url(Web.Endpoint, "/images/agency-logo-placeholder.svg")

  def winner_img(challenge, opts \\ []) do
    case is_nil(challenge.winner_image_key) do
      true ->
        path = Routes.static_url(Web.Endpoint, "/images/teams-card-logo.jpg")
        img_tag(path, alt: "Winner Image")

      false ->
        url =
          Storage.url(WinnerImage.winner_image_path(challenge, "thumbnail"),
            signed: [expires_in: 3600]
          )

        opts = Keyword.merge([alt: "Winner Image"], opts)
        img_tag(url, opts)
    end
  end

  def winner_img_url(challenge, _opts \\ []) do
    case is_nil(challenge.winner_image_key) do
      true ->
        nil

      false ->
        Storage.url(WinnerImage.winner_image_path(challenge, "original"),
          signed: [expires_in: 3600]
        )
    end
  end

  def public_index_url() do
    Routes.public_challenge_index_url(Web.Endpoint, :index)
  end

  def public_details_url(challenge) do
    Routes.public_challenge_details_url(
      Web.Endpoint,
      :index,
      challenge.custom_url || challenge.id
    )
  end

  def disqus_domain() do
    Application.get_env(:challenge_gov, :disqus_domain)
  end

  def timeline_position(event_time, events) do
    dates = Enum.map(events, fn x -> x.occurs_on end)
    dates = [Timex.today() | dates]

    {min, max} = Enum.min_max_by(dates, fn time -> Timex.to_unix(time) end)

    position =
      if min != max && Enum.count(dates) > 1 do
        days_range = Timex.diff(min, max, :days)
        days_from_start = Timex.diff(min, event_time, :days)
        "#{days_from_start / days_range * 100}%"
      else
        "0%"
      end

    position
  end

  def timeline_date(event_time) do
    with {:ok, time} <- Timex.format(event_time, "{Mshort} {D}, {YYYY}") do
      time
    end
  end

  def timeline_class(event_time) do
    case Timex.compare(event_time, Timex.today()) do
      -1 -> "timeline-item-past"
      0 -> "timeline-item-current"
      1 -> "timeline-item-future"
    end
  end

  def challenge_status(challenge) do
    challenge.status
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def champion_display(challenge) do
    case challenge.champion_name do
      nil ->
        nil

      _ ->
        content_tag :div, class: "mt-3" do
          [content_tag(:h5, "Champion Name"), content_tag(:p, challenge.champion_name)]
        end
    end
  end

  def neighborhood_display(challenge) do
    case challenge.neighborhood do
      nil ->
        nil

      _ ->
        content_tag :div, class: "mt-3" do
          [content_tag(:h5, "Location"), content_tag(:p, challenge.neighborhood)]
        end
    end
  end
end
