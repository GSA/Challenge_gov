defmodule Web.Admin.DashboardView do
  use Web, :view

  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.Accounts

  def recertification_warning(user) do
    case CertificationLogs.get_current_certification(user) do
      {:ok, certification} ->
        expiration = Timex.to_unix(certification.expires_at)
        two_weeks_from_now = Timex.to_unix(Timex.shift(Timex.now(), days: 14))

        if expiration < two_weeks_from_now do
          [
            content_tag(
              :span,
              "Your account certification will expire on
              #{certification.expires_at.month}/#{certification.expires_at.day}/#{
                certification.expires_at.year
              }",
              class: "mx-2"
            ),
            button("Request recertification",
              to: "/admin/recertify",
              method: :get,
              class: "btn btn-primary"
            )
          ]
        end

      {:error, :no_log_found} ->
        nil
    end
  end
end
