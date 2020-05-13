defmodule Web.Admin.DashboardView do
  use Web, :view

  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.Accounts

  def recertification_warning(conn, user) do
    case CertificationLogs.get_current_certification(user) do
      {:ok, certification} ->
        expiration = Timex.to_unix(certification.expires_at)
        two_weeks_from_now = Timex.to_unix(Timex.shift(Timex.now(), days: 14))

        cond do
          user.renewal_request === "certification" ->
            [
              recertification_action(conn, user)
            ]

          expiration < two_weeks_from_now ->
            [
              content_tag(
                :span,
                "Your account certification will expire on
                #{certification.expires_at.month}/#{certification.expires_at.day}/#{
                  certification.expires_at.year
                }",
                class: "mx-2"
              ),
              recertification_action(conn, user)
            ]

          true ->
            nil
        end

      {:error, :no_log_found} ->
        nil
    end
  end

  def recertification_action(conn, user) do
    if user.renewal_request == "certification" do
      [
        content_tag(:span, "Recertification requested", class: "btn btn-primary")
      ]
    else
      [
        link("Request recertification",
          to: Routes.admin_access_path(conn, :recertification),
          class: "btn btn-primary"
        )
      ]
    end
  end
end
