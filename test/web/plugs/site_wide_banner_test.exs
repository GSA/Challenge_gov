defmodule Web.Plugs.SiteWideBannerTest do
  use Web.ConnCase

  alias ChallengeGov.TestHelpers.AccountHelpers

  describe "checks for banner" do
    test "adds banner to assign if banner is active", %{conn: conn} do
      TestHelpers.create_site_wide_banner()
      user = AccountHelpers.create_user(%{role: "admin"})

      conn =
        conn
        |> assign(:current_user, user)
        |> get("/challenges")

      assert conn.assigns.site_wide_banner
    end

    test "does not add banner to assign if no banner", %{conn: conn} do
      user = AccountHelpers.create_user(%{role: "admin"})

      conn =
        conn
        |> assign(:current_user, user)
        |> get("/challenges")

      assert !Map.has_key?(conn.assigns, :site_wide_banner)
    end

    test "does not banner to assign if banner dates are not active", %{conn: conn} do
      end_date =
        DateTime.utc_now()
        |> DateTime.add(60 * 60 * -1, :second)
        |> DateTime.to_string()

      TestHelpers.create_site_wide_banner(%{"end_date" => end_date})
      user = AccountHelpers.create_user(%{role: "admin"})

      conn =
        conn
        |> assign(:current_user, user)
        |> get("/challenges")

      assert !Map.has_key?(conn.assigns, :site_wide_banner)
    end

    test "does not banner to assign if banner content is nil", %{conn: conn} do
      TestHelpers.create_site_wide_banner(%{"content" => ""})
      user = AccountHelpers.create_user(%{role: "admin"})

      conn =
        conn
        |> assign(:current_user, user)
        |> get("/challenges")

      assert !Map.has_key?(conn.assigns, :site_wide_banner)
    end
  end

  describe "checks for banner API" do
    test "adds banner to check if available", %{conn: conn} do
      TestHelpers.create_site_wide_banner(%{"content" => "this is a test"})

      conn =
        conn
        |> get("/api/banner")

      assert text_response(conn, 200) =~ "this is a test"
    end
  end

  test "does not banner to assign if banner dates are not active for API", %{conn: conn} do
    end_date =
      DateTime.utc_now()
      |> DateTime.add(60 * 60 * -1, :second)
      |> DateTime.to_string()

    TestHelpers.create_site_wide_banner(%{"end_date" => end_date})

    conn =
      conn
      |> get("/api/banner")

    assert text_response(conn, 200) =~ ""
  end

  test "does not banner to assign if banner content is nil API", %{conn: conn} do
    TestHelpers.create_site_wide_banner(%{"content" => ""})

    conn =
      conn
      |> get("/api/banner")

    assert text_response(conn, 200) =~ ""
  end
end
