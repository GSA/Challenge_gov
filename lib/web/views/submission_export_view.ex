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
    |> Enum.map_join(
      ", ",
      fn phase_id ->
        phase_id
        |> Phases.get()
        |> case do
          {:ok, phase} ->
            phase.title

          _ ->
            nil
        end
      end
    )
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

      "error" ->
        link("Restart",
          to: Routes.submission_export_path(conn, :restart, submission_export.id),
          method: "post"
        )
    end
  end

  def submission_csv(submissions) do
    [
      CSV.dump_to_iodata([csv_headers()]),
      Enum.map(submissions, fn submission ->
        scrubbed_content =
          submission
          |> csv_content()
          |> remove_html_markup([])
          |> remove_improperly_encoded_characters([])

        CSV.dump_to_iodata([scrubbed_content])
      end)
    ]
  end

  def remove_html_markup([head | rest], acc) when is_binary(head),
    do: remove_html_markup(rest, acc ++ [scrub(head)])

  def remove_html_markup([head | rest], acc), do: remove_html_markup(rest, acc ++ [head])
  def remove_html_markup([], acc), do: acc
  defp scrub(data), do: String.replace(data, ~r/<(?!\/?a(?=>|\s.*>))\/?.*?>/, " ")

  def remove_improperly_encoded_characters([head | rest], acc) when is_binary(head) do
    result =
      head
      |> String.replace("&quote;", "\"")
      |> String.replace("â€œ", "\"")
      |> String.replace("&#x27;", "'")
      |> String.replace("â€™", "'")
      |> String.replace("â€“", "-")
      |> String.replace("â€", "\"")
      |> String.replace("&#x2F;", "/")
      |> String.replace("&amp;", "&")
      |> String.replace("Â", " ")

    remove_improperly_encoded_characters(rest, acc ++ [result])
  end

  def remove_improperly_encoded_characters([head | rest], acc),
    do: remove_improperly_encoded_characters(rest, acc ++ [head])

  def remove_improperly_encoded_characters([], acc), do: acc

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
      submission_export_judging_status_text_csv(submission),
      SharedView.readable_datetime(submission.inserted_at),
      SharedView.readable_datetime(submission.updated_at)
    ]
  end

  def submission_export_judging_status_text_csv(submission_export) do
    case submission_export.judging_status do
      "not_selected" ->
        "Not selected"

      "selected" ->
        "Selected for judging"

      "winner" ->
        "Awardee/Selected for next phase"
    end
  end
end
