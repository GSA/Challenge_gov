NimbleCSV.define(ChallengeGov.Reports.CSV, separator: ",", escape: "\"")

defmodule Web.ReportsView do
  use Web, :view

  alias ChallengeGov.Reports.CSV
  alias Web.FormView
  alias Web.SharedView

  def render_query_log("recertified-accounts-range-header.csv", _assigns) do
    headers = [
      "user_id",
      "account_type",
      "action",
      "logged_date",
      "account_status",
      "last_login",
      "start_date",
      "end_date",
      "current_timestamp"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render_query_log("decertified-accounts-range-header.csv", _assigns) do
    headers = [
      "user_id",
      "account_type",
      "action",
      "logged_date",
      "account_status",
      "last_login",
      "start_date",
      "end_date",
      "current_timestamp"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render_query_log("reactivated-accounts-range-header.csv", _assigns) do
    headers = [
      "user_id",
      "account_type",
      "action",
      "logged_date",
      "account_status",
      "last_login",
      "start_date",
      "end_date",
      "current_timestamp"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render_query_log("deactivated-accounts-range-header.csv", _assigns) do
    headers = [
      "user_id",
      "account_type",
      "action",
      "logged_date",
      "account_status",
      "last_login",
      "start_date",
      "end_date",
      "current_timestamp"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render_query_log("accounts-created-date-range-header.csv", _assigns) do
    headers = [
      "user_id",
      "account_type",
      "created_date",
      "account_status",
      "last_login",
      "start_date",
      "end_date",
      "current_timestamp"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render_query_log("number-of-submissions-challenge-header.csv", _assigns) do
    headers = [
      "challenge_id",
      "challenge_name",
      "created_date",
      "start_date",
      "end_date",
      "listing_type",
      "submissions",
      "current_timestamp"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render_query_log("created-date-range-header.csv", _assigns) do
    headers = [
      "challenge_id",
      "challenge_name",
      "agency_name",
      "agency_id",
      "prize_amount",
      "created_date",
      "start_date",
      "end_date",
      "published_date",
      "listing_type",
      "challenge_type",
      "challenge_suscribers",
      "submissions",
      "status",
      "current_timestamp"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render_query_log("published-date-range-header.csv", _assigns) do
    headers = [
      "challenge_id",
      "challenge_name",
      "agency_name",
      "start_date",
      "end_date",
      "agency_id",
      "prize_amount",
      "created_date",
      "published_date",
      "listing_type",
      "challenge_type",
      "challenge_suscribers",
      "submissions",
      "status",
      "current_timestamp"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render_query_log("publish-active-challenge-header.csv", _assigns) do
    headers = [
      "challenge_id",
      "challenge_name",
      "agency_name",
      "agency_id",
      "prize_amount",
      "created_date",
      "published_date",
      "listing_type",
      "challenge_type",
      "challenge_suscribers",
      "submissions",
      "status",
      "current_timestamp"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render_security_log("security-log-header.csv", _assigns) do
    headers = [
      "ID",
      "Action",
      "Details",
      "Originator ID",
      "Originator Type",
      "Originator Identifier",
      "Originator IP Address",
      "Target ID",
      "Target Type",
      "Target Identifier",
      "Logged At"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render_certification_log("certification-log-header.csv", _assigns) do
    headers = [
      "ID",
      "Approver ID",
      "Approver Role",
      "Approver Identifier",
      "Approver IP Address",
      "User ID",
      "User Role",
      "User Identifier",
      "User IP Address",
      "Requested At",
      "Certified At",
      "Expires At",
      "Denied At",
      "Inserted At",
      "Updated At"
    ]

    CSV.dump_to_iodata([headers])
  end

  def render(file_name, %{record: record}) do
    csv = csv_schema_by_report(file_name, record)
    CSV.dump_to_iodata([csv])
  end

  defp csv_schema_by_report("decertified-accounts-range-content.csv", record) do
    [
      record.user_id,
      record.account_type,
      record.action,
      record.logged_date,
      record.account_status,
      record.last_login,
      record.start_date,
      record.end_date,
      record.current_timestamp
    ]
  end

  defp csv_schema_by_report("recertified-accounts-range-content.csv", record) do
    [
      record.user_id,
      record.account_type,
      record.action,
      record.logged_date,
      record.account_status,
      record.last_login,
      record.start_date,
      record.end_date,
      record.current_timestamp
    ]
  end

  defp csv_schema_by_report("reactivated-accounts-range-content.csv", record) do
    [
      record.user_id,
      record.account_type,
      record.action,
      record.logged_date,
      record.account_status,
      record.last_login,
      record.start_date,
      record.end_date,
      record.current_timestamp
    ]
  end

  defp csv_schema_by_report("deactivated-accounts-range-content.csv", record) do
    [
      record.user_id,
      record.account_type,
      record.action,
      record.logged_date,
      record.account_status,
      record.last_login,
      record.start_date,
      record.end_date,
      record.current_timestamp
    ]
  end

  defp csv_schema_by_report("accounts-created-date-range-content.csv", record) do
    [
      record.user_id,
      record.account_type,
      record.created_date,
      record.account_status,
      record.last_login,
      record.start_date,
      record.end_date,
      record.current_timestamp
    ]
  end

  defp csv_schema_by_report(file_name, record) do
    case file_name do
      "number-of-submissions-challenge-content.csv" ->
        [
          record.challenge_id,
          record.challenge_name,
          record.created_date,
          record.start_date,
          record.end_date,
          record.listing_type,
          record.submissions,
          record.current_timestamp
        ]

      "created-date-range-content.csv" ->
        [
          record.challenge_id,
          record.challenge_name,
          record.agency_name,
          record.agency_id,
          record.prize_amount,
          record.created_date,
          record.start_date,
          record.end_date,
          record.published_date,
          record.listing_type,
          record.challenge_type,
          record.challenge_suscribers,
          record.submissions,
          record.status,
          record.current_timestamp
        ]

      "published-date-range-content.csv" ->
        [
          record.challenge_id,
          record.challenge_name,
          record.agency_name,
          record.start_date,
          record.end_date,
          record.agency_id,
          record.prize_amount,
          record.created_date,
          record.published_date,
          record.listing_type,
          record.challenge_type,
          record.challenge_suscribers,
          record.submissions,
          record.status,
          record.current_timestamp
        ]

      "publish-active-challenge-content.csv" ->
        [
          record.challenge_id,
          record.challenge_name,
          record.agency_name,
          record.agency_id,
          record.prize_amount,
          record.created_date,
          record.published_date,
          record.listing_type,
          record.challenge_type,
          record.challenge_suscribers,
          record.submissions,
          record.status,
          record.current_timestamp
        ]

      "security-log-content.csv" ->
        [
          record.id,
          record.action,
          parse_details(record.details),
          record.originator_id,
          record.originator_role,
          record.originator_identifier,
          record.originator_remote_ip,
          record.target_id,
          record.target_type,
          record.target_identifier,
          record.logged_at
        ]

      "certification-log-content.csv" ->
        [
          record.id,
          record.approver_id,
          record.approver_role,
          record.approver_identifier,
          record.approver_remote_ip,
          record.user_id,
          record.user_role,
          record.user_identifier,
          record.user_remote_ip,
          record.requested_at,
          record.certified_at,
          record.expires_at,
          record.denied_at,
          record.inserted_at,
          record.updated_at
        ]
    end
  end

  defp parse_details(record) do
    if record do
      record
      |> Enum.map_join(
        ", ",
        fn x ->
          format_to_readable(x)
        end
      )
    end
  end

  defp format_to_readable(x) do
    case elem(x, 0) == "duration" do
      true ->
        ["#{elem(x, 0)}: #{convert_to_iostime(elem(x, 1))}"]

      false ->
        ["#{elem(x, 0)}: #{elem(x, 1)}"]
    end
  end

  defp convert_to_iostime(duration) do
    {hours, minutes, seconds, _microseconds} =
      duration
      |> Timex.Duration.from_seconds()
      |> Timex.Duration.to_clock()

    "#{ensure_double_digits(hours)}:#{ensure_double_digits(minutes)}:#{ensure_double_digits(seconds)}"
  end

  def ensure_double_digits(elem) do
    result =
      elem
      |> Integer.digits()
      |> length

    case result == 1 do
      true ->
        "0#{elem}"

      false ->
        elem
    end
  end
end
