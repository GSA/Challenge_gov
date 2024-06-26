defmodule ChallengeGov.GovDelivery.Implementation do
  @moduledoc """
  Implementation details for GovDelivery
  We never actually care about the return values
  Everything is best effort to maintain the GovDelivery state
  """

  @behaviour ChallengeGov.GovDelivery

  import SweetXml
  import Phoenix.View

  alias ChallengeGov.Challenges
  alias ChallengeGov.GovDelivery
  alias ChallengeGov.HTTPClient
  alias Web.Endpoint
  alias Web.Router.Helpers, as: Routes
  require Logger

  @impl ChallengeGov.GovDelivery
  def remove_topic(challenge) do
    endpoint =
      challenge.id
      |> code()
      |> GovDelivery.remove_topic_endpoint()

    request = Finch.build(:delete, endpoint, auth_headers())
    Logger.info(inspect(request))

    case Finch.request(request, HTTPClient) do
      {:ok, %{status: 200}} ->
        Logger.info("Gov Delivery Removed Topic #{challenge.id}")
        Challenges.clear_gov_delivery_topic(challenge)
        {:ok, :removed}

      {:ok, %{body: body}} ->
        Logger.error("Gov Delivery Failed to Remove Topic #{challenge.id} #{inspect(body)}")
        {:error, inspect(body)}

      e ->
        Logger.error("Gov Delivery Failed to Remove Topic #{challenge.id} E: #{inspect(e)}")
        {:error, e}
    end
  end

  @impl ChallengeGov.GovDelivery
  def add_topic(challenge) do
    body = xml_topic_from_challenge(challenge)

    request =
      Finch.build(
        :post,
        GovDelivery.create_topic_endpoint(),
        auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}],
        body
      )

    Logger.info(inspect(request))

    case Finch.request(request, HTTPClient) do
      {:ok, %{status: 200}} ->
        Challenges.store_gov_delivery_topic(challenge, code(challenge.id))
        set_category(challenge)

      {:ok, %{body: body}} ->
        Logger.error("Gov Delivery Failed to Add Topic #{challenge.id} #{inspect(body)}")
        {:error, inspect(body)}

      e ->
        Logger.error("Gov Delivery Failed to Add Topic #{challenge.id} E: #{inspect(e)}")
        {:error, e}
    end
  end

  @impl ChallengeGov.GovDelivery
  def subscribe_user_general(user) do
    body = xml_subscribe_general(user)

    request =
      Finch.build(
        :post,
        GovDelivery.subscribe_endpoint(),
        auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}],
        body
      )

    Logger.info(inspect(request))

    case Finch.request(request, HTTPClient) do
      {:ok, %{status: 200}} ->
        {:ok, :subscribed}

      {:ok, %{body: body}} ->
        Logger.error("Gov Delivery Failed to Subscribe User General #{user.id} #{inspect(body)}")
        {:error, inspect(body)}

      e ->
        Logger.error("Gov Delivery Failed to Subscribe User General #{user.id} E: #{inspect(e)}")
        {:error, e}
    end
  end

  @impl ChallengeGov.GovDelivery
  def subscribe_user_challenge(user, challenge) do
    body = xml_subscribe_challenge(user, challenge)

    request =
      Finch.build(
        :post,
        GovDelivery.subscribe_endpoint(),
        auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}],
        body
      )

    Logger.info(inspect(request))

    case Finch.request(request, HTTPClient) do
      {:ok, %{status: 200}} ->
        {:ok, :subscribed}

      {:ok, %{body: body}} ->
        Logger.error(
          "Gov Delivery Failed to Subscribe User Challenge user: #{user.id} challenge: #{challenge.id} #{inspect(body)}"
        )

        {:error, inspect(body)}

      e ->
        Logger.error(
          "Gov Delivery Failed to Subscribe User Challenge user: #{user.id} challenge: #{challenge.id} E: #{inspect(e)}"
        )

        {:error, e}
    end
  end

  @impl ChallengeGov.GovDelivery
  def send_bulletin(challenge, subject, body) do
    body = xml_send_bulletin(challenge, subject, body)

    request =
      Finch.build(
        :post,
        GovDelivery.send_bulletin_endpoint(),
        auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}],
        body
      )

    Logger.info(inspect(request))

    case Finch.request(request, HTTPClient) do
      {:ok, %{status: 200}} ->
        {:ok, :sent}

      {:ok, %{body: body}} ->
        Logger.error(
          "Gov Delivery Failed to Send Bulletin subject: #{inspect(subject)} challenge: #{challenge.id} #{inspect(body)}"
        )

        {:send_error, inspect(body)}

      e ->
        Logger.error(
          "Gov Delivery Failed to Send Bulletin subject: #{inspect(subject)} challenge: #{challenge.id} E: #{inspect(e)}"
        )

        {:send_error, e}
    end
  end

  @impl ChallengeGov.GovDelivery
  def get_topic_subscribe_count(challenge) do
    request =
      Finch.build(
        :get,
        GovDelivery.topic_details_endpoint(code(challenge.id)),
        auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}]
      )

    Logger.info(inspect(request))

    case Finch.request(request, HTTPClient) do
      {:ok, %{status: 200, body: body}} ->
        result =
          body
          |> xpath(~x"//topic/subscribers-count/text()")
          |> to_string()

        {:ok, parse_count_result(result)}

      {:ok, %{body: body}} ->
        Logger.error(
          "Gov Delivery Failed to get topic subscribe count challenge: #{challenge.id} #{inspect(body)}"
        )

        {:error, inspect(body)}

      e ->
        Logger.error(
          "Gov Delivery Failed to get topic subscribe count challenge: #{challenge.id} E: #{inspect(e)}"
        )

        {:error, e}
    end
  end

  def set_category(challenge) do
    endpoint =
      challenge.id
      |> code()
      |> GovDelivery.set_topic_categories_endpoint()

    request =
      Finch.build(
        :put,
        endpoint,
        auth_headers() ++ [{"content-type", "application/xml; charset: utf-8"}],
        xml_categories_for_challenge()
      )

    Logger.info(inspect(request))

    case Finch.request(request, HTTPClient) do
      {:ok, %{status: 200}} ->
        {:ok, :added}

      {:ok, %{body: body}} ->
        Logger.error(
          "Gov Delivery Failed to set category challenge: #{challenge.id} #{inspect(body)}"
        )

        {:category_error, inspect(body)}

      e ->
        Logger.error(
          "Gov Delivery Failed to set category challenge: #{challenge.id} E: #{inspect(e)}"
        )

        {:category_error, e}
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
