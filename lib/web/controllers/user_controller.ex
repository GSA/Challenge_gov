defmodule Web.UserController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.Challenges
  alias ChallengeGov.Security
  alias ChallengeGov.Users

  plug(
    Web.Plugs.EnsureRole,
    [:super_admin, :admin] when action in [:index, :show, :edit, :update, :toggle]
  )

  plug(Web.Plugs.EnsureRole, :super_admin when action in [:create])
  plug(Web.Plugs.FetchPage when action in [:index, :create])

  def index(conn, params) do
    %{current_user: current_user} = conn.assigns
    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "user", %{})
    sort = Map.get(params, "sort", %{})
    %{page: users, pagination: pagination} = Accounts.all(filter: filter, page: page, per: per)

    pending_users = Accounts.all_pending()
    reactivation_users = Accounts.all_reactivation()
    requesting_recertification = Accounts.requesting_recertification()

    conn
    |> assign(:user, current_user)
    |> assign(:current_user, current_user)
    |> assign(:users, users)
    |> assign(
      :users_requiring_action,
      pending_users ++ reactivation_users ++ requesting_recertification
    )
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> assign(:pagination, pagination)
    |> assign(:changeset, Accounts.new())
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, user} <- Accounts.get(id),
         {:ok, certification} <- CertificationLogs.get_current_certification(user) do
      conn
      |> assign(:user, user)
      |> assign(:certification, certification || %{})
      |> render("show.html")
    else
      _ ->
        conn
    end
  end

  def create(conn, %{"user" => %{"email" => email, "email_confirmation" => _} = user_params}) do
    %{current_user: originator} = conn.assigns

    with {:error, :not_found} <- Accounts.get_by_email(email),
         {:ok, _} <- Accounts.create(user_params, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User has been added!")
      |> redirect(to: Routes.user_path(conn, :index))
    else
      {:ok, user} ->
        {:ok, user}

        conn
        |> put_flash(:error, "A user with that email already exists")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, changeset} ->
        %{current_user: current_user} = conn.assigns

        %{page: page, per: per} = conn.assigns
        %{page: users, pagination: pagination} = Accounts.all(page: page, per: per)

        conn
        |> assign(:changeset, changeset)
        |> assign(:current_user, current_user)
        |> assign(:users, users)
        |> assign(:filter, %{})
        |> assign(:pagination, pagination)
        |> render("index.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    %{current_user: current_user} = conn.assigns

    with {:ok, user} <- Accounts.get(id) do
      conn
      |> assign(:current_user, current_user)
      |> assign(:user, user)
      |> assign(:changeset, Accounts.edit(user))
      |> render("edit.html")
    end
  end

  def update(conn, %{"id" => id, "user" => params}) do
    {:ok, user} = Accounts.get(id)
    %{current_user: current_user} = conn.assigns
    %{"role" => role} = params
    %{"status" => status} = params
    previous_role = user.role
    previous_status = user.status
    remote_ip = Security.extract_remote_ip(conn)

    params =
      if Map.get(params, "status") == "active" do
        Map.put(params, "renewal_request", nil)
      else
        params
      end

    case Accounts.update(user, params) do
      {:ok, user} ->
        execute_security_log(
          remote_ip,
          current_user,
          user,
          role,
          previous_role,
          status,
          previous_status
        )

        Users.maybe_decertify_user_manually(user, status, previous_status)

        {:ok, certification} =
          case CertificationLogs.get_current_certification(user) do
            {:ok, certification} ->
              {:ok, certification}

            {:error, :no_log_found} ->
              CertificationLogs.certify_user_with_approver(user, current_user, remote_ip)
          end

        conn
        |> assign(:user, user)
        |> assign(:certification, certification)
        |> render("show.html")

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:current_user, current_user)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def toggle(conn, %{"id" => id, "action" => "activate"}) do
    %{current_user: originator} = conn.assigns

    with {:ok, user} <- Accounts.get(id),
         {:ok, _updated_user} <-
           Accounts.activate(user, originator, Security.extract_remote_ip(conn)) do
      Users.send_email(user)

      conn
      |> put_flash(:info, "User activated")
      |> redirect(to: Routes.user_path(conn, :show, user.id))
    end
  end

  def toggle(conn, %{"id" => id, "action" => "recertify"}) do
    %{current_user: originator} = conn.assigns

    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <-
           Users.admin_recertify_user(user, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User recertified")
      |> redirect(to: Routes.user_path(conn, :show, user.id))
    end
  end

  def toggle(conn, %{"id" => id, "action" => "suspend"}) do
    %{current_user: originator} = conn.assigns

    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <- Accounts.suspend(user, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User suspended")
      |> redirect(to: Routes.user_path(conn, :show, user.id))
    end
  end

  def toggle(conn, %{"id" => id, "action" => "revoke"}) do
    %{current_user: originator} = conn.assigns

    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <- Accounts.revoke(user, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User revoked")
      |> redirect(to: Routes.user_path(conn, :show, user.id))
    end
  end

  def restore_challenge_access(conn, %{"user_id" => user_id, "challenge_id" => challenge_id}) do
    with {:ok, user} <- Accounts.get(user_id),
         {:ok, challenge} <- Challenges.get(challenge_id),
         _ <- Challenges.restore_access(user, challenge) do
      conn
      |> put_flash(:info, "Challenge access restored")
      |> redirect(to: Routes.user_path(conn, :show, user.id))
    end
  end

  defp execute_security_log(
         remote_ip,
         current_user,
         user,
         role,
         previous_role,
         status,
         previous_status
       ) do
    Security.track_role_change_in_security_log(
      remote_ip,
      current_user,
      user,
      role,
      previous_role
    )

    Security.track_status_update_in_security_log(
      remote_ip,
      current_user,
      user,
      status,
      previous_status
    )
  end
end
