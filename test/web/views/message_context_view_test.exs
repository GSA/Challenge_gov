defmodule Web.MessageContextViewTest do
  use Web.ConnCase, async: true

  alias Web.MessageContextView

  describe "get active message filter class" do
    test "success: all" do
      conn = %{params: %{}}

      assert MessageContextView.filter_active_class(conn, "all") == "btn-primary"
      assert MessageContextView.filter_active_class(conn, "non_active_filter") == "btn-link"
    end

    test "success: starred" do
      conn = %{
        params: %{
          "filter" => %{
            "starred" => "true"
          }
        }
      }

      assert MessageContextView.filter_active_class(conn, "starred") == "btn-primary"
      assert MessageContextView.filter_active_class(conn, "non_active_filter") == "btn-link"
    end
  end
end
