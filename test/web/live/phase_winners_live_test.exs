defmodule Web.PhaseWinnersLiveTest do
  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  use Web.ConnCase

  @endpoint Web.Endpoint

  describe "mount" do
    test "disconnected and connected mount", %{conn: conn} do
      # get path...
    end
  end

  describe "uploading winner images" do
    test "winner file upload works" do
      assert true == false
    end

    test "winner upload 10mb max" do
      assert true == false
    end

    test "winner upload img extensions only" do
      assert true == false
    end

    test "winner img is optional (nil value :ok)" do
      assert true == false
    end

    test "multiple winner images disallowed" do
      assert true == false
    end
  end

  describe "draft -> review -> published" do
    test "confirmation banner when published" do
      assert true == false
    end
  end

  describe "phase winners only chooseable after phase concludes" do

  end
end
