import React from 'react'
import { ChallengeTab } from "../ChallengeTab"
import { formatDateTime } from '../../helpers/phaseHelpers'

export const Timeline = ({challenge, print}) => {
  const renderEvents = (events) => {
    return (
      events.map((event, index) => {
        return (
          <div key={event.id}>
            <div><span class="text-bold">{formatDateTime(event.occurs_on)}</span>: {event.title}</div>
            { (events.length - 1 != index) && <hr class="my-3"/> }
          </div>
        )
      })
    )
  }

  return (
    <ChallengeTab label="Timeline" downloadsLabel="Additional timeline documents" section="timeline" challenge={challenge} print={print}>
      <div className="card">
        <div className="card-body">
          {renderEvents(challenge.events)}
        </div>
      </div>
    </ChallengeTab>
  )
}
