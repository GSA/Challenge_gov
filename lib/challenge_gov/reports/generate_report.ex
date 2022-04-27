defmodule ChallengeGov.Reports.GenerateReport do
  @moduledoc """
  generates file, file name, path and updates the `ChallengeGov.Submissions.Submission` pdf.
  """
  alias ChallengeGov.Reports.SubmissionData
  alias ChallengeGov.Submissions
  alias Ruby.Interface, as: Ruby
  require Logger

  def execute(submission) do
    Logger.info("Generating Submission for submission: #{submission.id}")
    pdf = generate_pdf(submission)
    file_name = build_submission_filename(submission.id)

    case Submissions.update_pdf(submission, %{
           type: :submission_pdf,
           pdf_reference: %{
             filename: file_name,
             binary: pdf
           }
         }) do
      {:ok, _detail_report} ->
        :ok

      _ ->
        :error
    end
  end

  defp build_submission_filename(title),
    do: to_string(title) <> ".pdf"

  defp generate_pdf(submission) do
    report_data = SubmissionData.for(submission)

    Ruby.call("submission", "generate_pdf", [report_data])
  end
end
