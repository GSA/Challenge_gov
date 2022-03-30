defmodule ChallengeGov.Submissions.SubmissionPdf do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]

  def storage_dir(_version, {_waffle_file, %{id: submission_id}}), do: "#{submission_id}"

  def delete_logo(submission), do: delete({"#{submission.id}/submission.pdf", submission})
end
