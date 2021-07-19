defmodule ChallengeGov.MessageContexts do
  @moduledoc """
  Context for MessageContexts
  """
  import Ecto.Query

  alias Ecto.Multi
  alias ChallengeGov.Repo

  alias ChallengeGov.Challenges
  alias ChallengeGov.MessageContextStatuses
  alias ChallengeGov.Messages.Message
  alias ChallengeGov.Messages.MessageContext

  def get(id) do
    messages_query =
      Message
      |> where([m], m.status == "sent")
      |> preload([:author])

    MessageContext
    |> preload(messages: ^messages_query)
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

  def get_context_record(message_context) do
    case message_context.context do
      "challenge" ->
        {:ok, challenge} = Challenges.get(message_context.context_id)
        challenge

      _ ->
        nil
    end
  end

  def get_last_author(message_context) do
    last_message =
      Message
      |> preload([:author])
      |> where([m], m.message_context_id == ^message_context.id)
      |> last()
      |> Repo.one()

    last_author = if last_message, do: last_message.author, else: nil

    {:ok, last_author}
  end
end
