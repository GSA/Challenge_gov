import React, { useState, useEffect } from 'react'
import { Tooltip } from 'reactstrap'
import { SectionResources } from "./challenge_tabs/SectionResources"

export const ChallengeTab = ({label, downloadsLabel, section, challenge, print, children}) => {
  const [copyTooltipOpen, setCopyTooltipOpen] = useState(false)
  const uniqueID = "challenge-link-btn-" + Math.floor(Math.random() * 1000000);
  const uniqueInputID = "challenge-link-text-" + Math.floor(Math.random() * 1000000);

  useEffect(() => {
    const copyTooltipTimeout = setTimeout(() => {
      setCopyTooltipOpen(false)
    }, 2000)
    return () => {
      clearInterval(copyTooltipTimeout)
    }
  }, [copyTooltipOpen])

  const handleCopyLink = () => {
    let copyText = document.getElementById(uniqueInputID)

    copyText.select()
    copyText.setSelectionRange(0,99999)
    document.execCommand("copy")

    setCopyTooltipOpen(true)
  }

  const copyShareCSS = print ? "float-right d-none" : "float-right"

  return (
    <main className="challenge-tab container">
      <div className="challenge-tab__header" id="challenge-link">
        <h2>{label}</h2>
          <div className={copyShareCSS}>
            <input disabled aria-hidden="true" id={uniqueInputID} className="opacity-0" defaultValue={window.location.href}/>
            <button id={uniqueID} className="usa-button usa-button--unstyled text-decoration-none" onClick={handleCopyLink} aria-label={`Copy share link for ${label}`}>
              <i className="far fa-copy me-1"></i>
              <span>Copy share link</span>
            </button>
            <Tooltip isOpen={copyTooltipOpen} fade={true} target={uniqueID}>Link copied</Tooltip>
          </div>
      </div>
      <hr/>
      <section className="challenge-tab__content">
        <>
          {children}
        </>
      </section>
      <SectionResources challenge={challenge} section={section} label={downloadsLabel} />
    </main>
  )
}