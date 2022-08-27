defmodule Web.AccessView do
  use Web, :view
  alias ChallengeGov.CertificationLogs

  def recertification_heading_by_status(user) do
    {:ok, log} = CertificationLogs.check_user_certification_history(user)

    case user.status do
      "decertified" ->
        ~E"""
          <h4 class="mt-5">User Account Recertification Needed</h4>
          <div>
            <div  class="mb-3">Your account was decertified on <%= log.expires_at["month"] %>/<%= log.expires_at["day"] %>/<%= log.expires_at["year"] %></div>
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
          <h4 class="mt-5">Account Expiration Notice</h4>
          <div>
            <div  class="mb-3">Your annual account certification will expire on <%= log.expires_at["month"] %>/<%= log.expires_at["day"] %>/<%= log.expires_at["year"] %></div>
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
