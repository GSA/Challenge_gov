defmodule ChallengeGov.Solutions do
  @moduledoc """
  Context for Solutions
  """  
  
  alias ChallengeGov.Solutions.Solution
  alias ChallengeGov.Repo
  alias Stein.Filter
  alias Stein.Pagination

  import Ecto.Query

  @behaviour Stein.Filter

  def all(opts \\ []) do
    IO.inspect "ALL"
    IO.inspect opts

    query =
      Solution
      |> preload([:submitter, :challenge])
      |> where([s], is_nil(s.deleted_at))
      |> Filter.filter(opts[:filter], __MODULE__)

    if !is_nil(opts[:page]) and !is_nil(opts[:per]) do
      Pagination.paginate(Repo, query, %{page: opts[:page], per: opts[:per]})
    else
      Repo.all(query)
    end
  end

  def get(id) do
    Solution
    |> where([s], is_nil(s.deleted_at))
    |> where([s], s.id == ^id)
    |> preload([
      :submitter,
      :challenge,
    ])
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      solution ->
        {:ok, solution}
    end
  end

  def new do
    Solution.changeset(%Solution{}, %{})
  end

  def create(%{"action" => action, "solution" => params}, user) do
    changeset = changeset_for_action(%Solution{}, params, action)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:solution, changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{solution: solution}} ->
        {:ok, solution}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def edit(solution) do
    Solution.changeset(solution, %{})
  end

  def update(solution, %{"action" => action, "solution" => params}, user) do    
    changeset = changeset_for_action(solution, params, action)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:solution, changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{solution: solution}} ->
        {:ok, solution}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end  
  
  defp changeset_for_action(struct, params, action) do
    case action do
      "draft" ->
        Solution.draft_changeset(struct, params)

      "submit" ->
        Solution.submit_changeset(struct, params)
    end
  end

  def delete(solution, user) do
    if allowed_to_delete?(solution, user) do
      soft_delete(solution, user)
    else
      {:error, :not_permitted}
    end
  end

  defp soft_delete(solution, user) do
    solution
    |> Solution.delete_changeset()
    |> Repo.update()
    |> case do
      {:ok, solution} ->
        {:ok, solution}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp allowed_to_delete?(solution, user) do
    true
  end

  @doc false
  def statuses(), do: Solution.statuses()

  @doc false
  def status_label(status) do
    status_data = Enum.find(statuses(), fn s -> s.id == status end)

    if status_data do
      status_data.label
    else
      status
    end
  end

  # BOOKMARK: Filter functions
  @impl true
  def filter_on_attribute({"search", value}, query) do
    value = "%" <> value <> "%"
    where(query, [s], ilike(s.title, ^value) or ilike(s.brief_description, ^value) or ilike(s.description, ^value) or ilike(s.external_url, ^value) or ilike(s.status, ^value))
  end

  def filter_on_attribute({"submitter_id", value}, query) do
    where(query, [c], c.submitter_id == ^value)
  end

  def filter_on_attribute({"challenge_id", value}, query) do
    where(query, [c], c.challenge_id == ^value)
  end

  def filter_on_attribute({"title", value}, query) do
    value = "%" <> value <> "%"
    where(query, [s], ilike(s.title, ^value))
  end

  def filter_on_attribute({"brief_description", value}, query) do
    value = "%" <> value <> "%"
    where(query, [s], ilike(s.brief_description, ^value))
  end

  def filter_on_attribute({"description", value}, query) do
    value = "%" <> value <> "%"
    where(query, [s], ilike(s.description, ^value))
  end

  def filter_on_attribute({"external_url", value}, query) do
    value = "%" <> value <> "%"
    where(query, [s], ilike(s.external_url, ^value))
  end

  def filter_on_attribute({"status", value}, query) do
    value = "%" <> value <> "%"
    where(query, [s], ilike(s.status, ^value))
  end
end