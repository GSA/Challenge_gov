defmodule ChallengeGov.ChallengeIntegrationTest do
  use Web.FeatureCase, async: true

  alias ChallengeGov.TestHelpers.AccountHelpers

  feature "create a challenge as a Challenge Manager", %{session: session} do
    create_and_sign_in_gov_challenge_manager(session)

    session
    |> click(link("Challenge management"))
    |> click(link("New"))
    |> complete_general_section()
    |> complete_details_section()
    |> complete_timeline_section()
    |> complete_prizes_section()
    |> complete_rules_section()
    |> complete_judging_section()
    |> complete_how_to_enter_section()
    |> complete_resources_section()

    session
    |> click(button("Submit"))
    |> has?(Query.text("Your Challenge was submitted on"))
  end

  defp complete_general_section(session) do
    year = String.slice("#{Timex.today().year}", -2..-1)

    session
    |> fill_in(text_field("Challenge manager of record"), with: "email@example.com")
    |> fill_in(text_field("Challenge manager email"), with: "email@example.com")
    |> fill_in(text_field("Point of contact email"), with: "email@example.com")
    |> click(select("Lead agency name"))
    |> click(option("Department of Agriculture"))
    |> click(select("Sub-agency name"))
    |> click(option("Agricultural Research Service"))
    |> fill_in(text_field("Fiscal year"), with: "FY#{year}")
    |> click(button("Next"))
  end

  defp complete_details_section(session) do
    session
    |> fill_in(text_field("Challenge title"), with: "Test Title")
    |> fill_in(text_field("Tagline"), with: "This is a test")
    |> find(select("Primary challenge type"))
    |> click(option("Ideas"))
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[0].innerHTML = 'Brief desciption here.'"
    )
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[1].innerHTML = 'Full description here.'"
    )
    |> execute_script("document.getElementById('challenge_upload_logo_false').click()")
    |> execute_script("document.getElementById('challenge_auto_publish_date_picker').focus()")
    |> execute_script(
      "document.getElementById('challenge_auto_publish_date_picker').value = '#{
        publish_date_picker()
      }'"
    )
    |> execute_script(
      "document.getElementById('challenge_auto_publish_date').value = '#{publish_date()}'"
    )

    # multi-phase false and accept confirm alert

    session
    |> accept_confirm(fn session ->
      execute_script(session, "document.getElementById('challenge_is_multi_phase_false').click()")
    end)

    # single phase date range
    session
    |> execute_script("document.getElementById('challenge_phases_0_start_date_picker').focus()")
    |> execute_script(
      "document.getElementById('challenge_phases_0_start_date_picker').value = '#{
        start_date_picker()
      }'"
    )
    |> execute_script(
      "document.getElementById('challenge_phases_0_start_date').value = '#{start_date()}'"
    )
    |> execute_script("document.getElementById('challenge_phases_0_end_date_picker').focus()")
    |> execute_script(
      "document.getElementById('challenge_phases_0_end_date_picker').value = '#{end_date_picker()}'"
    )
    |> execute_script(
      "document.getElementById('challenge_phases_0_end_date').value = '#{end_date()}'"
    )
    |> click(button("Next"))
  end

  defp complete_timeline_section(session) do
    session
    |> click(css(".add-nested-section"))
    |> fill_in(text_field("Timeline event title"), with: "Event 1")
    |> execute_script(
      "document.getElementById('challenge_timeline_events_0_date_picker').focus()"
    )
    |> execute_script(
      "document.getElementById('challenge_timeline_events_0_date_picker').value = '#{
        end_date_picker()
      }'"
    )
    |> execute_script(
      "document.getElementById('challenge_timeline_events_0_date').value = '#{end_date()}'"
    )
    |> click(button("Next"))
  end

  defp complete_prizes_section(session) do
    session
    |> execute_script("document.getElementById('challenge_prize_type_non_monetary').click()")
    |> fill_in(text_field("Non-monetary prize award"), with: "Prizes other than cash")
    |> click(button("Next"))
  end

  defp complete_rules_section(session) do
    session
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[0].innerHTML = 'Eligibilty requirements described here.'"
    )
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[1].innerHTML = 'Rules described here.'"
    )
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[2].innerHTML = 'Terms and conditions described here.'"
    )
    |> click(select("Legal authority"))
    |> click(option("Direct Prize Authority"))
    |> click(button("Next"))
  end

  defp complete_judging_section(session) do
    session
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[0].innerHTML = 'Judging criteria described here.'"
    )
    |> click(button("Next"))
  end

  defp complete_how_to_enter_section(session) do
    session
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[0].innerHTML = 'How to enter described here.'"
    )
    |> click(button("Next"))
  end

  defp complete_resources_section(session) do
    session
    |> click(button("Next"))
  end

  defp create_and_sign_in_gov_challenge_manager(session) do
    AccountHelpers.create_user(%{
      email: "challenge_owner_active@example.gov",
      role: "challenge_owner"
    })

    session
    |> visit("/dev_accounts")
    |> click(button("Gov Challenge Manager Active"))
  end

  defp publish_date_picker() do
    {:ok, publish_date_picker} =
      Timex.now()
      |> Timex.shift(days: 1)
      |> Timex.format("{YYYY}-{0M}-{0D}T{0h12}:{m}")

    publish_date_picker
  end

  defp publish_date() do
    {:ok, publish_date} =
      Timex.now()
      |> Timex.shift(days: 1)
      |> Timex.format("{YYYY}-{0M}-{0D} {0h12}:{m}:{s}Z")

    publish_date
  end

  defp start_date_picker() do
    {:ok, start_date_picker} =
      Timex.now()
      |> Timex.shift(days: 2)
      |> Timex.format("{YYYY}-{0M}-{0D}T{0h12}:{m}")

    start_date_picker
  end

  defp start_date() do
    {:ok, start_date} =
      Timex.now()
      |> Timex.shift(days: 2)
      |> Timex.format("{YYYY}-{0M}-{0D} {0h12}:{m}:{s}Z")

    start_date
  end

  defp end_date_picker() do
    {:ok, end_date_picker} =
      Timex.now()
      |> Timex.shift(days: 3)
      |> Timex.format("{YYYY}-{0M}-{0D}T{0h12}:{m}")

    end_date_picker
  end

  defp end_date() do
    {:ok, end_date} =
      Timex.now()
      |> Timex.shift(days: 3)
      |> Timex.format("{YYYY}-{0M}-{0D} {0h12}:{m}:{s}Z")

    end_date
  end
end
