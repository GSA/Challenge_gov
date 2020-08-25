defmodule ChallengeGov.GovDelivery.Implementation do
  @moduledoc """
  Implementation details for GovDelivery
  """

  @behaviour ChallengeGov.GovDelivery

  @impl true
  def remove_topic(code) do
    response = HTTPoison.delete(ChallengeGov.GovDelivery.remove_topic_endpoint(code))

    case response do
      {:ok, %{status_code: 200}} ->
        {:ok, :removed}

      e ->
        {:error, e}
    end
  end

  @impl true
  def add_topic(challenge) do
    body = xml_topic_from_challenge(challenge)

    response = HTTPoison.post(ChallengeGov.GovDelivery.create_topic_endpoint(), body)

    case response do
      {:ok, %{status_code: 200}} ->
        {:ok, :added}

      e ->
        {:error, e}
    end
  end

  defp xml_topic_from_challenge(challenge) do
    XmlBuilder.document(:topic)
    |> XmlBuilder.generate()
  end
end
