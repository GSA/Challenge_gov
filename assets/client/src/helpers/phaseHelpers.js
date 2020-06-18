import moment from "moment";

export const phaseInPast = (phase) => {
  return moment().isAfter(phase.end_date)
}

export const phaseIsCurrent = (phase) => {
  return moment().isBetween(phase.start_date, phase.end_date, null, "[]")
}

export const phaseInFuture = (phase) => {
  return moment().isBefore(phase.start_date)
}

export default {
  phaseInPast,
  phaseIsCurrent,
  phaseInFuture
}