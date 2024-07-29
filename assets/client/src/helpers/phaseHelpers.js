//import moment from "moment-timezone";

export const phaseInPast = (phase) => {
  //return moment().isAfter(phase.end_date)
  let now = new Date();
  let end = new Date(endDate);
  return now > end;
}

export const phaseIsCurrent = (phase) => {
//  return moment().isBetween(phase.start_date, phase.end_date, null, "[]")
  let now = new Date();
  let start = new Date(startDate);
  let end = new Date(endDate);
  return now >= start && now <= end;
}

export const phaseInFuture = (phase) => {
  //return moment().isBefore(phase.start_date)
  let now = new Date();
  let targetDate = new Date(date);
  return now < targetDate;
}

export const getPreviousPhase = (phases) => {
  let previousPhase = null
  sortPhasesByStartDate(phases).forEach((phase) => {
    if (phaseInPast(phase)) {
      previousPhase = phase
    }
  })
  return previousPhase
}

export const getCurrentPhase = (phases) => {
  return phases.filter((phase) => {
    return phaseIsCurrent(phase)
  })[0]
}

export const getNextPhase = (phases) => {
  let nextPhase = null
  sortPhasesByStartDate(phases).forEach((phase) => {
    if (phaseInFuture(phase) && nextPhase === null) {
      nextPhase = phase
    }
  })
  return nextPhase
}

export const sortPhasesByStartDate = (phases) => {
  return phases.sort((a, b) => {
    //return moment(a.start_date).diff(b.start_date)
    let dateA = new Date(a.start_date);
    let dateB = new Date(b.start_date);  
    let difference = dateA - dateB;
    return difference;
  })
}

export const isSinglePhase = (challenge) => {
  return challenge.phases.length === 1
}

export const isPhaseless = (challenge) => {
  return challenge.phases.length === 0
}

export const phaseNumber = (phases, phase) => {
  return phases.indexOf(phase) + 1
}

export const formatDateTime = (date) => {
 // let timeZone = moment.tz.guess(true)
 // return moment.tz(date, timeZone).format("MM/DD/YY hh:mm A z")

   let timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
   let dateObj = new Date(date);
 
   let options = {
     year: '2-digit',
     month: '2-digit',
     day: '2-digit',
     hour: '2-digit',
     minute: '2-digit',
     hour12: true,
     timeZone: timeZone,
     timeZoneName: 'short'
   };
 
   let formatter = new Intl.DateTimeFormat('en-US', options);
   let parts = formatter.formatToParts(dateObj);
   let formattedDate = `${parts.find(part => part.type === 'month').value}/${parts.find(part => part.type === 'day').value}/${parts.find(part => part.type === 'year').value}`;
   let formattedTime = `${parts.find(part => part.type === 'hour').value}:${parts.find(part => part.type === 'minute').value} ${parts.find(part => part.type === 'dayPeriod').value}`;
   let timeZoneAbbr = parts.find(part => part.type === 'timeZoneName').value;
 
   return `${formattedDate} ${formattedTime} ${timeZoneAbbr}`;

}

export const formatDate = (date) => {
  //return moment(date).local().format("MM/DD/YY")
  let options = { year: '2-digit', month: '2-digit', day: '2-digit', timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone };
  return new Date(date).toLocaleDateString('en-US', options);
}

export const formatTime = (date) => {

  let timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  let dateObj = new Date(date);

  let options = {
    hour: '2-digit',
    minute: '2-digit',
    hour12: true,
    timeZone: timeZone,
    timeZoneName: 'short'
  };

  let formatter = new Intl.DateTimeFormat('en-US', options);
  let parts = formatter.formatToParts(dateObj);

  let formattedTime = `${parts.find(part => part.type === 'hour').value}:${parts.find(part => part.type === 'minute').value} ${parts.find(part => part.type === 'dayPeriod').value}`;
  let timeZoneAbbr = parts.find(part => part.type === 'timeZoneName').value;

  return `${formattedTime} ${timeZoneAbbr}`;
}

export const daysInMinutes = (days) => {
  //return moment.duration(days, 'days').as('minutes')
  return days * 24 * 60;
}

export default {
  phaseInPast,
  phaseIsCurrent,
  phaseInFuture,
  getPreviousPhase,
  getCurrentPhase,
  getNextPhase,
  isSinglePhase,
  phaseNumber,
  formatDateTime,
  formatDate
}