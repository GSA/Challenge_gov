import React, {useContext} from 'react'
import { Link } from "react-router-dom";
import moment from "moment"
import {getCurrentPhase, getNextPhase, phaseNumber, formatDateTime, formatTime, isSinglePhase, isPhaseless, daysInMinutes} from "../helpers/phaseHelpers"
import {truncateString} from '../helpers/stringHelpers'
import { ApiUrlContext } from '../ApiUrlContext'

export const ChallengeTile = ({challenge, preview}) => {
  const apiUrl = useContext(ApiUrlContext)

  const renderTags = ({start_date, end_date, announcement_datetime}) => {
    const startDateDiff = moment().diff(start_date, 'minutes')
    const endDateDiff = moment().diff(end_date, 'minutes')
    const announcementDateDiff = moment().diff(announcement_datetime, 'minutes')

    let tags = []

    if (startDateDiff < 0) {
      tags.push(<div key={"coming_soon"} className="usa-tag usa-tag--coming-soon">Coming soon</div>)
    } else if (endDateDiff >= daysInMinutes(-7) && endDateDiff < 0) {
      tags.push(<div key={"closing_soon"} className="usa-tag usa-tag--closing-soon">Closing soon</div>)
    }

    if (announcementDateDiff <= daysInMinutes(7)) {
      tags.push(<div key={"important_update"} className="usa-tag usa-tag--important-update">Important update</div>)
    }

    if (tags.length > 0) {
      return (
        <div className="display-flex flex-align-start p-3">
          {tags}
        </div>
      )
    }
  }

  const renderDate = (challenge) => {
    const {start_date, end_date, phases} = challenge
    const startDateDiff = moment().diff(start_date, 'minutes')
    const endDateDiff = moment().diff(end_date, 'minutes')

    if (isPhaseless(challenge)) {
      return handlePhaselessChallengeDate(challenge)
    } else {
      let currentPhase = getCurrentPhase(phases)
      let nextPhase = getNextPhase(phases)

      if (startDateDiff < 0) {
        return `Opens on ${formatDateTime(start_date)}`
      }

      if (endDateDiff >= 0) {
        return "Closed to submissions"
      }

      if (currentPhase) {
        if (isSinglePhase(challenge)) {
          return `Open until ${formatDateTime(end_date)}`
        } else {
          return `Phase ${phaseNumber(phases, currentPhase)} open until ${formatDateTime(currentPhase.end_date)}`
        }
      }

      if (nextPhase) {
        return `Phase ${phaseNumber(phases, nextPhase)} opens on ${formatDateTime(nextPhase.start_date)}`
      }
    }
  }

  // TODO: This is potentially temporary until the importer handles adding phases to imported challenges
  const handlePhaselessChallengeDate = ({start_date, end_date}) => {
    const startDateDiff = moment().diff(start_date, 'minutes')
    const endDateDiff = moment().diff(end_date, 'minutes')

    if (startDateDiff < 0) {
      return `Opens on ${formatDateTime(start_date)}`
    }

    if (startDateDiff >= 0 && endDateDiff < daysInMinutes(-1)) {
      return `Open until ${formatDateTime(end_date)}`
    }

    if (endDateDiff >= daysInMinutes(-1) && endDateDiff < 0) {
      return `Closes today at ${formatTime(end_date)}`
    }

    if (endDateDiff >= 0) {
      return "Closed to submissions"
    }
  }

  return (
    challenge ? (
      <div key={challenge.id} className="challenge-tile card">
        <Link to={preview ? "#" : `/challenge/${challenge.id}`} aria-label="View challenge details">
          <div className="image_wrapper">
            { challenge.logo
              ? <img src={apiUrl + challenge.logo} alt="Challenge logo" title="Challenge logo" className="w-100"/>
              : <img
                  src={apiUrl + challenge.agency_logo}
                  alt="Challenge agency logo"
                  title="Challenge agency logo"
                  className="w-100"
                />
            }
          </div>
          <div className="challenge-tile__text-wrapper">
            <p className="challenge-tile__title test" aria-label="Challenge title">{truncateString(challenge.title, 90)}</p>
            <p className="challenge-tile__agency-name" aria-label="Agency name">{truncateString(challenge.agency_name, 90)}</p>
            <p className="challenge-tile__tagline" aria-label="Challenge tagline">{truncateString(challenge.tagline, 90)}</p>
            <p className="challenge-tile__date">{renderDate(challenge)}</p>
            {renderTags(challenge)}
          </div>
        </Link>
      </div>
    ) : (
      <div className="challenge-tile__loader--image"></div>
    )
  )
}
