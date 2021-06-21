defmodule Web.MessageContextController do
  use Web, :controller

  alias ChallengeGov.Challenges
  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses

  def index(conn, _params) do
    %{current_user: user} = conn.assigns

    message_context_statuses = MessageContextStatuses.all_for_user(user)

    conn
    |> assign(:message_context_statuses, message_context_statuses)
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    {:ok, message_context} = MessageContexts.get(id)

    conn
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
