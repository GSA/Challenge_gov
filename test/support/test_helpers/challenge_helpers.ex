defmodule ChallengeGov.TestHelpers.ChallengeHelpers do
  @moduledoc """
  Helper factory functions for challenges
  """
  alias ChallengeGov.Challenges
  alias ChallengeGov.Repo

  defp default_attributes(attributes) do
    Map.merge(
      %{
        title: "Test challenge",
        tagline: "Test tagline",
        brief_description: "Test brief description",
        description: "Test desription for a challenge",
        status: "published",
        auto_publish_date: Timex.shift(Timex.now(), hours: 1)
      },
      attributes
    )
  end

  def create_challenge(attributes \\ %{}) do
    {:ok, challenge} =
      %Challenges.Challenge{}
      |> Challenges.Challenge.changeset(default_attributes(attributes))
      |> Repo.insert()

    Repo.preload(challenge, [:agency])
  end

  def create_single_phase_challenge(user, attributes \\ %{}) do
    challenge = create_challenge(attributes)

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
                "start_date" => iso_timestamp(),
                "end_date" => iso_timestamp(hours: 1)
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
    challenge = create_challenge(attributes)

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

    challenge
  end

  defp iso_timestamp(opts \\ []) do
    {:ok, timestamp} =
      Timex.now()
      |> Timex.shift(opts)
      |> Timex.format("{ISO:Extended}")

    timestamp
  end
end
