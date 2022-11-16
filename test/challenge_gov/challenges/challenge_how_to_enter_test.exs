defmodule ChallengeGov.ChallengeHowToEnterTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "adding how to enter to single phase challenge" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "how_to_enter",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0),
                  "how_to_enter" => "Test how to enter 1"
                }
              },
              "how_to_enter_link" => "http://www.example.com"
            }
          },
          user,
          ""
        )

      titles = Enum.map(challenge.phases, & &1.how_to_enter)

      assert length(challenge.phases) === 1
      assert Enum.member?(titles, "Test how to enter 1")
      assert challenge.how_to_enter_link === "http://www.example.com"
    end

    test "successfully save draft" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "save_draft",
            "challenge" => %{
              "section" => "how_to_enter",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0)
                }
              }
            }
          },
          user,
          ""
        )

      titles = Enum.map(challenge.phases, & &1.how_to_enter)

      assert length(challenge.phases) === 1
      assert Enum.member?(titles, nil)
    end

    test "error missing how to enter" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "how_to_enter",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0)
                }
              }
            }
          },
          user,
          ""
        )

      errors = Enum.map(changeset.changes.phases, & &1.errors)

      assert length(errors) === 1

      Enum.map(errors, fn error ->
        assert error[:how_to_enter]
        {_message, type} = error[:how_to_enter]
        assert type[:validation] === :required
      end)
    end

    test "no limit how to enter length" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      length = 15_001
      how_to_enter = TestHelpers.generate_random_string(length)

      assert {:ok, _} =
               Challenges.update(
                 challenge,
                 %{
                   "action" => "next",
                   "challenge" => %{
                     "section" => "how_to_enter",
                     "phases" => %{
                       "0" => %{
                         "id" => Enum.at(phase_ids, 0),
                         "how_to_enter" => how_to_enter
                       }
                     }
                   }
                 },
                 user,
                 ""
               )
    end
  end

  describe "adding how to enter to multi phase challenge" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "how_to_enter",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0),
                  "how_to_enter" => "Test how to enter 1"
                },
                "1" => %{
                  "id" => Enum.at(phase_ids, 1),
                  "how_to_enter" => "Test how to enter 2"
                },
                "2" => %{
                  "id" => Enum.at(phase_ids, 2),
                  "how_to_enter" => "Test how to enter 3"
                }
              }
            }
          },
          user,
          ""
        )

      titles = Enum.map(challenge.phases, & &1.how_to_enter)

      assert length(challenge.phases) === 3
      assert Enum.member?(titles, "Test how to enter 1")
      assert Enum.member?(titles, "Test how to enter 2")
      assert Enum.member?(titles, "Test how to enter 3")
    end

    test "successfully save draft" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      {:ok, challenge} =
        Challenges.update(
          challenge,
          %{
            "action" => "save_draft",
            "challenge" => %{
              "section" => "how_to_enter",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0),
                  "how_to_enter" => "Test how to enter 1"
                },
                "1" => %{
                  "id" => Enum.at(phase_ids, 1)
                },
                "2" => %{
                  "id" => Enum.at(phase_ids, 2)
                }
              }
            }
          },
          user,
          ""
        )

      titles = Enum.map(challenge.phases, & &1.how_to_enter)

      assert length(challenge.phases) === 3
      assert Enum.member?(titles, "Test how to enter 1")
      assert !Enum.member?(titles, "Test how to enter 2")
      assert !Enum.member?(titles, "Test how to enter 3")
    end

    test "error missing how to enter" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "how_to_enter",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0),
                  "how_to_enter" => "Test how to enter 1"
                },
                "1" => %{
                  "id" => Enum.at(phase_ids, 1)
                },
                "2" => %{
                  "id" => Enum.at(phase_ids, 2)
                }
              }
            }
          },
          user,
          ""
        )

      errors = Enum.map(changeset.changes.phases, & &1.errors)

      errors
      |> Enum.with_index()
      |> Enum.map(fn {error, index} ->
        case index do
          i when i in [1, 2] ->
            assert error[:how_to_enter]
            {_message, type} = error[:how_to_enter]
            assert type[:validation] === :required

          _ ->
            assert !error[:how_to_enter]
        end
      end)
    end

    test "no limit how to enter length" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      length = 15_001
      how_to_enter = TestHelpers.generate_random_string(length)

      assert {:ok, _} =
               Challenges.update(
                 challenge,
                 %{
                   "action" => "next",
                   "challenge" => %{
                     "section" => "how_to_enter",
                     "phases" => %{
                       "0" => %{
                         "id" => Enum.at(phase_ids, 0),
                         "how_to_enter" => how_to_enter
                       },
                       "1" => %{
                         "id" => Enum.at(phase_ids, 1),
                         "how_to_enter" => "Test how to enter 2"
                       },
                       "2" => %{
                         "id" => Enum.at(phase_ids, 2),
                         "how_to_enter" => "Test how to enter 3"
                       }
                     }
                   }
                 },
                 user,
                 ""
               )
    end
  end
end
