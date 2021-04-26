import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Rules = ({challenge, print}) => {
  return (
    <ChallengeTab label="Rules" downloadsLabel="Additional rule documents" section="rules" challenge={challenge} print={print}>
      <div dangerouslySetInnerHTML={{ __html: challenge.rules }}></div>
    </ChallengeTab>
  )
}
