import React from 'react'
import { ChallengeTab } from "../ChallengeTab"
import { stripHtml } from "string-strip-html";

export const FAQ = ({challenge, print}) => {
  return (
    <ChallengeTab label="Frequently asked questions" downloadsLabel="Additional FAQ documents" section="faq" challenge={challenge} print={print}>
      <div className="card">
        <div className="card-body">
          <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.faq }}></div>
        </div>
      </div>
    </ChallengeTab>
  )
}
