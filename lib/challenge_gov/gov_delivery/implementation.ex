defmodule ChallengeGov.GovDelivery.Implementation do
  @moduledoc """
  Implementation details for GovDelivery
  We never actually care about the return values
  Everything is best effort to maintain the GovDelivery state
  """

  @behaviour ChallengeGov.GovDelivery

  import Phoenix.View

  alias ChallengeGov.Challenges
  alias ChallengeGov.GovDelivery
  alias Web.Endpoint
  alias Web.Router.Helpers, as: Routes
  require Logger

  @impl ChallengeGov.GovDelivery
  def remove_topic(challenge) do
    endpoint =
      challenge.id
      |> code()
      |> GovDelivery.remove_topic_endpoint()

    headers = auth_headers()

    case HTTPoison.delete(endpoint, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info("Gov Delivery Removed Topic #{challenge.id}")
        Challenges.clear_gov_delivery_topic(challenge)
        {:ok, :removed}

      {:ok, %HTTPoison.Response{body: body}} ->
        Logger.error("Gov Delivery Failed to Remove Topic #{challenge.id} #{inspect(body)}")
        {:error, inspect(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Gov Delivery Failed to Remove Topic #{challenge.id} E: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @impl ChallengeGov.GovDelivery
  def add_topic(challenge) do
    body = xml_topic_from_challenge(challenge)
    headers = auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}]
    endpoint = GovDelivery.create_topic_endpoint()

    case HTTPoison.post(endpoint, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Challenges.store_gov_delivery_topic(challenge, code(challenge.id))
        set_category(challenge)

      {:ok, %HTTPoison.Response{body: body}} ->
        Logger.error("Gov Delivery Failed to Add Topic #{challenge.id} #{inspect(body)}")
        {:error, inspect(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Gov Delivery Failed to Add Topic #{challenge.id} E: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @impl ChallengeGov.GovDelivery
  def subscribe_user_general(user) do
    body = xml_subscribe_general(user)
    headers = auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}]
    endpoint = GovDelivery.subscribe_endpoint()

    case HTTPoison.post(endpoint, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok, :subscribed}

      {:ok, %HTTPoison.Response{body: body}} ->
        Logger.error("Gov Delivery Failed to Subscribe User General #{user.id} #{inspect(body)}")
        {:error, inspect(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(
          "Gov Delivery Failed to Subscribe User General #{user.id} E: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end

  @impl ChallengeGov.GovDelivery
  def subscribe_user_challenge(user, challenge) do
    body = xml_subscribe_challenge(user, challenge)
    headers = auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}]
    endpoint = GovDelivery.subscribe_endpoint()

    case HTTPoison.post(endpoint, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok, :subscribed}

      {:ok, %HTTPoison.Response{body: body}} ->
        Logger.error(
          "Gov Delivery Failed to Subscribe User Challenge #{user.id} #{challenge.id} #{inspect(body)}"
        )

        {:error, inspect(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(
          "Gov Delivery Failed to Subscribe User Challenge #{user.id} #{challenge.id} E: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end

  @impl ChallengeGov.GovDelivery
  def send_bulletin(challenge, subject, body) do
    body = xml_send_bulletin(challenge, subject, body)
    headers = auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}]
    endpoint = GovDelivery.send_bulletin_endpoint()

    case HTTPoison.post(endpoint, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok, :sent}

      {:ok, %HTTPoison.Response{body: body}} ->
        Logger.error("Gov Delivery Failed to Send Bulletin #{challenge.id} #{inspect(body)}")
        {:error, inspect(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Gov Delivery Failed to Send Bulletin #{challenge.id} E: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @impl ChallengeGov.GovDelivery
  def get_topic_subscribe_count(challenge) do
    endpoint = challenge.id |> code() |> GovDelivery.get_topic_subscribe_count()

    headers = auth_headers()

    case HTTPoison.get(endpoint, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        count = body |> parse_count_result()
        {:ok, count}

      {:ok, %HTTPoison.Response{body: body}} ->
        Logger.error(
          "Gov Delivery Failed to Get Topic Subscribe Count #{challenge.id} #{inspect(body)}"
        )

        {:error, inspect(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(
          "Gov Delivery Failed to Get Topic Subscribe Count #{challenge.id} E: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end

  def set_category(challenge) do
    body = xml_categories_for_challenge()
    headers = auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}]
    endpoint = GovDelivery.set_topic_categories_endpoint(1)

    case HTTPoison.post(endpoint, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info("Gov Delivery Set Category #{challenge.id}")
        {:ok, :set}

      {:ok, %HTTPoison.Response{body: body}} ->
        Logger.error("Gov Delivery Failed to Set Category #{challenge.id} #{inspect(body)}")
        {:error, inspect(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Gov Delivery Failed to Set Category #{challenge.id} E: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp auth_headers() do
    auth64 = "#{GovDelivery.username()}:#{GovDelivery.password()}" |> Base.encode64()
    [{"authorization", "Basic #{auth64}"}]
  end

  defp parse_count_result(nil), do: 0

  defp parse_count_result(string) do
    case Integer.parse(string) do
      :error ->
        0

      {num, _remain} ->
        num
    end
  end

  defp xml_topic_from_challenge(challenge) do
    elements = [
      {:code, nil, code(challenge.id)},
      {:name, nil, challenge.title},
      {"short-name", nil, challenge.title},
      {:description, nil, challenge.tagline},
      {:visibility, nil, "unlisted"}
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
           GovDelivery.challenge_topic_category_code()
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
          {:code, nil, GovDelivery.news_topic_code()}
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

  defp xml_send_bulletin(challenge, subject, body) do
    challenge_topic = [
      {
        :topic,
        nil,
        [
          {:code, nil, code(challenge.id)}
        ]
      }
    ]

    header_img = """
    <img src="#{Routes.static_url(Endpoint, "/images/email-header.png")}"
      alt="Challenge.Gov logo" title="Challenge.Gov logo"/>
    """

    customized_body = render_to_string(Web.BulletinView, "body.html", body: body)

    elements = [
      {:header, nil, {:cdata, header_img}},
      {:subject, nil, subject},
      {:body, nil, {:cdata, customized_body}},
      {:topics, %{type: "array"}, challenge_topic}
    ]

    XmlBuilder.generate({:bulletin, nil, elements}, format: :none, encoding: "UTF-8")
  end

  defp code(id) do
    "#{GovDelivery.challenge_topic_prefix_code()}-#{id}"
  end
end
