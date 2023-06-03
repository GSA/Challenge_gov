import React, { useState } from 'react';
import { useHistory, useLocation, useRouteMatch, useParams } from 'react-router-dom';

import queryString from 'query-string';

export const ChallengeTabs = (props) => {
  const { children, print, preview, tab } = props;
  const [activeTab, setActiveTab] = useState(tab ?? 'overview');
  const history = useHistory();
  const currentPath = useRouteMatch();
  const params = useParams();

  let location = useLocation();

  const handleTabClick = (label, disabled) => {
    if (!disabled) {
      let queryParams = queryString.parse(location.search);
      queryParams.tab = label.toLowerCase();

      let pathRoot = preview ? '/public/previews/challenges?' : `${location.pathname}?`;

      const path = pathRoot + queryString.stringify(queryParams);
      history.push(path);
      setActiveTab(label);
    }
  };

  const tabProps = (label, disabled) => {
    let tProps = {
      className: tabClasses(label, disabled),
      disabled: disabled,
      'aria-disabled': disabled,
      'aria-controls': label.toLowerCase() + '-tabpanel',
    };

    if (disabled) {
      tProps['tab-index'] = -1;
    }

    return tProps;
  };
  const tabClasses = (label, disabled) => {
    return 'challenge-tabs__tab' + activeTabClasses(label) + disabledTabClasses(disabled);
  };
  const activeTabClasses = (label) => {
    return activeTab === label ? ' challenge-tabs__tab--active' : '';
  };
  const disabledTabClasses = (disabled) => {
    return disabled ? ' challenge-tabs__tab--disabled disabled' : '';
  };

  const renderWinnersIcon = (label, disabled) => {
    if (label === 'winners' && !disabled) {
      return (
        <i className="fas fa-award me-2" aria-hidden="true" aria-label="Winners Icon"></i>
      );
    }
  };

  const renderTabLabels = () => {
    return (
      <ul className="challenge-tabs__list" role="tablist">
        {React.Children.map(children, (child) => {
          if (child) {
            const { label, disabled } = child.props;
            const titleCasedLabel =
              label === 'faq'
                ? label.toUpperCase()
                : label[0].toUpperCase() + label.slice(1).toLowerCase();
            return (
              <li
                {...tabProps(label, disabled)}
                onClick={(e) => handleTabClick(label, disabled)}
                role="tab"
                aria-selected={activeTab === label}
                id={label.toLowerCase() + '-tab'}
              >
                {renderWinnersIcon(label, disabled)}
                {titleCasedLabel}
              </li>
            );
          }
        })}
      </ul>
    );
  };

  const renderTabContent = () => {
    return (
      <div className="challenge-tabs__content">
        {React.Children.map(children, (child) => {
          if (child) {
            const { label, children } = child.props;

            if (label !== activeTab && (!print || label === 'Contact')) {
              return (
                <div className="inactive-tabs" hidden>
                  {children}
                </div>
              );
            }
            return (
              <div
                id={label.toLowerCase() + '-tabpanel'}
                role="tabpanel"
                aria-labelledby={label.toLowerCase() + '-tab'}
              >
                {children}
              </div>
            );
          }
        })}
      </div>
    );
  };

  return (
    <div className="challenge-tabs">
      {renderTabLabels()}
      {renderTabContent()}
    </div>
  );
};