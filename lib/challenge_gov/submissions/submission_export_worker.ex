defmodule ChallengeGov.Submissions.SubmissionExportWorker do
  @moduledoc """
  Submission export worker background jobs
  """
  use Oban.Worker, queue: :default

  alias ChallengeGov.Repo
  alias ChallengeGov.SubmissionDocuments
  alias ChallengeGov.Submissions
  alias ChallengeGov.Submissions.SubmissionExport
  alias ChallengeGov.SubmissionExports
  alias Web.DocumentView
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
          Submissions.all(
            filter: %{
              "status" => "submitted",
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
    # Setup initial directories and files and clear old ones
    submission_exports_directory = "tmp/submission_exports/"

    tmp_submission_export_directory = "#{submission_export.id}/"
    tmp_file_directory = submission_exports_directory <> tmp_submission_export_directory

    zip_file_name = "#{submission_export.id}.zip"
    zip_file_path = tmp_file_directory <> zip_file_name

    File.rm_rf(tmp_file_directory)

    File.mkdir_p(tmp_file_directory)

    # Write CSV file to tmp directory
    csv = SubmissionExportView.submission_csv(submissions)

    File.write!(tmp_file_directory <> "submissions.csv", to_string(csv))

    # Write submission downloads to tmp directory
    Enum.each(submissions, fn submission ->
      Enum.map(submission.documents, fn document ->
        {:ok, document_download} = Storage.download(SubmissionDocuments.document_path(document))

        document_path = tmp_file_directory <> "submissions/#{submission.id}/"
        File.mkdir_p(document_path)
        document_filename = "#{DocumentView.filename(document)}#{document.extension}"

        File.cp!(document_download, document_path <> document_filename)
        File.rm(document_download)
      end)
    end)

    case Porcelain.exec("zip", ["-r", "#{submission_export.id}.zip", "."], dir: tmp_file_directory) do
      %{status: 0} ->
        file = Storage.prep_file(%{path: zip_file_path})

        path = SubmissionExports.document_path(submission_export.key, ".zip")

        meta = [
          {:content_disposition, ~s{attachment; filename="submission-export.zip"}}
        ]

        # Attempt to upload zip file
        case Storage.upload(file, path, meta: meta) do
          :ok ->
            # Remove tmp files
            File.rm_rf(tmp_file_directory)

            submission_export
            |> Ecto.Changeset.change(%{status: "completed"})
            |> Repo.update()
        end

      _error ->
        # Remove tmp files
        File.rm_rf(tmp_file_directory)

        submission_export
        |> Ecto.Changeset.change(%{status: "error"})
        |> Repo.update()
    end
  end
end
