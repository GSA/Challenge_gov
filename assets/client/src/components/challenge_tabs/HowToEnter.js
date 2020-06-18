import React from 'react'

import { ChallengeTab } from "../ChallengeTab"
import { Accordion } from "../phase/Accordion"
import { AccordionSection } from "../phase/AccordionSection"

export const HowToEnter = ({challenge}) => {
  const renderPhaseData = (phases) => {
    return phases.map((phase, index) => {
      return (
        <AccordionSection key={phase.id} phase={phase} index={index}>
          <div dangerouslySetInnerHTML={{ __html: phase.how_to_enter }}></div>
        </AccordionSection>
      )
    })
  }

  return (
    <ChallengeTab label="How to enter" downloadsLabel="Additional documents on how to enter" section="how_to_enter" challenge={challenge} wrapContent={false}>
      <Accordion>
        {renderPhaseData(challenge.phases)}
      </Accordion>
    </ChallengeTab>
  )
}
