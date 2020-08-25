defmodule ChallengeGov.GovDelivery do
  @moduledoc """
  Integration with GovDelivery
  """

  @type code() :: String.t()
  @type challenge() :: ChallengeGov.Challenges.Challenge.t()

  @callback remove_topic(code()) :: tuple()
  @callback add_topic(challenge()) :: tuple()

  @module Application.get_env(:challenge_gov, :gov_delivery)[:module]

  @doc """
  Get the username for GovDelivery
  """
  def username() do
    ChallengeGov.config(Application.get_env(:challenge_gov, :gov_delivery)[:username])
  end

  @doc """
  Get the password for GovDelivery
  """
  def password() do
    ChallengeGov.config(Application.get_env(:challenge_gov, :gov_delivery)[:password])
  end

  @doc """
  Get the endpoint for GovDelivery
  """
  def endpoint() do
    ChallengeGov.config(Application.get_env(:challenge_gov, :gov_delivery)[:url])
  end

  @doc """
  Get the account code for GovDelivery
  """
  def account_code() do
    ChallengeGov.config(Application.get_env(:challenge_gov, :gov_delivery)[:account_code])
  end

  @doc """
  Get the category code for topics for active challenges for GovDelivery
  """
  def challenge_topic_category_code() do
    ChallengeGov.config(Application.get_env(:challenge_gov, :gov_delivery)[:challenge_category_code])
  end

  @doc """
  Get the platform news topci for GovDelivery
  """
  def news_topic_code() do
    ChallengeGov.config(Application.get_env(:challenge_gov, :gov_delivery)[:news_topic_code])
  end

  def create_topic_endpoint() do
    "#{endpoint()}/api/account/#{account_code()}/topics.xml"
  end

  def remove_topic_endpoint(code) do
    "#{endpoint()}/api/account/#{account_code()}/topics/#{code}.xml"
  end
end
