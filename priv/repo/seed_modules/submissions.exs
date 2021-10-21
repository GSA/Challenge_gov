defmodule Seeds.SeedModules.Submissions do
  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Submissions

  @remote_ip "127.0.0.1"

  def run(challenges) do
    IO.inspect "Seeding Submissions"

    {:ok, solver} = Accounts.get_by_email("solver_active@example.com")

    challenge = Enum.at(challenges, 0)
    {:ok, phase} = Challenges.current_phase(challenge)

    generate_submission(solver, challenge, phase)

    challenge = Enum.at(challenges, 1)
    {:ok, phase} = Challenges.current_phase(challenge)

    generate_submission(solver, challenge, phase)
  end

  def generate_submission(solver, challenge, phase) do
    {:ok, submission} =
      Submissions.create_review(%{
        "title" => "Seeded Title",
        "brief_description" => "Seeded brief description",
        "description" => "Seeded long description",
        "terms_accepted" => "true",
        "external_url" => "https://www.example.com",
      }, solver, challenge, phase)

    Submissions.submit(submission, @remote_ip)
  end
end
