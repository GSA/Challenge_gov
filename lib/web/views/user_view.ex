defmodule Web.UserView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias Web.AccountView
  alias Web.SharedView
  alias Web.FormView

  def name_link(conn, user, opts \\ [show_email: true]) do
    if opts[:show_email] == true do
      link("#{user.first_name} #{user.last_name} (#{user.email})",
        to: Routes.user_path(conn, :show, user.id)
      )
    else
      link("#{user.first_name} #{user.last_name}",
        to: Routes.user_path(conn, :show, user.id)
      )
    end
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

  def user_edit_link(conn, user, current_user = %{role: "super_admin"}) do
    case Accounts.get_role_rank(current_user.role) > Accounts.get_role_rank(user.role) do
      true ->
        nil

      false ->
        link("Edit",
          to: Routes.user_path(conn, :edit, user.id),
          class: "btn btn-default btn-xs"
        )
    end
  end

  def user_edit_link(conn, user, current_user = %{role: "admin"}) do
    case Accounts.get_role_rank(current_user.role) >= Accounts.get_role_rank(user.role) do
      true ->
        nil

      false ->
        link("Edit",
          to: Routes.user_path(conn, :edit, user.id),
          class: "btn btn-default btn-xs"
        )
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
