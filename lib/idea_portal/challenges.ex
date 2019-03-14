defmodule IdeaPortal.Challenges do
  @moduledoc """
  Context for Challenges
  """

  alias IdeaPortal.Challenges.Challenge
  alias IdeaPortal.Repo
  alias Stein.Filter

  import Ecto.Query

  @behavior Stein.Filter

  @doc false
  def focus_areas(), do: Challenge.focus_areas()

  @doc """
  Get all challenges
  """
  def all(opts \\ []) do
    query = Filter.filter(Challenge, opts[:filter], __MODULE__)

    Stein.Pagination.paginate(Repo, query, %{page: opts[:page], per: opts[:per]})
  end

  @doc """
  Get a challenge
  """
  def get(id) do
    Challenge
    |> Repo.get(id)
  end

  @doc """
  New changeset for a challenge
  """
  def new(user) do
    user
    |> Ecto.build_assoc(:challenges)
    |> Challenge.create_changeset(%{})
  end

  @doc """
  Submit a new challenge for a user
  """
  def submit(user, params) do
    user
    |> Ecto.build_assoc(:challenges)
    |> Challenge.create_changeset(params)
    |> Repo.insert()
  end

  @impl true
  def filter_on_attribute({"search", value}, query) do
    value = "%" <> value <> "%"
    where(query, [c], like(c.name, ^value) or like(c.description, ^value))
  end
  def filter_on_attribute(_, query), do: query
end
