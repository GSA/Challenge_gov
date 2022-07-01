defmodule Web.Api.MessageController do
  use Web, :controller

  alias ChallengeGov.MessageContexts
  alias ChallengeGov.Messages

  action_fallback(Web.FallbackController)

  def create(
        conn,
        %{"message_context_id" => message_context_id, "message" => message_params}
      ) do
    %{current_user: user} = conn.assigns

    {:ok, message_context} = MessageContexts.get(message_context_id)

    case MessageContexts.user_can_message?(user, message_context) do
      true ->
        {:ok, message} = Messages.create(user, message_context, message_params)
        message = ChallengeGov.Repo.preload(message, :context)
        Messages.maybe_send_email(message)

        conn
        |> put_status(:ok)
        |> assign(:user, user)
        |> assign(:message, message)
        |> render("create.json")

      false ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json")
    end
  end
end
