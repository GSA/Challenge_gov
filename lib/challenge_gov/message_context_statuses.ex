defmodule ChallengeGov.MessageContextStatuses do
  @moduledoc """
  Context for MessageContextStatuses
  """
  alias ChallengeGov.Repo

  alias ChallengeGov.Messages.MessageContextStatus

  def get(user, context) do
    MessageContextStatus
    |> Repo.get_by(user_id: user.id, message_context_id: context.id)
    |> case do
      nil ->
        {:error, :not_found}

      message_context_status ->
        {:ok, message_context_status}
    end
  end

  def create(user, context) do
    %MessageContextStatus{}
    |> MessageContextStatus.create_changeset(user, context)
    |> Repo.insert()
  end
end
