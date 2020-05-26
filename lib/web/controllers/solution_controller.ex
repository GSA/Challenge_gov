defmodule Web.SolutionController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Solutions
  alias ChallengeGov.Security

  plug(Web.Plugs.EnsureRole, [:solver] when action not in [:index, :show, :delete])
  plug Web.Plugs.FetchPage when action in [:index]

  action_fallback(Web.FallbackController)

  def index(conn, params = %{"challenge_id" => challenge_id}) do
    %{current_user: user} = conn.assigns
    %{page: page, per: per} = conn.assigns

    filter =
      params
      |> Map.get("filter", %{})
      |> Map.merge(%{"challenge_id" => challenge_id})

    filter =
      if Accounts.role_at_or_below(user, "solver") do
        Map.merge(filter, %{"submitter_id" => user.id})
      else
        filter
      end

    sort = Map.get(params, "sort", %{})

    %{page: solutions, pagination: pagination} =
      Solutions.all(filter: filter, sort: sort, page: page, per: per)

    conn
    |> assign(:user, user)
    |> assign(:solutions, solutions)
    |> assign(:pagination, pagination)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> render("index.html")
  end

  def index(conn, params) do
    %{current_user: user} = conn.assigns
    %{page: page, per: per} = conn.assigns

    filter = Map.get(params, "filter", %{})

    filter =
      if Accounts.role_at_or_below(user, "solver") do
        Map.merge(filter, %{"submitter_id" => user.id})
      else
        filter
      end

    sort = Map.get(params, "sort", %{})

    %{page: solutions, pagination: pagination} =
      Solutions.all(filter: filter, sort: sort, page: page, per: per)

    conn
    |> assign(:user, user)
    |> assign(:solutions, solutions)
    |> assign(:pagination, pagination)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, solution} <- Solutions.get(id) do
      conn
      |> assign(:user, user)
      |> assign(:solution, solution)
      |> assign(:action, action_name(conn))
      |> assign(:navbar_text, solution.title || "Solution #{solution.id}")
      |> render("show.html")
    end
  end

  def new(conn, %{"challenge_id" => challenge_id}) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(challenge_id)

    conn
    |> assign(:user, user)
    |> assign(:challenge, challenge)
    |> assign(:action, action_name(conn))
    |> assign(:changeset, Solutions.new())
    |> assign(:navbar_text, "Submit solution")
    |> render("new.html")
  end

  def create(
        conn,
        %{
          "challenge_id" => challenge_id,
          "action" => "draft",
          "solution" => solution_params
        }
      ) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(challenge_id)

    with {:ok, solution} <- Solutions.create_draft(solution_params, user, challenge) do
      conn
      |> put_flash(:info, "Solution saved as draft")
      |> redirect(to: Routes.solution_path(conn, :edit, solution.id))
    else
      {:error, changeset} ->
        create_error(conn, changeset, user, challenge)
    end
  end

  def create(conn, %{
        "challenge_id" => challenge_id,
        "action" => "review",
        "solution" => solution_params
      }) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(challenge_id)

    with {:ok, solution} <- Solutions.create_review(solution_params, user, challenge) do
      conn
      |> redirect(to: Routes.solution_path(conn, :show, solution.id))
    else
      {:error, changeset} ->
        create_error(conn, changeset, user, challenge)
    end
  end

  defp create_error(conn, changeset, user, challenge) do
    conn
    |> assign(:user, user)
    |> assign(:challenge, challenge)
    |> assign(:path, Routes.challenge_path(conn, :create))
    |> assign(:action, action_name(conn))
    |> assign(:changeset, changeset)
    |> assign(:solution, nil)
    |> put_status(422)
    |> render("new.html")
  end

  def edit(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, solution} <- Solutions.get(id),
         {:ok, solution} <- Solutions.allowed_to_edit?(user, solution) do
      conn
      |> assign(:user, user)
      |> assign(:solution, solution)
      |> assign(:action, action_name(conn))
      |> assign(:path, Routes.solution_path(conn, :update, id))
      |> assign(:changeset, Solutions.edit(solution))
      |> assign(:navbar_text, "Edit solution")
      |> render("edit.html")
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this solution")
        |> redirect(to: Routes.solution_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Solution not found")
        |> redirect(to: Routes.solution_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "action" => "draft", "solution" => solution_params}) do
    %{current_user: user} = conn.assigns

    with {:ok, solution} <- Solutions.get(id),
         {:ok, solution} <- Solutions.allowed_to_edit?(user, solution),
         {:ok, solution} <- Solutions.update_draft(solution, solution_params) do
      conn
      |> put_flash(:info, "Solution saved as draft")
      |> redirect(to: Routes.solution_path(conn, :edit, solution.id))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This solution does not exist")
        |> redirect(to: Routes.solution_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this solution")
        |> redirect(to: Routes.solution_path(conn, :index))

      {:error, changeset} ->
        {:ok, solution} = Solutions.get(id)
        update_error(conn, changeset, user, solution)
    end
  end

  def update(conn, %{"id" => id, "action" => "review", "solution" => solution_params}) do
    %{current_user: user} = conn.assigns

    with {:ok, solution} <- Solutions.get(id),
         {:ok, solution} <- Solutions.allowed_to_edit?(user, solution),
         {:ok, solution} <- Solutions.update_review(solution, solution_params) do
      redirect(conn, to: Routes.solution_path(conn, :show, solution.id))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This solution does not exist")
        |> redirect(to: Routes.solution_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this solution")
        |> redirect(to: Routes.solution_path(conn, :index))

      {:error, changeset} ->
        {:ok, solution} = Solutions.get(id)
        update_error(conn, changeset, user, solution)
    end
  end

  defp update_error(conn, changeset, user, solution) do
    conn
    |> assign(:user, user)
    |> assign(:solution, solution)
    |> assign(:action, action_name(conn))
    |> assign(:path, Routes.solution_path(conn, :update, solution.id))
    |> assign(:changeset, changeset)
    |> put_status(422)
    |> render("edit.html")
  end

  def submit(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns
    {:ok, solution} = Solutions.get(id)

    with {:ok, solution} <- Solutions.allowed_to_edit?(user, solution),
         {:ok, solution} <- Solutions.submit(solution, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "Solution submitted")
      |> redirect(to: Routes.solution_path(conn, :show, solution.id))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This solution does not exist")
        |> redirect(to: Routes.solution_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this solution")
        |> redirect(to: Routes.solution_path(conn, :index))

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:solution, solution)
        |> assign(:action, action_name(conn))
        |> assign(:path, Routes.solution_path(conn, :update, id))
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, solution} <- Solutions.get(id),
         {:ok, _solution} <- Solutions.delete(solution, user) do
      conn
      |> put_flash(:info, "Solution deleted")
      |> redirect(to: Routes.solution_path(conn, :index))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This solution does not exist")
        |> redirect(to: Routes.solution_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.solution_path(conn, :index))
    end
  end
end
