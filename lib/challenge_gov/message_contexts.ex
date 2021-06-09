defmodule ChallengeGov.MessageContexts do
  @moduledoc """
  Context for MessageContexts
  """
  alias ChallengeGov.Repo

  alias ChallengeGov.Messages.MessageContext

  def get(context, context_id) do
    MessageContext
    |> Repo.get_by(context: context, context_id: context_id)
    |> case do
      nil ->
        {:error, :not_found}

      message_context ->
        {:ok, message_context}
    end
  end

  def create(context, context_id) do
    %MessageContext{}
    |> MessageContext.changeset(%{context: context, context_id: context_id})
    |> Repo.insert()
  end
end
