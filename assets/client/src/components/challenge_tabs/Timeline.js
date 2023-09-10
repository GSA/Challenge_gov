import React from 'react'
import { ChallengeTab } from "../ChallengeTab"
import { formatDateTime } from '../../helpers/phaseHelpers'

export const Timeline = ({challenge, print}) => {
 const renderEvents = (events) => {
  return (
    events.map((event, index) => {
      const style = (index === 0)
        ? { textAlign: 'left', padding: '10px' }
        : { textAlign: 'left', padding: '10px' };
      return (
        <div key={event.id} style={style}>
          <div><span className="text-bold">{formatDateTime(event.occurs_on)}</span>: {event.title}</div>
          { (events.length - 1 !== index) && <hr style={{margin: '5px 0'}} /> }
        </div>
      )
    })
  )
}

  return (
    <ChallengeTab label="Timeline" downloadsLabel="Additional timeline documents" section="timeline" challenge={challenge} print={print}>
      <div className="usa-card">
        <div className="usa-card-body">
          {renderEvents(challenge.events)}
        </div>
      </div>
    </ChallengeTab>
  )
}
