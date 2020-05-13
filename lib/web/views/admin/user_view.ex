defmodule Web.Admin.UserView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias Web.AccountView
  alias Web.SharedView
  alias Web.Admin.FormView

  def name_link(conn, user) do
    link("#{user.first_name} #{user.last_name} (#{user.email})",
      to: Routes.admin_user_path(conn, :show, user.id)
    )
  end

  def phone_number(%{phone_number: nil}), do: "Not Provided"

  def phone_number(user), do: user.phone_number

  def email_verified?(user) do
    case is_nil(user.email_verified_at) do
      true ->
        "Not verified"

      false ->
        "Verified"
    end
  end

  def certification_info(certification) do
    now = Timex.to_unix(Timex.now())
    expiration_date = certification.expires_at

    if Timex.to_unix(expiration_date) <= now do
      [
        content_tag(:span, "Certification status: decertified", class: "d-block"),
        content_tag(
          :span,
          "Decertified on #{expiration_date.month}/#{expiration_date.day}/#{expiration_date.year}",
          class: "d-block"
        )
      ]
    else
      [
        content_tag(:span, "Certification status: certified", class: "d-block"),
        content_tag(
          :span,
          "Expires on #{expiration_date.month}/#{expiration_date.day}/#{expiration_date.year}",
          class: "d-block"
        )
      ]
    end
  end
end
