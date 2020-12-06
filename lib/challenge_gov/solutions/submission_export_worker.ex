defmodule ChallengeGov.Solutions.SubmissionExportWorker do
  @moduledoc """
  Submission export worker background jobs
  """
  use Oban.Worker, queue: :default

  alias ChallengeGov.Repo
  alias ChallengeGov.Solutions
  alias ChallengeGov.Solutions.SubmissionExport
  alias ChallengeGov.SubmissionExports
  alias Web.SubmissionExportView
  alias Stein.Storage
  alias Stein.Storage.Temp

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    submission_export = Repo.get(SubmissionExport, id)

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

  # Make CSV
  # Make Create directory for each submissions that has uploads with id
  # Put directories and the CSV into a zip
  # Upload the zip
  # download all documents for the submissions into a temp folder, maybe use stein.temp
  # :zip.zip()    
  defp export_submissions(submission_export, ".zip", submissions) do
    csv = SubmissionExportView.submission_csv(submissions)

    # Enum.map(submissions, fn submission ->
    #   if length(submission.documents) > 1 do
    #     submission_upload_directory = "submission_#{submission.id}"
    #     File.mkdir(submission_upload_directory)

    #     Enum.map(submission.documents, fn document ->
    #       {:ok, document_download} = Storage.download(document.key)

    #       submission_upload_path =
    #         submission_upload_directory <>
    #           "/#{document.name || document.key}#{document.extension}"

    #       File.cp(document_download, submission_upload_path)
    #     end)
    #   end
    # end)

    {:ok, file_path} = Temp.create(extname: ".csv")
    :ok = File.write(file_path, csv)

    {:ok, zip_file_path} = Temp.create(extname: ".zip")
    {:ok, _zip} = :zip.create(zip_file_path, [String.to_charlist(file_path)])

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
