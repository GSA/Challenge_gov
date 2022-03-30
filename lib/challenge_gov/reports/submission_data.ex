defmodule ChallengeGov.Reports.SubmissionData do
  defstruct [
    :title,
    :description,
    :brief_description,
    :id,
    :status,
    :last_updated
  ]

  def for(submission) do
    %__MODULE__{
      title: submission.title,
      description: submission.description,
      brief_description: submission.brief_description,
      id: to_string(submission.id),
      status: submission.status,
      last_updated: DateTime.to_string(submission.updated_at)
    }
    |> to_keyword_list()
  end

  defp to_keyword_list(struct) do
    struct
    |> Map.from_struct()
    |> Enum.into([], fn
      {k, v} -> {k, maybe_transform_value(v)}
    end)
  end

  defp maybe_transform_value(nil), do: ""
  defp maybe_transform_value(item), do: scrub(item) |> remove_improperly_encoded_characters()
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
