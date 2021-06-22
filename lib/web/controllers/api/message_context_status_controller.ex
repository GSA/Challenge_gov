defmodule Web.Api.MessageContextStatusController do
  use Web, :controller

  alias ChallengeGov.MessageContextStatuses

  action_fallback(Web.FallbackController)

  def toggle_starred(conn, %{"id" => id}) do
    {:ok, message_context_status} = MessageContextStatuses.get(id)
    {:ok, message_context_status} = MessageContextStatuses.toggle_starred(message_context_status)

    conn
    |> put_status(:ok)
    |> assign(:message_context_status, message_context_status)
    |> render("star.json")
  end
end
