defmodule ChallengeGov.Messages do
  @moduledoc """
  Context for Messages
  """
  alias Ecto.Multi
  alias ChallengeGov.Repo

  alias ChallengeGov.MessageContexts
  alias ChallengeGov.MessageContextStatuses

  alias ChallengeGov.Messages.Message

  def create(user, context, context_id, params) do
    Multi.new()
    |> maybe_create_context(context, context_id)
    |> maybe_create_context_status(user)
    |> Multi.insert(:message, fn %{message_context: message_context} ->
      Message.create_changeset(%Message{}, user, message_context, params)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{message: message}} ->
        {:ok, message}

      {:error, _, _, _} ->
        {:error, :something_went_wrong}
    end
  end

  defp maybe_create_context(multi, context, context_id) do
    Multi.run(multi, :message_context, fn _repo, _changes ->
      case MessageContexts.get(context, context_id) do
        {:ok, message_context} ->
          {:ok, message_context}

        {:error, :not_found} ->
          MessageContexts.create(context, context_id)
      end
    end)
  end

  defp maybe_create_context_status(multi, user) do
    Multi.run(multi, :message_context_status, fn _repo, %{message_context: context} ->
      case MessageContextStatuses.get(user, context) do
        {:ok, message_context} ->
          {:ok, message_context}

        {:error, :not_found} ->
          MessageContextStatuses.create(user, context)
      end
    end)
  end
end
