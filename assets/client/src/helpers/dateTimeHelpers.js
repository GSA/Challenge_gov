// TODO: Move date and timezone related functions to this file
export const localDate = (datetime) => {
  let timeZone = moment.tz.guess(true)
  let local_time = moment.tz(datetime, timeZone).format("MM/DD/YYYY")

  return local_time
}

export default {
  localDate
}