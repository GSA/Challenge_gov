defmodule ChallengeGov.Integration.UserTest do
  use Web.FeatureCase, async: true

  feature "View user list as an admin", %{session: session} do
    create_and_sign_in_admin(session)

    user1 =
      create_user(%{
        email: "example_user_ial1@example.com",
        role: "evaluator"
      })

    user2 =
      create_user(%{
        email: "example_user_ial2@example.com",
        role: "evaluator",
        ial_level: 2
      })

    session
    |> visit("/users")
    |> assert_has(Query.css("th", text: "IAL Level"))
    |> assert_has(Query.css("tr", text: user1.email))
    |> assert_has(Query.css("td:nth-child(5)", text: "1", count: 2))
    |> assert_has(Query.css("tr", text: user2.email))
    |> assert_has(Query.css("td:nth-child(5)", text: "2", count: 1))
  end

  feature "View a user as an admin", %{session: session} do
    create_and_sign_in_admin(session)

    user1 =
      create_user(%{
        email: "example_user_ial1@example.com",
        role: "evaluator"
      })

    user2 =
      create_user(%{
        email: "example_user_ial2@example.com",
        role: "evaluator",
        ial_level: 2
      })

    session
    |> visit("/users/#{user1.id}")
    |> assert_has(Query.css("dd", text: user1.email))
    |> assert_has(Query.css("dt", text: "IAL Level"))
    |> assert_has(Query.css("dd", text: "1", count: 2))

    session
    |> visit("/users/#{user2.id}")
    |> assert_has(Query.css("dd", text: user2.email))
    |> assert_has(Query.css("dt", text: "IAL Level"))
    |> assert_has(Query.css("dd", text: "2", count: 2))
  end

  defp create_and_sign_in_admin(session) do
    create_user(%{
      email: "admin_active@example.com",
      role: "admin"
    })

    session
    |> visit("/dev_accounts")
    |> click(button("Admin Active"))
  end

  defp create_user(user_params) do
    user =
      ChallengeGov.TestHelpers.AccountHelpers.create_user(user_params)

    ChallengeGov.CertificationLogs.track(%{
      user_id: user.id,
      user_role: user.role,
      user_identifier: user.email,
      certified_at: Timex.now(),
      expires_at: ChallengeGov.CertificationLogs.calulate_expiry()
    })

    user
  end
end
