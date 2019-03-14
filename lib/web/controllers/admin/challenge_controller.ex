defmodule Web.Admin.ChallengeController do
  use Web, :controller

  alias IdeaPortal.Challenges

  plug Web.Plugs.FetchPage when action in [:index]

  def index(conn, params) do
    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "filter", %{})
    pagination = Challenges.all(filter: filter, page: page, per: per)

    conn
    |> assign(:challenges, pagination.page)
    |> assign(:pagination, pagination.pagination)
    |> assign(:filter, filter)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id) do
      conn
      |> assign(:challenge, challenge)
      |> render("show.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id) do
      conn
      |> assign(:challenge, challenge)
      |> assign(:changeset, Challenges.edit(challenge))
      |> render("edit.html")
    end
  end

  def update(conn, %{"id" => id, "challenge" => params}) do
    {:ok, challenge} = Challenges.get(id)

    case Challenges.update(challenge, params) do
      {:ok, challenge} ->
        conn
        |> put_flash(:info, "Challenge updated!")
        |> redirect(to: Routes.admin_challenge_path(conn, :show, challenge.id))

      {:error, changeset} ->
        conn
        |> assign(:challenge, challenge)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end
end
