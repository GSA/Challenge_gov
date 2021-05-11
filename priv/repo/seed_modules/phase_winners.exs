defmodule Seeds.SeedModules.PhaseWinners do
  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.PhaseWinners

  def run(challenges) do
    IO.inspect "Seeding PhaseWinners"

    challenge = Enum.at(challenges, 0)
    {:ok, phase} = Challenges.current_phase(challenge)

    generate_phase_winner(phase, winners_count: 2)

    challenge = Enum.at(challenges, 1)
    {:ok, phase} = Challenges.current_phase(challenge)

    generate_phase_winner(phase, winners_count: 5)
  end

  defp generate_phase_winner(phase, opts \\ []) do
    winners_count = Keyword.get(opts, :winners_count, 0)

    {:ok, phase_winner} = PhaseWinners.create(phase)

    PhaseWinners.update(phase_winner, %{
      "phase_winner" => %{
        "overview" => "<p>Seeded overview for phase #{phase.id}</p>",
        "overview_delta" => "{\"ops\":[{\"insert\":\"Seeded overview for phase #{phase.id}\\n\"}]}",
        "winners" => generate_winner_params(winners_count)
      }
    })
  end

  defp generate_winner_params(count) when count == 0, do: %{}

  defp generate_winner_params(count) do
    Enum.reduce(1..count, %{}, fn index, acc -> 
      Map.put(acc, index - 1, winner_params(index))
    end)
  end

  defp winner_params(index) do
    %{
      "id" => "",
      "image_path" => "",
      "place_title" => "Seeded place title #{index}",
      "name" => "Seeded name #{index}",
      "remove" => "false"
    }
  end
end
