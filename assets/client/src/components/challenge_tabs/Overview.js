import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Overview = ({challenge}) => {
  return (
    <ChallengeTab label="Overview" downloadsLabel="Additional overview documents" section="general" challenge={challenge}>
      <div dangerouslySetInnerHTML={{ __html: challenge.description }}></div>
    </ChallengeTab>
  )
}
