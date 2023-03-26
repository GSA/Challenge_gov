import React from 'react'
import { ChallengeTab } from "../ChallengeTab"
import { stripHtml } from "string-strip-html";
import NumberFormat from 'react-number-format';

export const Prizes = ({challenge, print}) => {
  return (
    <ChallengeTab label="Prizes" downloadsLabel="Additional prize documents" section="prizes" challenge={challenge} print={print}>
      {((challenge.prize_type === "monetary" || challenge.prize_type === "both") && challenge.prize_total > 0) &&
        <div className="card">
           <h5 class="p-4 card-title">Total Cash Prizes</h5>
          <div className="card-body">
            <NumberFormat className="ql-editor" value={challenge.prize_total/100} displayType={'text'} thousandSeparator={true} prefix={'$'} />
          </div>
        </div>
      }
      {((challenge.prize_type === "non_monetary" || challenge.prize_type === "both") && challenge.non_monetary_prizes) &&
        <div className="card">
          <h5 class="p-4 card-title">Non-monetary Prizes</h5>
          <div className="card-body">
            <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.non_monetary_prizes }}></div>
          </div>
        </div>
      }
      {challenge.prize_description &&
        <div className="card">
          <h5 class="p-4 card-title">Prize Description</h5>
          <div className="card-body">
            <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.prize_description }}></div>
          </div>
        </div>
      }
    </ChallengeTab>
  )
}
