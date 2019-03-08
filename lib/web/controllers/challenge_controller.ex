defmodule Web.ChallengeController do
  use Web, :controller

  alias IdeaPortal.Challenges

  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:changeset, Challenges.new(user))
    |> render("new.html")
  end

  def create(conn, %{"challenge" => params}) do
    %{current_user: user} = conn.assigns

    case Challenges.submit(user, params) do
      {:ok, _challenge} ->
        conn
        |> put_flash(:info, "Challenge submitted!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(422)
        |> render("new.html")
    end
  end
end
