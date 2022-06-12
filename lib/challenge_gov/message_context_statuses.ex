defmodule ChallengeGov.MessageContextStatuses do
  @moduledoc """
  Context for MessageContextStatuses
  """
  @behaviour Stein.Filter

  import Ecto.Query

  alias Ecto.Multi
  alias ChallengeGov.Repo

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Submissions
  alias ChallengeGov.Messages.MessageContextStatus
  alias Stein.Filter

  def all_for_user(user, opts \\ []) do
    MessageContextStatus
    |> preload(context: [:messages, last_message: [:author]])
    |> join(:inner, [mcs], mc in assoc(mcs, :context))
    |> order_by([mcs, mc], desc: mc.updated_at)
    |> where([mcs], mcs.user_id == ^user.id)
    |> maybe_filter_archived(opts[:filter])
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.all()
  end

  defp maybe_filter_archived(query, %{"archived" => _}), do: query
  defp maybe_filter_archived(query, _filter), do: where(query, [mcs], mcs.archived != true)

  def get(id) do
    MessageContextStatus
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      message_context_status ->
        {:ok, message_context_status}
    end
  end

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

  def get_by_ids(user_id, context_id) do
    MessageContextStatus
    |> Repo.get_by(user_id: user_id, message_context_id: context_id)
    |> case do
      nil ->
        {:error, :not_found}

      message_context_status ->
        {:ok, message_context_status}
    end
  end

  def create(user, context) do
    %MessageContextStatus{}
    |> MessageContextStatus.create_changeset(user.id, context.id)
    |> Repo.insert()
  end

  def create_all_for_message_context(message_context) do
    message_context
    |> get_user_ids_for_message_context
    |> Enum.reduce(Multi.new(), fn user_id, multi ->
      case get_by_ids(user_id, message_context.id) do
        {:ok, _message_context} ->
          multi

        {:error, :not_found} ->
          changeset =
            MessageContextStatus.create_changeset(
              %MessageContextStatus{},
              user_id,
              message_context.id
            )

          Multi.insert(multi, {:message_context_status, user_id, message_context.id}, changeset)
      end
    end)
  end

  def get_user_ids_for_message_context(
        message_context = %{context: "challenge", audience: "challenge_managers"}
      ) do
    %{context_id: context_id, audience: _audience} = message_context

    {:ok, challenge} = Challenges.get(context_id)

    admin_user_ids =
      Accounts.all_admins()
      |> Enum.map(& &1.id)

    challenge_manager_user_ids =
      challenge.challenge_managers
      |> Enum.map(& &1.user_id)

    user_ids = admin_user_ids ++ challenge_manager_user_ids

    Enum.uniq(user_ids)
  end

  def get_user_ids_for_message_context(message_context = %{context: "challenge"}) do
    %{context_id: context_id, audience: _audience} = message_context

    {:ok, challenge} = Challenges.get(context_id)

    admin_user_ids =
      Accounts.all_admins()
      |> Enum.map(& &1.id)

    challenge_manager_user_ids =
      challenge.challenge_managers
      |> Enum.map(& &1.user_id)

    solver_user_ids =
      %{filter: %{"challenge_id" => context_id}}
      |> Submissions.all()
      |> Enum.map(& &1.submitter_id)

    message_context = Repo.preload(message_context, [:contexts])

    # Should exclude solvers that already have a child context that is one of their submissions
    solver_user_ids_to_exclude =
      message_context.contexts
      |> Enum.map(fn context ->
        {:ok, solver} = Accounts.get(context.context_id)
        solver.id
      end)

    user_ids =
      admin_user_ids ++
        challenge_manager_user_ids ++ (solver_user_ids -- solver_user_ids_to_exclude)

    Enum.uniq(user_ids)
  end

  def get_user_ids_for_message_context(message_context = %{context: "submission"}) do
    %{context_id: context_id, audience: _audience} = message_context

    {:ok, submission} = Submissions.get(context_id)
    submission = Repo.preload(submission, challenge: [:challenge_managers])

    admin_user_ids =
      Accounts.all_admins()
      |> Enum.map(& &1.id)

    challenge_manager_user_ids =
      submission.challenge.challenge_managers
      |> Enum.map(& &1.user_id)

    solver_user_ids = [submission.submitter_id]

    user_ids = admin_user_ids ++ challenge_manager_user_ids ++ solver_user_ids

    Enum.uniq(user_ids)
  end

  def get_user_ids_for_message_context(message_context = %{context: "solver"}) do
    message_context = Repo.preload(message_context, [:parent])
    %{context_id: context_id, audience: _audience} = message_context

    {:ok, challenge} = Challenges.get(message_context.parent.context_id)
    challenge = Repo.preload(challenge, [:challenge_managers])

    admin_user_ids =
      Accounts.all_admins()
      |> Enum.map(& &1.id)

    challenge_manager_user_ids =
      challenge.challenge_managers
      |> Enum.map(& &1.user_id)

    solver_user_ids = [context_id]

    user_ids = admin_user_ids ++ challenge_manager_user_ids ++ solver_user_ids

    Enum.uniq(user_ids)
  end

  def get_challenges_for_user(user) do
    MessageContextStatus
    |> join(:inner, [mcs], mc in assoc(mcs, :context))
    |> join(:inner, [mcs, mc], c in Challenge,
      on: mc.context == "challenge" and mc.context_id == c.id
    )
    |> where([mcs], mcs.user_id == ^user.id)
    |> select([mcs, mc, c], c)
    |> Repo.all()
  end

  def toggle_read(message_context_status) do
    message_context_status
    |> MessageContextStatus.changeset(%{read: !message_context_status.read})
    |> Repo.update()
  end

  def mark_read(message_context_status) do
    message_context_status
    |> MessageContextStatus.changeset(%{read: true})
    |> Repo.update()
  end

  def mark_unread(message_context_status) do
    message_context_status
    |> MessageContextStatus.changeset(%{read: false})
    |> Repo.update()
  end

  def toggle_starred(message_context_status) do
    message_context_status
    |> MessageContextStatus.changeset(%{starred: !message_context_status.starred})
    |> Repo.update()
  end

  def toggle_archived(message_context_status) do
    message_context_status
    |> MessageContextStatus.changeset(%{archived: !message_context_status.archived})
    |> Repo.update()
  end

  def archive(message_context_status) do
    message_context_status
    |> MessageContextStatus.changeset(%{archived: true})
    |> Repo.update()
  end

  def unarchive(message_context_status) do
    message_context_status
    |> MessageContextStatus.changeset(%{archived: false})
    |> Repo.update()
  end

  def has_messages?(user) do
    MessageContextStatus
    |> where([mcs], mcs.user_id == ^user.id)
    |> Repo.aggregate(:count, :id)
    |> case do
      0 -> false
      _ -> true
    end
  end

  def has_unread_messages?(user) do
    MessageContextStatus
    |> where([mcs], mcs.user_id == ^user.id)
    |> where([mcs], mcs.read == false)
    |> Repo.aggregate(:count, :id)
    |> case do
      0 -> false
      _ -> true
    end
  end

  @impl Stein.Filter
  def filter_on_attribute({"starred", value}, query) do
    query
    |> where([mcs], mcs.starred == ^value)
  end

  def filter_on_attribute({"archived", value}, query) do
    query
    |> where([mcs], mcs.archived == ^value)
  end

  def filter_on_attribute({"read", value}, query) do
    query
    |> where([mcs], mcs.read == ^value)
  end

  def filter_on_attribute({"challenge_id", value}, query) do
    query
    |> join(:inner, [mcs], mc in assoc(mcs, :context))
    |> where([mcs, mc], mc.context == "challenge" and mc.context_id == ^value)
  end
end
