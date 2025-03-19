defmodule Web.DashboardView do
  use Web, :view

  alias ChallengeGov.Challenges
  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.Accounts
  alias ChallengeGov.MessageContextStatuses
  alias Web.Endpoint

  def recertification_warning(conn, user) do
    case CertificationLogs.get_current_certification(user) do
      {:ok, certification} ->
        expiration = Timex.to_unix(certification.expires_at)
        thirty_days_from_now = Timex.to_unix(Timex.shift(Timex.now(), days: 30))

        if expiration < thirty_days_from_now do
          account_decertification_warning(conn, user)
        end

      {:error, :no_log_found} ->
        nil
    end
  end

  defp account_decertification_warning(conn, user) do
    {:ok, log} = CertificationLogs.check_user_certification_history(user)

    assigns = %{log: log, conn: conn, user: user}

    ~H"""
      <div class="content-header">
        <div class="container-fluid">

        <div class="usa-alert usa-alert--warning usa-alert--no-icon">
        <div class="usa-alert__body">
         <p class="usa-alert__text">
          <%= if user.renewal_request == "certification" do %>
            <p class="h4 mb-0">Recertification Pending</p>
            <p>Your annual account certification is now pending approval.</p>
          <% else %>
            <p class="h4 mb-0">It's time for your annual account recertification.</p>
            <p>Your annual account certification will expire on <%= @log.expires_at.month %>/<%= @log.expires_at.day %>/<%= @log.expires_at.year %></p>
            <p><%= recertification_action(conn, user) %></p>
          <% end %>

         </p>
        </div>
       </div>

        </div>
      </div>
    """
  end

  def recertification_action(conn, _user) do
    link("Request Recertification",
      to: Routes.access_path(conn, :recertification),
      target: "",
      class: "usa-button",
      style: "color:white;text-decoration:none;"
    )
  end

  def evaluator_notice do
    ~E"""
      <div class="content-header">
        <div class="container-fluid">
          <p>This account is an evaluator and has no access on this site. If this is a mistake contact an admin.</p>
        </div>
      </div>
    """
  end

  def dashboard_header(user) do
    wrapper_classes = "grid-col"

    cond do
      Accounts.has_admin_access?(user) ->
        admin_header(wrapper_classes)

      Accounts.is_challenge_manager?(user) ->
        challenge_manager_header(wrapper_classes)

      Accounts.is_solver?(user) ->
        solver_header(wrapper_classes)

      true ->
        content_tag(:div, "")
    end
  end

  defp admin_header(wrapper_classes) do
    content_tag :div, class: wrapper_classes do
      [
        content_tag(:h1, "Dashboard")
      ]
    end
  end

  defp challenge_manager_header(wrapper_classes) do
    content_tag :div, class: wrapper_classes do
      [
        content_tag(:h1, "Dashboard")
      ]
    end
  end

  defp solver_header(wrapper_classes) do
    content_tag :div, class: wrapper_classes do
      [
        content_tag(:h1, "Dashboard")
      ]
    end
  end

  def dashboard_card_links(user) do
    cond do
      Accounts.has_admin_access?(user) ->
        admin_card_links()

      Accounts.is_challenge_manager?(user) ->
        challenge_manager_card_links(user)

      Accounts.is_solver?(user) ->
        solver_card_links(user)

      true ->
        content_tag(:div, "")
    end
  end

  defp render_solver_message_center_link(user) do
    if MessageContextStatuses.has_messages?(user) do
      render("_card_link.html",
        to: Routes.message_context_path(Endpoint, :index),
        target: "",
        icon: my_icon("mail"),
        title: "Message Center",
        description: "View and send messages to Challenge.Gov users."
      )
    else
      []
    end
  end

  defp my_icon(pl) do
    content_tag :svg,
      class: "usa-icon usa-challenge-dashboard",
      "aria-hidden": "true",
      focusable: "false",
      role: "img",
      style: "color: #000;" do
      content_tag(:use, "", href: "/assets/img/sprite.svg##{pl}")
    end
  end

  defp admin_card_links() do
    [
      content_tag :div, class: "grid-row grid-gap-2" do
        [
          render("_card_link.html",
            to: Routes.user_path(Endpoint, :index),
            target: "",
            icon: my_icon("people"),
            title: "User management",
            description: "View and edit user roles, permissions, and activities on the platform."
          ),
          render("_card_link.html",
            to: Routes.challenge_path(Endpoint, :index),
            target: "",
            icon: my_icon("emoji_events"),
            title: "Challenges",
            description: "Create and manage your challenges."
          )
        ]
      end,
      content_tag :div, class: "grid-row grid-gap-2" do
        [
          render("_card_link.html",
            to: Routes.message_context_path(Endpoint, :index),
            target: "",
            icon: my_icon("mail"),
            title: "Message center",
            description: "View and send messages to Challenge.Gov users."
          ),
          render("_card_link.html",
            to: Routes.analytics_path(Endpoint, :index),
            target: "",
            icon: my_icon("assessment"),
            title: "Analytics",
            description: "View web analytics related to your challenges."
          )
        ]
      end,
      content_tag :div, class: "grid-row grid-gap-2" do
        [
          render("_card_link.html",
            to: Routes.site_content_path(Endpoint, :index),
            target: "",
            icon: my_icon("list"),
            title: "Site management",
            description: "Manage content and perform site management tasks."
          )
        ]
      end
    ]
  end

  defp challenge_manager_card_links(user) do
    [
      content_tag :div, class: "grid-row grid-gap-2" do
        [
          render("_card_link.html",
            to: Routes.challenge_path(Endpoint, :index),
            target: "",
            icon: my_icon("emoji_events"),
            title: "Challenges",
            description: "Create and manage your challenges."
          ),
          render("_card_link.html",
            to: "https://challenge-dev.app.cloud.gov/manage_submissions",
            target: "",
            icon: my_icon("star_half"),
            title: "Submissions & Evaluations",
            description: "Manage submissions, evaluations, and evaluators."
          )
        ]
      end,
      content_tag :div, class: "grid-row grid-gap-2" do
        [
          render("_card_link.html",
            to: "https://challenge-dev.app.cloud.gov/evaluation_forms",
            target: "",
            icon: my_icon("check_circle_outline"),
            title: "Evaluation Forms",
            description: "Create and manage evaluation forms."
          ),
          render("_card_link.html",
            to: Routes.message_context_path(Endpoint, :index),
            target: "",
            icon: my_icon("mail"),
            title: "Message Center",
            description: "View and send messages to Challenge.Gov users."
          )
        ]
      end,
      content_tag :div, class: "grid-row grid-gap-2" do
        [
          render("_card_link.html",
            to: Routes.analytics_path(Endpoint, :index),
            target: "",
            icon: my_icon("assessment"),
            title: "Analytics",
            description: "View web analytics related to your challenges."
          ),
          render("_card_link.html",
            to: Routes.help_path(Endpoint, :index),
            target: "",
            icon: my_icon("support"),
            title: "Resources",
            description: "Learn how to make the most of Challenge.gov and find support."
          )
        ]
      end,
      content_tag :div, class: "grid-row grid-gap-2" do
        [
          render("_card_link.html",
            to: Routes.static_path(Endpoint, "/pdfs/prize_and_challenge_toolkit.pdf"),
            target: "_blank",
            icon: my_icon("construction"),
            title: "Agency Toolkit",
            description: "View the Prizes and Challenges Toolkit to learn more."
          )
        ]
      end
    ]
  end

  defp solver_card_links(user) do
    content_tag :div, class: "grid-row grid-gap-2" do
      [
        render("_card_link.html",
          to: Routes.submission_path(Endpoint, :index),
          target: "",
          icon: my_icon("file_present"),
          title: "My submissions",
          description: "View my challenges submissions."
        ),
        render("_card_link.html",
          to: Routes.saved_challenge_path(Endpoint, :index),
          target: "",
          icon: my_icon("emoji_events"),
          title: "My saved challenges",
          description: "View challenges you've saved and click for challenge details."
        ),
        render_solver_message_center_link(user),
        render("_card_link.html",
          to: Routes.help_path(Endpoint, :solver_index),
          target: "",
          icon: my_icon("support"),
          title: "Resources",
          description: "Learn how to make the most of Challenge.gov and find support."
        )
      ]
    end
  end
end
