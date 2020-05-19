import React from 'react'
import { SectionResources } from "./SectionResources"

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
    <section className="challenge-tab container">
      <div className="challenge-tab__header">Timeline</div>
      <hr/>      
      <section className="card challenge-tab__content">
        <div className="card-body">
          {renderEvents(challenge.events)}
        </div>
      </section>
      <SectionResources challenge={challenge} section="timeline" />
    </section>
  )
}
