import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Prizes = ({challenge}) => {
  return (
    <ChallengeTab label="Prizes" downloadsLabel="Additional prize documents" section="prizes" challenge={challenge}>
      <div>{challenge.prize_total}</div>
      <div>{challenge.prize_description}</div>
      <div>{challenge.non_monetary_prizes}</div>
    </ChallengeTab>
  )
}
