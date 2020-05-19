import React from 'react'
import { SectionResources } from "./SectionResources"

export const Timeline = ({challenge}) => {
  const renderEvents = (events) => {
    return (
      events.map((event) => {
        return (
          <div key={event.id}>
            <div>{event.title}</div>
            <div>{event.body}</div>
            <div>{event.occurs_on}</div>
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
