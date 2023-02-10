import React, { useEffect, useState, useContext } from 'react'
import axios from 'axios'
import { useLocation } from "react-router-dom";

import { ChallengeDetails } from '../components/ChallengeDetails';
import { ApiUrlContext } from '../ApiUrlContext'
import NotFound from '../components/NotFound'

import queryString from 'query-string'
import { Helmet, HelmetProvider } from 'react-helmet-async';

export const DetailsPage = ({challengeId}) => {
  const [currentChallenge, setCurrentChallenge] = useState()
  const [challengePhases, setChallengePhases] = useState([])
  const [loadingState, setLoadingState] = useState(true)

  let query = useLocation().search
  const { print, tab } = queryString.parse(query)

  const { apiUrl } = useContext(ApiUrlContext)

  useEffect(() => {
    setLoadingState(true)
    // TODO: Temporary hiding of layout on chal details until the layout is moved
    $(".top-banner").hide()
    $(".help-section").hide()
    $(".section-divider").hide()
    $(".footer").hide()
    $(".usa-hero").hide()
    $(".video").hide()
    $(".challenges-header").hide()
    $(".newsletter").hide()
    

    let challengeApiPath = apiUrl + `/api/challenges/${challengeId}`
    axios
      .get(challengeApiPath)
      .then(res => {
        setCurrentChallenge(res.data)
        setChallengePhases(res.data.phases)
        setLoadingState(false)
      })
      .catch(e => {
        setLoadingState(false)
        console.log({e})
      })
  }, [])

  const usePageMeta = (title, description) =>{
    const defaultTitle = "app-name";
    const defaultDesc = "meta description";

    useEffect(() => {
        document.title = title || defaultTitle;
        document.querySelector("meta[name='description']").setAttribute("content", description || defaultDesc);
        document.querySelector("meta[property='og:description']").setAttribute("content", description || defaultDesc);
        document.querySelector("meta[property='og:title']").setAttribute("content", title || defaultTitle);
        document.querySelector("link[rel='canonical']").setAttribute("href", window.location.href);
        document.querySelector("meta[property='og:url']").setAttribute("content", window.location.href);
    }, [defaultTitle, title, defaultDesc, description]);
};


  const renderContent = () => {
    if (currentChallenge) {
      return  <div>
      <HelmetProvider>
        <Helmet>
        <title>{currentChallenge.title}</title>
        <meta data-rh='true' name="description" content={currentChallenge.brief_description}  />
        <meta property="og:title" key="og:title" content={currentChallenge.title} />
        <meta property="og:description" content={currentChallenge.brief_description} />
        <meta name="twitter:card" value={currentChallenge.logo} />
        <meta name="twitter:site" content="" />
        <meta property="og:image" content={currentChallenge.logo} />
        <meta property="og:url" content={`/?challenge=${currentChallenge.custom_url}`} />
        <link rel='canonical' href={`/?challenge=${currentChallenge.custom_url}`}   />
        <meta property="og:type" content="article" />
      </Helmet>
      </HelmetProvider>  
     <ChallengeDetails challenge={currentChallenge} challengePhases={challengePhases} tab={tab} print={print} />
              </div>  
    } else if (!currentChallenge && !loadingState) {
      return <NotFound />
    }
  }
  
  return (
    <div>    
      {renderContent()}
    </div>
  )
}
