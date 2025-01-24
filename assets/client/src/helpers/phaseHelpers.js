
export const phaseInPast = (phase) => {
  let now = new Date();
  let end = new Date(phase.end_date);
  return now > end;
}

export const phaseIsCurrent = (phase) => {
  let now = new Date();
  let start = new Date(phase.start_date);
  let end = new Date(phase.end_date);
  return now >= start && now <= end;
}

export const phaseInFuture = (phase) => {
  let now = new Date();
  let targetDate = new Date(phase.start_date);
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