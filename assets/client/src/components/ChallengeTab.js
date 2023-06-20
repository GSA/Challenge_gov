import React, { useState, useEffect } from 'react';
import { Tooltip } from 'reactstrap';
import { SectionResources } from "./challenge_tabs/SectionResources";

export const ChallengeTab = ({ label, downloadsLabel, section, challenge, children }) => {
  const [copyTooltipOpen, setCopyTooltipOpen] = useState(false);

  useEffect(() => {
    const copyTooltipTimeout = setTimeout(() => {
      setCopyTooltipOpen(false);
    }, 2000);
    return () => {
      clearTimeout(copyTooltipTimeout);
    };
  }, [copyTooltipOpen]);

  const handleCopyLink = () => {
    let copyText = document.getElementById(`challenge-link-text-${section}`);
    copyText.select();
    copyText.setSelectionRange(0, 99999);
    document.execCommand("copy");
    setCopyTooltipOpen(true);
  };

  const renderCopyShareButton = () => {
    if (label === "Overview") {
      return (
        <div className="float-right" id="challenge-link">
          <input id={`challenge-link-text-${section}`} className="opacity-0" defaultValue={window.location.href} />
          <button id="challenge-link-btn" className="usa-button usa-button--unstyled text-decoration-none" onClick={handleCopyLink}>
            <i className="far fa-copy me-1"></i>
            <span>Copy share link</span>
          </button>
          <Tooltip isOpen={copyTooltipOpen} fade={true} target="challenge-link-btn">Link copied</Tooltip>
        </div>
      );
    }
    return null;
  };

  return (
    <section className="challenge-tab container" id={`challenge-tab-${section}`}>
      <div className="challenge-tab__header">
        <span>{label}</span>        
        {/* {renderCopyShareButton()} */}
      </div>
      <hr />
      <section className="challenge-tab__content">
        {children}
      </section>
      <SectionResources challenge={challenge} section={section} label={downloadsLabel} />
    </section>
  )
};