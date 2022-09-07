defmodule Web.AccessView do
  use Web, :view
  alias ChallengeGov.CertificationLogs

  def recertification_heading_by_status(user) do
    {:ok, log} = certification_log(user)

    case user.status do
      "decertified" ->
        ~E"""
          <div class="content-header">
            <div class="container-fluid">
              <div class="callout callout-warning d-flex align-items-center">
                <i class="fa fa-check-circle h4 mb-0 flash-icon"></i>
                <span>
                  <p class="h4">User Account Recertification Needed</p>
                  <p class="pl-0">Your account was decertified on <%= log.expires_at.month %>/<%= log.expires_at.day %>/<%= log.expires_at.year %></p>
                </span>
              </div>
            </div>
          </div>
          <div>
            <h4 class="mb-3">Welcome Back!</h4>
            <div class="row">
              <div class="col-4"></div>
              <div class="col-4 mb-3">
                Before accessing the portal, you will need to recertify your account.
                Annual recertification of Challenge.Gov user accounts allows us to confirm
                individual users still need access to the portal, and is an important part
                of ensuring system security.
              </div>
            </div>
            <div class="row">
              <div class="col-4"></div>
              <div class="col-4 mb-3">
                In completing this form, you confirm your acceptance of site policies and
                attest that you still need access to the Challenge.Gov portal. If you have
                any questions about completing this form, contact us at <a href="team@challenge.gov">team@challenge.gov</a>.
              </div>
            </div>
            <div style="color:red">* Required fields</div>
          </div>
        """

      "active" ->
        ~E"""
          <div class="content-header">
            <div class="container-fluid">
              <div class="callout callout-warning d-flex align-items-center">
                <i class="fa fa-check-circle h4 mb-0 flash-icon"></i>
                <span>
                  <p class="h4">Account Expiration Notice</p>
                  <p class="pl-0">Your annual account certification will expire on <%= log.expires_at.month %>/<%= log.expires_at.day %>/<%= log.expires_at.year %></p>
                </span>
              </div>
            </div>
          </div>
          <div>
            <div class="row">
              <div class="col-4"></div>
              <div class="col-4 mb-3">
                In completing this form, you confirm your acceptance of site policies and
                attest that you still need access to the Challenge.Gov portal. If you have
                any questions about completing this form, contact us at <a href="team@challenge.gov">team@challenge.gov</a>.
              </div>
            </div>
            <div style="color:red">* Required fields</div>
          </div>
        """

      true ->
        [
          content_tag(:p, "Request recertification by submitting the following:", class: "mt-5")
        ]
    end
  end

  defp certification_log(user) do
    case CertificationLogs.check_user_certification_history(user) do
      {:ok, log} ->
        {:ok, log}

      _ ->
        {:ok, %{expires_at: %{month: nil, day: nil, year: nil}}}
    end
  end

  def request_type_by_status(user) do
    case user.status do
      "decertified" ->
        "recertification"

      "active" ->
        "recertification"

      "deactivated" ->
        "reactivation"
    end
  end
end
