defmodule ChallengeGov.Messages do
  @moduledoc """
  Context for Messages
  """
  @behaviour Stein.Filter
  import Ecto.Query

  alias Ecto.Multi
  alias ChallengeGov.Repo

  alias ChallengeGov.Emails
  alias ChallengeGov.Mailer
  alias ChallengeGov.MessageContexts
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

  def all_drafts_for_user(user, opts \\ []) do
    case user.role do
      "challenge_manager" ->
        Message
        |> join(:inner, [m], mc in assoc(m, :context), as: :context)
        |> join(:inner, [m], a in assoc(m, :author), as: :author)
        |> join(:inner, [context: mc], mcs in assoc(mc, :statuses),
          on: mcs.user_id == ^user.id,
          as: :context_statuses
        )
        |> preload([:author, :context])
        |> order_by([m], desc: m.updated_at)
        |> where([m], m.status == "draft")
        |> where([author: a], a.id == ^user.id or a.role == "challenge_manager")
        |> Repo.all()

      _ ->
        filter =
          opts[:filter]
          |> Map.merge(%{
            "author_id" => user.id,
            "status" => "draft"
          })

        all(preload: [:author, :context], filter: filter)
    end
  end

  def get(id) do
    Message
    |> Repo.get_by(id: id)
    |> case do
      nil ->
        {:error, :not_found}

      message ->
        {:ok, message}
    end
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
    {:ok, context} = MessageContexts.maybe_switch_to_isolated_context(user, context)

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

  def can_view_draft?(user, message) do
    message = Repo.preload(message, context: [:parent])

    if user.id == message.author_id or
         MessageContexts.user_related_to_context?(user, message.context) do
      {:ok, message}
    else
      {:error, :cant_view_draft}
    end
  end

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
    if has_named_binding?(query, :context) do
      query
      # |> join(:inner, [m], mc in assoc(m, :context))
      |> where([context: mc], mc.context == "challenge" and mc.context_id == ^value)
    else
      query
      |> join(:inner, [m], mc in assoc(m, :context))
      |> where([m, mc], mc.context == "challenge" and mc.context_id == ^value)
    end
  end

  def maybe_send_email(
        message = %{
          author_id: author_id,
          context: %{context: "solver", context_id: original_recipient_id}
        }
      )
      when author_id != original_recipient_id do
    recipient = ChallengeGov.Repo.get!(ChallengeGov.Accounts.User, original_recipient_id)
    content = scrub(message.content)

    recipient
    |> Emails.message_center_new_message(content)
    |> Mailer.deliver_later()
  end

  def maybe_send_email(_), do: nil

  def maybe_send_email(solver_ids, message_content) when is_list(solver_ids) do
    Enum.map(solver_ids, fn solver_id ->
      recipient = ChallengeGov.Repo.get!(ChallengeGov.Accounts.User, solver_id)
      content = scrub(message_content)

      recipient
      |> Emails.message_center_new_message(content)
      |> Mailer.deliver_later()
    end)
  end

  def maybe_send_email(_, _), do: nil

  defp scrub(data), do: String.replace(data, ~r/<(?!\/?a(?=>|\s.*>))\/?.*?>/, " ")
end
