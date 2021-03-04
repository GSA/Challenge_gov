defmodule ChallengeGov.ChallengePhaseWinnersTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Challenges
  alias ChallengeGov.TestHellpers.ChallengeHelpers

  describe "phase winner permissions" do
    test "can only add phase winners as challenge owner" do
      assert false == true
    end
  end

  describe "adding phase winners" do
    test "can't add phase winners before a phase is complete" do
      assert false == true
    end
    
    test "can add phase winners after a phase is complete" do
      assert false == true
    end
    
    test "success: multiple individual winners" do
      assert false == true
    end

    test "success: draft -> review -> published" do
      assert false == true
    end
  end
end
