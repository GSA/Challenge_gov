defmodule IdeaPortal.Timeline do
  @moduledoc """
  Timeline for challenges
  """

  alias IdeaPortal.Timeline.Event
  alias IdeaPortal.Repo

  @doc """
  Create a new event on the challenge timeline
  """
  def create_event(challenge, params) do
    challenge
    |> Ecto.build_assoc(:events)
    |> Event.create_changeset(params)
    |> Repo.insert()
  end

  @doc """
  Update an event
  """
  def update_event(event, params) do
    event
    |> Event.update_changeset(params)
    |> Repo.update()
  end

  @doc """
  Delete an event from the challenge timeline
  """
  def delete_event(event) do
    Repo.delete(event)
  end
end
