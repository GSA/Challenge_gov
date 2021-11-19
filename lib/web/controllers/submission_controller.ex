defmodule Web.SubmissionController do
  use Web, :controller

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.Submissions
  alias ChallengeGov.Security
  alias Web.ChallengeView

  plug(
    Web.Plugs.EnsureRole,
    [:admin, :super_admin, :solver]
    when action in [:new, :submit, :create, :edit, :update, :delete]
  )

  plug(
    Web.Plugs.EnsureRole,
    [:admin, :super_admin] when action in [:managed_submissions]
  )

  plug(Web.Plugs.EnsureRole, [:solver] when action in [:index])

  plug Web.Plugs.FetchPage when action in [:index, :show, :managed_submissions]

  plug(Web.Plugs.FetchSubmission when action in [:edit, :show, :update, :submit, :delete])

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
    |> assign(:unreviewed_submissions, [])
    |> assign(:pagination, pagination)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> render("index.html")
  end

  def index(conn, params) do
    %{current_user: user} = conn.assigns
    %{page: page, per: per} = conn.assigns

    filter = Map.get(params, "filter", %{})

    sort = Map.get(params, "sort", %{})

    %{page: unreviewed_submissions, pagination: unreviewed_pagination} =
      Submissions.all_unreviewed_by_submitter_id(
        user.id,
        page: String.to_integer(params["unreviewed"]["page"] || "1"),
        per: 5
      )

    %{page: submissions, pagination: pagination} =
      Submissions.all_submissible_by_submitter_id(user.id,
        filter: filter,
        sort: sort,
        page: page,
        per: per
      )

    conn
    |> assign(:user, user)
    |> assign(:submissions, submissions)
    |> assign(:pagination, pagination)
    |> assign(:unreviewed_submissions, unreviewed_submissions)
    |> assign(:unreviewed_pagination, unreviewed_pagination)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> render("index.html")
  end

  def managed_submissions(
        conn,
        params = %{"challenge_id" => challenge_id, "phase_id" => phase_id}
      ) do
    %{current_user: user} = conn.assigns
    %{page: page, per: per} = conn.assigns

    {:ok, challenge} = Challenges.get(challenge_id)
    {:ok, phase} = Phases.get(phase_id)

    filter = Map.get(params, "filter", %{})
    sort = Map.get(params, "sort", %{})

    %{page: submissions, pagination: pagination} =
      Submissions.all_by_phase_with_manager_id(phase_id,
        filter: filter,
        sort: sort,
        page: page,
        per: per
      )

    conn
    |> assign(:user, user)
    |> assign(:challenge, challenge)
    |> assign(:phase, phase)
    |> assign(:submissions, submissions)
    |> assign(:pagination, pagination)
    |> assign(:filter, filter)
    |> assign(:sort, sort)
    |> render("index_managed.html")
  end

  def show(conn, params = %{"id" => _id}) do
    %{current_user: user, current_submission: submission, page: page} = conn.assigns

    filter = Map.get(params, "filter", %{})
    sort = Map.get(params, "sort", %{})

    with {:ok, phase} <- Phases.get(submission.phase_id),
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
    else
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Submission not found")
        |> redirect_by_user_type(user, submission)
    end
  end

  def new(conn, %{"challenge_id" => challenge_id, "phase_id" => phase_id}) do
    %{current_user: user} = conn.assigns
    {:ok, challenge} = Challenges.get(challenge_id)

    with true <- Accounts.has_admin_access?(user),
         true <- challenge.sub_status != "archived" do
      phase =
        Enum.find(challenge.phases, fn %{id: id} ->
          id == String.to_integer(phase_id)
        end)

      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:phase, phase)
      |> assign(:action, action_name(conn))
      |> assign(:changeset, Submissions.new())
      |> assign(:navbar_text, "Create submission")
      |> render("new.html")
    else
      _ ->
        conn
        |> put_flash(:error, "Action not permitted")
        |> redirect(
          to:
            Routes.challenge_phase_managed_submission_path(
              conn,
              :managed_submissions,
              challenge_id,
              phase_id
            )
        )
    end
  end

  def new(conn, %{"challenge_id" => challenge_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, challenge} <- Challenges.get(challenge_id),
         {:ok, phase} <- Challenges.current_phase(challenge) do
      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:phase, phase)
      |> assign(:action, action_name(conn))
      |> assign(:changeset, Submissions.new())
      |> assign(:navbar_text, "Create submission")
      |> render("new.html")
    else
      {:error, :no_current_phase} ->
        {:ok, challenge} = Challenges.get(challenge_id)

        conn
        |> redirect(external: ChallengeView.public_details_url(challenge))

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Challenge not found")
        |> redirect(external: ChallengeView.public_index_url())
    end
  end

  def create(
        conn,
        %{
          "challenge_id" => challenge_id,
          "phase_id" => phase_id,
          "action" => action,
          "submission" => submission_params
        }
      ) do
    %{current_user: current_user} = conn.assigns
    {:ok, challenge} = Challenges.get(challenge_id)

    phase =
      Enum.find(challenge.phases, fn %{id: id} ->
        id == String.to_integer(phase_id)
      end)

    {submitter, submission_params} = get_params_by_current_user(submission_params, current_user)

    case action do
      "draft" ->
        case Submissions.create_draft(submission_params, submitter, challenge, phase) do
          {:ok, submission} ->
            conn
            |> assign(:phase_id, phase.id)
            |> put_flash(:info, "Submission draft saved")
            |> redirect(to: Routes.submission_path(conn, :edit, submission.id))

          {:error, changeset} ->
            create_error(conn, changeset, current_user, challenge, phase)
        end

      "review" ->
        case Submissions.create_review(submission_params, submitter, challenge, phase) do
          {:ok, submission} ->
            conn
            |> redirect(to: Routes.submission_path(conn, :show, submission.id))

          {:error, changeset} ->
            create_error(conn, changeset, current_user, challenge, phase)
        end
    end
  end

  defp create_error(conn, changeset, user, challenge, phase) do
    conn
    |> assign(:user, user)
    |> assign(:challenge, challenge)
    |> assign(:phase, phase)
    |> assign(:path, Routes.challenge_path(conn, :create))
    |> assign(:action, action_name(conn))
    |> assign(:changeset, changeset)
    |> assign(:submission, nil)
    |> put_status(422)
    |> render("new.html")
  end

  def edit(conn, %{"id" => id}) do
    %{current_user: user, current_submission: submission} = conn.assigns

    with {:ok, submission} <- Submissions.allowed_to_edit(user, submission),
         {:ok, submission} <- Submissions.is_editable(user, submission) do
      conn
      |> assign(:user, user)
      |> assign(:submission, submission)
      |> assign(:challenge, submission.challenge)
      |> assign(:phase, submission.phase)
      |> assign(:action, action_name(conn))
      |> assign(:path, Routes.submission_path(conn, :update, id))
      |> assign(:changeset, Submissions.edit(submission))
      |> assign(:navbar_text, "Edit submission")
      |> render("edit.html")
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not authorized to edit this submission")
        |> redirect_by_user_type(user, submission)

      {:error, :not_editable} ->
        conn
        |> put_flash(:error, "Submission cannot be edited")
        |> redirect_by_user_type(user, submission)
    end
  end

  def update(conn, %{"id" => id, "action" => "draft", "submission" => submission_params}) do
    %{current_user: user, current_submission: submission} = conn.assigns

    {submitter, _submission_params} = get_params_by_current_user(submission_params, user)
    submission_params = Map.put_new(submission_params, "submitter_id", submitter.id)

    with {:ok, submission} <- Submissions.allowed_to_edit(user, submission),
         {:ok, submission} <- Submissions.is_editable(user, submission),
         true <- Submissions.has_not_been_submitted?(submission),
         {:ok, submission} <- Submissions.update_draft(submission, submission_params) do
      conn
      |> put_flash(:info, "Submission draft saved")
      |> redirect(to: Routes.submission_path(conn, :edit, submission.id))
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "Action not authorized")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, :not_editable} ->
        conn
        |> put_flash(:error, "Submission cannot be edited")
        |> redirect_by_user_type(user, submission)

      {:error, changeset} ->
        update_error(conn, changeset, user, submission)

      false ->
        conn
        |> put_flash(:error, "Submission cannot be saved as a draft")
        |> redirect(to: Routes.submission_path(conn, :edit, id))
    end
  end

  def update(conn, %{"id" => _id, "action" => "review", "submission" => submission_params}) do
    %{current_user: user, current_submission: submission} = conn.assigns

    with {:ok, submission} <- Submissions.allowed_to_edit(user, submission),
         {:ok, submission} <- Submissions.is_editable(user, submission),
         {:ok, submission} <- Submissions.update_review(submission, submission_params) do
      redirect(conn, to: Routes.submission_path(conn, :show, submission.id))
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not authorized to edit this submission")
        |> redirect_by_user_type(user, submission)

      {:error, :not_editable} ->
        conn
        |> put_flash(:error, "Submission cannot be edited")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, changeset} ->
        update_error(conn, changeset, user, submission)
    end
  end

  defp update_error(conn, changeset, user, submission) do
    conn
    |> assign(:user, user)
    |> assign(:submission, submission)
    |> assign(:challenge, submission.challenge)
    |> assign(:phase, submission.phase)
    |> assign(:action, action_name(conn))
    |> assign(:path, Routes.submission_path(conn, :update, submission.id))
    |> assign(:changeset, changeset)
    |> put_status(422)
    |> render("edit.html")
  end

  def submit(conn, %{"id" => id}) do
    %{current_user: user, current_submission: submission} = conn.assigns

    with {:ok, submission} <- Submissions.allowed_to_edit(user, submission),
         {:ok, submission} <- Submissions.is_editable(user, submission),
         {:ok, submission} <- Submissions.submit(submission, Security.extract_remote_ip(conn)) do
      conn
      |> put_flash(:info, "Submission saved")
      |> redirect(to: Routes.submission_path(conn, :show, submission.id))
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not authorized to edit this submission")
        |> redirect_by_user_type(user, submission)

      {:error, :not_editable} ->
        conn
        |> put_flash(:error, "Submission cannot be edited")
        |> redirect(to: Routes.submission_path(conn, :index))

      {:error, changeset} ->
        conn
        |> assign(:user, user)
        |> assign(:submission, submission)
        |> assign(:phase, submission.phase)
        |> assign(:action, action_name(conn))
        |> assign(:path, Routes.submission_path(conn, :update, id))
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => _id}) do
    %{current_user: user, current_submission: submission} = conn.assigns

    with {:ok, submission} <- Submissions.allowed_to_delete(user, submission),
         {:ok, submission} <- Submissions.delete(submission) do
      conn
      |> put_flash(:info, "Submission deleted")
      |> redirect_by_user_type(user, submission)
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not authorized to delete this submission")
        |> redirect_by_user_type(user, submission)

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect_by_user_type(user, submission)
    end
  end

  def redirect_by_user_type(conn, %{id: id}, %{submitter_id: id}),
    do: redirect(conn, to: Routes.submission_path(conn, :index))

  def redirect_by_user_type(conn, user, submission) do
    if Accounts.has_admin_access?(user) do
      redirect(conn,
        to:
          Routes.challenge_phase_managed_submission_path(
            conn,
            :managed_submissions,
            submission.challenge_id,
            submission.phase_id
          )
      )
    else
      redirect(conn, to: Routes.submission_path(conn, :index))
    end
  end

  defp get_params_by_current_user(submission_params, current_user) do
    case Accounts.has_admin_access?(current_user) do
      true ->
        {:ok, submitter} = Accounts.get_by_email(submission_params["solver_addr"])
        submission_params = Map.merge(submission_params, %{"manager_id" => current_user.id})
        {submitter, submission_params}

      false ->
        {:ok, submitter} = Accounts.get_by_email(current_user.email)
        {submitter, submission_params}
    end
  end
end
