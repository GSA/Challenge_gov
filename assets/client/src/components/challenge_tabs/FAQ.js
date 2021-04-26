import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const FAQ = ({challenge, print}) => {
  return (
    <ChallengeTab label="Frequently asked questions" downloadsLabel="Additional FAQ documents" section="faq" challenge={challenge} print={print}>
      <div dangerouslySetInnerHTML={{ __html: challenge.faq }}></div>
    </ChallengeTab>
  )
}
