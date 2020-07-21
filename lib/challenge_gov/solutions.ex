defmodule ChallengeGov.Solutions do
  @moduledoc """
  Context for Solutions
  """

  alias ChallengeGov.Solutions.Solution
  alias ChallengeGov.SolutionDocuments
  alias ChallengeGov.Emails
  alias ChallengeGov.Mailer
  alias ChallengeGov.Repo
  alias ChallengeGov.SecurityLogs
  alias Stein.Filter

  import Ecto.Query

  @behaviour Stein.Filter

  def all(opts \\ []) do
    Solution
    |> base_preload
    |> where([s], is_nil(s.deleted_at))
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.paginate(opts[:page], opts[:per])
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

  def base_preload(solution) do
    preload(solution, [:submitter, :documents, challenge: [:agency]])
  end

  def new do
    %Solution{}
    |> new_form_preload
    |> Solution.changeset(%{})
  end

  defp new_form_preload(solution) do
    Repo.preload(solution, [:submitter, :documents, challenge: [:agency]])
  end

  def create_draft(params, user, challenge) do
    params = attach_default_multi_params(params)
    changeset = Solution.draft_changeset(%Solution{}, params, user, challenge)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:solution, changeset)
    |> attach_documents(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{solution: solution}} ->
        {:ok, solution}

      {:error, _type, changeset, _changes} ->
        changeset = preserve_document_ids_on_error(changeset, params)
        changeset = %Ecto.Changeset{changeset | data: Repo.preload(changeset.data, [:documents])}

        {:error, changeset}
    end
  end

  def create_review(params, user, challenge) do
    params = attach_default_multi_params(params)
    changeset = Solution.review_changeset(%Solution{}, params, user, challenge)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:solution, changeset)
    |> attach_documents(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{solution: solution}} ->
        {:ok, solution}

      {:error, _type, changeset, _changes} ->
        changeset = preserve_document_ids_on_error(changeset, params)
        changeset = %Ecto.Changeset{changeset | data: Repo.preload(changeset.data, [:documents])}

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
    |> attach_documents(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{solution: solution}} ->
        {:ok, solution}

      {:error, _type, changeset, _changes} ->
        changeset = preserve_document_ids_on_error(changeset, params)
        {:error, changeset}
    end
  end

  def update_review(solution, params) do
    params = attach_default_multi_params(params)
    changeset = Solution.update_review_changeset(solution, params)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:solution, changeset)
    |> attach_documents(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{solution: solution}} ->
        {:ok, solution}

      {:error, _type, changeset, _changes} ->
        changeset = preserve_document_ids_on_error(changeset, params)
        {:error, changeset}
    end
  end

  defp attach_default_multi_params(params) do
    Map.put_new(params, "documents", [])
  end

  def submit(solution, remote_ip \\ nil) do
    solution
    |> Repo.preload(challenge: [:challenge_owner_users])
    |> Solution.submit_changeset()
    |> Repo.update()
    |> case do
      {:ok, solution} ->
        solution = new_form_preload(solution)
        send_solution_confirmation_email(solution)
        challenge_owner_new_submission_email(solution)
        add_to_security_log(solution.submitter, solution, "submit", remote_ip)
        {:ok, solution}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp challenge_owner_new_submission_email(solution) do
    Enum.map(solution.challenge.challenge_owner_users, fn owner ->
      owner
      |> Emails.new_solution_submission(solution)
      |> Mailer.deliver_later()
    end)
  end

  defp send_solution_confirmation_email(solution) do
    solution
    |> Emails.solution_confirmation()
    |> Mailer.deliver_later()
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

  # Attach supporting document functions
  defp attach_documents(multi, %{document_ids: ids}) do
    attach_documents(multi, %{"document_ids" => ids})
  end

  defp attach_documents(multi, %{"document_ids" => ids}) do
    Enum.reduce(ids, multi, fn document_id, multi ->
      Ecto.Multi.run(multi, {:document, document_id}, fn _repo, changes ->
        document_id
        |> SolutionDocuments.get()
        |> attach_document(changes.solution)
      end)
    end)
  end

  defp attach_documents(multi, _params), do: multi

  defp attach_document({:ok, document}, solution) do
    SolutionDocuments.attach_to_solution(document, solution)
  end

  defp attach_document(result, _challenge), do: result

  defp preserve_document_ids_on_error(changeset, %{"document_ids" => ids}) do
    {document_ids, documents} =
      Enum.reduce(ids, {[], []}, fn document_id, {document_ids, documents} ->
        with {:ok, document} <- SolutionDocuments.get(document_id) do
          {[document_id | document_ids], [document | documents]}
        else
          _ ->
            {document_ids, documents}
        end
      end)

    changeset
    |> Ecto.Changeset.put_change(:document_ids, document_ids)
    |> Ecto.Changeset.put_change(:document_objects, documents)
  end

  defp preserve_document_ids_on_error(changeset, _params), do: changeset

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

  defp add_to_security_log(user, solution, type, remote_ip, details \\ nil) do
    SecurityLogs.track(%{
      originator_id: user.id,
      originator_role: user.role,
      originator_identifier: user.email,
      originator_remote_ip: remote_ip,
      target_id: solution.id,
      target_type: "solution",
      target_identifier: solution.title,
      action: type,
      details: details
    })
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
