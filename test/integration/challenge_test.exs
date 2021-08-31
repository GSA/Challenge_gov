defmodule ChallengeGov.ChallengeTest do
  use Web.FeatureCase, async: true

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers

  feature "create a challenge as a Challenge Manager", %{session: session} do
    create_and_sign_in_challenge_manager(session)
    year = String.slice("#{Timex.today.year}", -2..-1)

    start_date = "2021-08-30T22:22"

    session
    |> click(link("Challenge management"))
    |> click(link("New"))
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
      "document.getElementById('challenge_upload_logo_true').click()"
    )
    |> execute_script(
      "document.getElementById('challenge_auto_publish_date_picker').focus()"
    )
    |> execute_script(
      "document.getElementById('challenge_auto_publish_date_picker').value = '#{start_date}'"
    )
    |> execute_script(
      "document.getElementById('challenge_auto_publish_date').value = '#{start_date}'"
    )
    # multi-phase false & and single phase date range

    |> accept_alert(fn(session) ->
      execute_script(session,
      "document.getElementById('challenge_is_multi_phase_false').click()"
    )
    end)
    # |> execute_script(
    #   "document.getElementById('challenge_is_multi_phase_false').click()"
    # )
    # |> execute_script(
    #   "document.getElementById('challenge_phases_0_start_date_picker').focus()"
    # )
    # |> execute_script(
    #   "document.getElementById('challenge_phases_0_start_date_picker').value = '#{start_date}'"
    # )
    # |> execute_script(
    #   "document.getElementById('challenge_phases_0_start_date').value = '#{start_date}'"
    # )

    session
    |> resize_window(900, 2500)
    |> take_screenshot()
    # |> click(button("Next"))

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
