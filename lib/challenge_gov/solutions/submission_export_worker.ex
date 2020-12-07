defmodule ChallengeGov.Solutions.SubmissionExportWorker do
  @moduledoc """
  Submission export worker background jobs
  """
  use Oban.Worker, queue: :default

  alias ChallengeGov.Repo
  alias ChallengeGov.SolutionDocuments
  alias ChallengeGov.Solutions
  alias ChallengeGov.Solutions.SubmissionExport
  alias ChallengeGov.SubmissionExports
  alias Web.SubmissionExportView
  alias Stein.Storage
  alias Stein.Storage.Temp

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    case Repo.get(SubmissionExport, id) do
      nil ->
        :ok

      submission_export ->
        submissions =
          Solutions.all(
            filter: %{
              "phase_ids" => submission_export.phase_ids,
              "judging_status" => submission_export.judging_status
            }
          )

        export_submissions(submission_export, submission_export.format, submissions)

        :ok
    end
  end

  defp export_submissions(submission_export, ".csv", submissions) do
    csv = SubmissionExportView.submission_csv(submissions)

    {:ok, file_path} = Temp.create(extname: ".csv")
    :ok = File.write(file_path, csv)
    file = Storage.prep_file(%{path: file_path})

    path = SubmissionExports.document_path(submission_export.key, ".csv")

    meta = [
      {:content_disposition, ~s{attachment; filename="submission-export.csv"}}
    ]

    case Storage.upload(file, path, meta: meta) do
      :ok ->
        submission_export
        |> Ecto.Changeset.change(%{status: "completed"})
        |> Repo.update()
    end
  end

  defp export_submissions(submission_export, ".zip", submissions) do
    # TODO: Remove this. Currently added to demonstrate pending status and export cancelling
    Process.sleep(10_000)
    csv = SubmissionExportView.submission_csv(submissions)

    zip_files =
      Enum.flat_map(submissions, fn submission ->
        Enum.map(submission.documents, fn document ->
          {:ok, document_download} = Storage.download(SolutionDocuments.document_path(document))
          document_path = "/submissions/#{submission.id}/#{document.key}#{document.extension}"

          data = File.read!(document_download)
          File.rm(document_download)

          {String.to_charlist(document_path), data}
        end)
      end)

    zip_files = [{'submissions.csv', to_string(csv)} | zip_files]

    {:ok, zip_file_path} = Temp.create(extname: ".zip")
    {:ok, _zip} = :zip.create(String.to_charlist(zip_file_path), zip_files)

    file = Storage.prep_file(%{path: zip_file_path})

    path = SubmissionExports.document_path(submission_export.key, ".zip")

    meta = [
      {:content_disposition, ~s{attachment; filename="submission-export.zip"}}
    ]

    case Storage.upload(file, path, meta: meta) do
      :ok ->
        submission_export
        |> Ecto.Changeset.change(%{status: "completed"})
        |> Repo.update()
    end
  end
end
