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
          class: "btn btn-primary"
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
          class: "btn btn-primary"
        )
    end
  end

  def certification_status(certification, %{status: status}) do
    one_year_from_certification =
      Timex.add(certification.certified_at, Timex.Duration.from_days(365))

    after? = Timex.after?(certification.certified_at, one_year_from_certification)

    if after? || status == "decertified" do
      ~E"""
        <span style="color:#B50808"><i class="fas fa-shield-alt"></i>&nbsp;Decertified</span>
      """
    else
      ~E"""
        <span style="color:#4D8055"><i class="fas fa-shield-alt"></i>&nbsp;Certified</span>
      """
    end
  end

  def certification_info(certification, %{status: status}) do
    ~E"""
      <span>
        <%= if status == "decertified" do %>
          Decertified On:
        <% else %>
          Due On:
        <% end %>
        <%= certification.expires_at.month %>/<%= certification.expires_at.day %>/<%= certification.expires_at.year %>
      </span>
    """
  end

  def recertification_requested(%{renewal_request: "certification"}),
    do: ~E"""
      <span><b>Request Submitted:</b> <span style="color:#4D8055">Yes</span></span>
    """

  def recertification_requested(_),
    do: ~E"""
      <span><b>Request Submitted:</b> <span style="color:#B50808">No</span></span>
    """

  def status("active"),
    do: ~E"""
     <span style="color:#4D8055"><span><i class="fas fa-user-circle"></i>&nbsp;</span>Active</span>
    """

  def status("pending"),
    do: ~E"""
     <span style="color:#E5A002"><span><i class="fas fa-user-circle"></i>&nbsp;</span>Pending</span>
    """

  def status("deactivated"),
    do: ~E"""
     <span style="color:#B50808"><span><i class="fas fa-user-circle"></i>&nbsp;</span>Deactivated</span>
    """

  def status("decertified"),
    do: ~E"""
     <span style="color:#B50808"><span><i class="fas fa-user-circle"></i>&nbsp;</span>Decertified</span>
    """

  def status("suspended"),
    do: ~E"""
     <span style="color:#E5A000"><span><i class="fas fa-user-circle"></i>&nbsp;</span>Suspended</span>
    """

  def status("revoked"),
    do: ~E"""
     <span style="color:#B50808"><span><i class="fas fa-user-circle"></i>&nbsp;</span>Revoked</span>
    """
end
