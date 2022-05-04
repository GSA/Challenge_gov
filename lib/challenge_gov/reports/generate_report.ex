defmodule ChallengeGov.Reports.GenerateReport do
  @moduledoc """
  generates file, file name, path and updates the `ChallengeGov.Submissions.Submission` pdf.
  """
  alias ChallengeGov.Repo
  alias ChallengeGov.Reports.SubmissionData
  alias ChallengeGov.Submissions.Document
  alias Stein.Storage
  alias Ruby.Interface, as: Ruby
  require Logger

  @tmp_dir "/tmp/submission_synopsis/"

  def execute(user, submission) do
    Logger.info("Generating Submission for submission: #{submission.id}")
    key = UUID.uuid4()
    pdf = generate_pdf(submission)
    file_name = build_submission_filename(submission.id)
    path = @tmp_dir <> file_name
    extension = Path.extname(file_name)
    File.mkdir_p(path)
    {:ok, tmp_file} = Stein.Storage.Temp.create(extname: extension)

    File.write!(tmp_file, pdf, [:binary])
    file = Storage.prep_file(%{path: path})

    meta = [
      {:content_disposition, ~s{attachment; filename="#{file.filename}"}}
    ]

    case Storage.upload(file, path, meta: meta, extensions: [".pdf"]) do
      :ok ->
        user
        |> Ecto.build_assoc(:submission_documents)
        |> Document.create_changeset(file, key, "synopsis")
        |> Repo.insert()

      {:error, _reason} ->
        user
        |> Ecto.build_assoc(:submission_documents)
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:file, "had an issue uploading")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  defp build_submission_filename(title),
    do: to_string(title) <> ".pdf"

  defp generate_pdf(submission) do
    report_data = SubmissionData.for(submission)

    Ruby.call("submission", "generate_pdf", [report_data])
  end
end
