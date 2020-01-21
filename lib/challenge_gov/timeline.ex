defmodule ChallengeGov.Timeline do
  @moduledoc """
  Timeline for challenges
  """

  alias ChallengeGov.Timeline.Event
  alias ChallengeGov.Repo

  @doc """
  Get today, timezone shifted to Eastern
  """
  def today() do
    new_york = Timex.Timezone.get("America/New_York", Timex.now())

    Timex.now()
    |> Timex.Timezone.convert(new_york)
    |> Timex.to_date()
  end

  @doc """
  Changeset for a new event
  """
  def new_event(challenge) do
    challenge
    |> Ecto.build_assoc(:events)
    |> Event.create_changeset(%{})
  end

  @doc """
  Changeset for editing an event
  """
  def edit_event(event) do
    Event.create_changeset(event, %{})
  end

  @doc """
  Get an event by its ID
  """
  def get_event(id) do
    case Repo.get(Event, id) do
      nil ->
        {:error, :not_found}

      event ->
        {:ok, event}
    end
  end

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
