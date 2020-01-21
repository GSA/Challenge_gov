defmodule Web.Admin.UserController do
  use Web, :controller

  alias ChallengeGov.Accounts

  plug(Web.Plugs.FetchPage when action in [:index])

  def index(conn, params) do
    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "user", %{})
    %{page: users, pagination: pagination} = Accounts.all(filter: filter, page: page, per: per)

    conn
    |> assign(:users, users)
    |> assign(:filter, filter)
    |> assign(:pagination, pagination)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, user} <- Accounts.get(id) do
      conn
      |> assign(:user, user)
      |> render("show.html")
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
