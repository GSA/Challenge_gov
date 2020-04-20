defmodule Web.Admin.SolutionController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Solutions

  plug Web.Plugs.FetchPage when action in [:index]

  action_fallback(Web.Admin.FallbackController)

  def index(conn, params = %{"challenge_id" => challenge_id}) do
    %{current_user: user} = conn.assigns
    %{page: page, per: per} = conn.assigns

    filter =
      params
      |> Map.get("filter", %{})
      |> Map.merge(%{"challenge_id" => challenge_id})

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

    filter =
      params
      |> Map.get("filter", %{})
      |> Map.merge(%{"submitter_id" => user.id})

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
      |> render("show.html")
    end
  end

  def new(conn, _params) do
    %{current_user: user} = conn.assigns

    conn
    |> assign(:user, user)
    |> assign(:action, action_name(conn))
    |> assign(:changeset, Solutions.new())
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

    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, solution} <- Solutions.create_draft(solution_params, user, challenge) do
      conn
      |> put_flash(:info, "Solution saved as draft")
      |> redirect(to: Routes.admin_solution_path(conn, :edit, solution.id))
    else
      {:error, changeset} ->
        create_error(conn, changeset, user)
    end
  end

  def create(conn, %{
        "challenge_id" => challenge_id,
        "action" => "review",
        "solution" => solution_params
      }) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, solution} <- Solutions.create_review(solution_params, user, challenge) do
      conn
      |> redirect(to: Routes.admin_solution_path(conn, :show, solution.id))
    else
      {:error, changeset} ->
        create_error(conn, changeset, user)
    end
  end

  defp create_error(conn, changeset, user) do
    conn
    |> assign(:user, user)
    |> assign(:path, Routes.admin_challenge_path(conn, :create))
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
      |> assign(:path, Routes.admin_solution_path(conn, :update, id))
      |> assign(:changeset, Solutions.edit(solution))
      |> render("edit.html")
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this solution")
        |> redirect(to: Routes.admin_solution_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Solution not found")
        |> redirect(to: Routes.admin_solution_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "action" => "draft", "solution" => solution_params}) do
    %{current_user: user} = conn.assigns

    with {:ok, solution} <- Solutions.get(id),
         {:ok, solution} <- Solutions.allowed_to_edit?(user, solution),
         {:ok, solution} <- Solutions.update_draft(solution, solution_params) do
      conn
      |> put_flash(:info, "Solution saved as draft")
      |> redirect(to: Routes.admin_solution_path(conn, :edit, solution.id))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This solution does not exist")
        |> redirect(to: Routes.admin_solution_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this solution")
        |> redirect(to: Routes.admin_solution_path(conn, :index))

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:path, Routes.admin_solution_path(conn, :update, id))
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def update(conn, %{"id" => id, "action" => "review", "solution" => solution_params}) do
    %{current_user: user} = conn.assigns

    with {:ok, solution} <- Solutions.get(id),
         {:ok, solution} <- Solutions.allowed_to_edit?(user, solution),
         {:ok, solution} <- Solutions.update_review(solution, solution_params) do
      redirect(conn, to: Routes.admin_solution_path(conn, :show, solution.id))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This solution does not exist")
        |> redirect(to: Routes.admin_solution_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this solution")
        |> redirect(to: Routes.admin_solution_path(conn, :index))

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:path, Routes.admin_solution_path(conn, :update, id))
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def submit(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, solution} <- Solutions.get(id),
         {:ok, solution} <- Solutions.allowed_to_edit?(user, solution),
         {:ok, solution} <- Solutions.submit(solution) do
      conn
      |> put_flash(:info, "Solution submitted")
      |> redirect(to: Routes.admin_solution_path(conn, :show, solution.id))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This solution does not exist")
        |> redirect(to: Routes.admin_solution_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this solution")
        |> redirect(to: Routes.admin_solution_path(conn, :index))

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:path, Routes.admin_solution_path(conn, :update, id))
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
      |> redirect(to: Routes.admin_solution_path(conn, :index))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This solution does not exist")
        |> redirect(to: Routes.admin_solution_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.admin_solution_path(conn, :index))
    end
  end
end
