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

export const isPhaseless = (challenge) => {
  return challenge.phases.length === 0
}

export const phaseNumber = (phases, phase) => {
  return phases.indexOf(phase) + 1
}

export const formatDateTime = (date) => {
  let timeZone = moment.tz.guess(true)
  return moment.tz(date, timeZone).format("MM/DD/YY hh:mm A z")
}

export const formatDate = (date) => {
  return moment(date).local().format("MM/DD/YY")
}

export const formatTime = (date) => {
  return moment(date).local().format("hh:mm A z")
}

export const daysInMinutes = (days) => {
  return moment.duration(days, 'days').as('minutes')
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