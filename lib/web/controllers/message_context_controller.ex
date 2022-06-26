defmodule Web.MessageContextController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses
  alias ChallengeGov.Messages
  alias ChallengeGov.Submissions

  alias Web.ChallengeView

  def index(conn, params) do
    %{current_user: user} = conn.assigns
    MessageContexts.sync_for_user(user)

    filter = Map.get(params, "filter", %{})
    message_context_statuses = MessageContextStatuses.all_for_user(user, filter: filter)

    challenges = MessageContextStatuses.get_challenges_for_user(user)

    conn
    |> assign(:user, user)
    |> assign(:message_context_statuses, message_context_statuses)
    |> assign(:challenges, challenges)
    |> assign(:filter, filter)
    |> render("index.html")
  end

  def drafts(conn, params) do
    %{current_user: user} = conn.assigns
    MessageContexts.sync_for_user(user)

    filter = Map.get(params, "filter", %{})

    draft_messages = Messages.all_drafts_for_user(user, filter: filter)

    challenges = MessageContextStatuses.get_challenges_for_user(user)

    conn
    |> assign(:user, user)
    |> assign(:draft_messages, draft_messages)
    |> assign(:challenges, challenges)
    |> assign(:filter, filter)
    |> render("drafts.html")
  end

  def show(conn, %{"id" => id, "message_id" => message_id}) do
    %{current_user: user} = conn.assigns
    MessageContexts.sync_for_user(user)

    {:ok, message_context} = MessageContexts.get(id)
    {:ok, message_context} = MessageContexts.check_solver_child_context(user, message_context)

    messages = MessageContexts.maybe_merge_parent_messages(message_context)

    with {:ok, message_context_status} <- MessageContextStatuses.get(user, message_context),
         {:ok, _message_context_status} <-
           MessageContextStatuses.mark_read(message_context_status),
         {:ok, draft_message} <- Messages.get_draft(message_id),
         {:ok, draft_message} <- Messages.can_view_draft?(user, draft_message),
         true <- MessageContexts.user_can_view?(user, message_context) do
      conn
      |> assign(:user, user)
      |> assign(:changeset, Messages.edit(draft_message))
      |> assign(:message_context, message_context)
      |> assign(:messages, messages)
      |> render("show.html")
    else
      _ ->
        conn
        |> redirect(to: Routes.message_context_path(conn, :show, message_context))
    end
  end

  def show(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns
    MessageContexts.sync_for_user(user)

    {:ok, message_context} = MessageContexts.get(id)
    {:ok, message_context} = MessageContexts.check_solver_child_context(user, message_context)

    message_changeset = Messages.new()

    messages = MessageContexts.maybe_merge_parent_messages(message_context)

    with {:ok, message_context_status} <- MessageContextStatuses.get(user, message_context),
         {:ok, _message_context_status} <-
           MessageContextStatuses.mark_read(message_context_status),
         true <- MessageContexts.user_can_view?(user, message_context) do
      conn
      |> assign(:user, user)
      |> assign(:changeset, message_changeset)
      |> assign(:message_context, message_context)
      |> assign(:messages, messages)
      |> render("show.html")
    else
      _ ->
        conn
        |> put_flash(:error, "You can not view that thread")
        |> redirect(to: Routes.message_context_path(conn, :index))
    end
  end

  def new(conn, %{"context" => context}) do
    %{current_user: user} = conn.assigns

    changeset = MessageContexts.new(context)
    challenges = Challenges.all_for_user_paginated(user, sort: %{})

    case MessageContexts.user_can_create?(user) do
      true ->
        conn
        |> assign(:challenges, challenges)
        |> assign(:changeset, changeset)
        |> assign(:path, Routes.message_context_path(conn, :create))
        |> render("new.html")

      false ->
        conn
        |> put_flash(:error, "You can not start a message thread")
        |> redirect(to: Routes.message_context_path(conn, :index))
    end
  end

  def create(conn, %{"message_context" => context_params = %{"audience" => "individual"}}) do
    {:ok, challenge} = Challenges.get(context_params["context_id"])

    conn
    |> redirect(to: ChallengeView.manage_submissions_initial_path(conn, challenge))
  end

  def create(conn, %{"message_context" => context_params}) do
    %{current_user: user} = conn.assigns

    case MessageContexts.user_can_create?(user) do
      true ->
        {:ok, message_context} = MessageContexts.create(context_params)

        conn
        |> redirect(to: Routes.message_context_path(conn, :show, message_context.id))

      false ->
        conn
        |> put_flash(:error, "You can not start a message thread")
        |> redirect(to: Routes.message_context_path(conn, :index))
    end
  end

  def bulk_new(conn, %{"cid" => challenge_id, "sid" => submission_ids}) do
    %{current_user: _user} = conn.assigns

    conn
    |> assign(:challenge_id, challenge_id)
    |> assign(:submission_ids, submission_ids)
    |> assign(:changeset, conn)
    |> assign(:path, Routes.message_context_path(conn, :bulk_message, challenge_id))
    |> render("new_multi_submission_message.html")
  end

  def bulk_new(conn, %{"cid" => challenge_id}) do
    %{current_user: _user} = conn.assigns

    {:ok, challenge} = Challenges.get(challenge_id)

    conn
    |> put_flash(:error, "Please select submissions to message")
    |> redirect(to: ChallengeView.manage_submissions_initial_path(conn, challenge))
    |> render("new_multi_submission_message.html")
  end

  def bulk_message(
        conn,
        %{
          "challenge_id" => challenge_id,
          "submission_ids" => submission_ids,
          "content" => content,
          "content_delta" => content_delta
        }
      ) do
    %{current_user: user} = conn.assigns

    solver_ids = Submissions.solver_ids_from_submission_ids(submission_ids)

    message_content = %{
      "content" => content,
      "content_delta" => content_delta,
      "status" => "sent"
    }

    MessageContexts.multi_submission_message(user, challenge_id, solver_ids, message_content)
    send_email(solver_ids, message_content["content"])

    conn
    |> put_flash(:info, "Message sent to selected submissions")
    |> redirect(to: Routes.message_context_path(conn, :index))
  end

  defp send_email(solver_ids, message_content),
    do: Messages.maybe_send_email(solver_ids, message_content)
end
