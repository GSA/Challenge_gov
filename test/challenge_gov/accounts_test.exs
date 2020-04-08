defmodule ChallengeGov.AccountsTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Accounts
  alias ChallengeGov.Emails

  describe "warnings for account deactivation" do
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
end
