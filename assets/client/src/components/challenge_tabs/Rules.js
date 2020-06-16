import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Rules = ({challenge}) => {
  return (
    <ChallengeTab label="Rules" downloadsLabel="Additional rule documents" section="rules" challenge={challenge}>
      <div dangerouslySetInnerHTML={{ __html: challenge.rules }}></div>
    </ChallengeTab>
  )
}
