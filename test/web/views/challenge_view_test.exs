defmodule Web.ChallengeViewTest do
  use Web.ConnCase, async: true

  alias TestHelpers.AccountHelpers
  alias TestHelpers.AgencyHelpers
  alias TestHelpers.ChallengeHelpers
  alias Web.ChallengeView

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
end
