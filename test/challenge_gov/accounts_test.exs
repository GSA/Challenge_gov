defmodule ChallengeGov.AccountsTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Accounts
  alias ChallengeGov.Emails

  describe "warnings for account deactivation" do
    test "with no last active" do
      timeout = 90
      warning_one = 10
      warning_two = 5
      user = %{last_active: nil, email: "test@example.com"}
      Accounts.maybe_send_deactivation_notice(user, timeout, warning_one, warning_two)
      assert_no_emails_delivered()
    end

    test "more than the warning away" do
      timeout = 90
      warning_one = 10
      warning_two = 5
      last_active = DateTime.utc_now()
      user = %{last_active: last_active, email: "test@example.com"}
      Accounts.maybe_send_deactivation_notice(user, timeout, warning_one, warning_two)
      assert_no_emails_delivered()
    end

    test "warning one away" do
      timeout = 90
      warning_one = 10
      warning_two = 5
      last_active = Timex.shift(DateTime.utc_now(), days: -1 * (timeout - warning_one))
      user = %{last_active: last_active, email: "test@example.com"}
      Accounts.maybe_send_deactivation_notice(user, timeout, warning_one, warning_two)
      assert_delivered_email(Emails.days_deactivation_warning(user, warning_one))
    end

    test "beteween warning one and two" do
      timeout = 90
      warning_one = 10
      warning_two = 5
      last_active = Timex.shift(DateTime.utc_now(), days: -1 * (timeout - warning_one - 2))
      user = %{last_active: last_active, email: "test@example.com"}
      Accounts.maybe_send_deactivation_notice(user, timeout, warning_one, warning_two)
      assert_no_emails_delivered()
    end

    test "warning two away" do
      timeout = 90
      warning_one = 10
      warning_two = 5
      last_active = Timex.shift(DateTime.utc_now(), days: -1 * (timeout - warning_two))
      user = %{last_active: last_active, email: "test@example.com"}
      Accounts.maybe_send_deactivation_notice(user, timeout, warning_one, warning_two)
      assert_delivered_email(Emails.days_deactivation_warning(user, warning_two))
    end

    test "the day before" do
      timeout = 90
      warning_one = 10
      warning_two = 5
      last_active = Timex.shift(DateTime.utc_now(), days: -1 * (timeout - 1))
      user = %{last_active: last_active, email: "test@example.com"}
      Accounts.maybe_send_deactivation_notice(user, timeout, warning_one, warning_two)
      assert_delivered_email(Emails.one_day_deactivation_warning(user))
    end

    test "the day of" do
      timeout = 90
      warning_one = 10
      warning_two = 5
      last_active = Timex.shift(DateTime.utc_now(), days: -1 * timeout)
      user = %{last_active: last_active, email: "test@example.com"}
      Accounts.maybe_send_deactivation_notice(user, timeout, warning_one, warning_two)
      assert_no_emails_delivered()
    end
  end

  describe "roles" do
    test "get role rank" do
      assert Accounts.get_role_rank("super_admin") === 1
      assert Accounts.get_role_rank("admin") === 2
      assert Accounts.get_role_rank("challenge_manager") === 3
      assert Accounts.get_role_rank("solver") === 4
    end

    test "role at or above" do
      user = %{role: "super_admin"}
      assert Accounts.role_at_or_above(user, "super_admin")
      assert Accounts.role_at_or_above(user, "admin")
      assert Accounts.role_at_or_above(user, "challenge_manager")
      assert Accounts.role_at_or_above(user, "solver")

      user = %{role: "admin"}
      assert !Accounts.role_at_or_above(user, "super_admin")
      assert Accounts.role_at_or_above(user, "admin")
      assert Accounts.role_at_or_above(user, "challenge_manager")
      assert Accounts.role_at_or_above(user, "solver")

      user = %{role: "challenge_manager"}
      assert !Accounts.role_at_or_above(user, "super_admin")
      assert !Accounts.role_at_or_above(user, "admin")
      assert Accounts.role_at_or_above(user, "challenge_manager")
      assert Accounts.role_at_or_above(user, "solver")

      user = %{role: "solver"}
      assert !Accounts.role_at_or_above(user, "super_admin")
      assert !Accounts.role_at_or_above(user, "admin")
      assert !Accounts.role_at_or_above(user, "challenge_manager")
      assert Accounts.role_at_or_above(user, "solver")
    end

    test "role at or below" do
      user = %{role: "super_admin"}
      assert Accounts.role_at_or_below(user, "super_admin")
      assert !Accounts.role_at_or_below(user, "admin")
      assert !Accounts.role_at_or_below(user, "challenge_manager")
      assert !Accounts.role_at_or_below(user, "solver")

      user = %{role: "admin"}
      assert Accounts.role_at_or_below(user, "super_admin")
      assert Accounts.role_at_or_below(user, "admin")
      assert !Accounts.role_at_or_below(user, "challenge_manager")
      assert !Accounts.role_at_or_below(user, "solver")

      user = %{role: "challenge_manager"}
      assert Accounts.role_at_or_below(user, "super_admin")
      assert Accounts.role_at_or_below(user, "admin")
      assert Accounts.role_at_or_below(user, "challenge_manager")
      assert !Accounts.role_at_or_below(user, "solver")

      user = %{role: "solver"}
      assert Accounts.role_at_or_below(user, "super_admin")
      assert Accounts.role_at_or_below(user, "admin")
      assert Accounts.role_at_or_below(user, "challenge_manager")
      assert Accounts.role_at_or_below(user, "solver")
    end
  end
end
