import React from 'react'

import { ChallengeTab } from "../ChallengeTab"
import { Accordion } from "../phase/Accordion"
import { AccordionSection } from "../phase/AccordionSection"
import { isSinglePhase, phaseNumber, getPreviousPhase, getCurrentPhase, getNextPhase } from "../../helpers/phaseHelpers"

export const Judging = ({challenge}) => {
  const renderPhaseData = (phases) => {
    if (isSinglePhase(challenge)) {
      return (
        <div>
          <div dangerouslySetInnerHTML={{ __html: phases[0].judging_criteria }}></div>
        </div>
      )
    } else {
      return (
        <Accordion>
          {
            phases.map((phase, index) => {
              return (
                <AccordionSection key={phase.id} phase={phase} index={index}>
                  <div dangerouslySetInnerHTML={{ __html: phase.judging_criteria }}></div>
                </AccordionSection>
              )
            })
          }
        </Accordion>
      )
    }
  }

  return (
    <ChallengeTab label="Judging" downloadsLabel="Additional judging documents" section="judging" challenge={challenge} wrapContent={isSinglePhase(challenge)}>
      {renderPhaseData(challenge.phases)}
    </ChallengeTab>
  )
}
