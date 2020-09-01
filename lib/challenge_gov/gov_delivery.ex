defmodule ChallengeGov.GovDelivery do
  @moduledoc """
  Integration with GovDelivery
  """

  @type id() :: integer()
  @type challenge() :: ChallengeGov.Challenges.Challenge.t()

  @callback remove_topic(id()) :: tuple()
  @callback add_topic(challenge()) :: tuple()

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
  Get the platform news topic for GovDelivery
  """
  def news_topic_code() do
    ChallengeGov.config(Application.get_env(:challenge_gov, __MODULE__)[:news_topic_code])
  end

  def create_topic_endpoint() do
    "#{endpoint()}/api/account/#{account_code()}/topics.xml"
  end

  def update_topic_endpoint(topic_code) do
    "#{endpoint()}/api/account/#{account_code()}/topics/#{topic_code}.xml"
  end

  def remove_topic_endpoint(code) do
    "#{endpoint()}/api/account/#{account_code()}/topics/#{code}.xml"
  end

  def list_topics_endpoint() do
    "#{endpoint()}/api/account/#{account_code()}/topics.xml"
  end

  def list_categories_endpoint() do
    "#{endpoint()}/api/account/#{account_code()}/categories.xml"
  end

  @doc """
  Add challenge as a topic
  """
  def add_topic(challenge) do
    @module.add_topic(challenge)
  end

  @doc """
  Add challenge as a topic
  """
  def remove_topic(id) do
    @module.remove_topic(id)
  end

  @doc """
  List all topics
  """
  def list_topics() do
    @module.list_topics()
  end

  @doc """
  List categories
  """
  def list_categories() do
    @module.list_categories()
  end
end
