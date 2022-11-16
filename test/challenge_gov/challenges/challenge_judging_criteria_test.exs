defmodule ChallengeGov.ChallengeJudgingCriteriaTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "adding judging criteria to single phase challenge" do
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
              "section" => "judging",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0),
                  "judging_criteria" => "Test judging criteria 1"
                }
              }
            }
          },
          user,
          ""
        )

      titles = Enum.map(challenge.phases, & &1.judging_criteria)

      assert length(challenge.phases) === 1
      assert Enum.member?(titles, "Test judging criteria 1")
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
              "section" => "judging",
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

      titles = Enum.map(challenge.phases, & &1.judging_criteria)

      assert length(challenge.phases) === 1
      assert Enum.member?(titles, nil)
    end

    test "error missing judging criteria" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "judging",
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
        assert error[:judging_criteria]
        {_message, type} = error[:judging_criteria]
        assert type[:validation] === :required
      end)
    end

    test "no limit judging criteria length" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      length = 15_001
      judging_criteria = TestHelpers.generate_random_string(length)

      assert {:ok, _} =
               Challenges.update(
                 challenge,
                 %{
                   "action" => "next",
                   "challenge" => %{
                     "section" => "judging",
                     "phases" => %{
                       "0" => %{
                         "id" => Enum.at(phase_ids, 0),
                         "judging_criteria" => judging_criteria
                       }
                     }
                   }
                 },
                 user,
                 ""
               )
    end
  end

  describe "adding judging criteria to multi phase challenge" do
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
              "section" => "judging",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0),
                  "judging_criteria" => "Test judging criteria 1"
                },
                "1" => %{
                  "id" => Enum.at(phase_ids, 1),
                  "judging_criteria" => "Test judging criteria 2"
                },
                "2" => %{
                  "id" => Enum.at(phase_ids, 2),
                  "judging_criteria" => "Test judging criteria 3"
                }
              }
            }
          },
          user,
          ""
        )

      titles = Enum.map(challenge.phases, & &1.judging_criteria)

      assert length(challenge.phases) === 3
      assert Enum.member?(titles, "Test judging criteria 1")
      assert Enum.member?(titles, "Test judging criteria 2")
      assert Enum.member?(titles, "Test judging criteria 3")
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
              "section" => "judging",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0),
                  "judging_criteria" => "Test judging criteria 1"
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

      titles = Enum.map(challenge.phases, & &1.judging_criteria)

      assert length(challenge.phases) === 3
      assert Enum.member?(titles, "Test judging criteria 1")
      assert !Enum.member?(titles, "Test judging criteria 2")
      assert !Enum.member?(titles, "Test judging criteria 3")
    end

    test "error missing judging criteria" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      {:error, changeset} =
        Challenges.update(
          challenge,
          %{
            "action" => "next",
            "challenge" => %{
              "section" => "judging",
              "phases" => %{
                "0" => %{
                  "id" => Enum.at(phase_ids, 0),
                  "judging_criteria" => "Test judging criteria 1"
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
            assert error[:judging_criteria]
            {_message, type} = error[:judging_criteria]
            assert type[:validation] === :required

          _ ->
            assert !error[:judging_criteria]
        end
      end)
    end

    test "No limit judging criteria length" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      phase_ids = Enum.map(challenge.phases, & &1.id)

      length = 15_001
      judging_criteria = TestHelpers.generate_random_string(length)

      assert {:ok, _} =
               Challenges.update(
                 challenge,
                 %{
                   "action" => "next",
                   "challenge" => %{
                     "section" => "judging",
                     "phases" => %{
                       "0" => %{
                         "id" => Enum.at(phase_ids, 0),
                         "judging_criteria" => judging_criteria
                       },
                       "1" => %{
                         "id" => Enum.at(phase_ids, 1),
                         "judging_criteria" => "Test judging criteria 2"
                       },
                       "2" => %{
                         "id" => Enum.at(phase_ids, 2),
                         "judging_criteria" => "Test judging criteria 3"
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
