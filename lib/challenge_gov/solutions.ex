defmodule ChallengeGov.Solutions do
  @moduledoc """
  Context for Solutions
  """

  alias ChallengeGov.Solutions.Solution
  alias ChallengeGov.SolutionDocuments
  alias ChallengeGov.Repo
  alias Stein.Filter
  alias Stein.Pagination

  import Ecto.Query

  @behaviour Stein.Filter

  def all(opts \\ []) do
    query =
      Solution
      |> base_preload
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
    |> base_preload
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      solution ->
        {:ok, solution}
    end
  end

  defp base_preload(solution) do
    solution
    |> preload([:submitter, :challenge, :documents])
  end

  def new do
    %Solution{}
    |> new_form_preload
    |> Solution.changeset(%{})
  end

  defp new_form_preload(solution) do
    Repo.preload(solution, [:submitter, :challenge, :documents])
  end

  def create_draft(params, user, challenge) do
    params = attach_default_multi_params(params)
    changeset = Solution.draft_changeset(%Solution{}, params, user, challenge)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:solution, changeset)
    |> attach_documents(params, user)
    |> Repo.transaction()
    |> case do
      {:ok, %{solution: solution}} ->
        {:ok, solution}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def create_review(params, user, challenge) do
    params = attach_default_multi_params(params)
    changeset = Solution.review_changeset(%Solution{}, params, user, challenge)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:solution, changeset)
    |> attach_documents(params, user)
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

  def update_draft(solution, params) do
    params = attach_default_multi_params(params)
    changeset = Solution.update_draft_changeset(solution, params)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:solution, changeset)
    |> attach_documents(params, solution.submitter)
    |> Repo.transaction()
    |> case do
      {:ok, %{solution: solution}} ->
        {:ok, solution}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def update_review(solution, params) do
    params = attach_default_multi_params(params)
    changeset = Solution.update_review_changeset(solution, params)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:solution, changeset)
    |> attach_documents(params, solution.submitter)
    |> Repo.transaction()
    |> case do
      {:ok, %{solution: solution}} ->
        {:ok, solution}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  defp attach_default_multi_params(params) do
    Map.put_new(params, "documents", [])
  end

  def submit(solution) do
    solution
    |> Solution.submit_changeset()
    |> Repo.update()
  end

  def allowed_to_edit?(user, solution) do
    if solution.submitter_id === user.id do
      {:ok, solution}
    else
      {:error, :not_permitted}
    end
  end

  def delete(solution, user) do
    if allowed_to_delete?(solution, user) do
      soft_delete(solution)
    else
      {:error, :not_permitted}
    end
  end

  defp soft_delete(solution) do
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

  defp allowed_to_delete?(_solution, _user) do
    true
  end

  # Attach solution document functions
  defp attach_documents(multi, %{documents: documents}, _user) do
    attach_documents(multi, %{"documents" => documents})
  end

  defp attach_documents(multi, %{"documents" => documents}, user) do
    documents
    |> Enum.with_index()
    |> Enum.reduce(multi, fn document, multi ->
      {document, index} = document

      Ecto.Multi.run(multi, {:document, index}, fn _repo, changes ->
        user
        |> SolutionDocuments.upload(document)
        |> attach_document(changes.solution)
      end)
    end)
  end

  #   IO.inspect file
  #   file = Stein.Storage.prep_file(file)
  #   IO.inspect file
  #   meta = [
  #     {:content_disposition, ~s{attachment; filename="#{file.filename}"}}
  #   ]
  #   key = UUID.uuid4()
  #   path = SolutionDocuments.document_path(key, file.extension)
  #   Stein.Storage.upload(file, path, meta: meta)
  #   Ecto.Multi.run(multi, :document, fn _repo, changes ->
  #     changes.solution
  #     |> ChallengeGov.Solutions.Document.create_changeset(file, key)
  #     |> attach_document(changes.solution)
  #     |> Repo.insert
  #   end)
  #   # IO.inspect documents
  #   # # Enum.reduce(ids, multi, fn document_id, multi ->
  #   #   Ecto.Multi.run(multi, :document, fn _repo, changes ->
  #   #     ids
  #   #     |> SolutionDocuments.upload(user)
  #   #     |> attach_document(changes.solution)
  #   #   end)
  #   # # end)
  # end

  defp attach_documents(multi, _params), do: multi

  defp attach_document({:ok, document}, solution) do
    SolutionDocuments.attach_to_solution(document, solution, "")
  end

  defp attach_document(result, _solution), do: result

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

    where(
      query,
      [s],
      ilike(s.title, ^value) or ilike(s.brief_description, ^value) or ilike(s.description, ^value) or
        ilike(s.external_url, ^value) or ilike(s.status, ^value)
    )
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
