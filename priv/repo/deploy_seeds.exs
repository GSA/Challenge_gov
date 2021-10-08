# Script for populating the database. You can run it as:
#
#     mix run priv/repo/deploy_seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ChallengeGov.Repo.insert!(%ChallengeGov.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias ChallengeGov.Accounts

defmodule DeployHelpers do
  def create_super_admin(nil, nil, nil) do
  end

  def create_super_admin(email, first_name, last_name) do
    case Accounts.get_by_email(email) do
      {:error, :not_found} ->
        Accounts.system_create(%{
          email: email,
          first_name: first_name,
          last_name: last_name,
          role: "super_admin",
          terms_of_use: DateTime.truncate(DateTime.utc_now(), :second),
          privacy_guidelines: DateTime.truncate(DateTime.utc_now(), :second),
          status: "active"
        })

      _ ->
        nil
    end
  end
end

defmodule DeploySeeds do
  import DeployHelpers

  def run do
    create_super_admin(
      System.get_env("FIRST_USER_EMAIL"),
      System.get_env("FIRST_USER_FN"),
      System.get_env("FIRST_USER_LN")
    )
  end
end

DeploySeeds.run()
