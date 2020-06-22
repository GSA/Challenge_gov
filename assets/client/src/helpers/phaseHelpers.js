import moment from "moment-timezone";

export const phaseInPast = (phase) => {
  return moment().isAfter(phase.end_date)
}

export const phaseIsCurrent = (phase) => {
  return moment().isBetween(phase.start_date, phase.end_date, null, "[]")
}

export const phaseInFuture = (phase) => {
  return moment().isBefore(phase.start_date)
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
    return moment(a.start_date).diff(b.start_date)
  })
}

export const isSinglePhase = (challenge) => {
  return challenge.phases.length === 1
}

export const phaseNumber = (phases, phase) => {
  return phases.indexOf(phase) + 1
}

export const formatDateTime = (date) => {
  let timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
  let time = new Date();
  let timeZoneOffset = time.getTimezoneOffset();
  let timeZoneAbbr = moment.tz.zone(timeZone).abbr(timeZoneOffset);
  return moment(date).local().format("MM/DD/YY hh:mm A ") + timeZoneAbbr
}

export const formatDate = (date) => {
  return moment(date).local().format("MM/DD/YY")
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