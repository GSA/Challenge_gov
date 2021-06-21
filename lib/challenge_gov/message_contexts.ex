defmodule ChallengeGov.MessageContexts do
  @moduledoc """
  Context for MessageContexts
  """
  alias Ecto.Multi
  alias ChallengeGov.Repo

  alias ChallengeGov.MessageContextStatuses
  alias ChallengeGov.Messages.MessageContext

  def get(id) do
    MessageContext
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      message_context ->
        {:ok, message_context}
    end
  end

  def get(context, context_id, audience) do
    MessageContext
    |> Repo.get_by(context: context, context_id: context_id, audience: audience)
    |> case do
      nil ->
        {:error, :not_found}

      message_context ->
        {:ok, message_context}
    end
  end

  def new(context) do
    %MessageContext{}
    |> MessageContext.changeset(%{context: context})
  end

  def create(params) do
    %{"context" => context, "context_id" => context_id, "audience" => audience} = params

    Multi.new()
    |> Multi.run(:message_context, fn _repo, _changes ->
      case get(context, context_id, audience) do
        {:ok, message_context} ->
          {:ok, message_context}

        {:error, :not_found} ->
          %MessageContext{}
          |> MessageContext.changeset(params)
          |> Repo.insert()
      end
    end)
    |> create_message_context_statuses
    |> Repo.transaction()
    |> case do
      {:ok, %{message_context: message_context}} ->
        {:ok, message_context}

      error ->
        error
    end
  end

  defp create_message_context_statuses(multi) do
    multi
    |> Multi.merge(fn %{message_context: message_context} ->
      MessageContextStatuses.create_all_for_message_context(message_context)
    end)
  end
end
