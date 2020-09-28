defmodule ChallengeGov.GovDelivery do
  @moduledoc """
  Integration with GovDelivery
  """

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges

  @type challenge() :: Challenges.Challenge.t()
  @type user() :: Accounts.User.t()

  @callback remove_topic(challenge()) :: tuple()
  @callback add_topic(challenge()) :: tuple()
  @callback subscribe_user_general(user()) :: tuple()
  @callback subscribe_user_challenge(user(), challenge()) :: tuple()
  @callback send_bulletin(challenge(), binary(), binary()) :: tuple()
  @callback get_topic_subscribe_count(challenge()) :: tuple()

  @module Application.get_env(:challenge_gov, :gov_delivery)[:module]

  @doc """
  Get the username for GovDelivery
  """
  def username() do
    ChallengeGov.config(Application.get_env(:challenge_gov, __MODULE__)[:username])
  end

  @doc """
  Get the password for GovDelivery
  """
  def password() do
    ChallengeGov.config(Application.get_env(:challenge_gov, __MODULE__)[:password])
  end

  @doc """
  Get the endpoint for GovDelivery
  """
  def endpoint() do
    ChallengeGov.config(Application.get_env(:challenge_gov, __MODULE__)[:url])
  end

  @doc """
  Get the account code for GovDelivery
  """
  def account_code() do
    ChallengeGov.config(Application.get_env(:challenge_gov, __MODULE__)[:account_code])
  end

  @doc """
  Get the category code for topics for active challenges for GovDelivery
  """
  def challenge_topic_category_code() do
    ChallengeGov.config(Application.get_env(:challenge_gov, __MODULE__)[:challenge_category_code])
  end

  @doc """
  Get the prefix for all topic codes for challenges
  """
  def challenge_topic_prefix_code() do
    ChallengeGov.config(
      Application.get_env(:challenge_gov, __MODULE__)[:challenge_topic_prefix_code]
    )
  end

  @doc """
  Get the platform news topic for GovDelivery
  """
  def news_topic_code() do
    ChallengeGov.config(Application.get_env(:challenge_gov, __MODULE__)[:news_topic_code])
  end

  def public_subscribe_url_base() do
    ChallengeGov.config(Application.get_env(:challenge_gov, __MODULE__)[:public_subscribe_base])
  end

  def create_topic_endpoint() do
    "#{endpoint()}/api/account/#{account_code()}/topics.xml"
  end

  def set_topic_categories_endpoint(code) do
    "#{endpoint()}/api/account/#{account_code()}/topics/#{code}/categories.xml"
  end

  def remove_topic_endpoint(code) do
    "#{endpoint()}/api/account/#{account_code()}/topics/#{code}.xml"
  end

  def topic_details_endpoint(code) do
    "#{endpoint()}/api/account/#{account_code()}/topics/#{code}.xml"
  end

  def subscribe_endpoint() do
    "#{endpoint()}/api/account/#{account_code()}/subscriptions.xml"
  end

  def send_bulletin_endpoint() do
    "#{endpoint()}/api/account/#{account_code()}/bulletins/send_now"
  end

  @doc """
  Add challenge as a topic
  """
  def add_topic(challenge) do
    @module.add_topic(challenge)
  end

  @doc """
  Remove challenge as a topic
  """
  def remove_topic(challenge) do
    @module.remove_topic(challenge)
  end

  @doc """
  Subscribe User
  """
  def subscribe_user_general(user) do
    @module.subscribe_user_general(user)
  end

  @doc """
  Subscribe User
  """
  def subscribe_user_challenge(user, challenge) do
    @module.subscribe_user_challenge(user, challenge)
  end

  @doc """
  Send bulletin to subscribers
  """
  def send_bulletin(challenge, subject, body) do
    @module.send_bulletin(challenge, subject, body)
  end

  @doc """
  Get the count of subscribers on a topic
  """
  def get_topic_subscribe_count(challenge) do
    @module.get_topic_subscribe_count(challenge)
  end

  @doc """
  Ensure all topics are correct in GovDelivery
  """
  def check_topics do
    Challenges.all_for_govdelivery()
    |> Enum.each(fn challenge ->
      add_topic(challenge)
    end)

    Challenges.all_for_removal_from_govdelivery()
    |> Enum.each(fn challenge ->
      remove_topic(challenge)
    end)
  end

  @doc """
  Update all counts
  """
  def update_subscriber_counts do
    Challenges.all_in_govdelivery()
    |> Enum.each(fn challenge ->
      result = get_topic_subscribe_count(challenge)
      Challenges.update_subscribe_count(challenge, result)
    end)
  end

  @doc """
  Get gov delivery topic subscribe url
  """
  def public_subscribe_link(%{gov_delivery_topic: nil}), do: nil

  def public_subscribe_link(%{gov_delivery_topic: topic}) do
    "#{public_subscribe_url_base()}#{topic}"
  end
end
