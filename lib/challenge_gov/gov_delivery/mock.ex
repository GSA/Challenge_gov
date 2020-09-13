defmodule ChallengeGov.GovDelivery.Mock do
  @moduledoc """
  Mock implementation details for GovDelivery

  We never actually care about the return
  values from the real implmentation, these are all no-ops

  Everything is best effort
  """

  @behaviour ChallengeGov.GovDelivery

  @impl true
  def remove_topic(_challenge) do
  end

  @impl true
  def add_topic(_challenge) do
  end

  @impl true
  def subscribe_user_general(_user) do
  end

  @impl true
  def subscribe_user_challenge(_user, _challenge) do
  end
end
