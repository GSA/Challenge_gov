defmodule Web.Admin.ChallengeController do
  use Web, :controller

  alias ChallengeGov.Challenges

  plug Web.Plugs.FetchPage when action in [:index]

  action_fallback(Web.Admin.FallbackController)

  def index(conn, params) do
    %{current_user: user} = conn.assigns

    %{page: page, per: per} = conn.assigns
    filter = Map.get(params, "filter", %{})
    pagination = Challenges.all_for_user(user, filter: filter, page: page, per: per)

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

  def new(conn, %{"non_wizard" => _value}) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:user, user)
    |> assign(:action, action_name(conn))
    |> assign(:changeset, Challenges.new(user))
    |> render("new.html")
  end

  # TODO: Make an old "new" to keep access to old challenge form for now
  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:user, user)
    |> assign(:changeset, Challenges.new(user))
    |> assign(:path, Routes.admin_challenge_path(conn, :create))
    |> assign(:action, action_name(conn))
    |> assign(:section, "general")
    |> render("form.html")
  end

  def create(conn, params = %{"action" => action, "challenge" => %{"section" => section}}) do
    %{current_user: user} = conn.assigns

    case Challenges.create(params) do
      {:ok, challenge} ->
        if action == "save_draft" do
          conn
          |> put_flash(:info, "Challenge saved as draft")
          |> redirect(to: Routes.admin_challenge_path(conn, :index))
        else
          conn
          |> redirect(
            to:
              Routes.admin_challenge_path(
                conn,
                :edit,
                challenge.id,
                Challenges.next_section(section).id
              )
          )
        end

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:path, Routes.admin_challenge_path(conn, :create))
        |> assign(:action, action_name(conn))
        |> assign(:section, section)
        |> assign(:changeset, changeset)
        |> put_status(422)
        |> render("form.html")
    end
  end

  # TODO: Remove this old create
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

  def edit(conn, %{"id" => id, "section" => section}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge) do
      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:path, Routes.admin_challenge_path(conn, :update, id))
      |> assign(:action, action_name(conn))
      |> assign(:section, section)
      |> assign(:changeset, Challenges.edit(challenge))
      |> render("form.html")
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this challenge")
        |> redirect(to: Routes.admin_challenge_path(conn, :index))
    end
  end

  # TODO: Remove old edit
  def edit(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge) do
      conn
      |> assign(:challenge, challenge)
      |> assign(:user, user)
      |> assign(:supporting_documents, challenge.supporting_documents)
      |> assign(:changeset, Challenges.edit(challenge))
      |> assign(:action, action_name(conn))
      |> render("edit.html")
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this challenge")
        |> redirect(to: Routes.admin_challenge_path(conn, :index))
    end
  end

  def update(
        conn,
        params = %{"id" => id, "action" => action, "challenge" => %{"section" => section}}
      ) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(id)
    to_section = Challenges.to_section(section, action)

    with {:ok, challenge} <- Challenges.update(challenge, params),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge) do
      if action == "save_draft" do
        conn
        |> put_flash(:info, "Challenge saved as draft")
        |> redirect(to: Routes.admin_challenge_path(conn, :index))
      end

      if to_section do
        redirect(conn, to: Routes.admin_challenge_path(conn, :edit, challenge.id, to_section.id))
      else
        redirect(conn, to: Routes.admin_challenge_path(conn, :index))
      end
    else
      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:challenge, challenge)
        |> assign(:path, Routes.admin_challenge_path(conn, :update, id))
        |> assign(:action, action_name(conn))
        |> assign(:section, section)
        |> assign(:changeset, changeset)
        |> render("form.html")

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this challenge")
        |> redirect(to: Routes.admin_challenge_path(conn, :index))
    end
  end

  # TODO: Remove old update
  def update(conn, %{"id" => id, "challenge" => params}) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(id)

    with {:ok, challenge} <- Challenges.update(challenge, params, user),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge) do
      conn
      |> put_flash(:info, "Challenge updated!")
      |> redirect(to: Routes.admin_challenge_path(conn, :show, challenge.id))
    else
      {:error, changeset} ->
        conn
        |> assign(:challenge, challenge)
        |> assign(:changeset, changeset)
        |> render("edit.html")

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this challenge")
        |> redirect(to: Routes.admin_challenge_path(conn, :index))
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

  def reject(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.reject(challenge) do
      conn
      |> put_flash(:info, "Challenge rejected")
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

  def remove_logo(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.remove_logo(challenge) do
      conn
      |> put_flash(:info, "Logo removed")
      |> redirect(to: Routes.admin_challenge_path(conn, :show, challenge.id))
    end
  end

  def remove_winner_image(conn, %{"id" => id}) do
    with {:ok, challenge} <- Challenges.get(id),
         {:ok, challenge} <- Challenges.remove_winner_image(challenge) do
      conn
      |> put_flash(:info, "Winner image removed")
      |> redirect(to: Routes.admin_challenge_path(conn, :show, challenge.id))
    end
  end
end
