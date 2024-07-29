
const localDate = (datetime) => {

  let dateObj = new Date(datetime);
  let month = (dateObj.getMonth() + 1).toString().padStart(2, '0'); 
  let day = dateObj.getDate().toString().padStart(2, '0');
  let year = dateObj.getFullYear(); 
  
  return `${year}-${month}-${day}`;
}

const localDateTime = (date) => {

  let dateObj = new Date(date);
  let year = dateObj.getFullYear();
  let month = (dateObj.getMonth() + 1).toString().padStart(2, '0'); // Months are zero-based
  let day = dateObj.getDate().toString().padStart(2, '0');
  let hours = dateObj.getHours().toString().padStart(2, '0');
  let minutes = dateObj.getMinutes().toString().padStart(2, '0');

  // Format the date as "YYYY-MM-DDTHH:mm"
  return `${year}-${month}-${day}T${hours}:${minutes}`;

}

const localTime = (date) => {

  let dateObj = new Date(date);
  let hours = dateObj.getHours().toString().padStart(2, '0');
  let minutes = dateObj.getMinutes().toString().padStart(2, '0');

  // Format the date as "HH:mm"
  return `${hours}:${minutes}`;

}

const localToUTC = (date) => {

  let dateObj = new Date(date);

  // Convert to UTC time
  let utcYear = dateObj.getUTCFullYear();
  let utcMonth = (dateObj.getUTCMonth() + 1).toString().padStart(2, '0'); // Months are zero-based
  let utcDay = dateObj.getUTCDate().toString().padStart(2, '0');
  let utcHours = dateObj.getUTCHours().toString().padStart(2, '0');
  let utcMinutes = dateObj.getUTCMinutes().toString().padStart(2, '0');
  let utcSeconds = dateObj.getUTCSeconds().toString().padStart(2, '0');

  // Format the date as an ISO 8601 string
  return `${utcYear}-${utcMonth}-${utcDay}T${utcHours}:${utcMinutes}:${utcSeconds}Z`;
}


// When datetime inputs load convert utc from hidden field to local time in date picker input
$(".js-datetime-input").each(function() {
  let utc_time = $(this).siblings("input[type=hidden]").val();
  let local_time = localDateTime(utc_time);

  $(this).val(local_time);
})

// When datetime input changes convert local to utc in a hidden field after it
$("body").on("input", ".js-datetime-input", function() {
  let local_time = $(this).val();
  let utc_time = localToUTC(local_time);

  $(this).siblings("input[type=hidden]").val(utc_time);
})

// Firefox inputs

// set inputs on page load via hidden input
$(".js-date-input").each(function() {
  let utc_time = $(this).siblings("input[type=hidden]").val();
  // format("YYYY-MM-DD")
  let local_date = localDate(utc_time);

  $(this).val(local_date)
})

$(".js-time-input").each(function() {
  let utc_time = $(this).siblings("input[type=hidden]").val()
  // format("HH:mm")
  let local_time = localTime(utc_time);

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
   
  let utc_time = localToUTC(`${date} ${time}`); 

  utc_time === "Invalid date" ? null : input.siblings("input[type=hidden]").val(utc_time)
}
