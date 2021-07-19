defmodule ChallengeGov.Messages do
  @moduledoc """
  Context for Messages
  """
  @behaviour Stein.Filter
  import Ecto.Query

  alias Ecto.Multi
  alias ChallengeGov.Repo

  alias ChallengeGov.Messages.Message
  alias ChallengeGov.Messages.MessageContextStatus
  alias Stein.Filter

  def all(opts \\ []) do
    Message
    |> preload(^opts[:preload])
    |> order_by([m], desc: m.updated_at)
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.all()
  end

  def get_draft(id) do
    Message
    |> Repo.get_by(id: id, status: "draft")
    |> case do
      nil ->
        {:error, :not_found}

      draft_message ->
        {:ok, draft_message}
    end
  end

  def new(), do: Message.changeset(%Message{})

  def edit(message), do: Message.changeset(message)

  def create(user, context, params) do
    Multi.new()
    |> Multi.run(:find_message, fn repo, _changes ->
      message_id = Map.get(params, "id", nil)

      case message_id do
        nil ->
          {:ok, %Message{}}

        id ->
          {:ok, repo.get(Message, id)}
      end
    end)
    |> Multi.insert_or_update(:message, fn %{find_message: message} ->
      Message.create_changeset(message, user, context, params)
    end)
    |> Multi.run(:cache_last_message, fn _repo, %{message: message} ->
      maybe_cache_last_message(message, context)
    end)
    |> Multi.run(:message_context_statuses, fn _repo, %{message: message} ->
      maybe_set_recipients_unread(message)
    end)
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

  defp maybe_cache_last_message(message = %{status: "sent"}, context) do
    context
    |> Repo.preload([:last_message])
    |> Ecto.Changeset.change(last_message: message)
    |> Repo.update()
  end

  defp maybe_cache_last_message(%{status: "draft"}, context), do: {:ok, context}

  defp maybe_set_recipients_unread(message = %{status: "sent"}) do
    result =
      MessageContextStatus
      |> where([mcs], mcs.message_context_id == ^message.message_context_id)
      |> update(set: [read: false])
      |> Repo.update_all([])

    {:ok, result}
  end

  defp maybe_set_recipients_unread(%{status: "draft"}), do: {:ok, nil}

  @impl Stein.Filter
  def filter_on_attribute({"status", value}, query) do
    query
    |> where([m], m.status == ^value)
  end

  def filter_on_attribute({"author_id", value}, query) do
    query
    |> where([m], m.author_id == ^value)
  end

  def filter_on_attribute({"challenge_id", value}, query) do
    query
    |> join(:inner, [m], mc in assoc(m, :context))
    |> where([m, mc], mc.context == "challenge" and mc.context_id == ^value)
  end
end
