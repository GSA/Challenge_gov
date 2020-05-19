import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Judging = ({challenge}) => {
  return (
    <ChallengeTab label="Judging" downloadsLabel="Additional judging documents" section="judging" challenge={challenge}>
      <div>{challenge.judging_criteria}</div>
    </ChallengeTab>
  )
}
