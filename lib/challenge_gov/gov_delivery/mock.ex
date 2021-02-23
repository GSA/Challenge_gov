defmodule ChallengeGov.GovDelivery.Mock do
  @moduledoc """
  Mock implementation details for GovDelivery

  We never actually care about the return
  values from the real implmentation, these are all no-ops

  Everything is best effort
  """

  @behaviour ChallengeGov.GovDelivery

  @impl ChallengeGov.GovDelivery
  def remove_topic(_challenge) do
  end

  @impl ChallengeGov.GovDelivery
  def add_topic(_challenge) do
  end

  @impl ChallengeGov.GovDelivery
  def subscribe_user_general(_user) do
  end

  @impl ChallengeGov.GovDelivery
  def subscribe_user_challenge(_user, _challenge) do
  end

  @impl ChallengeGov.GovDelivery
  def send_bulletin(_challenge, _subject, _body) do
  end

  @impl ChallengeGov.GovDelivery
  def get_topic_subscribe_count(_challenge) do
  end
end
