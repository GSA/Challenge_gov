defmodule Web.SubmissionInviteController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.Phases
  alias ChallengeGov.Solutions
  alias ChallengeGov.SubmissionInvites

  plug(
    Web.Plugs.EnsureRole,
    [:super_admin, :admin, :challenge_owner] when action not in [:show, :accept]
  )

  def index(conn, %{"phase_id" => phase_id}) do
    %{current_user: user} = conn.assigns

    with {:ok, phase} <- Phases.get(phase_id),
         {:ok, challenge} <- Challenges.get(phase.challenge_id),
         {:ok, challenge} <- Challenges.allowed_to_edit(user, challenge) do
      submissions = Solutions.all(filter: %{"phase_id" => phase_id, "judging_status" => "winner"})

      conn
      |> assign(:user, user)
      |> assign(:challenge, challenge)
      |> assign(:submissions, submissions)
      |> render("index.html")
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to view this page")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, submission_invite} <- SubmissionInvites.get(id),
         {:ok, challenge} <- Challenges.get(submission_invite.solution.challenge_id),
         {:ok, _challenge} <- Challenges.allowed_to_edit(user, challenge) do
      conn
      |> assign(:user, user)
      |> assign(:submission_invite, submission_invite)
      |> render("show.html")
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to view this page")
        |> redirect(to: Routes.challenge_path(conn, :index))
    end
  end

  def create(conn, params = %{"phase_id" => phase_id, "submission_ids" => submission_ids}) do
    %{current_user: user} = conn.assigns

    with {:ok, phase} <- Phases.get(phase_id),
         {:ok, challenge} <- Challenges.get(phase.challenge_id),
         {:ok, _challenge} <- Challenges.allowed_to_edit(user, challenge),
         {:ok, _submission_invites} <- SubmissionInvites.bulk_create(params, submission_ids) do
      conn
      |> put_flash(:info, "Invites sent")
      |> redirect(to: Routes.submission_invite_path(conn, :index, phase_id))
    else
      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to send invites for this challenge")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  def accept(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, submission_invite} <- SubmissionInvites.get(id),
         {:ok, submission_invite} <- SubmissionInvites.accept(submission_invite) do
      conn
      |> assign(:user, user)
      |> assign(:submission_invite, submission_invite)
      |> render("show.html")
    else
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not accept invite")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  def revoke(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    with {:ok, submission_invite} <- SubmissionInvites.get(id),
         {:ok, submission_invite} <- SubmissionInvites.revoke(submission_invite) do
      conn
      |> assign(:user, user)
      |> assign(:submission_invite, submission_invite)
      |> render("show.html")
    else
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Could not revoke invite")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end
end
