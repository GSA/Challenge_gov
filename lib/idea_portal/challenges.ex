defmodule IdeaPortal.Challenges do
  @moduledoc """
  Context for Challenges
  """

  alias IdeaPortal.Challenges.Challenge
  alias IdeaPortal.Repo
  alias IdeaPortal.SupportingDocuments
  alias Stein.Filter

  import Ecto.Query

  @behaviour Stein.Filter

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
    case Repo.get(Challenge, id) do
      nil ->
        {:error, :not_found}

      challenge ->
        challenge = Repo.preload(challenge, [:supporting_documents, :user])
        {:ok, challenge}
    end
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
  Changeset for editing a challenge (as an admin)
  """
  def edit(challenge) do
    Challenge.update_changeset(challenge, %{})
  end

  @doc """
  Submit a new challenge for a user
  """
  def submit(user, params) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:challenge, submit_challenge(user, params))
      |> attach_documents(params)
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, :challenge, changeset, _} ->
        {:error, changeset}

      {:error, {:document, _}, _, _} ->
        user
        |> Ecto.build_assoc(:challenges)
        |> Challenge.create_changeset(params)
        |> Ecto.Changeset.add_error(:document_ids, "are invalid")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  defp submit_challenge(user, params) do
    user
    |> Ecto.build_assoc(:challenges)
    |> Challenge.create_changeset(params)
  end

  defp attach_documents(multi, %{document_ids: ids}) do
    attach_documents(multi, %{"document_ids" => ids})
  end

  defp attach_documents(multi, %{"document_ids" => ids}) do
    Enum.reduce(ids, multi, fn document_id, multi ->
      Ecto.Multi.run(multi, {:document, document_id}, fn _repo, changes ->
        document_id
        |> SupportingDocuments.get()
        |> attach_document(changes.challenge)
      end)
    end)
  end

  defp attach_documents(multi, _params), do: multi

  defp attach_document({:ok, document}, challenge) do
    SupportingDocuments.attach_to_challenge(document, challenge)
  end

  defp attach_document(result, _challenge), do: result

  @doc """
  Update a challenge
  """
  def update(challenge, params) do
    challenge
    |> Challenge.update_changeset(params)
    |> Repo.update()
  end

  @impl true
  def filter_on_attribute({"search", value}, query) do
    value = "%" <> value <> "%"
    where(query, [c], ilike(c.name, ^value) or ilike(c.description, ^value))
  end

  def filter_on_attribute({"area", value}, query) do
    where(query, [c], c.focus_area in ^value)
  end

  def filter_on_attribute(_, query), do: query
end
