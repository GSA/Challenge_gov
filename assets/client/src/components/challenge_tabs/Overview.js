import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Overview = ({challenge, print}) => {
  return (
    <ChallengeTab label="Overview" downloadsLabel="Additional overview documents" section="general" challenge={challenge} print={print}>
      <div className="usa-card">
        <div className="usa-card-body" style={{padding: '15px'}}>
          <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.description }}></div>
        </div>
      </div>
    </ChallengeTab>
  )
}