import moment from "moment-timezone";

// When datetime inputs load convert utc from hidden field to local time in date picker input
$(".js-datetime-input").each(function() {
  let utc_time = $(this).siblings("input[type=hidden]").val()
  let local_time = moment(utc_time).local().format("YYYY-MM-DDTHH:mm")

  $(this).val(local_time)
})

// When datetime input changes convert local to utc in a hidden field after it
$("body").on("input", ".js-datetime-input", function() {
  let local_time = $(this).val()
  let utc_time = moment(local_time).utc().format()

  $(this).siblings("input[type=hidden]").val(utc_time)
})

// Firefox inputs

// set inputs on page load via hidden input
$(".js-date-input").each(function() {
  let utc_time = $(this).siblings("input[type=hidden]").val()
  let local_date = moment(utc_time).local().format("YYYY-MM-DD")

  $(this).val(local_date)
})

$(".js-time-input").each(function() {
  let utc_time = $(this).siblings("input[type=hidden]").val()
  let local_time = moment(utc_time).local().format("HH:mm")

  $(this).val(local_time)
})

// set hidden input with both date and time on change of either
$("body").on("input", ".js-date-input", function() {
  setCombinedDatetimeValue($(this))
})

$("body").on("input", ".js-time-input", function() {
  setCombinedDatetimeValue($(this))
})

function setCombinedDatetimeValue(input) {
  let date =
    Object.values(input[0].classList).includes("js-date-input")
      ? input.val()
      : input.siblings(".js-date-input").val()
  let time =
    Object.values(input[0].classList).includes("js-time-input")
      ? input.val()
      : input.siblings(".js-time-input").val()

  let utc_time = moment(`${date} ${time}`).utc().format()

  utc_time === "Invalid date" ? null : input.siblings("input[type=hidden]").val(utc_time)
}
