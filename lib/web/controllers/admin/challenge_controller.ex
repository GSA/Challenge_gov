defmodule Web.Admin.ChallengeController do
  use Web, :controller

  alias IdeaPortal.Challenges

  plug Web.Plugs.FetchPage when action in [:index]

  action_fallback(Web.Admin.FallbackController)

  def index(conn, params) do
    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "filter", %{})
    pagination = Challenges.admin_all(filter: filter, page: page, per: per)

    counts = Challenges.admin_counts()

    conn
    |> assign(:challenges, pagination.page)
    |> assign(:pagination, pagination.pagination)
    |> assign(:filter, filter)
    |> assign(:pending_count, counts.pending)
    |> assign(:created_count, counts.created)
    |> assign(:archived_count, counts.archived)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id) do
      conn
      |> assign(:challenge, challenge)
      |> assign(:events, challenge.events)
      |> assign(:supporting_documents, challenge.supporting_documents)
      |> render("show.html")
    end
  end

  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:changeset, Challenges.admin_new(user))
    |> render("new.html")
  end

  def create(conn, %{"challenge" => params}) do
    %{current_user: user} = conn.assigns

    case Challenges.create(user, params) do
      {:ok, challenge} ->
        conn
        |> put_flash(:info, "Challenge created!")
        |> redirect(to: Routes.admin_challenge_path(conn, :show, challenge.id))

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> put_status(422)
        |> render("new.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id) do
      conn
      |> assign(:challenge, challenge)
      |> assign(:supporting_documents, challenge.supporting_documents)
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

  def publish(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.publish(challenge) do
      conn
      |> put_flash(:info, "Challenge published")
      |> redirect(to: Routes.admin_challenge_path(conn, :show, challenge.id))
    end
  end

  def archive(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.archive(challenge) do
      conn
      |> put_flash(:info, "Challenge archived")
      |> redirect(to: Routes.admin_challenge_path(conn, :show, challenge.id))
    end
  end
end
