defmodule ChallengeGov.GovDelivery.Implementation do
  @moduledoc """
  Implementation details for GovDelivery
  """

  @behaviour ChallengeGov.GovDelivery

  @impl true
  def remove_topic(challenge) do
    endpoint =
      challenge.id
      |> code()
      |> ChallengeGov.GovDelivery.remove_topic_endpoint()

    response =
      Mojito.delete(
        endpoint,
        [auth_headers()]
      )

    case response do
      {:ok, %{status_code: 200}} ->
        ChallengeGov.Challenges.clear_gov_delivery_topic(challenge)
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
        ChallengeGov.Challenges.store_gov_delivery_topic(challenge, code(challenge.id))
        set_category(challenge)

      {:ok, %{body: body, status_code: code}} ->
        {:error, %{body: body, status_code: code}}

      e ->
        {:error, e}
    end
  end

  @impl true
  def subscribe_user_general(user) do
    body = xml_subscribe_general(user)

    response =
      Mojito.post(
        ChallengeGov.GovDelivery.subscribe_endpoint(),
        [
          auth_headers(),
          {"content-type", "application/xml; charset: utf-8"}
        ],
        body
      )

    case response do
      {:ok, %{status_code: 200}} ->
        {:ok, :subscribed}

      {:ok, %{body: body, status_code: code}} ->
        {:error, %{body: body, status_code: code}}

      e ->
        {:error, e}
    end
  end

  @impl true
  def subscribe_user_challenge(user, challenge) do
    body = xml_subscribe_challenge(user, challenge)

    response =
      Mojito.post(
        ChallengeGov.GovDelivery.subscribe_endpoint(),
        [
          auth_headers(),
          {"content-type", "application/xml; charset: utf-8"}
        ],
        body
      )

    case response do
      {:ok, %{status_code: 200}} ->
        {:ok, :subscribed}

      {:ok, %{body: body, status_code: code}} ->
        {:error, %{body: body, status_code: code}}

      e ->
        {:error, e}
    end
  end

  def set_category(challenge) do
    endpoint =
      challenge.id
      |> code()
      |> ChallengeGov.GovDelivery.set_topic_categories_endpoint()

    response =
      Mojito.put(
        endpoint,
        [
          auth_headers(),
          {"content-type", "application/xml; charset: utf-8"}
        ],
        xml_categories_for_challenge()
      )

    case response do
      {:ok, %{status_code: 200}} ->
        {:ok, :added}

      {:ok, %{body: body, status_code: code}} ->
        {:category_error, %{body: body, status_code: code}}

      e ->
        {:category_error, e}
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
      {:description, nil, challenge.tagline}
    ]

    XmlBuilder.generate({:topic, nil, elements}, format: :none, encoding: "UTF-8")
  end

  defp xml_categories_for_challenge() do
    elements = [
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

  defp xml_subscribe_general(user) do
    general_topic = [
      {
        :topic,
        nil,
        [
          {:code, nil, ChallengeGov.GovDelivery.news_topic_code()}
        ]
      }
    ]

    elements = [
      {:email, nil, user.email},
      {"send-notifications", %{type: "boolean"}, "true"},
      {:topics, %{type: "array"}, general_topic}
    ]

    XmlBuilder.generate({:subscriber, nil, elements}, format: :none, encoding: "UTF-8")
  end

  defp xml_subscribe_challenge(user, challenge) do
    general_topic = [
      {
        :topic,
        nil,
        [
          {:code, nil, code(challenge.id)}
        ]
      }
    ]

    elements = [
      {:email, nil, user.email},
      {"send-notifications", %{type: "boolean"}, "true"},
      {:topics, %{type: "array"}, general_topic}
    ]

    XmlBuilder.generate({:subscriber, nil, elements}, format: :none, encoding: "UTF-8")
  end

  defp code(id) do
    "#{ChallengeGov.GovDelivery.challenge_topic_prefix_code()}-#{id}"
  end
end
