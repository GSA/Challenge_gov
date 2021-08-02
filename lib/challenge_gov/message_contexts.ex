defmodule ChallengeGov.MessageContexts do
  @moduledoc """
  Context for MessageContexts
  """
  import Ecto.Query

  alias Ecto.Multi
  alias ChallengeGov.Repo

  alias ChallengeGov.Challenges
  alias ChallengeGov.Submissions
  alias ChallengeGov.MessageContextStatuses
  alias ChallengeGov.Messages.Message
  alias ChallengeGov.Messages.MessageContext

  def get(id) do
    messages_query =
      Message
      |> where([m], m.status == "sent")
      |> order_by([m], m.updated_at)
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

  @doc """
  - Try to find a context from given params. Otherwise create
  - If challenge context
    - Look for submission contexts that should be attached to it
    - Attach message statuses to the challenge context for all involved users
      prioritizing attaching to submission context for solvers if it exists
  - If submission context
    - Will use parent id if the related challenge context exists. Otherwise nil until then
    - Attach message statuses to the submission context for all involved users
    - Solver message context should just be migrated from the parent one if one was given
  """
  def create(params) do
    Multi.new()
    |> find_or_create_message_context(params)
    |> maybe_attach_existing_child_contexts
    |> maybe_migrate_message_context_status
    |> create_message_context_statuses
    |> Repo.transaction()
    |> case do
      {:ok, %{message_context: message_context}} ->
        {:ok, message_context}

      error ->
        error
    end
  end

  defp find_or_create_message_context(multi, params) do
    context = Map.get(params, "context")
    context_id = Map.get(params, "context_id")
    audience = Map.get(params, "audience")

    multi
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
  end

  defp maybe_attach_existing_child_contexts(multi) do
    multi
    |> Multi.merge(fn %{message_context: message_context} ->
      case message_context.context do
        "challenge" ->
          attach_existing_child_contexts(message_context)

        "submission" ->
          Multi.new()
      end
    end)
  end

  defp attach_existing_child_contexts(message_context) do
    {:ok, challenge} = Challenges.get(message_context.context_id)

    submission_ids = Enum.map(challenge.submissions, & &1.id)

    Multi.new()
    |> Multi.update_all(
      :update_all,
      fn _changes ->
        MessageContext
        |> where([mc], mc.context == "submission" and mc.context_id in ^submission_ids)
      end,
      set: [parent_id: message_context.id]
    )
  end

  defp maybe_migrate_message_context_status(multi) do
    multi
    |> Multi.merge(fn %{message_context: message_context} ->
      case message_context.context do
        "challenge" ->
          Multi.new()

        "submission" ->
          migrate_existing_message_context_status(message_context)
      end
    end)
  end

  defp migrate_existing_message_context_status(message_context) do
    message_context = Repo.preload(message_context, [:parent])

    case message_context.parent do
      nil ->
        Multi.new()

      parent_message_context ->
        {:ok, submission} = Submissions.get(message_context.context_id)

        {:ok, message_context_status} =
          MessageContextStatuses.get_by_ids(submission.submitter_id, parent_message_context.id)

        Multi.update(Multi.new(), :migrate_message_context_status, fn _changes ->
          Ecto.Changeset.change(message_context_status, message_context_id: message_context.id)
        end)
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
