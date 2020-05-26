defmodule Web.ChallengeView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias ChallengeGov.Agencies
  alias ChallengeGov.Challenges
  alias ChallengeGov.Challenges.Logo
  alias ChallengeGov.Challenges.WinnerImage
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
    Challenges.status_label(challenge.status)
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
                "Some edits were requested"
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

  def back_button(conn, challenge) do
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

  def save_draft_button() do
    submit("Save Draft",
      name: "action",
      value: "save_draft",
      class: "btn btn-link float-right",
      formnovalidate: true
    )
  end

  def submit_button(section) do
    if section == Enum.at(Challenges.sections(), -1).id do
      submit("Submit", name: "action", value: "next", class: "btn btn-primary float-right")
    else
      submit("Next", name: "action", value: "next", class: "btn btn-primary float-right")
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
        nil

      false ->
        Storage.url(Logo.logo_path(challenge, "original"), signed: [expires_in: 3600])
    end
  end

  def agency_name(challenge) do
    if challenge.agency, do: challenge.agency.name
  end

  def agency_logo(challenge) do
    if challenge.agency.avatar_key,
      do: AgencyView.avatar_url(challenge.agency),
      else: nil
  end

  def winner_img(challenge, opts \\ []) do
    case is_nil(challenge.winner_image_key) do
      true ->
        path = Routes.static_path(Web.Endpoint, "/images/teams-card-logo.jpg")
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
    with {:ok, time} = Timex.format(event_time, "{Mshort} {D}, {YYYY}") do
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
