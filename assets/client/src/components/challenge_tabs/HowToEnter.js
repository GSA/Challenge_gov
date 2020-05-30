import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const HowToEnter = ({challenge}) => {
  return (
    <ChallengeTab label="How to enter" downloadsLabel="Additional documents on how to enter" section="how_to_enter" challenge={challenge}>
      {challenge.how_to_enter}
    </ChallengeTab>
  )
}
