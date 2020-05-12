defmodule Web.AccessController do
  use Web, :controller

  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.Security
  alias ChallengeGov.Accounts

  # on recert button press:
  # ERROR: function Web.Admin.AccessController.init/1 is undefined (module Web.Admin.AccessController is not available)

  # def init(conn) do
  #   conn
  #   |> render("recertification.html")
  # end

  def create(conn, params) do
    %{current_user: user} = conn.assigns

    case Accounts.update_terms(user, params) do
      {:ok, user} ->
        CertificationLogs.track(%{
          user_id: user.id,
          user_role: user.role,
          user_identifier: user.email,
          user_remote_ip: Security.extract_remote_ip(conn),
          requested_at: Timex.now()
        })

        conn
        |> put_flash(:info, "Success")
        |> redirect(to: Routes.admin_access_path(conn, :index, user))

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

  def decertified(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:user, user)
    |> assign(:changeset, Accounts.edit(user))
    |> render("recertification.html")
  end

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end
