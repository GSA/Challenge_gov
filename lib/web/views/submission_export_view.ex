NimbleCSV.define(ChallengeGov.SubmissionExport.CSV, separator: ",", escape: "\"")

defmodule Web.SubmissionExportView do
  use Web, :view

  alias ChallengeGov.SubmissionExport.CSV
  alias Web.ChallengeView

  def format_content(submissions, format) do
    case format do
      "csv" ->
        {:ok, submission_csv(submissions)}

      "csv_with_uploads" ->
        {:ok, submission_csv(submissions)}

      _ ->
        {:error, :invalid_format}
    end
  end

  def submission_csv(submissions) do
    [
      CSV.dump_to_iodata([csv_headers()]),
      Enum.map(submissions, fn submission ->
        CSV.dump_to_iodata([csv_content(submission)])
      end)
    ]
  end

  defp csv_headers() do
    [
      "ID",
      "Submitter email",
      "Title",
      "Brief description",
      "Description",
      "External URL",
      "Status",
      "Judging status",
      "Created at",
      "Updated at"
    ]
  end

  defp csv_content(submission) do
    [
      submission.id,
      submission.submitter.email,
      submission.title,
      submission.brief_description,
      submission.description,
      submission.external_url,
      submission.status,
      submission.judging_status,
      submission.inserted_at,
      submission.updated_at
    ]
  end
end
