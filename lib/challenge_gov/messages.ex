defmodule ChallengeGov.Messages do
  @moduledoc """
  Context for Messages
  """
  import Ecto.Query

  alias Ecto.Multi
  alias ChallengeGov.Repo

  alias ChallengeGov.Messages.Message
  alias ChallengeGov.Messages.MessageContextStatus

  def new(), do: Message.changeset(%Message{})

  def create(user, context, params) do
    message_changeset = Message.create_changeset(%Message{}, user, context, params)

    message_context_status_query =
      where(MessageContextStatus, [mcs], mcs.message_context_id == ^context.id)

    Multi.new()
    |> Multi.insert(:message, message_changeset)
    |> Multi.update(:cache_last_message, fn %{message: message} ->
      context
      |> Repo.preload([:last_message])
      |> Ecto.Changeset.change(last_message: message)
    end)
    |> Multi.update_all(:message_context_statuses, message_context_status_query,
      set: [read: false]
    )
    |> Multi.update(:author_message_context_status, fn _changes ->
      MessageContextStatus
      |> Repo.get_by(user_id: user.id, message_context_id: context.id)
      |> Ecto.Changeset.change(read: true)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{message: message}} ->
        message = Repo.preload(message, [:author])
        {:ok, message}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end
end
