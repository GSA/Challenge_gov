defmodule ChallengeGov.Messages do
  @moduledoc """
  Context for Messages
  """
  alias ChallengeGov.Repo

  alias ChallengeGov.Messages.Message

  def new(), do: Message.changeset(%Message{})

  def create(user, context, params) do
    %Message{}
    |> Message.create_changeset(user, context, params)
    |> Repo.insert()
    |> case do
      {:ok, message} ->
        message = Repo.preload(message, [:author])
        {:ok, message}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
