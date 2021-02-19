defmodule Web.LayoutView do
  use Web, :view

  alias ChallengeGov.Accounts
  alias ChallengeGov.Recaptcha
  alias Web.AccountView
  alias Web.PageTitle

  def page_title(conn) do
    view = Phoenix.Controller.view_module(conn)

    action =
      case view do
        Web.ErrorView -> nil
        _ -> Phoenix.Controller.action_name(conn)
      end

    PageTitle.for({view, action, conn.assigns})
  end

  def user_signed_in?(conn) do
    Map.has_key?(conn.assigns, :current_user)
  end

  def current_user(conn) do
    if user_signed_in?(conn) do
      Map.get(conn.assigns, :current_user)
    end
  end

  def recaptcha_script() do
    recaptcha_key = Recaptcha.recaptcha_key()

    case is_nil(recaptcha_key) do
      true ->
        []

      false ->
        content_tag(:script, "",
          src: "https://www.google.com/recaptcha/api.js?render=#{recaptcha_key}"
        )
    end
  end

  def tab_selected(conn, "dashboard") do
    case conn.path_info == ["admin"] do
      true ->
        "active"

      false ->
        ""
    end
  end

  def tab_selected(conn, route) do
    case conn.path_info do
      ["admin", ^route] ->
        "active"

      ["admin", ^route, _] ->
        "active"

      [^route] ->
        "active"

      [^route, _] ->
        "active"

      _ ->
        ""
    end
  end

  def load_filter_panel(conn, view_module) do
    Phoenix.Controller.action_name(conn) == :index and
      view_module != Web.DashboardView and
      view_module != Web.AccessView and
      view_module != Web.SiteContentView and
      view_module != Web.PhaseView and
      view_module != Web.SubmissionExportView and
      view_module != Web.SubmissionInviteView
  end
end

defmodule Web.PageTitle do
  alias Web.Admin
    alias Web.SessionView
    alias Web.RegistrationView
    alias Web.RegistrationResetView
    alias Web.UserInviteView
    alias Web.ChallengeView
    alias Web.AccountView
    alias Web.AgencyView
    alias Web.ErrorView

  @app_name "Challenge.gov"

  def for({view, action, assigns}) do
    {view, action, assigns}
    |> get()
    |> add_app_name()
  end

  defp get({Admin.DashboardView, :index, _}) do
    "Admin - Dashboard"
  end

  defp get({Admin.ChallengeView, :index, _}) do
    "Admin - Challenges"
  end

  defp get({Admin.ChallengeView, :edit, assigns}) do
    "Admin - Editing Challenge - #{assigns.challenge.title}"
  end

  defp get({Admin.ChallengeView, :show, assigns}) do
    "Admin - Viewing Challenge - #{assigns.challenge.title}"
  end

  defp get({Admin.AgencyView, :index, _}) do
    "Admin - Agencies"
  end

  defp get({Admin.AgencyView, :show, assigns}) do
    "Admin - Viewing Agency - #{assigns.agency.name}"
  end

  defp get({Admin.UserView, :index, _}) do
    "Admin - Challenge Owners"
  end

  defp get({Admin.UserView, :show, assigns}) do
    user = Map.get(assigns, :user, %{})
    "Admin - Viewing Challenge Owner - #{user.first_name} #{user.last_name}"
  end

  defp get({SessionView, :new, _}) do
    "Sign In"
  end

  defp get({RegistrationView, :new, _}) do
    "Register"
  end

  defp get({RegistrationResetView, _, _}) do
    "Password Reset"
  end

  defp get({UserInviteView, _, _}) do
    "Invite Someone"
  end

  defp get({ChallengeView, :index, _}) do
    "Challenges"
  end

  defp get({ChallengeView, :new, _}) do
    "Submit Your Challenge"
  end

  defp get({ChallengeView, :show, assigns}) do
    "Challenge - #{assigns.challenge.title}"
  end

  defp get({AccountView, :index, _}) do
    "Challenge Owners"
  end

  defp get({AccountView, :edit, _}) do
    "Editing Challenge Owner"
  end

  defp get({AccountView, :show, assigns}) do
    "Challenge Owner - #{assigns.account.first_name} #{assigns.account.last_name}"
  end

  defp get({AgencyView, :index, _}) do
    "Agencies"
  end

  defp get({AgencyView, :new, _}) do
    "Create an Agency"
  end

  defp get({AgencyView, :show, assigns}) do
    "Agency - #{assigns.agency.name}"
  end

  defp get({ErrorView, _, _}) do
    "Error"
  end

  defp get(_), do: nil

  defp add_app_name(nil), do: @app_name
  defp add_app_name(title), do: "#{title} | #{@app_name}"
end
