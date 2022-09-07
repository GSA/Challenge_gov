defmodule Web.AccessController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.Security
  alias ChallengeGov.SecurityLogs

  def index(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:user, user)
    |> render("index.html")
  end

  def recertification(conn, _params) do
    %{current_user: user} = conn.assigns

    case user.renewal_request do
      nil ->
        conn
        |> assign(:user, user)
        |> assign(:changeset, Accounts.edit(user))
        |> render("recertification.html")

      _ ->
        conn
        |> assign(:user, user)
        |> render("index.html")
    end
  end

  def request_recertification(conn, params) do
    %{current_user: current_user} = conn.assigns

    with {:ok, user} <- Accounts.update_terms(current_user, params),
         {:ok, user} <- Accounts.update(user, %{renewal_request: "certification"}) do
      CertificationLogs.certification_request(conn, user)

      conn
      |> put_flash(:info, "Success")
      |> redirect(to: Routes.access_path(conn, :index))
    else
      {:error, changeset} ->
        %{current_user: user} = conn.assigns

        conn
        |> put_flash(:error, "There was an issue updating your account")
        |> put_status(422)
        |> assign(:user, user)
        |> assign(:changeset, changeset)
        |> render("recertification.html")
    end
  end

  def reactivation(conn, _params) do
    %{current_user: user} = conn.assigns

    case user.renewal_request do
      nil ->
        conn
        |> assign(:user, user)
        |> assign(:changeset, Accounts.edit(user))
        |> render("reactivation.html")

      _ ->
        conn
        |> assign(:user, user)
        |> render("index.html")
    end
  end

  def request_reactivation(conn, _params) do
    %{current_user: current_user} = conn.assigns

    with {:ok, user} <- update_reactivation_request(current_user) do
      SecurityLogs.track(%{
        action: "renewal_request",
        details: %{renewal_requested: "reactivation"},
        originatory_id: user.id,
        originator_role: user.role,
        originator_identifier: user.email,
        originator_remote_ip: Security.extract_remote_ip(conn)
      })

      maybe_send_activation_security_log(user)

      conn
      |> put_flash(:info, "Success")
      |> route_user(user)
    end
  end

  defp update_reactivation_request(user = %{role: "solver"}),
    do: Accounts.update(user, %{status: "active"})

  defp update_reactivation_request(user),
    do: Accounts.update(user, %{renewal_request: "activation"})

  defp maybe_send_activation_security_log(user = %{role: "solver"}) do
    SecurityLogs.track(%{
      originator_id: nil,
      originator_role: nil,
      originator_identifier: nil,
      originator_remote_ip: nil,
      target_id: user.id,
      target_type: user.role,
      target_identifier: user.email,
      action: "status_change",
      details: %{previous_status: "deactivated", new_status: "active"}
    })
  end

  defp maybe_send_activation_security_log(_), do: :noop

  defp route_user(conn, user = %{role: "solver"}) do
    conn
    |> assign(:user, user)
    |> render(Web.DashboardView, "index.html")
  end

  defp route_user(conn, _user), do: redirect(conn, to: Routes.access_path(conn, :index))
end
