defmodule ChallengeGov.SubmissionExports do
  @moduledoc """
  Context for managing submission exports from a challenge
  """
  import Ecto.Query

  alias ChallengeGov.Submissions.SubmissionExport
  alias ChallengeGov.Submissions.SubmissionExportWorker
  alias ChallengeGov.Repo
  alias Stein.Storage

  def all(challenge) do
    SubmissionExport
    |> where([se], se.challenge_id == ^challenge.id)
    |> order_by([se], desc: se.updated_at)
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

  def restart_export(submission_export) do
    submission_export
    |> Ecto.Changeset.change(%{status: "pending"})
    |> Repo.update!()
    |> trigger_export()
  end

  def document_path(key, extension), do: "/submission-exports/#{key}#{extension}"

  def download_export_url(submission_export) do
    Storage.url(document_path(submission_export.key, submission_export.format),
      signed: [expires_in: 3600]
    )
  end

  def create(params, challenge) do
    case check_for_existing(params) do
      nil ->
        %SubmissionExport{}
        |> SubmissionExport.create_changeset(params, challenge)
        |> Repo.insert()

      submission_export ->
        {:ok, submission_export}
    end
  end

  defp check_for_existing(%{
         "phase_ids" => phase_ids,
         "judging_status" => judging_status,
         "format" => format
       }) do
    submission_export_params = [
      phase_ids: phase_ids,
      judging_status: judging_status,
      format: format
    ]

    SubmissionExport
    |> where(^submission_export_params)
    |> Repo.all()
    |> case do
      [] ->
        nil

      submission_exports ->
        prune_duplicates(submission_exports)
    end
  end

  defp prune_duplicates(submission_exports) do
    if length(submission_exports) == 1 do
      {:ok, submission_export} =
        submission_exports
        |> Enum.at(0)
        |> Ecto.Changeset.change(%{updated_at: DateTime.utc_now()})
        |> Repo.update()

      submission_export
    else
      Enum.each(submission_exports, fn submission_export ->
        delete(submission_export)
      end)

      nil
    end
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
        Storage.delete(document_path(submission_export.key, submission_export.format))
        {:ok, submission_export}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def check_for_outdated(phase_id) do
    phase_id = to_string(phase_id)

    SubmissionExport
    |> where([se], fragment("? @> ?::jsonb", se.phase_ids, ^[phase_id]))
    |> Repo.update_all(set: [status: "outdated"])
  end
end
