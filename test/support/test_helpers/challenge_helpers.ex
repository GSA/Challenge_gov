defmodule ChallengeGov.TestHelpers.ChallengeHelpers do
  @moduledoc """
  Helper factory functions for challenges
  """

  alias ChallengeGov.Challenges
  alias ChallengeGov.Repo

  alias ChallengeGov.TestHelpers
  alias ChallengeGov.TestHelpers.AgencyHelpers

  defp default_attributes(attributes) do
    Map.merge(
      %{
        title: "Test challenge",
        tagline: "Test tagline",
        brief_description: "Test brief description",
        description: "Test desription for a challenge",
        terms_and_conditions: "Test terms",
        terms_equal_rules: false,
        eligibility_requirements: "Test eligibility",
        rules: "Test rules",
        legal_authority: "Test legal authority",
        prize_type: "both",
        challenge_manager: "Test challenge manager",
        challenge_manager_email: "test@example.com",
        poc_email: "test_poc@example.com",
        agency_id: AgencyHelpers.create_agency().id,
        fiscal_year: "FY20",
        status: "published",
        primary_type: Enum.at(Challenges.challenge_types(), 0),
        auto_publish_date: Timex.shift(Timex.now(), hours: 1)
      },
      attributes
    )
  end

  def create_challenge(attributes \\ %{}, user \\ nil) do
    {:ok, challenge} =
      %Challenges.Challenge{}
      |> Challenges.Challenge.changeset(default_attributes(attributes))
      |> Repo.insert()

    if !is_nil(user) do
      %Challenges.ChallengeManager{}
      |> Challenges.ChallengeManager.changeset(%{
        user_id: user.id,
        challenge_id: challenge.id
      })
      |> Repo.insert()
    end

    Repo.preload(challenge, [:agency, :sub_agency])
  end

  def create_single_phase_challenge(user, attributes \\ %{}) do
    challenge = create_challenge(attributes, user)

    {:ok, challenge} =
      Challenges.update(
        challenge,
        %{
          "action" => "next",
          "challenge" => %{
            "section" => "details",
            "challenge_title" => challenge.title,
            "upload_logo" => "false",
            "is_multi_phase" => "false",
            "phases" => %{
              "0" => %{
                "start_date" => TestHelpers.iso_timestamp(),
                "end_date" => TestHelpers.iso_timestamp(hours: 1),
                "open_to_submissions" => "true"
              }
            }
          }
        },
        user,
        ""
      )

    challenge
  end

  def create_closed_single_phase_challenge(user, attributes \\ %{}) do
    challenge = create_challenge(attributes, user)

    {:ok, challenge} =
      Challenges.update(
        challenge,
        %{
          "action" => "next",
          "challenge" => %{
            "section" => "details",
            "challenge_title" => challenge.title,
            "upload_logo" => "false",
            "is_multi_phase" => "false",
            "phases" => %{
              "0" => %{
                "start_date" => TestHelpers.iso_timestamp(hours: -2),
                "end_date" => TestHelpers.iso_timestamp(hours: -1),
                "open_to_submissions" => "true"
              }
            }
          }
        },
        user,
        ""
      )

    challenge
  end

  def create_multi_phase_challenge(user, attributes \\ %{}) do
    challenge = create_challenge(attributes, user)

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
                "start_date" => TestHelpers.iso_timestamp(hours: 1),
                "end_date" => TestHelpers.iso_timestamp(hours: 2),
                "open_to_submissions" => "true"
              },
              "1" => %{
                "title" => "Test 1",
                "start_date" => TestHelpers.iso_timestamp(hours: 3),
                "end_date" => TestHelpers.iso_timestamp(hours: 4),
                "open_to_submissions" => "true"
              },
              "2" => %{
                "title" => "Test 2",
                "start_date" => TestHelpers.iso_timestamp(hours: 5),
                "end_date" => TestHelpers.iso_timestamp(hours: 6),
                "open_to_submissions" => "false"
              }
            }
          }
        },
        user,
        ""
      )

    challenge
  end

  def create_open_multi_phase_challenge(user, attributes \\ %{}) do
    challenge = create_challenge(attributes, user)

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
                "start_date" => TestHelpers.iso_timestamp(),
                "end_date" => TestHelpers.iso_timestamp(hours: 1),
                "open_to_submissions" => "true"
              },
              "1" => %{
                "title" => "Test 1",
                "start_date" => TestHelpers.iso_timestamp(hours: 2),
                "end_date" => TestHelpers.iso_timestamp(hours: 3),
                "open_to_submissions" => "true"
              },
              "2" => %{
                "title" => "Test 2",
                "start_date" => TestHelpers.iso_timestamp(hours: 4),
                "end_date" => TestHelpers.iso_timestamp(hours: 5),
                "open_to_submissions" => "false"
              }
            }
          }
        },
        user,
        ""
      )

    challenge
  end

  def create_closed_multi_phase_challenge(user, attributes \\ %{}) do
    challenge = create_challenge(attributes, user)

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
                "start_date" => TestHelpers.iso_timestamp(hours: -2),
                "end_date" => TestHelpers.iso_timestamp(hours: -1),
                "open_to_submissions" => "true"
              },
              "1" => %{
                "title" => "Test 2",
                "start_date" => TestHelpers.iso_timestamp(),
                "end_date" => TestHelpers.iso_timestamp(hours: 1),
                "open_to_submissions" => "false"
              }
            }
          }
        },
        user,
        ""
      )

    challenge
  end

  def create_closed_and_open_phased_multi_phase_challenge(user, attributes \\ %{}) do
    challenge = create_challenge(attributes, user)

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
                "start_date" => TestHelpers.iso_timestamp(hours: -2),
                "end_date" => TestHelpers.iso_timestamp(hours: -1),
                "open_to_submissions" => "true"
              },
              "1" => %{
                "title" => "Test 2",
                "start_date" => TestHelpers.iso_timestamp(),
                "end_date" => TestHelpers.iso_timestamp(hours: 1),
                "open_to_submissions" => "true"
              }
            }
          }
        },
        user,
        ""
      )

    challenge
  end

  def create_archived_multi_phase_challenge(user, attributes \\ %{}) do
    challenge = create_challenge(attributes, user)

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
                "start_date" => TestHelpers.iso_timestamp(months: -5),
                "end_date" => TestHelpers.iso_timestamp(months: -4),
                "open_to_submissions" => "true"
              },
              "1" => %{
                "title" => "Test 2",
                "start_date" => TestHelpers.iso_timestamp(months: -3, hours: -2),
                "end_date" => TestHelpers.iso_timestamp(months: -3, hours: -1),
                "open_to_submissions" => "false"
              }
            }
          }
        },
        user,
        ""
      )

    challenge
  end

  def create_old_archived_multi_phase_challenge(user, attributes \\ %{}) do
    challenge = create_challenge(attributes, user)

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
                "start_date" => TestHelpers.iso_timestamp(months: -5),
                "end_date" => TestHelpers.iso_timestamp(months: -5),
                "open_to_submissions" => "true"
              },
              "1" => %{
                "title" => "Test 2",
                "start_date" => TestHelpers.iso_timestamp(months: -5),
                "end_date" => TestHelpers.iso_timestamp(months: -4),
                "open_to_submissions" => "false"
              }
            }
          }
        },
        user,
        ""
      )

    challenge
  end
end
