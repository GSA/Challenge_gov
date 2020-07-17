import React from 'react';
import moment from 'moment';
import {formatDate} from "../helpers/phaseHelpers"

export const ChallengeAnnouncement = ({challenge}) => {
  const checkAnnouncementDate = ({announcement_datetime}) => {
    return moment().diff(announcement_datetime, 'days') <= 14
  }

  return (    
    checkAnnouncementDate(challenge) ? (
      <div className="usa-alert usa-alert--info mb-3">
        <div className="usa-alert__body">
          <h3 className="usa-alert__heading">Important update on {formatDate(challenge.announcement_datetime)}</h3>
          <p className="usa-alert__text">{challenge.announcement}</p>
        </div>
      </div>
    ) : null
  )
}