defmodule Web.Admin.UserController do
  use Web, :controller

  alias ChallengeGov.Accounts

  plug(Web.Plugs.FetchPage when action in [:index, :create])

  def index(conn, params) do
    %{current_user: current_user} = conn.assigns

    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "user", %{})
    %{page: users, pagination: pagination} = Accounts.all(filter: filter, page: page, per: per)

    conn
    |> assign(:current_user, current_user)
    |> assign(:users, users)
    |> assign(:filter, filter)
    |> assign(:pagination, pagination)
    |> assign(:changeset, Accounts.new())
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    %{current_user: current_user} = conn.assigns

    with {:ok, user} <- Accounts.get(id) do
      conn
      |> assign(:current_user, current_user)
      |> assign(:user, user)
      |> render("show.html")
    end
  end

  def create(conn, %{"user" => %{"email" => email, "email_confirmation" => _} = user_params}) do
    with {:error, :not_found} <- Accounts.get_by_email(email),
         {:ok, _} <- Accounts.create(user_params) do
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
    {:ok, user} = Accounts.get(id)

    case Accounts.update(user, params) do
      {:ok, user} ->
        conn
        |> assign(:user, user)
        |> render("show.html")

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def toggle(conn, %{"id" => id, "action" => "participation"}) do
    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <- Accounts.toggle_display(user) do
      conn
      |> put_flash(:info, "User display updated")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end

  def toggle(conn, %{"id" => id, "action" => "admin"}) do
    with {:ok, user} <- Accounts.get(id),
         {:ok, user} <- Accounts.toggle_admin(user) do
      conn
      |> put_flash(:info, "User role updated")
      |> redirect(to: Routes.admin_user_path(conn, :show, user.id))
    end
  end
end
