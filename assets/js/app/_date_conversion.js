//import moment from "moment-timezone";


const localDate = (datetime) => {

  let dateObj = new Date(datetime);
  let month = (dateObj.getMonth() + 1).toString().padStart(2, '0'); 
  let day = dateObj.getDate().toString().padStart(2, '0');
  let year = dateObj.getFullYear(); 
  
  return `${month}/${day}/${year}`;
}

let localTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone; 

const localDateTime = (date) => {
  let dateObj = new Date(date);    

  let options = {
    timeZone: localTimeZone,
    year: '2-digit',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: true,
    timeZoneName: 'short'
  };
  
  let formatter = new Intl.DateTimeFormat('en-US', options);
  let parts = formatter.formatToParts(dateObj);

  // Extract and format the parts to match "MM/DD/YY hh:mm A z"
  let month = parts.find(p => p.type === 'month').value;
  let day = parts.find(p => p.type === 'day').value;
  let year = parts.find(p => p.type === 'year').value;
  let hour = parts.find(p => p.type === 'hour').value;
  let minute = parts.find(p => p.type === 'minute').value;
  let ampm = parts.find(p => p.type === 'dayPeriod').value;
  let timeZoneName = parts.find(p => p.type === 'timeZoneName').value;

  return `${month}/${day}/${year} ${hour}:${minute} ${ampm} ${timeZoneName}`;

}   


$(".js-local-date").each(function() {
  //let timeZone = moment.tz.guess(true)
  let utc_time = $(this).text();
  //let local_time = moment(utc_time).tz(timeZone).format("MM/DD/YYYY")
  let local_time = localDate(utc_time);

  $(this).text(local_time)
})

$(".js-local-datetime").each(function() {
 // let timeZone = moment.tz.guess(true)
  let utc_time = $(this).text()
 // let local_time = moment(utc_time).tz(timeZone).format("MM/DD/YY hh:mm A z")
  let local_time = localDateTime(utc_time);

  if (local_time != "Invalid date") { $(this).text(local_time) }
})

$(".js-current-local-date").each(function() {
  //let timeZone = moment.tz.guess(true)
  //let utc_time = moment.now()
  let utc_time = new Date();
  let local_time = localDate(utc_time);

  $(this).text(local_time)
})

$(".js-current-local-time").each(function() {
  //let timeZone = moment.tz.guess(true)
  //let utc_time = moment.now()
  let utc_time = new Date();
  //let local_time = moment.tz(utc_time, timeZone).format("hh:mm A z")
  let local_time = localDateTime(utc_time);

  $(this).text(local_time)
})