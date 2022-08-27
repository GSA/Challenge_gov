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

  def certification_status(certification, %{status: status}) do
    one_year_from_certification =
      Timex.add(certification.certified_at, Timex.Duration.from_days(365))

    after? = Timex.after?(certification.certified_at, one_year_from_certification)

    if after? || status == "decertified" do
      ~E"""
        <span style="color:#B50808">Decertified</span>
      """
    else
      ~E"""
        <span style="color:#4D8055">Certified</span>
      """
    end
  end

  def certification_info(certification, %{status: status}) do
    one_year_from_certification =
      Timex.add(certification.certified_at, Timex.Duration.from_days(365))

    after? = Timex.after?(certification.certified_at, one_year_from_certification)

    if after? || status == "deactivated" do
      ~E"""
        <span>Decertified on <%= one_year_from_certification.month %>/<%= one_year_from_certification.day %>/<%= one_year_from_certification.year %></span>
      """
    else
      ~E"""
        <span>Due On: <%= certification.expires_at.month %>/<%= certification.expires_at.day %>/<%= certification.expires_at.year %></span>
      """
    end
  end

  def recertification_requested(%{renewal_request: "certification"}),
    do: ~E"""
      <span>Request Submitted: <span style="color:#4D8055">Yes</span></span>
    """

  def recertification_requested(_),
    do: ~E"""
      <span>Request Submitted: <span style="color:#B50808">No</span></span>
    """

  def status("active"),
    do: ~E"""
     <span style="color:#4D8055">Active</span>
    """

  def status("pending"),
    do: ~E"""
     <span style="color:#E5A002">Pending</span>
    """

  def status("deactivated"),
    do: ~E"""
     <span style="color:#B50808">Deactivated</span>
    """

  def status("decertified"),
    do: ~E"""
     <span style="color:#B50808">Decertified</span>
    """

  def status("suspended"),
    do: ~E"""
     <span style="color:#B50808">Suspended</span>
    """

  def status("revoked"),
    do: ~E"""
     <span style="color:#B50808">Revoked</span>
    """
end
