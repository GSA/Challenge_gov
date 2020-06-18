import React from 'react'

import { ChallengeTab } from "../ChallengeTab"
import { Accordion } from "../phase/Accordion"
import { AccordionSection } from "../phase/AccordionSection"

export const Judging = ({challenge}) => {
  const renderPhaseData = (phases) => {
    return phases.map((phase, index) => {
      return (
        <AccordionSection key={phase.id} phase={phase} index={index}>
          <div dangerouslySetInnerHTML={{ __html: phase.judging_criteria }}></div>
        </AccordionSection>
      )
    })
  }

  return (
    <ChallengeTab label="Judging" downloadsLabel="Additional judging documents" section="judging" challenge={challenge} wrapContent={false}>
      <Accordion>
        {renderPhaseData(challenge.phases)}
      </Accordion>
    </ChallengeTab>
  )
}
