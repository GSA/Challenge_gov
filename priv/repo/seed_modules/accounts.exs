defmodule Seeds.SeedModules.Accounts do
  alias ChallengeGov.Accounts

  def run do
    IO.inspect "Seeding Accounts"

    # Super Admins
    create_role_of_status("super_admin", "active")
    create_role_of_status("super_admin", "pending")
    create_role_of_status("super_admin", "suspended")
    create_role_of_status("super_admin", "revoked")
    create_role_of_status("super_admin", "deactivated")
    create_role_of_status("super_admin", "decertified")

    # Admins
    create_role_of_status("admin", "active")
    create_role_of_status("admin", "pending")
    create_role_of_status("admin", "suspended")
    create_role_of_status("admin", "revoked")
    create_role_of_status("admin", "deactivated")
    create_role_of_status("admin", "decertified")

    # Challenge Managers
    create_role_of_status("challenge_manager", "active")
    create_role_of_status("challenge_manager", "pending")
    create_role_of_status("challenge_manager", "suspended")
    create_role_of_status("challenge_manager", "revoked")
    create_role_of_status("challenge_manager", "deactivated")
    create_role_of_status("challenge_manager", "decertified")

    # .gov Challenge Manager
    Accounts.system_create(%{
      token: Ecto.UUID.generate(),
      role: "challenge_manager",
      status: "active",
      email: "challenge_manager_active@example.gov",
      first_name: generate_name("challenge_manager"),
      last_name: generate_name("active"),
      last_active: last_active_for_role("challenge_manager"),
      terms_of_use: terms_and_privacy_for_role("challenge_manager"),
      privacy_guidelines: terms_and_privacy_for_role("challenge_manager")
    })

    # Solvers
    create_role_of_status("solver", "active")
    create_role_of_status("solver", "pending")
    create_role_of_status("solver", "suspended")
    create_role_of_status("solver", "revoked")
    create_role_of_status("solver", "deactivated")
    create_role_of_status("solver", "decertified")
  end

  defp create_role_of_status(role, status) do
    params = role_status_params(role, status)
    Accounts.system_create(params)
  end

  defp role_status_params(role, status) do
    %{
      token: Ecto.UUID.generate(),
      role: role,
      status: status,
      email: "#{role}_#{status}@example.com",
      first_name: generate_name(role),
      last_name: generate_name(status),
      last_active: last_active_for_role(role),
      terms_of_use: terms_and_privacy_for_role(role),
      privacy_guidelines: terms_and_privacy_for_role(role)
    }
  end

  defp generate_name(role_or_status) do
    role_or_status
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(fn text -> String.capitalize(text) end)
    |> Enum.join(" ")
  end

  defp last_active_for_role("deactivated"), do: deactivated_last_active()
  defp last_active_for_role("decertified"), do: decertified_last_active()
  defp last_active_for_role(_role), do: DateTime.utc_now()

  defp terms_and_privacy_for_role("pending"), do: nil
  defp terms_and_privacy_for_role(_role), do: DateTime.utc_now()

  defp deactivated_last_active() do
    DateTime.utc_now()
    |> DateTime.add(-60 * 60 * 24 * 91, :second)
  end

  defp decertified_last_active() do
    DateTime.utc_now()
    |> DateTime.add(-60 * 60 * 24 * 366, :second)
  end
end

Seeds.SeedModules.Accounts.run()