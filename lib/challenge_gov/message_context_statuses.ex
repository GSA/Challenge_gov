defmodule ChallengeGov.MessageContextStatuses do
  @moduledoc """
  Context for MessageContextStatuses
  """
  import Ecto.Query

  alias Ecto.Multi
  alias ChallengeGov.Repo

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Submissions
  alias ChallengeGov.Messages.MessageContextStatus

  def all_for_user(user) do
    MessageContextStatus
    |> where([mcs], mcs.user_id == ^user.id)
    |> Repo.all()
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

  def get_user_ids_for_message_context(message_context = %{context: "challenge"}) do
    %{context_id: context_id, audience: _audience} = message_context

    {:ok, challenge} = Challenges.get(context_id)

    admin_user_ids =
      Accounts.all_admins()
      |> Enum.map(& &1.id)

    challenge_owner_user_ids =
      challenge.challenge_owners
      |> Enum.map(& &1.user_id)

    solver_user_ids =
      %{filter: %{"challenge_id" => context_id}}
      |> Submissions.all()
      |> Enum.map(& &1.submitter_id)

    user_ids = admin_user_ids ++ challenge_owner_user_ids ++ solver_user_ids

    user_ids
  end
end
