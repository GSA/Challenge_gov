defmodule Web.MessageContextController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses
  alias ChallengeGov.Messages

  def index(conn, params) do
    %{current_user: user} = conn.assigns

    filter = Map.get(params, "filter", %{})
    message_context_statuses = MessageContextStatuses.all_for_user(user, filter: filter)

    challenges = MessageContextStatuses.get_challenges_for_user(user)

    conn
    |> assign(:message_context_statuses, message_context_statuses)
    |> assign(:challenges, challenges)
    |> assign(:filter, filter)
    |> render("index.html")
  end

  def drafts(conn, params) do
    %{current_user: user} = conn.assigns

    filter = Map.get(params, "filter", %{})

    draft_messages = Messages.all_drafts_for_user(user, filter: filter)

    challenges = MessageContextStatuses.get_challenges_for_user(user)

    conn
    |> assign(:draft_messages, draft_messages)
    |> assign(:challenges, challenges)
    |> assign(:filter, filter)
    |> render("drafts.html")
  end

  def show(conn, %{"id" => id, "message_id" => message_id}) do
    %{current_user: user} = conn.assigns

    {:ok, message_context} = MessageContexts.get(id)

    {:ok, message_context_status} = MessageContextStatuses.get(user, message_context)
    {:ok, _message_context_status} = MessageContextStatuses.mark_read(message_context_status)

    {:ok, draft_message} = Messages.get_draft(message_id)

    conn
    |> assign(:user, user)
    |> assign(:changeset, Messages.edit(draft_message))
    |> assign(:message_context, message_context)
    |> render("show.html")
  end

  def show(conn, %{"id" => id}) do
    %{current_user: user} = conn.assigns

    {:ok, message_context} = MessageContexts.get(id)

    {:ok, message_context_status} = MessageContextStatuses.get(user, message_context)
    {:ok, _message_context_status} = MessageContextStatuses.mark_read(message_context_status)

    message_changeset = Messages.new()

    conn
    |> assign(:user, user)
    |> assign(:changeset, message_changeset)
    |> assign(:message_context, message_context)
    |> render("show.html")
  end

  def new(conn, %{"context" => context}) do
    %{current_user: user} = conn.assigns

    changeset = MessageContexts.new(context)
    challenges = Challenges.all_for_user(user, sort: %{})

    conn
    |> assign(:challenges, challenges)
    |> assign(:changeset, changeset)
    |> assign(:path, Routes.message_context_path(conn, :create))
    |> render("new.html")
  end

  def create(conn, %{"message_context" => message_context}) do
    {:ok, message_context} = MessageContexts.create(message_context)

    conn
    |> redirect(to: Routes.message_context_path(conn, :show, message_context.id))
  end
end
