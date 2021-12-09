import React, {useContext} from 'react'
import { Link } from "react-router-dom";
import moment from "moment"
import {getCurrentPhase, getNextPhase, phaseNumber, formatDateTime, formatTime, isSinglePhase, isPhaseless, daysInMinutes} from "../helpers/phaseHelpers"
import {truncateString} from '../helpers/stringHelpers'
import { ApiUrlContext } from '../ApiUrlContext'

export const ChallengeTile = ({challenge, preview}) => {
  const { publicUrl, imageBase } = useContext(ApiUrlContext)

  const renderTags = ({is_archived, start_date, end_date, announcement_datetime}) => {
    const startDateDiff = moment().diff(start_date, 'minutes')
    const endDateDiff = moment().diff(end_date, 'minutes')
    const announcementDateDiff = moment().diff(announcement_datetime, 'minutes')

    let tags = []

    if (is_archived) {
      tags.push(<div key={"archived"} className="usa-tag usa-tag--archived">Archived</div>)
    }

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

  const challengeTileUrl = (challenge, preview) => {
    if (challenge.external_url) {
      return challenge.external_url
    } else if (preview) {
      return "#"
    } else {
      return `${publicUrl}/?challenge=${challenge.custom_url || challenge.id}`
    }
  }

  const renderTileLogo = () => {
    if (challenge.imported && challenge.sub_status === "archived" && challenge.logo.includes("challenge-logo-2_1")) {
      return (
        <div className="agency_image_wrapper">
          <img
            className="agency-logo"
            src={imageBase + challenge.agency_logo}
            alt={`${challenge.agency_name} logo`}
            title="Challenge agency logo" />
        </div>
      )
    }

    if (challenge.logo) {
      return (
        <div className="image_wrapper">
          <img src={challenge.logo} alt={challenge.logo_alt_text} title="Challenge logo" className="w-100"/>
        </div>
      )
    }

    return (
      <div className="image_wrapper">
        <img
          src={imageBase + challenge.agency_logo}
          alt="Challenge agency logo"
          title="Challenge agency logo"
          className="w-100"
        />
      </div>
    )
  }

  return (
    challenge ? (
      <div key={challenge.id} className="challenge-tile card">
        <a href={challengeTileUrl(challenge, preview)} target={challenge.external_url ? "_blank" : ""} aria-label="View challenge details">
          {renderTileLogo()}
          <div className="challenge-tile__text-wrapper">
            <p className="challenge-tile__title test" aria-label="Challenge title">{truncateString(challenge.title, 90)}</p>
            <p className="challenge-tile__agency-name" aria-label="Agency name">{truncateString(challenge.agency_name, 90)}</p>
            <p className="challenge-tile__tagline" aria-label="Challenge tagline">{truncateString(challenge.tagline, 90)}</p>
            <p className="challenge-tile__date">{renderDate(challenge)}</p>
            {renderTags(challenge)}
          </div>
        </a>
      </div>
    ) : (
      <div className="challenge-tile__loader--image"></div>
    )
  )
}
