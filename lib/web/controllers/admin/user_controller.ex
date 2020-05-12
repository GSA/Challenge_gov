defmodule Web.Admin.UserController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.Challenges
  alias ChallengeGov.Repo
  alias ChallengeGov.Security

  plug(Web.Plugs.FetchPage when action in [:index, :create])

  def index(conn, params) do
    %{current_user: current_user} = conn.assigns

    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "user", %{})
    sort = Map.get(params, "sort", %{})
    %{page: users, pagination: pagination} = Accounts.all(filter: filter, page: page, per: per)

    conn
    |> assign(:user, current_user)
    |> assign(:current_user, current_user)
    |> assign(:users, users)
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
      |> redirect(to: Routes.admin_user_path(conn, :index))
    else
      {:ok, user} ->
        {:ok, user}

        conn
        |> put_flash(:error, "A user with that email already exists")
        |> redirect(to: Routes.admin_user_path(conn, :index))

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
    %{current_user: current_user} = conn.assigns
    {:ok, user} = Accounts.get(id)

    case Accounts.update(user, params) do
      {:ok, user} ->
        conn
        |> assign(:user, user)
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
         {:ok, user} <- Accounts.activate(user, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User activated")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end

  def toggle(conn, %{"id" => id, "action" => "recertify"}) do
    %{current_user: originator} = conn.assigns

    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <- admin_recertify_user(user, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User recertified")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end

  def toggle(conn, %{"id" => id, "action" => "suspend"}) do
    %{current_user: originator} = conn.assigns

    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <- Accounts.suspend(user, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User suspended")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end

  def toggle(conn, %{"id" => id, "action" => "revoke"}) do
    %{current_user: originator} = conn.assigns

    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <- Accounts.revoke(user, originator, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "User revoked")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end

  def restore_challenge_access(conn, %{"user_id" => user_id, "challenge_id" => challenge_id}) do
    with {:ok, user} <- Accounts.get(user_id),
         {:ok, challenge} <- Challenges.get(challenge_id),
         _ <- Challenges.restore_access(user, challenge) do
      conn
      |> put_flash(:info, "Challenge access restored")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end

  def admin_recertify_user(user, approver, approver_remote_ip) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:user, fn _repo, _changes ->
        Accounts.activate(user, approver, approver_remote_ip)
      end)
      |> Ecto.Multi.run(:certification_record, fn _repo, _changes ->
        CertificationLogs.track(%{
          approver_id: approver.id,
          approver_role: approver.role,
          approver_identifier: approver.email,
          approver_remote_ip: approver_remote_ip,
          user_id: user.id,
          user_role: user.role,
          user_identifier: user.email,
          certified_at: Timex.now(),
          expires_at: CertificationLogs.calulate_expiry()
        })
      end)
      |> Repo.transaction()

    case result do
      {:ok, result} ->
        {:ok, result.user}

      :error ->
        {:error, :not_recertified}
    end
  end
end
