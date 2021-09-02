defmodule ChallengeGov.ChallengeTest do
  use Web.FeatureCase, async: true

  alias ChallengeGov.TestHelpers.AccountHelpers

  feature "create a challenge as a Challenge Manager", %{session: session} do
    create_and_sign_in_challenge_manager(session)
    year = String.slice("#{Timex.today.year}", -2..-1)

    {:ok, publish_date_picker} =
      Timex.now()
      |> Timex.shift(days: 1)
      |> Timex.format("{YYYY}-{0M}-{0D}T{0h12}:{m}")

    {:ok, publish_date} =
      Timex.now()
      |> Timex.shift(days: 1)
      |> Timex.format("{YYYY}-{0M}-{0D} {0h12}:{m}:{s}Z")

    {:ok, start_date_picker} =
      Timex.now()
      |> Timex.shift(days: 2)
      |> Timex.format("{YYYY}-{0M}-{0D}T{0h12}:{m}")

    {:ok, start_date} =
      Timex.now()
      |> Timex.shift(days: 2)
      |> Timex.format("{YYYY}-{0M}-{0D} {0h12}:{m}:{s}Z")

    {:ok, end_date_picker} =
      Timex.now()
      |> Timex.shift(days: 3)
      |> Timex.format("{YYYY}-{0M}-{0D}T{0h12}:{m}")

    {:ok, end_date} =
      Timex.now()
      |> Timex.shift(days: 3)
      |> Timex.format("{YYYY}-{0M}-{0D} {0h12}:{m}:{s}Z")

    session
    |> click(link("Challenge management"))
    |> click(link("New"))
    |> assert_text("Please note a Challenge Manager with a .gov or .mil email will need to submit")
    |> fill_in(text_field("Challenge manager of record"), with: "email@example.com")
    |> fill_in(text_field("Challenge manager email"), with: "email@example.com")
    |> fill_in(text_field("Point of contact email"), with: "email@example.com")
    |> click(select("Lead agency name"))
    |> click(option("Department of Agriculture"))
    |> click(select("Sub-agency name"))
    |> click(option("Agricultural Research Service"))
    |> fill_in(text_field("Fiscal year"), with: "FY#{year}")
    |> click(button("Next"))
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
    |> execute_script(
      "document.getElementById('challenge_upload_logo_false').click()"
    )
    |> execute_script(
      "document.getElementById('challenge_auto_publish_date_picker').focus()"
    )
    |> execute_script(
      "document.getElementById('challenge_auto_publish_date_picker').value = '#{publish_date_picker}'"
    )
    |> execute_script(
      "document.getElementById('challenge_auto_publish_date').value = '#{publish_date}'"
    )

    # multi-phase false and accept confirm alert

    session
    |> accept_confirm(fn(session) ->
      execute_script(session,
        "document.getElementById('challenge_is_multi_phase_false').click()"
      )
    end)

    # single phase date range

    session
    |> execute_script(
      "document.getElementById('challenge_phases_0_start_date_picker').focus()"
    )
    |> execute_script(
      "document.getElementById('challenge_phases_0_start_date_picker').value = '#{start_date_picker}'"
    )
    |> execute_script(
      "document.getElementById('challenge_phases_0_start_date').value = '#{start_date}'"
    )
    |> execute_script(
      "document.getElementById('challenge_phases_0_end_date_picker').focus()"
    )
    |> execute_script(
      "document.getElementById('challenge_phases_0_end_date_picker').value = '#{end_date_picker}'"
    )
    |> execute_script(
      "document.getElementById('challenge_phases_0_end_date').value = '#{end_date}'"
    )
    |> click(button("Next"))

    # Timeline
    session
    |> click(css(".add-nested-section"))
    |> fill_in(text_field("Timeline event title"), with: "Event 1")
    |> execute_script(
      "document.getElementById('challenge_timeline_events_0_date_picker').focus()"
    )
    |> execute_script(
      "document.getElementById('challenge_timeline_events_0_date_picker').value = '#{end_date_picker}'"
    )
    |> execute_script(
      "document.getElementById('challenge_timeline_events_0_date').value = '#{end_date}'"
    )
    |> click(button("Next"))

    # Prizes
    session
    |> execute_script(
      "document.getElementById('challenge_prize_type_non_monetary').click()"
    )
    |> fill_in(text_field("Non-monetary prize award"), with: "Prizes other than cash")
    |> click(button("Next"))

    session
    |> resize_window(900, 1500)
    |> take_screenshot()

    # assert .com manager can't submit
  end

  # then sign in as .gov manager and submit

  defp create_and_sign_in_challenge_manager(session) do
    AccountHelpers.create_user(%{email: "challenge_owner_active@example.com", role: "challenge_owner"})

    session
    |> visit("/dev_accounts")
    |> click(button("Challenge Manager Active"))
  end
end


# add federal parners
# |> find(data("child", "federal_partners"))
# |> click(select("Agency name"), option("Department of Education"))
