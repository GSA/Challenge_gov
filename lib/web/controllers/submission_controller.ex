defmodule Web.SubmissionController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.Submissions
  alias ChallengeGov.Security

  plug(
    Web.Plugs.EnsureRole,
    [:solver]
    when action not in [
           :index,
           :show,
           :edit,
           :delete,
           :update_judging_status,
           :new,
           :submit,
           :create,
           :managed_submissions
         ]
  )

  plug(
    Web.Plugs.EnsureRole,
    [:admin, :super_admin, :solver] when action in [:new, :submit, :create]
  )

  plug(
    Web.Plugs.EnsureRole,
    [:admin, :super_admin] when action in [:managed_submissions]
  )

  plug Web.Plugs.FetchPage when action in [:index, :show]

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

    %{page: submissions, pagination: pagination} =
      Submissions.all(filter: filter, sort: sort, page: page, per: per)

    conn
    |> assign(:user, user)
    |> assign(:submissions, submissions)
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

    %{page: submissions, pagination: pagination} =
      Submissions.all(filter: filter, sort: sort, page: page, per: per)

    conn
    |> assign(:user, user)
    |> assign(:submissions, submissions)
    |> assign(:pagination, pagination)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> render("index.html")
  end

  def managed_submissions(
        conn,
        params = %{"challenge_id" => challenge_id, "phase_id" => phase_id}
      ) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(challenge_id)
    {:ok, phase} = Phases.get(phase_id)
    filter = %{"manager_id" => user.id}
    sort = Map.get(params, "sort", %{})
    submissions = Submissions.all(filter: filter)

    conn
    |> assign(:user, user)
    |> assign(:challenge, challenge)
    |> assign(:phase, phase)
    |> assign(:submissions, submissions)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> render("index_managed.html")
  end

  def show(conn, params = %{"id" => id}) do
    %{current_user: user, page: page} = conn.assigns

    filter = Map.get(params, "filter", %{})
    sort = Map.get(params, "sort", %{})

    with {:ok, submission} <- Submissions.get(id),
         {:ok, phase} <- Phases.get(submission.phase_id),
         {:ok, challenge} <- Challenges.get(submission.challenge_id) do
      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:phase, phase)
      |> assign(:submission, submission)
      |> assign(:page, page)
      |> assign(:filter, filter)
      |> assign(:sort, sort)
      |> assign(:action, action_name(conn))
      |> assign(:navbar_text, submission.title || "Submission #{submission.id}")
      |> render("show.html")
    end
  end

  def new(conn, %{"challenge_id" => challenge_id, "phase_id" => phase_id}) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(challenge_id)

    conn
    |> assign(:user, user)
    |> assign(:challenge, challenge)
    |> assign(:phase_id, phase_id)
    |> assign(:action, action_name(conn))
    |> assign(:changeset, Submissions.new())
    |> assign(:navbar_text, "Create submission")
    |> render("new.html")
  end

  def new(conn, %{"challenge_id" => challenge_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, %{id: phase_id}} <- Challenges.current_phase(challenge) do
      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:phase_id, phase_id)
      |> assign(:action, action_name(conn))
      |> assign(:changeset, Submissions.new())
      |> assign(:navbar_text, "Create submission")
      |> render("new.html")
    else
      {:error, :no_current_phase} ->
        conn
        |> put_flash(:error, "No current phase found")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Challenge not found")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  def create(
        conn,
        %{
          "challenge_id" => challenge_id,
          "phase_id" => phase_id,
          "action" => "draft",
          "submission" => submission_params
        }
      ) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(challenge_id)

    conn =
      conn
      |> assign(:phase_id, phase_id)

    with {:ok, phase} <- Challenges.current_phase(challenge),
         {:ok, submission} <- Submissions.create_draft(submission_params, user, challenge, phase) do
      conn =
        conn
        |> assign(:phase_id, phase.id)

      conn
      |> put_flash(:info, "Submission saved as draft")
      |> redirect(to: Routes.submission_path(conn, :edit, submission.id))
    else
      {:error, :no_current_phase} ->
        conn
        |> put_flash(:error, "No current phase found")
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, changeset} ->
        create_error(conn, changeset, user, challenge)
    end
  end

  def create(
        conn,
        %{
          "challenge_id" => challenge_id,
          "phase_id" => phase_id,
          "action" => "review",
          "submission" => submission_params
        }
      ) do
    %{current_user: user} = conn.assigns

    conn =
      conn
      |> assign(:phase_id, phase_id)

    {:ok, challenge} = Challenges.get(challenge_id)

    {solver, phase, submission_params} =
      if Accounts.has_admin_access?(user) do
        submission_params =
          Map.merge(submission_params, %{"manager_id" => user.id, "terms_accepted" => false})

        solver =
          case Accounts.get_by_email(submission_params["solver_addr"]) do
            {:ok, solver} ->
              solver

            {:error, :not_found} ->
              conn
              |> put_flash(:error, "That user is not found")
              |> redirect(to: Routes.dashboard_path(conn, :index))
          end

        {:ok, phase} = Phases.get(phase_id)
        {solver, phase, submission_params}
      else
        solver = user

        phase =
          case Challenges.current_phase(challenge) do
            {:ok, phase} ->
              phase

            {:error, :no_current_phase} ->
              conn
              |> put_flash(:error, "No current phase found")
              |> redirect(to: Routes.dashboard_path(conn, :index))
          end

        {solver, phase, submission_params}
      end

    case Submissions.create_review(submission_params, solver, challenge, phase) do
      {:ok, submission} ->
        conn
        |> redirect(to: Routes.submission_path(conn, :show, submission.id))

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
    |> assign(:submission, nil)
    |> put_status(422)
    |> render("new.html")
  end

  def edit(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, submission} <- Submissions.get(id),
         {:ok, submission} <- Submissions.allowed_to_edit?(user, submission) do
      conn
      |> assign(:user, user)
      |> assign(:submission, submission)
      |> assign(:action, action_name(conn))
      |> assign(:path, Routes.submission_path(conn, :update, id))
      |> assign(:changeset, Submissions.edit(submission))
      |> assign(:navbar_text, "Edit submission")
      |> render("edit.html")
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this submission")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Submission not found")
        |> redirect(to: Routes.submission_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "action" => "draft", "submission" => submission_params}) do
    %{current_user: user} = conn.assigns

    with {:ok, submission} <- Submissions.get(id),
         {:ok, submission} <- Submissions.allowed_to_edit?(user, submission),
         {:ok, submission} <- Submissions.update_draft(submission, submission_params) do
      conn
      |> put_flash(:info, "Submission saved as draft")
      |> redirect(to: Routes.submission_path(conn, :edit, submission.id))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This submission does not exist")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this submission")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, changeset} ->
        {:ok, submission} = Submissions.get(id)
        update_error(conn, changeset, user, submission)
    end
  end

  def update(conn, %{"id" => id, "action" => "review", "submission" => submission_params}) do
    %{current_user: user} = conn.assigns

    with {:ok, submission} <- Submissions.get(id),
         {:ok, submission} <- Submissions.allowed_to_edit?(user, submission),
         {:ok, submission} <- Submissions.update_review(submission, submission_params) do
      redirect(conn, to: Routes.submission_path(conn, :show, submission.id))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This submission does not exist")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this submission")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, changeset} ->
        {:ok, submission} = Submissions.get(id)
        update_error(conn, changeset, user, submission)
    end
  end

  defp update_error(conn, changeset, user, submission) do
    conn
    |> assign(:user, user)
    |> assign(:submission, submission)
    |> assign(:action, action_name(conn))
    |> assign(:path, Routes.submission_path(conn, :update, submission.id))
    |> assign(:changeset, changeset)
    |> put_status(422)
    |> render("edit.html")
  end

  def submit(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns
    {:ok, submission} = Submissions.get(id)

    with {:ok, submission} <- Submissions.allowed_to_edit?(user, submission),
         {:ok, submission} <- Submissions.submit(submission, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "Submission created")
      |> redirect(to: Routes.submission_path(conn, :show, submission.id))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This submission does not exist")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to edit this submission")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:submission, submission)
        |> assign(:action, action_name(conn))
        |> assign(:path, Routes.submission_path(conn, :update, id))
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, submission} <- Submissions.get(id),
         {:ok, _submission} <- Submissions.delete(submission, user) do
      conn
      |> put_flash(:info, "Submission deleted")
      |> redirect(to: Routes.submission_path(conn, :index))
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "This submission does not exist")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.submission_path(conn, :index))
    end
  end
end
