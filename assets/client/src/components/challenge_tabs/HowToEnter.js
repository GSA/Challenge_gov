import React from 'react'

import { ChallengeTab } from "../ChallengeTab"
import { Accordion } from "../phase/Accordion"
import { AccordionSection } from "../phase/AccordionSection"
import { isSinglePhase } from '../../helpers/phaseHelpers'

export const HowToEnter = ({challenge, print}) => {
  const renderPhaseData = (phases) => {
    if (isSinglePhase(challenge)) {
      return (
        <div className="ql-editor" dangerouslySetInnerHTML={{ __html: phases[0].how_to_enter }}></div>
      )
    } else {
      return (
        <Accordion>
          {
            phases.map((phase, index) => {
              return (
                <AccordionSection key={phase.id} phase={phase} index={index} section="how to enter" print={print}>
                  <div className="ql-editor" dangerouslySetInnerHTML={{ __html: phase.how_to_enter }}></div>
                </AccordionSection>
              )
            })
          }
        </Accordion>
      )
    }
  }

  return (
    <ChallengeTab label="How to enter" downloadsLabel="Additional documents on how to enter" section="how_to_enter" challenge={challenge} wrapContent={isSinglePhase(challenge)} print={print}>
      <div className="card">
        {renderPhaseData(challenge.phases)}
      </div>
    </ChallengeTab>
  )
}
