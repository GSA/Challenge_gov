defmodule Web.AccountController do
  use Web, :controller

  alias ChallengeGov.Accounts

  plug Web.Plugs.FetchPage, [per: 12] when action in [:index]

  action_fallback(Web.FallbackController)

  def index(conn, params) do
    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "filter", %{})
    pagination = Accounts.public(filter: filter, page: page, per: per)

    conn
    |> assign(:accounts, pagination.page)
    |> assign(:pagination, pagination.pagination)
    |> assign(:filter, filter)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, account} <- Accounts.public_get(id) do
      conn
      |> assign(:account, account)
      |> render("show.html")
    end
  end

  def edit(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:changeset, Accounts.edit(user))
    |> render("edit.html")
  end

  def update(conn, %{"user" => params = %{"password" => _password}}) do
    %{current_user: user} = conn.assigns

    case Accounts.update_password(user, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Your account has been updated")
        |> redirect(to: Routes.account_path(conn, :edit))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was an issue updating your account")
        |> redirect(to: Routes.account_path(conn, :edit))
    end
  end

  def update(conn, %{"user" => params}) do
    %{current_user: user} = conn.assigns

    case Accounts.update(user, params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Your account has been updated")
        |> redirect(to: Routes.account_path(conn, :edit))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was an issue updating your account")
        |> put_status(422)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end
end
