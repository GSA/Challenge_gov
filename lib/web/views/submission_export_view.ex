NimbleCSV.define(ChallengeGov.SubmissionExports.CSV, separator: ",", escape: "\"")

defmodule Web.SubmissionExportView do
  use Web, :view

  alias ChallengeGov.Phases
  alias ChallengeGov.SubmissionExports
  alias ChallengeGov.SubmissionExports.CSV
  alias Web.ChallengeView
  alias Web.SharedView

  def submission_export_phases_text(submission_export) do
    submission_export.phase_ids
    |> Enum.map(fn phase_id ->
      phase_id
      |> Phases.get()
      |> case do
        {:ok, phase} ->
          phase.title

        _ ->
          nil
      end
    end)
    |> Enum.join(", ")
  end

  def submission_export_judging_status_text(submission_export) do
    case submission_export.judging_status do
      "all" ->
        "All entries"

      "selected" ->
        "Selected for judging"

      "winner" ->
        "Awardees/Selected for next phase"
    end
  end

  def submission_export_action(conn, submission_export) do
    case submission_export.status do
      "completed" ->
        link("Download", to: SubmissionExports.download_export_url(submission_export))

      "outdated" ->
        link("Restart",
          to: Routes.submission_export_path(conn, :restart, submission_export.id),
          method: "post"
        )

      "pending" ->
        link("Cancel",
          to: Routes.submission_export_path(conn, :delete, submission_export.id),
          method: "delete"
        )
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
