import React from 'react'
import moment from 'moment'

import {phaseInPast, phaseIsCurrent, phaseInFuture} from "../../helpers/phaseHelpers"

export const AccordionSection = ({phase, index, section, children, print}) => {
  const renderPhaseText = (phase) => {
    let phaseText = ""
    let phaseClass = "phase__text phase__text"

    if (phaseInPast(phase)) {
      phaseText = "(closed)"
      phaseClass += "--closed"
    } else if (phaseIsCurrent(phase)) {
      phaseText = `(open until ${moment(phase.end_date).local().format("MM/DD/YY")})`
      phaseClass += "--open"
    } else if (phaseInFuture(phase)) {
      phaseText = `(opens on ${moment(phase.start_date).local().format("MM/DD/YY")})`
    }

    return <span className={phaseClass}>{phaseText}</span>
  }

  return (
    <div>
      <h2 className="usa-accordion__heading">
        <div className="usa-accordion__button" aria-expanded="true" >
          <span>{`Phase ${index + 1}${phase.title ? ": " + phase.title : ""}`}</span>
          {renderPhaseText(phase)}
        </div>
      </h2>
      <div id={`a${index}`} className="usa-accordion__content" >
        {children}
      </div>
    </div>
  )
}
