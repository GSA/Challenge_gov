defmodule ChallengeGov.GovDelivery.Implementation do
  @moduledoc """
  Implementation details for GovDelivery
  """

  @behaviour ChallengeGov.GovDelivery

  def list_topics() do
    response =
      Mojito.get(
        ChallengeGov.GovDelivery.list_topics_endpoint(),
        [auth_headers()]
      )

    case response do
      {:ok, %{body: body, status_code: 200}} ->
        {:ok, body}

      {:ok, %{body: body, status_code: code}} ->
        {:error, %{body: body, status_code: code}}

      e ->
        {:error, e}
    end
  end

  def list_categories() do
    response =
      Mojito.get(
        ChallengeGov.GovDelivery.list_categories_endpoint(),
        [auth_headers()]
      )

    case response do
      {:ok, %{body: body, status_code: 200}} ->
        {:ok, body}

      {:ok, %{body: body, status_code: code}} ->
        {:error, %{body: body, status_code: code}}

      e ->
        {:error, e}
    end
  end

  @impl true
  def remove_topic(id) do
    response =
      Mojito.delete(
        ChallengeGov.GovDelivery.remove_topic_endpoint(code(id)),
        [auth_headers()]
      )

    case response do
      {:ok, %{status_code: 200}} ->
        {:ok, :removed}

      {:ok, %{body: body, status_code: code}} ->
        {:error, %{body: body, status_code: code}}

      e ->
        {:error, e}
    end
  end

  @impl true
  def add_topic(challenge) do
    body = xml_topic_from_challenge(challenge)

    response =
      Mojito.post(
        ChallengeGov.GovDelivery.create_topic_endpoint(),
        [
          auth_headers(),
          {"content-type", "application/xml; charset: utf-8"}
        ],
        body
      )

    case response do
      {:ok, %{status_code: 200}} ->
        {:ok, :added}

      {:ok, %{body: body, status_code: code}} ->
        {:error, %{body: body, status_code: code}}

      e ->
        {:error, e}
    end
  end

  defp auth_headers() do
    Mojito.Headers.auth_header(
      ChallengeGov.GovDelivery.username(),
      ChallengeGov.GovDelivery.password()
    )
  end

  defp xml_topic_from_challenge(challenge) do
    elements = [
      {:code, nil, code(challenge.id)},
      {:name, nil, challenge.title},
      {"short-name", nil, challenge.title},
      {:description, nil, challenge.tagline},
      {:categories, %{type: "array"}, categories()}
    ]

    XmlBuilder.generate({:topic, nil, elements}, format: :none, encoding: "UTF-8")
  end

  defp categories() do
    [
      {:category, nil,
       [
         {
           :code,
           nil,
           ChallengeGov.GovDelivery.challenge_topic_category_code()
         }
       ]}
    ]
  end

  defp code(id) do
    "CHAL_TEST-#{id}"
  end
end
