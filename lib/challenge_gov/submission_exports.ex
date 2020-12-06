defmodule ChallengeGov.SubmissionExports do
  @moduledoc """
  Context for managing submission exports from a challenge
  """

  alias ChallengeGov.Solutions.SubmissionExport
  alias ChallengeGov.Solutions.SubmissionExportWorker
  alias ChallengeGov.Repo
  alias Stein.Storage

  import Ecto.Query

  def all(challenge) do
    SubmissionExport
    |> where([se], se.challenge_id == ^challenge.id)
    |> order_by([se], desc: se.inserted_at)
    |> Repo.all()
  end

  def get(id) do
    SubmissionExport
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      submission_export ->
        {:ok, submission_export}
    end
  end

  def trigger_export(submission_export) do
    %{id: submission_export.id}
    |> SubmissionExportWorker.new()
    |> Oban.insert()
  end

  def document_path(key, extension), do: "/submission-exports/#{key}#{extension}"

  def download_export_url(submission_export) do
    Storage.url(document_path(submission_export.key, submission_export.format),
      signed: [expires_in: 3600]
    )
  end

  # def new(), do: SubmissionExport.changeset(%SubmissionExport{}, %{})

  def create(params, challenge) do
    %SubmissionExport{}
    |> SubmissionExport.create_changeset(params, challenge)
    |> Repo.insert()
  end

  def update(submission_export, params) do
    submission_export
    |> SubmissionExport.update_changeset(params)
    |> Repo.update()
  end

  def delete(submission_export) do
    submission_export
    |> Repo.delete()
    |> case do
      {:ok, submission_export} ->
        Storage.delete(submission_export.key)
        {:ok, submission_export}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
