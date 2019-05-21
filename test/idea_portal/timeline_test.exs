defmodule IdeaPortal.TimelineTest do
  use IdeaPortal.DataCase

  alias IdeaPortal.Timeline

  describe "creating a new event" do
    test "successfully" do
      challenge = TestHelpers.create_challenge(TestHelpers.create_user())

      {:ok, event} =
        Timeline.create_event(challenge, %{
          title: "Created",
          body: "Challenge is created",
          occurs_on: "2019-05-01"
        })

      assert event.challenge_id == challenge.id
    end
  end

  describe "updating an event" do
    test "successfully" do
      challenge = TestHelpers.create_challenge(TestHelpers.create_user())
      event = TestHelpers.create_event(challenge)

      {:ok, event} =
        Timeline.update_event(event, %{
          title: "Updated",
          body: "Challenge is updated",
          occurs_on: "2019-05-02"
        })

      assert event.title == "Updated"
    end
  end

  describe "deleting an event" do
    test "successfully" do
      challenge = TestHelpers.create_challenge(TestHelpers.create_user())
      event = TestHelpers.create_event(challenge)

      {:ok, _event} = Timeline.delete_event(event)
    end
  end
end
