defmodule ChallengeGov.AutoPublishTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.Emails
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "get all challenges ready for publish" do
    test "successfully" do
      setup_challenges()
      assert length(Challenges.all_unpaginated()) === 15
      assert length(Challenges.all_ready_for_publish()) === 2
    end
  end

  describe "publish all challenges ready to be published and send emails" do
    test "successfully" do
      setup_challenges()
      challenges_for_publish = Challenges.all_ready_for_publish()

      assert length(Challenges.all_unpaginated(%{filter: %{"status" => "published"}})) === 2
      assert length(Challenges.all_ready_for_publish()) === 2

      Challenges.check_for_auto_publish()

      assert length(Challenges.all_unpaginated(%{filter: %{"status" => "published"}})) === 4

      Enum.map(challenges_for_publish, fn challenge ->
        {:ok, challenge} = Challenges.get(challenge.id)

        Enum.map(challenge.challenge_manager_users, fn manager ->
          assert_delivered_email(Emails.challenge_auto_published(manager, challenge))
        end)
      end)
    end
  end

  def setup_challenges() do
    one_minute_ago =
      Timex.now()
      |> Timex.shift(minutes: -1)

    one_minute_in_future =
      Timex.now()
      |> Timex.shift(minutes: 1)

    user = AccountHelpers.create_user()

    # Challenges past publish date different statuses
    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_ago,
          status: "approved"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_ago,
          status: "approved"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_ago,
          status: "gsa_review"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_ago,
          status: "edits_requested"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_ago,
          status: "draft"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_ago,
          status: "unpublished"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_ago,
          status: "published"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_ago,
          status: "archived"
        },
        user
      )

    # Challenges past publish date different statuses
    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_in_future,
          status: "approved"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_in_future,
          status: "gsa_review"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_in_future,
          status: "edits_requested"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_in_future,
          status: "draft"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_in_future,
          status: "unpublished"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_in_future,
          status: "published"
        },
        user
      )

    _challenge =
      ChallengeHelpers.create_challenge(
        %{
          user_id: user.id,
          auto_publish_date: one_minute_in_future,
          status: "archived"
        },
        user
      )
  end
end
