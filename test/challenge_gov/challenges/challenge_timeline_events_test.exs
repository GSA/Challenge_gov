defmodule ChallengeGov.ChallengeTimelineEventsTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "adding timeline events" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:ok, _updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "title" => "Test",
                  "date" => TestHelpers.iso_timestamp()
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      titles = Enum.map(challenge.timeline_events, & &1.title)

      assert length(challenge.timeline_events) === 1
      assert Enum.member?(titles, "Test")
    end

    test "successfully as draft" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:ok, _updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "save_draft",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "title" => "Test",
                  "date" => DateTime.utc_now()
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.timeline_events) === 1
    end

    test "successfully adding multiple" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:ok, _updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "title" => "Test",
                  "date" => TestHelpers.iso_timestamp(hours: 1)
                },
                "1" => %{
                  "title" => "Test 1",
                  "date" => TestHelpers.iso_timestamp(hours: 3)
                },
                "2" => %{
                  "title" => "Test 2",
                  "date" => TestHelpers.iso_timestamp(hours: 5)
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.timeline_events) === 3
    end

    test "failure with one before start_date" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "title" => "Test",
                  "date" => TestHelpers.iso_timestamp(hours: -1)
                },
                "1" => %{
                  "title" => "Test 1",
                  "date" => TestHelpers.iso_timestamp(hours: 3)
                },
                "2" => %{
                  "title" => "Test 2",
                  "date" => TestHelpers.iso_timestamp(hours: 5)
                }
              }
            }
          },
          user,
          ""
        )

      timeline_changes = changeset.changes.timeline_events
      assert length(timeline_changes) === 3

      Enum.map(timeline_changes, fn change ->
        if length(change.errors) > 0 do
          if change.changes[:title] === "Test" do
            assert change.errors[:date]
          else
            assert !change.errors[:date]
          end
        end
      end)
    end

    test "failure with multiple before start_date" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "title" => "Test",
                  "date" => TestHelpers.iso_timestamp(hours: -1)
                },
                "1" => %{
                  "title" => "Test 1",
                  "date" => TestHelpers.iso_timestamp(hours: -1)
                },
                "2" => %{
                  "title" => "Test 2",
                  "date" => TestHelpers.iso_timestamp(hours: 5)
                }
              }
            }
          },
          user,
          ""
        )

      timeline_changes = changeset.changes.timeline_events
      assert length(timeline_changes) === 3

      Enum.map(timeline_changes, fn change ->
        if length(change.errors) > 0 do
          case change.changes[:title] do
            t when t === "Test" or t === "Test 1" ->
              assert change.errors[:date]

            _ ->
              assert !change.errors[:date]
          end
        end
      end)
    end

    test "failure from missing titles" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "date" => TestHelpers.iso_timestamp(hours: 1)
                },
                "1" => %{
                  "title" => "",
                  "date" => TestHelpers.iso_timestamp(hours: 1)
                },
                "2" => %{
                  "title" => "Test 2",
                  "date" => TestHelpers.iso_timestamp(hours: 5)
                }
              }
            }
          },
          user,
          ""
        )

      timeline_changes = changeset.changes.timeline_events
      assert length(timeline_changes) === 3

      Enum.map(timeline_changes, fn change ->
        if length(change.errors) > 0 do
          assert change.errors[:title]
        end
      end)
    end

    test "failure from missing date" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "title" => "Test"
                },
                "1" => %{
                  "title" => "Test 1",
                  "date" => ""
                },
                "2" => %{
                  "title" => "Test 2",
                  "date" => TestHelpers.iso_timestamp(hours: 5)
                }
              }
            }
          },
          user,
          ""
        )

      timeline_changes = changeset.changes.timeline_events
      assert length(timeline_changes) === 3

      Enum.map(timeline_changes, fn change ->
        if length(change.errors) > 0 do
          assert change.errors[:date]
        end
      end)
    end
  end

  describe "modifying timeline events" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "title" => "Test",
                  "date" => TestHelpers.iso_timestamp(hours: 1)
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.timeline_events) === 1
      event = Enum.at(challenge.timeline_events, 0)
      assert event.title === "Test"

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "title" => "New title",
                  "date" => TestHelpers.iso_timestamp(hours: 2)
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.timeline_events) === 1
      event = Enum.at(challenge.timeline_events, 0)
      assert event.title === "New title"
    end

    test "successfully modifying multiple" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "title" => "Test",
                  "date" => TestHelpers.iso_timestamp(hours: 1)
                },
                "1" => %{
                  "title" => "Test 1",
                  "date" => TestHelpers.iso_timestamp(hours: 3)
                },
                "2" => %{
                  "title" => "Test 2",
                  "date" => TestHelpers.iso_timestamp(hours: 5)
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.timeline_events) === 3
      event_titles = Enum.map(challenge.timeline_events, & &1.title)
      assert event_titles === ["Test", "Test 1", "Test 2"]

      phase_ids = Enum.map(challenge.timeline_events, & &1.id)

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "timeline",
              "timeline_events" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0),
                  "title" => "Test 3",
                  "date" => TestHelpers.iso_timestamp(hours: 1)
                },
                "1" => %{
                  "id" => Enum.at(phase_ids, 1),
                  "title" => "Test 4",
                  "date" => TestHelpers.iso_timestamp(hours: 3)
                },
                "2" => %{
                  "id" => Enum.at(phase_ids, 2),
                  "title" => "Test 5",
                  "date" => TestHelpers.iso_timestamp(hours: 5)
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.timeline_events) === 3
      event_titles = Enum.map(challenge.timeline_events, & &1.title)
      assert event_titles === ["Test 3", "Test 4", "Test 5"]
    end
  end
end
