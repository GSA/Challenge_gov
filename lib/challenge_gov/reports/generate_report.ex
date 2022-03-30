defmodule ChallengeGov.Reports.GenerateReport do
  alias ChallengeGov.Reports.SubmissionData
  alias ChallengeGov.Submissions
  alias Ruby.Interface, as: Ruby
  require Logger

  def execute(submission) do
    Logger.info("Generating Submission for submission: #{submission.id}")
    pdf = generate_pdf(submission)

    with {:ok, _detail_report} <-
           Submissions.update_pdf(submission, %{
             type: :submission_pdf,
             pdf_reference: %{
               filename: build_submission_filename(submission.title),
               binary: pdf
             },
           }) do
      :ok
    else
      _ -> :error
    end
  end

  defp build_submission_filename(title),
    do: title <> ".pdf"

  defp generate_pdf(submission) do
    report_data = SubmissionData.for(submission)

    Ruby.call("submission", "generate_pdf", [report_data])
  end
end
