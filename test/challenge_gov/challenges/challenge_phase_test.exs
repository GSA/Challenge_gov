defmodule ChallengeGov.ChallengePhasesTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "adding phases" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, _updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "challenge_title" => challenge.title,
              "upload_logo" => "false",
              "is_multi_phase" => "true",
              "phases" => %{
                "0" => %{
                  "title" => "Test",
                  "start_date" => iso_timestamp(),
                  "end_date" => iso_timestamp(hours: 1),
                  "open_to_submissions" => true
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      titles = Enum.map(challenge.phases, & &1.title)

      assert length(challenge.phases) === 1
      assert Enum.member?(titles, "Test")
    end

    test "successfully as draft" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, _updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "save_draft",
            "challenge" => %{
              "section" => "details",
              "challenge_title" => challenge.title,
              "upload_logo" => "false",
              "phases" => %{
                "0" => %{
                  "title" => "Test"
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.phases) === 1
    end

    test "successfully adding multiple" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, _updated_challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "challenge_title" => challenge.title,
              "upload_logo" => "false",
              "is_multi_phase" => "true",
              "phases" => %{
                "0" => %{
                  "title" => "Test",
                  "start_date" => iso_timestamp(hours: 1),
                  "end_date" => iso_timestamp(hours: 2),
                  "open_to_submissions" => true
                },
                "1" => %{
                  "title" => "Test 1",
                  "start_date" => iso_timestamp(hours: 3),
                  "end_date" => iso_timestamp(hours: 4),
                  "open_to_submissions" => true
                },
                "2" => %{
                  "title" => "Test 2",
                  "start_date" => iso_timestamp(hours: 5),
                  "end_date" => iso_timestamp(hours: 6),
                  "open_to_submissions" => true
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.phases) === 3
    end

    test "failure from overlaps" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "challenge_title" => challenge.title,
              "upload_logo" => "false",
              "is_multi_phase" => "true",
              "phases" => %{
                "0" => %{
                  "title" => "Test",
                  "start_date" => iso_timestamp(hours: 1),
                  "end_date" => iso_timestamp(hours: 2),
                  "open_to_submissions" => true
                },
                "1" => %{
                  "title" => "Test 1",
                  "start_date" => iso_timestamp(hours: 1),
                  "end_date" => iso_timestamp(hours: 4),
                  "open_to_submissions" => true
                },
                "2" => %{
                  "title" => "Test 2",
                  "start_date" => iso_timestamp(hours: 5),
                  "end_date" => iso_timestamp(hours: 6),
                  "open_to_submissions" => true
                }
              }
            }
          },
          user,
          ""
        )

      assert changeset.errors[:phase_dates]
    end

    test "failure from an invalid date range" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "challenge_title" => challenge.title,
              "upload_logo" => "false",
              "is_multi_phase" => "true",
              "phases" => %{
                "0" => %{
                  "title" => "Test",
                  "start_date" => iso_timestamp(hours: 2),
                  "end_date" => iso_timestamp(hours: 1),
                  "open_to_submissions" => true
                },
                "1" => %{
                  "title" => "Test 1",
                  "start_date" => iso_timestamp(hours: 3),
                  "end_date" => iso_timestamp(hours: 4),
                  "open_to_submissions" => true
                },
                "2" => %{
                  "title" => "Test 2",
                  "start_date" => iso_timestamp(hours: 5),
                  "end_date" => iso_timestamp(hours: 6),
                  "open_to_submissions" => true
                }
              }
            }
          },
          user,
          ""
        )

      assert changeset.errors[:phase_dates]
    end
  end

  describe "modifying phases" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "challenge_title" => challenge.title,
              "upload_logo" => "false",
              "is_multi_phase" => "true",
              "phases" => %{
                "0" => %{
                  "title" => "Test",
                  "start_date" => iso_timestamp(hours: 1),
                  "end_date" => iso_timestamp(hours: 2),
                  "open_to_submissions" => true
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.phases) === 1
      phase = Enum.at(challenge.phases, 0)
      assert phase.title === "Test"

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "challenge_title" => challenge.title,
              "upload_logo" => "false",
              "is_multi_phase" => "true",
              "phases" => %{
                "0" => %{
                  "id" => phase.id,
                  "title" => "New title",
                  "start_date" => iso_timestamp(hours: 1),
                  "end_date" => iso_timestamp(hours: 2),
                  "open_to_submissions" => true
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.phases) === 1
      phase = Enum.at(challenge.phases, 0)
      assert phase.title === "New title"
    end

    test "successfully modifying multiple" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "challenge_title" => challenge.title,
              "upload_logo" => "false",
              "is_multi_phase" => "true",
              "phases" => %{
                "0" => %{
                  "title" => "Test",
                  "start_date" => iso_timestamp(hours: 1),
                  "end_date" => iso_timestamp(hours: 2),
                  "open_to_submissions" => true
                },
                "1" => %{
                  "title" => "Test 1",
                  "start_date" => iso_timestamp(hours: 3),
                  "end_date" => iso_timestamp(hours: 4),
                  "open_to_submissions" => true
                },
                "2" => %{
                  "title" => "Test 2",
                  "start_date" => iso_timestamp(hours: 5),
                  "end_date" => iso_timestamp(hours: 6),
                  "open_to_submissions" => true
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.phases) === 3
      phase_titles = Enum.map(challenge.phases, & &1.title)
      assert phase_titles === ["Test", "Test 1", "Test 2"]

      phase_ids = Enum.map(challenge.phases, & &1.id)

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "details",
              "challenge_title" => challenge.title,
              "upload_logo" => "false",
              "is_multi_phase" => "true",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0),
                  "title" => "Test 3",
                  "start_date" => iso_timestamp(hours: 1),
                  "end_date" => iso_timestamp(hours: 2),
                  "open_to_submissions" => true
                },
                "1" => %{
                  "id" => Enum.at(phase_ids, 1),
                  "title" => "Test 4",
                  "start_date" => iso_timestamp(hours: 3),
                  "end_date" => iso_timestamp(hours: 4),
                  "open_to_submissions" => true
                },
                "2" => %{
                  "id" => Enum.at(phase_ids, 2),
                  "title" => "Test 5",
                  "start_date" => iso_timestamp(hours: 5),
                  "end_date" => iso_timestamp(hours: 6),
                  "open_to_submissions" => true
                }
              }
            }
          },
          user,
          ""
        )

      {:ok, challenge} = Challenges.get(challenge.id)

      assert length(challenge.phases) === 3
      phase_titles = Enum.map(challenge.phases, & &1.title)
      assert phase_titles === ["Test 3", "Test 4", "Test 5"]
    end
  end

  defp iso_timestamp(opts \\ []) do
    {:ok, timestamp} =
      Timex.now()
      |> Timex.shift(opts)
      |> Timex.format("{ISO:Extended}")

    timestamp
  end
end
