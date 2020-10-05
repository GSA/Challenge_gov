import React from 'react';
import { SectionResources } from "./challenge_tabs/SectionResources"

export const ChallengeTab = ({label, downloadsLabel, section, challenge, wrapContent = true, children}) => {
  const handleCopyLink = () => {
    let copyText = document.getElementById("challenge-link-text")

    copyText.select()
    copyText.setSelectionRange(0,99999)
    document.execCommand("copy")
  }

  return (    
    <section className="challenge-tab container">
      <div className="challenge-tab__header">
        <span>{label}</span>
        <div className="float-right">
          <input id="challenge-link-text" className="opacity-0" defaultValue={window.location.href}/>
          <button className="usa-button usa-button--unstyled text-decoration-none" onClick={handleCopyLink}>
            <i className="far fa-copy mr-1"></i>
            Copy share link
          </button>
        </div>
      </div>
      <hr/>
      <section className="card challenge-tab__content">
        {wrapContent ?  
          (
            <div className="card-body">
              {children}
            </div>
          ) : (
            <>
              {children}
            </>
          )
        }
      </section>
      <SectionResources challenge={challenge} section={section} label={downloadsLabel} />
    </section>
  )
}