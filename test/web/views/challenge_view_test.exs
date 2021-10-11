defmodule Web.ChallengeViewTest do
  use Web.ConnCase, async: true

  alias TestHelpers.AccountHelpers
  alias TestHelpers.AgencyHelpers
  alias TestHelpers.ChallengeHelpers
  alias Web.ChallengeView

  @public_root_url Application.get_env(:challenge_gov, :public_root_url)

  describe "construct agency name from challenge" do
    test "successfully with no sub agency" do
      lead_agency = AgencyHelpers.create_agency(%{name: "Lead agency"})

      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, agency_id: lead_agency.id}, user)

      assert ChallengeView.agency_name(challenge) === "Lead agency"
    end

    test "successfully with sub agency" do
      lead_agency = AgencyHelpers.create_agency(%{name: "Lead agency"})
      sub_agency = AgencyHelpers.create_agency(%{name: "Sub agency", parent_id: lead_agency.id})

      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(
          %{user_id: user.id, agency_id: lead_agency.id, sub_agency_id: sub_agency.id},
          user
        )

      assert ChallengeView.agency_name(challenge) === "Lead agency - Sub agency"
    end
  end

  describe "public challenge index url" do
    test "success" do
      assert ChallengeView.public_index_url() == @public_root_url
    end
  end

  describe "public challenge details url" do
    test "success" do
      lead_agency = AgencyHelpers.create_agency(%{name: "Lead agency"})

      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: user.id, agency_id: lead_agency.id}, user)

      assert ChallengeView.public_details_url(challenge) ==
               "#{@public_root_url}/?challenge=#{challenge.id}"
    end

    test "success: with custom_url" do
      lead_agency = AgencyHelpers.create_agency(%{name: "Lead agency"})

      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(
          %{user_id: user.id, agency_id: lead_agency.id, custom_url: "test_custom_url"},
          user
        )

      assert ChallengeView.public_details_url(challenge) ==
               "#{@public_root_url}/?challenge=test_custom_url"
    end

    test "success: with custom url and tab" do
      lead_agency = AgencyHelpers.create_agency(%{name: "Lead agency"})

      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_challenge(
          %{user_id: user.id, agency_id: lead_agency.id, custom_url: "test_custom_url"},
          user
        )

      assert ChallengeView.public_details_url(challenge, tab: "rules") ==
               "#{@public_root_url}/?challenge=test_custom_url&tab=rules"
    end
  end
end
