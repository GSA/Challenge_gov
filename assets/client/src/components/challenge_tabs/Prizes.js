import React from 'react'
import { ChallengeTab } from "../ChallengeTab"
import { stripHtml } from "string-strip-html";
import NumberFormat from 'react-number-format';

export const Prizes = ({challenge, print}) => {
  return (
    <ChallengeTab label="Prizes" downloadsLabel="Additional prize documents" section="prizes" challenge={challenge} print={print}>
      {((challenge.prize_type === "monetary" || challenge.prize_type === "both") && challenge.prize_total > 0) &&
      <span>
        <h3 className="usa-m-1rem"><b>Total cash prizes</b></h3>
        <div className="usa-card">
          <div className="usa-card-body" style={{padding: '15px'}}>
            <NumberFormat className="ql-editor" value={challenge.prize_total/100} displayType={'text'} thousandSeparator={true} prefix={'$'} />
          </div>
        </div>
      </span>
      }
      {((challenge.prize_type === "non_monetary" || challenge.prize_type === "both") && challenge.non_monetary_prizes) &&
      <span>
        <h3 className="usa-m-1rem"><b>Non-monetary prizes</b></h3>
        <div className="usa-card">
          <div className="usa-card-body" style={{padding: '15px'}}>
            <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.non_monetary_prizes }}></div>
          </div>
        </div>
      </span>
      }
      {challenge.prize_description &&
      <span>
        <h3 className="usa-m-1rem"><b>Prize description</b></h3>
        <div className="usa-card">
          <div className="usa-card-body" style={{padding: '15px'}}>
            <div className="ql-editor" dangerouslySetInnerHTML={{ __html: challenge.prize_description }}></div>
          </div>
        </div>
      </span>
      }
    </ChallengeTab>
  )
}