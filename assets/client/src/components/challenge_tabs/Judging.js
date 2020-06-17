import React from 'react'
import moment from 'moment'

import { ChallengeTab } from "../ChallengeTab"

export const Judging = ({challenge}) => {
  const renderPhaseData = (phases) => {
    return phases.map((phase, index) => {
      return (
        <div key={phase.id}>
          <h2 className="usa-accordion__heading">
            <button className="usa-accordion__button"
              aria-expanded={isCurrentPhase(phase)}
              aria-controls={`a${index}`}>
              <div>{`Phase ${index + 1}: ${phase.title}`}</div>
              <br/>
              <div>{`${utcToLocalTimestamp(phase.start_date)} - ${utcToLocalTimestamp(phase.end_date)}`}</div>
            </button>
          </h2>
          <div id={`a${index}`} className="usa-accordion__content" hidden={!isCurrentPhase(phase)}>
            <div dangerouslySetInnerHTML={{ __html: phase.judging_criteria }}></div>
          </div>
        </div>
      )
    })
  }

  const utcToLocalTimestamp = (datetime) => {
    return moment(datetime).local().format("llll")
  }

  const isCurrentPhase = (phase) => {
    return moment().isBetween(phase.start_date, phase.end_date, null, "[]")
  }

  return (
    <ChallengeTab label="Judging" downloadsLabel="Additional judging documents" section="judging" challenge={challenge} wrapContent={false}>
      <div className="usa-accordion">
        {renderPhaseData(challenge.phases)}
      </div>
    </ChallengeTab>
  )
}
