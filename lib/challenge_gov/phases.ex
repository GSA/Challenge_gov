defmodule ChallengeGov.Phases do
  @moduledoc """
  Context for Phases
  """

  @behaviour Stein.Filter

  import Ecto.Query

  alias ChallengeGov.Repo
  alias ChallengeGov.Challenges.Phase
  alias ChallengeGov.Submissions
  alias Stein.Filter

  def all(opts \\ []) do
    Phase
    |> base_query
    |> order_by(asc: :start_date)
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.all()
  end

  def get(id) do
    Phase
    |> base_query
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      phase ->
        {:ok, phase}
    end
  end

  defp base_query(query) do
    query
    |> preload([:submissions, challenge: [:challenge_managers]])
  end

  def is_current?(%{start_date: nil, end_date: _}), do: false

  def is_current?(%{start_date: start_date, end_date: nil}) do
    now = DateTime.utc_now()
    DateTime.compare(now, start_date) === :gt
  end

  def is_current?(%{start_date: start_date, end_date: end_date}) do
    now = DateTime.utc_now()
    DateTime.compare(now, start_date) === :gt && DateTime.compare(now, end_date) === :lt
  end

  def is_current?(_phase), do: false

  def is_past?(%{end_date: nil}), do: false

  def is_past?(%{end_date: end_date}) do
    if end_date do
      now = DateTime.utc_now()
      DateTime.compare(now, end_date) === :gt
    end
  end

  def is_past?(_phase), do: false

  def is_future?(%{start_date: nil}), do: false

  def is_future?(%{start_date: start_date}) do
    now = DateTime.utc_now()
    DateTime.compare(now, start_date) === :lt
  end

  def is_future?(_phase), do: false

  def closed_for_challenge(challenge) do
    now = DateTime.utc_now()

    Phase
    |> where([p], p.challenge_id == ^challenge.id and p.end_date < ^now)
    |> Repo.all()
  end

  def submission_count(phase, filter \\ %{}) do
    phase
    |> Ecto.assoc(:submissions)
    |> Filter.filter(filter, Submissions)
    |> select([s], count(s))
    |> Repo.one()
  end

  def filter_on_attribute({"challenge_id", value}, query) do
    where(query, [c], c.challenge_id == ^value)
  end

  def filter_on_attribute(_, query), do: query
end
