import React, { useEffect, useState, useContext } from 'react';
import axios from 'axios';
import { useLocation } from 'react-router-dom';

import { ChallengeDetails } from '../components/ChallengeDetails';
import { ApiUrlContext } from '../ApiUrlContext';
import NotFound from '../components/NotFound';

import queryString from 'query-string';

export const DetailsPage = ({ challengeId }) => {
  const [currentChallenge, setCurrentChallenge] = useState();
  const [challengePhases, setChallengePhases] = useState([]);
  const [loadingState, setLoadingState] = useState(true);

  let query = useLocation().search;
  const { print, tab } = queryString.parse(query);

  const { apiUrl } = useContext(ApiUrlContext);

  useEffect(() => {
    setLoadingState(true);

    let challengeApiPath = apiUrl + `/api/challenges/${challengeId}`;
    axios
      .get(challengeApiPath)
      .then(res => {
        setCurrentChallenge(res.data);
        setChallengePhases(res.data.phases);
        setLoadingState(false);
      })
      .catch(e => {
        setLoadingState(false);
      });
  }, []);

  const renderContent = () => {
    if (currentChallenge) {
      return (
        <>
          <h2 className="a11y-hidden">Challenge Details</h2>
          <ChallengeDetails challenge={currentChallenge} challengePhases={challengePhases} tab={tab} print={print} />
        </>
      );
    } else if (!currentChallenge && !loadingState) {
      return (
        <>
          <h2 className="a11y-hidden">Challenge Not Found</h2>
          <NotFound />
        </>
      );
    }
  };

  return (
    <div role="main" aria-labelledby="main-heading">
      {renderContent()}
    </div>
  );
};