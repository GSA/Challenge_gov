import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Timeline = ({challenge}) => {
  const renderEvents = (events) => {
    return (
      events.map((event, index) => {
        return (
          <div key={event.id}>
            <div>{event.occurs_on}: {event.title}</div>
            <div>{event.body}</div>
            { (events.length - 1 != index) && <hr/> }
          </div>
        )
      })
    )
  }

  return (
    <ChallengeTab label="Timeline" downloadsLabel="Additional timeline documents" section="timeline" challenge={challenge}>
      {renderEvents(challenge.events)}
    </ChallengeTab>
  )
}
