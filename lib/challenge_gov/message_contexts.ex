defmodule ChallengeGov.MessageContexts do
  @moduledoc """
  Context for MessageContexts
  """
  import Ecto.Query

  alias Ecto.Multi
  alias ChallengeGov.Repo

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Submissions
  alias ChallengeGov.MessageContextStatuses
  alias ChallengeGov.Messages.Message
  alias ChallengeGov.Messages.MessageContext
  alias ChallengeGov.Messages.MessageContextStatus

  def sync_for_user(user) do
    case user.role do
      "super_admin" ->
        sync_for_admin(user)

      "admin" ->
        sync_for_admin(user)

      "challenge_owner" ->
        sync_for_challenge_owner(user)

      "solver" ->
        sync_for_solver(user)
    end
  end

  def sync_for_admin(user) do
    contexts = Repo.all(MessageContext)

    contexts
    |> Enum.reduce(Multi.new(), fn context, multi ->
      case MessageContextStatuses.get(user, context) do
        {:ok, _context_status} ->
          multi

        {:error, :not_found} ->
          changeset =
            MessageContextStatus.create_changeset(%MessageContextStatus{}, user.id, context.id)

          Multi.insert(multi, {:insert_context_status, user.id, context.id}, changeset)
      end
    end)
    |> Repo.transaction()
  end

  def sync_for_challenge_owner(user) do
    contexts =
      MessageContext
      |> preload([:parent, :contexts])
      |> Repo.all()

    contexts
    |> Enum.reduce(Multi.new(), fn context, multi ->
      sync_context(multi, user, context)
    end)
    |> Repo.transaction()
  end

  def sync_for_solver(user) do
    contexts =
      MessageContext
      |> preload([:parent, :contexts])
      |> Repo.all()

    contexts
    |> Enum.reduce(Multi.new(), fn context, multi ->
      sync_context(multi, user, context)
    end)
    |> Repo.transaction()
  end

  def sync_context(multi, user = %{role: "challenge_owner"}, context = %{context: "challenge"}) do
    challenge = get_context_record(context)

    if Challenges.is_challenge_owner?(user, challenge) do
      case MessageContextStatuses.get(user, context) do
        {:ok, _context_status} ->
          multi

        {:error, :not_found} ->
          changeset =
            MessageContextStatus.create_changeset(%MessageContextStatus{}, user.id, context.id)

          Multi.insert(multi, {:insert_context_status, user.id, context.id}, changeset)
      end
    else
      # TODO: Do nothing or delete if exists
      multi
    end
  end

  def sync_context(multi, user = %{role: "challenge_owner"}, context = %{context: "solver"}) do
    challenge = get_context_record(context.parent)

    if Challenges.is_challenge_owner?(user, challenge) do
      case MessageContextStatuses.get(user, context) do
        {:ok, _context_status} ->
          multi

        {:error, :not_found} ->
          changeset =
            MessageContextStatus.create_changeset(%MessageContextStatus{}, user.id, context.id)

          Multi.insert(multi, {:insert_context_status, user.id, context.id}, changeset)
      end
    else
      # TODO: Do nothing or delete if exists
      multi
    end
  end

  def sync_context(multi, user = %{role: "solver"}, context = %{context: "challenge"}) do
    challenge = get_context_record(context)

    context = Repo.preload(context, [:contexts])
    user = Repo.preload(user, [:submissions])

    user_challenge_ids = Enum.map(user.submissions, & &1.challenge_id)
    context_solver_ids = Enum.map(context.contexts, & &1.context_id)

    if Enum.member?(user_challenge_ids, challenge.id) and
         !Enum.member?(context_solver_ids, user.id) do
      case MessageContextStatuses.get(user, context) do
        {:ok, _context_status} ->
          multi

        {:error, :not_found} ->
          changeset =
            MessageContextStatus.create_changeset(%MessageContextStatus{}, user.id, context.id)

          Multi.insert(multi, {:insert_context_status, user.id, context.id}, changeset)
      end
    else
      # TODO: Do nothing or delete if exists
      multi
    end
  end

  def sync_context(multi, user = %{role: "solver"}, context = %{context: "solver"}) do
    if context.context_id == user.id do
      case MessageContextStatuses.get(user, context) do
        {:ok, _context_status} ->
          multi

        {:error, :not_found} ->
          changeset =
            MessageContextStatus.create_changeset(%MessageContextStatus{}, user.id, context.id)

          Multi.insert(multi, {:insert_context_status, user.id, context.id}, changeset)
      end
    else
      # TODO: Do nothing or delete if exists
      multi
    end
  end

  def sync_context(multi, _user, _context), do: multi

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

  def get(context, context_id, audience, parent_id \\ "") do
    MessageContext
    |> where(
      [mc],
      mc.context == ^context and mc.context_id == ^context_id and mc.audience == ^audience
    )
    |> maybe_filter_parent_id(parent_id)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      message_context ->
        {:ok, message_context}
    end
  end

  defp maybe_filter_parent_id(query, ""), do: query

  defp maybe_filter_parent_id(query, parent_id),
    do: where(query, [mc], mc.parent_id == ^parent_id)

  def maybe_merge_parent_messages(message_context) do
    (message_context.messages ++ get_parent_messages(message_context))
    |> Enum.sort_by(& &1.updated_at)
  end

  def get_parent_messages(%{parent_id: nil}), do: []

  def get_parent_messages(%{parent_id: parent_id}) do
    {:ok, message_context} = get(parent_id)
    message_context.messages
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
    # |> maybe_attach_existing_child_contexts # TODO: This might not be needed anymore
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
    parent_id = Map.get(params, "parent_id", "")
    context = Map.get(params, "context")
    context_id = Map.get(params, "context_id")
    audience = Map.get(params, "audience")

    multi
    |> Multi.run(:message_context, fn _repo, _changes ->
      case get(context, context_id, audience, parent_id) do
        {:ok, message_context} ->
          {:ok, message_context}

        {:error, :not_found} ->
          %MessageContext{}
          |> MessageContext.changeset(params)
          |> Repo.insert()
      end
    end)
  end

  # TODO: These may not be needed with new solver context and changes
  # defp maybe_attach_existing_child_contexts(multi) do
  #   multi
  #   |> Multi.merge(fn %{message_context: message_context} ->
  #     case message_context.context do
  #       "challenge" ->
  #         attach_existing_child_contexts(message_context)

  #       _ ->
  #         Multi.new()
  #     end
  #   end)
  # end

  # defp attach_existing_child_contexts(message_context) do
  #   {:ok, challenge} = Challenges.get(message_context.context_id)

  #   submission_ids = Enum.map(challenge.submissions, & &1.id)

  #   Multi.new()
  #   |> Multi.update_all(
  #     :update_all,
  #     fn _changes ->
  #       MessageContext
  #       |> where([mc], mc.context == "submission" and mc.context_id in ^submission_ids)
  #     end,
  #     set: [parent_id: message_context.id]
  #   )
  # end

  defp maybe_migrate_message_context_status(multi) do
    multi
    |> Multi.merge(fn %{message_context: message_context} ->
      case message_context.context do
        "solver" ->
          migrate_existing_message_context_status(message_context)

        _ ->
          Multi.new()
      end
    end)
  end

  defp migrate_existing_message_context_status(message_context) do
    message_context = Repo.preload(message_context, [:parent])

    case message_context.parent do
      nil ->
        Multi.new()

      parent_message_context ->
        # TODO: Currently if there is a parent context then the new context is a "solver" context
        # This will eventually handle "challenge_owner" contexts as well but may work the same
        migrate_message_context_status(message_context, parent_message_context)
    end
  end

  defp migrate_message_context_status(message_context, parent_message_context) do
    case MessageContextStatuses.get_by_ids(
           message_context.context_id,
           parent_message_context.id
         ) do
      {:ok, message_context_status} ->
        Multi.update(Multi.new(), :migrate_message_context_status, fn _changes ->
          Ecto.Changeset.change(message_context_status, message_context_id: message_context.id)
        end)

      {:error, :not_found} ->
        Multi.new()
    end
  end

  defp create_message_context_statuses(multi) do
    multi
    |> Multi.merge(fn %{message_context: message_context} ->
      MessageContextStatuses.create_all_for_message_context(message_context)
    end)
  end

  def maybe_switch_to_isolated_context(
        user = %{role: "solver"},
        context = %{context: "challenge"}
      ) do
    create(%{
      "parent_id" => context.id,
      "context" => "solver",
      "context_id" => user.id,
      "audience" => "all"
    })
  end

  def maybe_switch_to_isolated_context(_user, context), do: {:ok, context}

  def get_context_record(message_context) do
    case message_context.context do
      "challenge" ->
        {:ok, challenge} = Challenges.get(message_context.context_id)
        challenge

      "challenge_owner" ->
        {:ok, challenge_owner} = Accounts.get(message_context.context_id)
        challenge_owner

      "submission" ->
        {:ok, submission} = Submissions.get(message_context.context_id)
        submission

      "solver" ->
        {:ok, solver} = Accounts.get(message_context.context_id)
        solver

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
