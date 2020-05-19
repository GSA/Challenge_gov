import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Winners = ({challenge}) => {
  return (
    <ChallengeTab label="Winners" downloadsLabel="Additional winner documents" section="winners" challenge={challenge}>
      <div>{challenge.winner_image}</div>
      <div>{challenge.winner_information}</div>
    </ChallengeTab>
  )
}
