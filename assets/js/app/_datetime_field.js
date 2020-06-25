import moment from "moment";

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

$(".js-local-datetime").each(function() {
  let utc_time = $(this).text()
  let local_time = moment(utc_time).local().format("llll")
  $(this).text(local_time)
})