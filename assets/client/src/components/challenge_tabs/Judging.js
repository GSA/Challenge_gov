import React from 'react'

import { ChallengeTab } from "../ChallengeTab"
import { Accordion } from "../phase/Accordion"
import { AccordionSection } from "../phase/AccordionSection"
import { isSinglePhase, phaseNumber, getPreviousPhase, getCurrentPhase, getNextPhase } from "../../helpers/phaseHelpers"

export const Judging = ({challenge, print}) => {
  const renderPhaseData = (phases) => {
    if (isSinglePhase(challenge)) {
      return (
        <div className="ql-editor" dangerouslySetInnerHTML={{ __html: phases[0].judging_criteria }}></div>
      )
    } else {
      return (
        <Accordion>
          {
            phases.map((phase, index) => {
              return (
                <AccordionSection key={phase.id} phase={phase} index={index} section="judging" print={print}>
                  <div className="ql-editor" dangerouslySetInnerHTML={{ __html: phase.judging_criteria }}></div>
                </AccordionSection>
              )
            })
          }
        </Accordion>
      )
    }
  }

  return (
    <ChallengeTab label="Judging" downloadsLabel="Additional judging documents" section="judging" challenge={challenge} wrapContent={isSinglePhase(challenge)} print={print}>
      <div className="card">
        {renderPhaseData(challenge.phases)}
      </div>
    </ChallengeTab>
  )
}
