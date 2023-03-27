import React from 'react'
import { ChallengeTab } from "../ChallengeTab"

export const Rules = ({challenge, print}) => {
  return (
    <ChallengeTab label="Rules" downloadsLabel="Additional rule documents" section="rules" challenge={challenge} print={print}>
      {challenge.eligibility_requirements &&
        <span>
          <h5 class="m-3"><b>Eligibility requirements</b></h5>
          <div className="card">
            <div className="card-body">
              <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.eligibility_requirements }}></div>
            </div>
          </div>
        </span>
      }
      <span>
        <h5 class="m-3"><b>Rules</b></h5>
        <div className="card">
          <h5 class="p-4 card-title">Terms And Conditions</h5>
          <div className="card-body">
            <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.rules }}></div>
          </div>
        </div>
      </span>
      {!challenge.terms_equal_rules &&
        <span>
          <h5 class="m-3"><b>Terms and conditions</b></h5>
          <div className="card">
            <div className="card-body">
              <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.terms_and_conditions }}></div>
            </div>
          </div>
        </span>
      }
    </ChallengeTab>
  )
}
