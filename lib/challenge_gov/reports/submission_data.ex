defmodule ChallengeGov.Reports.SubmissionData do
  @moduledoc """
  Gathers, filters and structures the data for a `ChallengeGov.Submissions.Submission` pdf
  """

  defstruct title: " ",
            agency_name: " ",
            brief_description: " ",
            challenge_logo:
              Path.join([:code.priv_dir(:challenge_gov), "static/images/email-header.png"]),
            challenge_title: " ",
            id: " ",
            asset_root: " ",
            status: " ",
            phase: " ",
            submitted_on: " ",
            description: " ",
            uploaded_files: [],
            external_url: " "

  def for(submission) do
    submission =
      ChallengeGov.Repo.preload(submission, [
        :documents,
        :phase,
        [challenge: [:agency, :sub_agency]]
      ])

    document_titles = get_document_names(submission.documents)

    %__MODULE__{
      agency_name: submission.challenge.agency.name,
      brief_description: submission.brief_description,
      challenge_logo:
        Path.join([:code.priv_dir(:challenge_gov), "static/images/email-header.png"]),
      challenge_title: submission.challenge.title,
      description: submission.description,
      external_url: submission.external_url,
      id: to_string(submission.id),
      phase: submission.phase.title,
      status: submission.status,
      submitted_on: Date.to_string(DateTime.to_date(submission.updated_at)),
      title: submission.title,
      uploaded_files: document_titles
    }
    |> to_keyword_list()
  end

  defp get_document_names(documents) do
    for document <- documents do
      document.name
    end
  end

  defp to_keyword_list(struct) do
    struct
    |> Map.from_struct()
    |> Enum.into([], fn
      {k, v} -> {k, maybe_transform_value(v)}
    end)
  end

  defp maybe_transform_value(data) when is_list(data), do: data
  defp maybe_transform_value(nil), do: ""
  defp maybe_transform_value(item), do: item |> scrub() |> remove_improperly_encoded_characters()
  defp scrub(data), do: String.replace(data, ~r/<(?!\/?a(?=>|\s.*>))\/?.*?>/, " ")

  def remove_improperly_encoded_characters(item) when is_binary(item) do
    item
    |> String.replace("&quote;", "\"")
    |> String.replace("â€œ", "\"")
    |> String.replace("&#x27;", "'")
    |> String.replace("â€™", "'")
    |> String.replace("â€“", "-")
    |> String.replace("â€", "\"")
    |> String.replace("&#x2F;", "/")
    |> String.replace("&amp;", "&")
    |> String.replace("Â", " ")
  end
end
