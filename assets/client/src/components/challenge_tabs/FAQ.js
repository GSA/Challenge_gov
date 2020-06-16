import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const FAQ = ({challenge}) => {
  return (
    <ChallengeTab label="Frequently asked questions" downloadsLabel="Additional FAQ documents" section="faq" challenge={challenge}>
      <div dangerouslySetInnerHTML={{ __html: challenge.faq }}></div>
    </ChallengeTab>
  )
}
