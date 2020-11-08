defmodule ChallengeGov.Phases do
  @moduledoc """
  Context for Phases
  """

  alias ChallengeGov.Repo
  alias ChallengeGov.Challenges.Phase
  alias Stein.Filter

  import Ecto.Query

  @behaviour Stein.Filter

  def all(opts \\ []) do
    Phase
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.all()
  end

  def get(id) do
    Phase
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      phase ->
        {:ok, phase}
    end
  end

  def is_current?(%{start_date: start_date, end_date: end_date}) do
    now = DateTime.utc_now()
    now >= start_date && now <= end_date
  end

  def is_current?(_phase), do: false

  def filter_on_attribute({"challenge_id", value}, query) do
    where(query, [c], c.challenge_id == ^value)
  end

  def filter_on_attribute(_, query), do: query
end
