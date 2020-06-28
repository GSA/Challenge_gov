import React from 'react'
import { Link } from "react-router-dom";
import moment from "moment"
import {formatDateTime} from "../helpers/phaseHelpers"

export const ChallengeTile = ({challenge, preview}) => {
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
          </div>
        </Link>
      </div>
    ) : (
      <div className="card__loader--image"></div>
    )
  )
}
