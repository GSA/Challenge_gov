import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Rules = ({challenge, print}) => {
  return (
    <ChallengeTab label="Rules" downloadsLabel="Additional rule documents" section="rules" challenge={challenge} print={print}>
      {challenge.eligibility_requirements &&
        <div className="card">
          <h5 class="card-title">Eligibility Requirements</h5>
          <div className="card-body">
            <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.eligibility_requirements }}></div>
          </div>
        </div>
      }
      <div className="card">
        <h5 class="card-title">Official Rules</h5>
        <div className="card-body">
          <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.rules }}></div>
        </div>
      </div>
      {!challenge.terms_equal_rules &&
        <div className="card">
          <h5 class="card-title">Terms And Conditions</h5>
          <div className="card-body">
            <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.terms_and_conditions }}></div>
          </div>
        </div>
      }
    </ChallengeTab>
  )
}
