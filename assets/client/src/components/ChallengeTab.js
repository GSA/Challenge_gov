import React, { useState, useEffect } from 'react';
import { Tooltip } from 'reactstrap';
import { SectionResources } from './challenge_tabs/SectionResources';

export const ChallengeTab = ({ label, downloadsLabel, section, challenge, print, children }) => {
  const [copyTooltipOpen, setCopyTooltipOpen] = useState(false);

  useEffect(() => {
    const copyTooltipTimeout = setTimeout(() => {
      setCopyTooltipOpen(false);
    }, 2000);
    return () => {
      clearInterval(copyTooltipTimeout);
    };
  }, [copyTooltipOpen]);

  const handleCopyLink = () => {
    let copyText = document.getElementById('challenge-link-text');

    copyText.select();
    copyText.setSelectionRange(0, 99999);
    document.execCommand('copy');

    setCopyTooltipOpen(true);
  };

  const copyShareCSS = print ? 'float-right d-none' : 'float-right';

  return (
    <section className="challenge-tab container" aria-label={`${label} section`}>
      <div className="challenge-tab__header">
        <h2>{label}</h2>
        <div className={copyShareCSS} id="challenge-link">
          <input
            id="challenge-link-text"
            className="opacity-0"
            defaultValue={window.location.href}
            aria-hidden="true"
          />
          <button
            id="challenge-link-btn"
            className="usa-button usa-button--unstyled text-decoration-none"
            onClick={handleCopyLink}
            aria-label="Copy share link"
          >
            <i className="far fa-copy me-1" aria-hidden="true"></i>
            <span>Copy share link</span>
          </button>
          <Tooltip isOpen={copyTooltipOpen} fade={true} target="challenge-link-btn">
            Link copied
          </Tooltip>
        </div>
      </div>
      <hr />
      <section className="challenge-tab__content" aria-labelledby="challengeContent">
        <h3 id="challengeContent" className="usa-sr-only">
          {label} Content
        </h3>
        <>{children}</>
      </section>
      <SectionResources challenge={challenge} section={section} label={downloadsLabel} />
    </section>
  );
};