Code.require_file("seed_modules/accounts.exs", __DIR__)
Code.require_file("seed_modules/agencies.exs", __DIR__)
Code.require_file("seed_modules/challenges.exs", __DIR__)
Code.require_file("seed_modules/phase_winners.exs", __DIR__)
Code.require_file("seed_modules/submissions.exs", __DIR__)

defmodule SeedsUpdated do
  alias Seeds.SeedModules.Accounts
  alias Seeds.SeedModules.Agencies
  alias Seeds.SeedModules.Challenges
  alias Seeds.SeedModules.PhaseWinners
  alias Seeds.SeedModules.Submissions

  def run() do
    Agencies.run()
    Accounts.run()
    challenges = Challenges.run()
    Submissions.run(challenges)
    PhaseWinners.run(challenges)
  end
end

SeedsUpdated.run()