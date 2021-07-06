defmodule Web.MessageContextStatusController do
  use Web, :controller

  alias ChallengeGov.MessageContextStatuses

  def mark_read(conn, %{"id" => id}) do
    {:ok, message_context_status} = MessageContextStatuses.get(id)
    {:ok, _message_context_status} = MessageContextStatuses.mark_read(message_context_status)

    conn
    |> put_flash(:info, "Message thread marked as read")
    |> redirect(to: Routes.message_context_path(conn, :index))
  end

  def mark_unread(conn, %{"id" => id}) do
    {:ok, message_context_status} = MessageContextStatuses.get(id)
    {:ok, _message_context_status} = MessageContextStatuses.mark_unread(message_context_status)

    conn
    |> put_flash(:info, "Message thread marked as unread")
    |> redirect(to: Routes.message_context_path(conn, :index))
  end

  def archive(conn, %{"id" => id}) do
    {:ok, message_context_status} = MessageContextStatuses.get(id)
    {:ok, _message_context_status} = MessageContextStatuses.archive(message_context_status)

    conn
    |> put_flash(:info, "Message thread archived")
    |> redirect(to: Routes.message_context_path(conn, :index))
  end

  def unarchive(conn, %{"id" => id}) do
    {:ok, message_context_status} = MessageContextStatuses.get(id)
    {:ok, _message_context_status} = MessageContextStatuses.unarchive(message_context_status)

    conn
    |> put_flash(:info, "Message thread unarchived")
    |> redirect(to: Routes.message_context_path(conn, :index))
  end
end
