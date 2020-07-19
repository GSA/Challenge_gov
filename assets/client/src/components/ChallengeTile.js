import React from 'react'
import { Link } from "react-router-dom";
import moment from "moment"
import {formatDateTime} from "../helpers/phaseHelpers"

export const ChallengeTile = ({challenge, preview}) => {
  const renderTags = ({start_date, end_date, announcement_datetime}) => {
    let tags = []

    if (moment().diff(start_date, 'days') <= 0) {
      tags.push(<div key={"coming_soon"} className="usa-tag usa-tag--coming-soon">Coming soon</div>)
    }

    if (moment().diff(end_date, 'days') >= -7 && moment().diff(end_date, 'days') < 1) {
      tags.push(<div key={"closing_soon"} className="usa-tag usa-tag--closing-soon">Closing soon</div>)
    }

    if (moment().diff(announcement_datetime, 'days') <= 7) {
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

  return (
    challenge ? (
      <div key={challenge.id} className="challenge-tile card">
        <Link to={preview ? "#" : `/public/challenge/${challenge.id}`} aria-label="View challenge details">
          <div className="image_wrapper">
            { challenge.logo
              ? <img src={challenge.logo} alt="Challenge logo" title="Challenge logo" className="w-100"/>
              : <img
                  src={challenge.agency_logo}
                  alt="Challenge agency logo"
                  title="Challenge agency logo"
                  className="w-100"
                />
            }
          </div>
          <div className="card__text-wrapper">
            <p className="card__title test" aria-label="Challenge title">{challenge.title}</p>
            <p className="card__agency-name" aria-label="Agency name">{challenge.agency_name}</p>
            <p className="card__tagline" aria-label="Challenge tagline">{challenge.tagline}</p>
            <p className="card__date">{formatDateTime(challenge.open_until)}</p>
            {renderTags(challenge)}
          </div>
        </Link>
      </div>
    ) : (
      <div className="card__loader--image"></div>
    )
  )
}
