import React from 'react';
import moment from 'moment';
import {formatDate, daysInMinutes, formatDateTime} from "../helpers/phaseHelpers"

export const ChallengeAnnouncement = ({challenge}) => {
  const checkAnnouncementDate = ({announcement_datetime}) => {
    return moment().diff(announcement_datetime, 'minutes') <= daysInMinutes(14)
  }

  const renderAnnouncement = ({header, body}) => {
    return (
      <div className="usa-alert usa-alert--info mb-3">
        <div className="usa-alert__body">
          {header ? <h3 className="usa-alert__heading">{header}</h3> : null}
          {body ? <p className="usa-alert__text">{body}</p> : null}
        </div>
      </div>
    )
  }

  const renderClosedBanner = ({is_closed, is_archived}) => {
    if (checkAnnouncementDate(challenge)) return null

    if (is_archived) {
      return renderAnnouncement({body: "This challenge is closed to submissions."})
    } else if (is_closed) {
      return renderAnnouncement({body: "This is an ongoing competition open to select participants only."})
    }
  }

  return (
    <>
      {renderClosedBanner(challenge)}
      {checkAnnouncementDate(challenge) ? 
        renderAnnouncement({header: `Important update on ${formatDate(challenge.announcement_datetime)}`, body: challenge.announcement}) : null
      }
    </>
  )
}
