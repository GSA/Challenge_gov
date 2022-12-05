# defmodule ChallengeGov.ChallengeIntegrationTest do
#   use Web.FeatureCase, async: true

#   alias ChallengeGov.TestHelpers.AccountHelpers
#   alias ChallengeGov.Challenges

#   feature "create a challenge as a Challenge Manager", %{session: session} do
#     create_and_sign_in_challenge_manager(session)

#     session
#     |> click(link("Challenge management"))
#     |> click(link("New"))
#     |> complete_general_section()
#     |> complete_details_section()
#     |> complete_timeline_section()
#     |> complete_prizes_section()
#     |> complete_rules_section()
#     |> complete_judging_section()
#     |> complete_how_to_enter_section()
#     |> complete_resources_section()

#     session
#     |> click(button("Submit"))
#     |> has?(Query.text("Your Challenge was submitted on"))
#   end

#   defp complete_general_section(session) do
#     year = String.slice("#{Timex.today().year}", -2..-1)

#     session
#     |> maximize_window()
#     |> fill_in(text_field("Challenge manager of record"),
#       with: "challenge_manager_active@example.com"
#     )
#     |> fill_in(text_field("Challenge manager email"), with: "email@example.com")
#     |> fill_in(text_field("Point of contact email"), with: "email@example.com")
#     |> click(select("Lead agency name"))
#     |> click(option("Department of Agriculture"))
#     |> click(select("Sub-agency name"))
#     |> click(option("Agricultural Research Service"))
#     |> fill_in(text_field("Fiscal year"), with: "FY#{year}")
#     |> touch_scroll(button("Next"), 0, 1)
#     |> click(button("Next"))

#     # |> focus_frame(css(".form-horizontal", count: 1))
#   end

#   defp complete_details_section(session) do
#     verify_previous_section(:agency_id, 24)

#     session
#     |> fill_in(text_field("Challenge title"), with: "Test Title")
#     |> fill_in(text_field("Tagline"), with: "This is a test")
#     |> find(select("Primary challenge type"))
#     |> click(option("Ideas"))
#     |> populate_markdown_field("Brief desciption here.")
#     |> populate_markdown_field("Full description here.", 1)

#     session
#     |> touch_scroll(css(".logo-section"), 0, 1)
#     |> focus_frame(css(".logo-section"))
#     |> click(radio_button("Use agency seal"))
#     |> focus_frame(css(".publish-date-section"))
#     |> populate_auto_publish_date()

#     # multi-phase false and accept confirm alert

#     session
#     |> focus_frame(css(".multi-phase-section"))
#     |> touch_scroll(radio_button("No"), 0, 1)
#     |> click(radio_button("No"))

#     # single phase date range
#     session
#     |> populate_start_date("challenge_phases_0_start_date")
#     |> populate_end_date("challenge_phases_0_end_date")
#     |> touch_scroll(button("Next"), 0, 1)
#     |> click(css(".btn-testing"))
#   end

#   defp complete_timeline_section(session) do
#     verify_previous_section(:title, "Test Title")

#     session
#     |> focus_frame(css(".timeline-event-fields"))
#     |> assert_has(css(".timeline-event-fields"))
#     |> click(css(".add-nested-section"))
#     |> fill_in(text_field("Timeline event title"), with: "Event 1")
#     |> populate_end_date("challenge_timeline_events_0_date")
#     |> touch_scroll(button("Next"), 0, 1)
#     |> click(button("Next"))
#   end

#   defp complete_prizes_section(session) do
#     verify_previous_section(:timeline_events, :title, "Event 1")

#     session
#     |> click(radio_button("Non-monetary prize"))
#     |> fill_in(text_field("Non-monetary prize award"), with: "Prizes other than cash")
#     |> touch_scroll(button("Next"), 0, 1)
#     |> click(button("Next"))
#   end

#   defp complete_rules_section(session) do
#     verify_previous_section(:non_monetary_prizes, "Prizes other than cash")

#     session
#     |> populate_markdown_field("Eligibilty requirements described here.")
#     |> populate_markdown_field("Rules described here.", 1)
#     |> populate_markdown_field("Terms and conditions described here.", 2)
#     |> click(select("Legal authority"))
#     |> click(option("Direct Prize Authority"))
#     |> touch_scroll(button("Next"), 0, 1)
#     |> click(button("Next"))
#   end

#   defp complete_judging_section(session) do
#     verify_previous_section(:legal_authority, "Direct Prize Authority")

#     session
#     |> populate_markdown_field("Judging criteria described here.")
#     |> touch_scroll(button("Next"), 0, 1)
#     |> click(button("Next"))
#   end

#   defp complete_how_to_enter_section(session) do
#     verify_previous_section(:phases, :judging_criteria, "Judging criteria described here.")

#     session
#     |> populate_markdown_field("How to enter described here.")
#     |> touch_scroll(button("Next"), 0, 1)
#     |> click(button("Next"))
#   end

#   defp complete_resources_section(session) do
#     verify_previous_section(:phases, :how_to_enter, "How to enter described here.")

#     session
#     |> touch_scroll(button("Next"), 0, 1)
#     |> click(button("Next"))
#   end

#   defp create_and_sign_in_challenge_manager(session) do
#     AccountHelpers.create_user(%{
#       email: "challenge_manager_active@example.gov",
#       role: "challenge_manager"
#     })

#     session
#     |> visit("/dev_accounts")
#     |> click(button("Challenge Manager Active"))
#   end

#   defp populate_auto_publish_date(session) do
#     session
#     |> execute_script(
#       "document.getElementById('challenge_auto_publish_date_picker').value = '#{set_date_picker(days: 1)}'"
#     )
#     |> execute_script(
#       "document.getElementById('challenge_auto_publish_date').value = '#{set_date(days: 1)}'"
#     )
#   end

#   defp populate_start_date(session, id) do
#     session
#     |> execute_script(
#       "document.getElementById('#{id}_picker').value = '#{set_date_picker(days: 2)}'"
#     )
#     |> execute_script("document.getElementById('#{id}').value = '#{set_date(days: 2)}'")
#   end

#   defp populate_end_date(session, id) do
#     session
#     |> execute_script(
#       "document.getElementById('#{id}_picker').value = '#{set_date_picker(days: 3)}'"
#     )
#     |> execute_script("document.getElementById('#{id}').value = '#{set_date(days: 3)}'")
#   end

#   defp populate_markdown_field(session, value, index \\ 0) do
#     session
#     |> execute_script(
#       "document.getElementsByClassName('ql-editor')[#{index}].innerHTML = '#{value}'"
#     )
#   end

#   defp verify_previous_section(field, value) do
#     challenge = List.first(Challenges.admin_all())
#     key = Map.get(challenge, field)
#     assert(key == value)
#   end

#   defp verify_previous_section(field, nested_field, value) do
#     {:ok, [parent_field]} =
#       Challenges.admin_all()
#       |> List.first()
#       |> Map.fetch(field)

#     key = Map.get(parent_field, nested_field)

#     assert(key =~ value)
#   end

#   defp set_date_picker(days) do
#     {:ok, start_date_picker} =
#       Timex.now()
#       |> Timex.shift(days)
#       |> Timex.format("{YYYY}-{0M}-{0D}T{0h12}:{m}")

#     start_date_picker
#   end

#   defp set_date(days) do
#     {:ok, start_date} =
#       Timex.now()
#       |> Timex.shift(days)
#       |> Timex.format("{YYYY}-{0M}-{0D} {0h12}:{m}:{s}Z")

#     start_date
#   end
# end
