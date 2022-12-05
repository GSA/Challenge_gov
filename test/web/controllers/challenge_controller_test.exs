defmodule Web.ChallengeControllerTest do
  use Web.ConnCase

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.AgencyHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "index for challenges" do
    setup([:create_challenges])

    test "redirect to sign in when signed out", %{conn: conn} do
      conn = get(conn, Routes.challenge_path(conn, :index))

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "failure: access list of challenges as a solver", %{conn: conn} do
      conn = prep_conn_solver(conn)
      %{current_user: _user} = conn.assigns

      conn = get(conn, Routes.challenge_path(conn, :index))

      assert conn.status === 302
      assert get_flash(conn, :error) === "You are not authorized"
      assert conn.halted
      assert redirected_to(conn) == Routes.dashboard_path(conn, :index)
    end

    # test "given challenges in [approved, published] and substatus in [open, nil], puts challenge in the published section",
    #      %{
    #        conn: conn,
    #        approved_challenge: approved_challenge,
    #        published_challenge_open: published_challenge_open
    #      } do
    #   conn =
    #     conn
    #     |> prep_conn()
    #     |> get(Routes.challenge_path(conn, :index))

    #   html = html_response(conn, 200)

    #   result =
    #     html
    #     |> Floki.parse_document!()
    #     |> Floki.find("#active-challenges")
    #     |> Floki.find("table tbody tr")
    #     |> Enum.map(fn row -> Floki.text(row) end)

    #   assert Enum.count(result) == 2
    #   assert Enum.at(result, 0) =~ to_string(approved_challenge.id)
    #   assert Enum.at(result, 1) =~ to_string(published_challenge_open.id)
    # end

    # test "given challenges in draft, puts challenge in the draft section", %{
    #   conn: conn,
    #   draft_challenge: draft_challenge,
    #   gsa_review_challenge: gsa_review_challenge,
    #   edits_requested_challenge: edits_requested_challenge,
    #   unpublished_challenge: unpublished_challenge
    # } do
    #   conn =
    #     conn
    #     |> prep_conn()
    #     |> get(Routes.challenge_path(conn, :index))

    #   html = html_response(conn, 200)

    #   result =
    #     html
    #     |> Floki.parse_document!()
    #     |> Floki.find("#draft-challenges")
    #     |> Floki.find("table tbody tr")
    #     |> Enum.map(fn row -> Floki.text(row) end)

    #   assert Enum.count(result) == 4
    #   assert Enum.at(result, 0) =~ to_string(unpublished_challenge.id)
    #   assert Enum.at(result, 1) =~ to_string(edits_requested_challenge.id)
    #   assert Enum.at(result, 2) =~ to_string(gsa_review_challenge.id)
    #   assert Enum.at(result, 3) =~ to_string(draft_challenge.id)
    # end

    # test "given challenges in [published] and sub_status in [closed, archived], puts challenge in the archived section",
    #      %{
    #        conn: conn,
    #        published_challenge_closed: published_challenge_closed,
    #        published_challenge_archived: published_challenge_archived,
    #        archived_challenge: archived_challenge
    #      } do
    #   conn =
    #     conn
    #     |> prep_conn()
    #     |> get(Routes.challenge_path(conn, :index))

    #   html = html_response(conn, 200)

    #   result =
    #     html
    #     |> Floki.parse_document!()
    #     |> Floki.find("#archived-challenges")
    #     |> Floki.find("table tbody tr")
    #     |> Enum.map(fn row -> Floki.text(row) end)

    #   assert Enum.count(result) == 3
    #   assert Enum.at(result, 0) =~ to_string(archived_challenge.id)
    #   assert Enum.at(result, 1) =~ to_string(published_challenge_archived.id)
    #   assert Enum.at(result, 2) =~ to_string(published_challenge_closed.id)
    # end

    defp create_challenges(_ctx) do
      user =
        AccountHelpers.create_user(%{
          email: "challenge_manager_user@example.com",
          role: "challenge_manager"
        })

      published_challenge_open =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          status: "published",
          sub_status: "open"
        })

      published_challenge_closed =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          status: "published",
          sub_status: "closed"
        })

      published_challenge_archived =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          status: "published",
          sub_status: "archived"
        })

      approved_challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, status: "approved"})

      draft_challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "draft"})

      gsa_review_challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, status: "gsa_review"})

      edits_requested_challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, status: "edits_requested"})

      unpublished_challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, status: "unpublished"})

      archived_challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, status: "archived"})

      [
        published_challenge_open: published_challenge_open,
        published_challenge_closed: published_challenge_closed,
        published_challenge_archived: published_challenge_archived,
        approved_challenge: approved_challenge,
        draft_challenge: draft_challenge,
        gsa_review_challenge: gsa_review_challenge,
        edits_requested_challenge: edits_requested_challenge,
        unpublished_challenge: unpublished_challenge,
        archived_challenge: archived_challenge
      ]
    end
  end

  describe "show for challenges" do
    test "successfully retrieve a challenge", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

      conn = get(conn, Routes.challenge_path(conn, :show, challenge.id))

      %{
        user: user_in_assigns,
        challenge: challenge_in_assigns,
        events: events,
        supporting_documents: supporting_documents
      } = conn.assigns

      assert user === user_in_assigns

      assert challenge.id === challenge_in_assigns.id
      assert Enum.empty?(events)
      assert Enum.empty?(supporting_documents)

      assert html_response(conn, 200) =~ "Challenge"
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      user = AccountHelpers.create_user(%{email: "user@example.com"})
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

      conn = get(conn, Routes.challenge_path(conn, :show, challenge.id))

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "new for challenges" do
    test "successfully open wizard form", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      conn = get(conn, Routes.challenge_path(conn, :new))

      %{
        user: user_in_assigns,
        changeset: changeset,
        path: path,
        section: section,
        challenge: challenge
      } = conn.assigns

      assert user === user_in_assigns
      assert changeset === Challenges.new(user)
      assert section === "general"
      assert path === Routes.challenge_path(conn, :create)
      assert challenge === nil

      assert html_response(conn, 200) =~ "Create a new challenge"
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      conn = get(conn, Routes.challenge_path(conn, :new))

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "create an announcement" do
    test "successfully", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          agency_id: agency.id,
          title: "Test Title 1",
          description: "Test description 1",
          status: "pending"
        })

      conn =
        post(conn, Routes.challenge_path(conn, :create_announcement, challenge.id),
          announcement: "Test announcement"
        )

      assert get_flash(conn, :info) === "Challenge announcement posted"
      assert redirected_to(conn) === Routes.challenge_path(conn, :show, challenge.id)
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      user = AccountHelpers.create_user(%{email: "user@example.com"})
      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          agency_id: agency.id,
          title: "Test Title 1",
          description: "Test description 1",
          status: "pending"
        })

      conn =
        post(conn, Routes.challenge_path(conn, :create_announcement, challenge.id),
          announcement: "Test announcement"
        )

      assert conn.status === 302
      assert conn.halted
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "edit for challenges" do
    test "successfully", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "draft"})

      conn = get(conn, Routes.challenge_path(conn, :edit, challenge.id, "general"))

      %{
        user: user_in_assigns,
        challenge: challenge_in_assigns,
        changeset: changeset,
        section: section
      } = conn.assigns

      assert user === user_in_assigns
      assert challenge.id === challenge_in_assigns.id
      assert changeset === Challenges.edit(challenge_in_assigns)
      assert section === "general"

      assert conn.request_path ===
               Routes.challenge_path(conn, :edit, challenge_in_assigns, "general")

      assert html_response(conn, 200) =~ "Challenge"
    end

    test "successfully edit a challenge in review", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge =
        ChallengeHelpers.create_challenge(
          %{user_id: user.id, status: "gsa_review", title: "Who's Line is it Anyway?"},
          user
        )

      conn = get(conn, Routes.challenge_path(conn, :edit, challenge.id, "general"))

      %{
        current_user: user_in_assigns,
        challenge: challenge_in_assigns,
        section: section
      } = conn.assigns

      assert user === user_in_assigns
      assert challenge.id === challenge_in_assigns.id
      assert html_response(conn, 200) =~ "Challenge"
      assert challenge_in_assigns.status === "draft"
      assert section === "general"

      assert conn.request_path ===
               Routes.challenge_path(conn, :edit, challenge_in_assigns, "general")

      assert get_flash(conn, :warning) ===
               [
                 {:safe,
                  [
                    60,
                    "p",
                    [[32, "class", 61, 34, "h4 mb-0", 34]],
                    62,
                    "Challenge Removed from Queue",
                    60,
                    47,
                    "p",
                    62
                  ]},
                 {:safe,
                  [
                    60,
                    "p",
                    [],
                    62,
                    "Once edits are made you will need to resubmit this challenge for GSA approval",
                    60,
                    47,
                    "p",
                    62
                  ]}
               ]
    end

    test "successfully edit a published challenge", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge =
        ChallengeHelpers.create_challenge(
          %{user_id: user.id, status: "published", title: "Who's Line is it Anyway?"},
          user
        )

      conn = get(conn, Routes.challenge_path(conn, :edit, challenge.id, "general"))

      %{
        current_user: user_in_assigns,
        challenge: challenge_in_assigns,
        changeset: changeset,
        section: section
      } = conn.assigns

      assert user === user_in_assigns
      assert challenge.id === challenge_in_assigns.id
      assert changeset === Challenges.edit(challenge_in_assigns)
      assert html_response(conn, 200) =~ "Challenge"
      assert section === "general"

      assert conn.request_path ===
               Routes.challenge_path(conn, :edit, challenge_in_assigns, "general")

      assert challenge_in_assigns.status === "published"
    end
  end

  describe "update for challenges" do
    test "successfully update a section as a draft", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "draft"})

      params = %{
        "id" => "#{challenge.id}",
        "action" => "save_draft",
        "challenge" => %{
          "section" => "general",
          "agency_id" => AgencyHelpers.create_agency().id,
          "challenge_id" => "#{challenge.id}",
          "challenge_manager" => "Challenge Manager",
          "challenge_manager_email" => "challenge_manager_active@example.com",
          "federal_partners" => %{
            "0" => %{
              "agency_id" => AgencyHelpers.create_agency().id,
              "sub_agency_id" => AgencyHelpers.create_agency().id
            }
          },
          "fiscal_year" => "FY20",
          "local_timezone" => "America/New_York",
          "non_federal_partners" => %{
            "0" => %{"id" => "1", "name" => "Non federal partner 1"},
            "1" => %{"id" => "2", "name" => "Non federal partner 2"}
          },
          "poc_email" => "new_poc@example.com",
          "sub_agency_id" => AgencyHelpers.create_agency().id,
          "user_id" => "#{user.id}"
        }
      }

      conn = put(conn, Routes.challenge_path(conn, :update, challenge.id), params)

      {:ok, challenge} = Challenges.get(challenge.id)

      assert challenge.status === "draft"
      assert challenge.poc_email === "new_poc@example.com"
      assert get_flash(conn, :info) === "Challenge saved as draft"
      assert redirected_to(conn) === Routes.challenge_path(conn, :edit, challenge.id, "general")
    end

    test "successfully update a section and return to review", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "draft"})

      params = %{
        "id" => "#{challenge.id}",
        "action" => "save",
        "challenge" => %{
          "section" => "general",
          "agency_id" => AgencyHelpers.create_agency().id,
          "challenge_id" => "#{challenge.id}",
          "challenge_manager" => "Challenge Manager",
          "challenge_manager_email" => "challenge_manager_active@example.com",
          "federal_partners" => %{
            "0" => %{
              "agency_id" => AgencyHelpers.create_agency().id,
              "sub_agency_id" => AgencyHelpers.create_agency().id
            }
          },
          "fiscal_year" => "FY20",
          "local_timezone" => "America/New_York",
          "non_federal_partners" => %{
            "0" => %{"id" => "1", "name" => "Non federal partner 1"},
            "1" => %{"id" => "2", "name" => "Non federal partner 2"}
          },
          "poc_email" => "new_poc@example.com",
          "sub_agency_id" => AgencyHelpers.create_agency().id,
          "user_id" => "#{user.id}"
        }
      }

      conn = put(conn, Routes.challenge_path(conn, :update, challenge.id), params)

      {:ok, challenge} = Challenges.get(challenge.id)

      assert challenge.status === "draft"
      assert challenge.poc_email === "new_poc@example.com"
      assert get_flash(conn, :info) === "Changes saved"

      assert redirected_to(conn) ===
               Routes.challenge_path(conn, :edit, challenge.id, "general")
    end

    test "successfully update a section and go to next section", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "draft"})

      params = %{
        "id" => "#{challenge.id}",
        "action" => "next",
        "challenge" => %{
          "section" => "general",
          "agency_id" => AgencyHelpers.create_agency().id,
          "challenge_id" => "#{challenge.id}",
          "challenge_manager" => "Challenge Manager",
          "challenge_manager_email" => "challenge_manager_active@example.com",
          "federal_partners" => %{
            "0" => %{
              "agency_id" => AgencyHelpers.create_agency().id,
              "sub_agency_id" => AgencyHelpers.create_agency().id
            }
          },
          "fiscal_year" => "FY20",
          "local_timezone" => "America/New_York",
          "non_federal_partners" => %{
            "0" => %{"id" => "1", "name" => "Non federal partner 1"},
            "1" => %{"id" => "2", "name" => "Non federal partner 2"}
          },
          "poc_email" => "new_poc@example.com",
          "sub_agency_id" => AgencyHelpers.create_agency().id,
          "user_id" => "#{user.id}"
        }
      }

      conn = put(conn, Routes.challenge_path(conn, :update, challenge.id), params)

      {:ok, challenge} = Challenges.get(challenge.id)

      to_section = Challenges.to_section("general", "next")

      assert challenge.status === "draft"
      assert challenge.poc_email === "new_poc@example.com"

      assert redirected_to(conn) ===
               Routes.challenge_path(conn, :edit, challenge.id, to_section.id)
    end

    test "successfully update a published challenge", %{conn: conn} do
      conn = prep_conn_challenge_manager(conn)
      %{current_user: user} = conn.assigns

      past_publish_date =
        DateTime.utc_now()
        |> Timex.shift(days: -1)
        |> DateTime.to_string()

      challenge =
        ChallengeHelpers.create_challenge(
          %{
            user_id: user.id,
            status: "published",
            auto_publish_date: past_publish_date
          },
          user
        )

      params = %{
        "id" => "#{challenge.id}",
        "action" => "save",
        "challenge" => %{
          "section" => "general",
          "agency_id" => AgencyHelpers.create_agency().id,
          "challenge_id" => "#{challenge.id}",
          "challenge_manager" => "Challenge Manager",
          "challenge_manager_email" => "challenge_manager_active@example.com",
          "federal_partners" => %{
            "0" => %{
              "agency_id" => AgencyHelpers.create_agency().id,
              "sub_agency_id" => AgencyHelpers.create_agency().id
            }
          },
          "fiscal_year" => "FY20",
          "local_timezone" => "America/New_York",
          "non_federal_partners" => %{
            "0" => %{"id" => "1", "name" => "Non federal partner 1"},
            "1" => %{"id" => "2", "name" => "Non federal partner 2"}
          },
          "poc_email" => "new_poc@example.com",
          "sub_agency_id" => AgencyHelpers.create_agency().id,
          "user_id" => "#{user.id}"
        }
      }

      conn = put(conn, Routes.challenge_path(conn, :update, challenge.id), params)

      {:ok, challenge} = Challenges.get(challenge.id)

      assert challenge.status === "published"
      assert challenge.poc_email === "new_poc@example.com"

      assert get_flash(conn, :info) ===
               [
                 safe: [
                   60,
                   "p",
                   [[32, "class", 61, 34, "h4 mb-0", 34]],
                   62,
                   "Challenge updated",
                   60,
                   47,
                   "p",
                   62
                 ],
                 safe: [
                   60,
                   "p",
                   [],
                   62,
                   [
                     "Please share critical updates with Solvers that have saved this challenge ",
                     [
                       60,
                       "a",
                       [[32, "href", 61, 34, "/challenges/#{challenge.id}/bulletin/new", 34]],
                       62,
                       "Govdelivery",
                       60,
                       47,
                       "a",
                       62
                     ]
                   ],
                   60,
                   47,
                   "p",
                   62
                 ]
               ]

      assert redirected_to(conn) ===
               Routes.challenge_path(conn, :edit, challenge.id, "general")
    end
  end

  defp prep_conn(conn) do
    user = AccountHelpers.create_user(%{role: "admin"})
    assign(conn, :current_user, user)
  end

  defp prep_conn_challenge_manager(conn) do
    user =
      AccountHelpers.create_user(%{
        email: "challenge_manager@example.com",
        role: "challenge_manager"
      })

    assign(conn, :current_user, user)
  end

  defp prep_conn_solver(conn) do
    user = AccountHelpers.create_user(%{role: "solver"})
    assign(conn, :current_user, user)
  end
end
