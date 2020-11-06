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

  def filter_on_attribute({"challenge_id", value}, query) do
    where(query, [c], c.challenge_id == ^value)
  end

  def filter_on_attribute(_, query), do: query
end
