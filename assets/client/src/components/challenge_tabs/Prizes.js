import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Prizes = ({challenge, print}) => {
  return (
    <ChallengeTab label="Prizes" downloadsLabel="Additional prize documents" section="prizes" challenge={challenge} print={print}>
      <div>{challenge.prize_total}</div>
      <div>{challenge.non_monetary_prizes}</div>
      <div dangerouslySetInnerHTML={{ __html: challenge.prize_description }}></div>
    </ChallengeTab>
  )
}
