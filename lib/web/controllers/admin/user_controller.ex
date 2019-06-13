defmodule Web.Admin.UserController do
  use Web, :controller

  alias IdeaPortal.Accounts

  plug(Web.Plugs.FetchPage when action in [:index])

  def index(conn, _params) do
    %{page: page, per: per} = conn.assigns
    %{page: users, pagination: pagination} = Accounts.all(page: page, per: per)

    conn
    |> assign(:users, users)
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
