defmodule Web.Admin.AccessController do
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

    conn
    |> assign(:user, user)
    |> assign(:changeset, Accounts.edit(user))
    |> render("recertification.html")
  end

  def request_recertification(conn, params) do
    %{current_user: user} = conn.assigns

    with {:ok, user} <- Accounts.update_terms(user, params),
         {:ok, user} <- Accounts.update(user, %{renewal_request: "certification"}) do
      CertificationLogs.track(%{
        user_id: user.id,
        user_role: user.role,
        user_identifier: user.email,
        user_remote_ip: Security.extract_remote_ip(conn),
        requested_at: Timex.now()
      })

      conn
      |> put_flash(:info, "Success")
      |> redirect(to: Routes.admin_access_path(conn, :index))
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

    conn
    |> assign(:user, user)
    |> assign(:changeset, Accounts.edit(user))
    |> render("reactivation.html")
  end

  def request_reactivation(conn, _params) do
    %{current_user: current_user} = conn.assigns

    with {:ok, user} <- Accounts.update(current_user, %{renewal_request: "activation"}) do
      SecurityLogs.track(%{
        action: "renewal_request",
        details: %{renewal_requested: "reactivation"},
        originatory_id: user.id,
        originator_role: user.role,
        originator_identifier: user.email,
        originator_remote_ip: Security.extract_remote_ip(conn)
      })

      conn
      |> put_flash(:info, "Success")
      |> redirect(to: Routes.admin_access_path(conn, :index))
    end
  end
end
