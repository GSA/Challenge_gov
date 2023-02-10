import React from 'react';
import ReactDOM from 'react-dom';
import queryString from 'query-string'
import { BrowserRouter, Redirect, Route, useLocation } from "react-router-dom";
import { Helmet, HelmetProvider } from 'react-helmet-async';
import { IndexRoutes } from "./routes/index";
import * as serviceWorker from './serviceWorker';
import { useTracking } from './useTracking'
import { ApiUrlContext } from "./ApiUrlContext"

import { LandingPage } from './pages/LandingPage'
import { DetailsPage } from './pages/DetailsPage'

import '../../css/public/index.scss'

const getRoutes = () => {
  return IndexRoutes.map((prop, i) => {
    if (prop.redirect) {
      return (
        <Redirect from={prop.path} to={prop.pathTo} key={`route-${i}`} />
      );
    }
    return (
      <Route
        path={prop.path}
        key={`route-${i}`}
        component={prop.component}
        exact={prop.exact && true}
      />
    );
  });
};

const Application = () => {
  useTracking()

  let query = useLocation().search

  const { challenge, state } = queryString.parse(query)

  if (challenge) {
    return  <div>
                    <HelmetProvider>
                  <Helmet>
                  <title>testing</title>
                  
                  <meta property="og:title" key="og:title" content="testing" />
                  
                </Helmet>
                </HelmetProvider> 
              <DetailsPage challengeId={challenge} />       
            </div>
              
  } else if (state == "archived") {
    return <LandingPage isArchived={true} />
  } else {
    return <LandingPage />
  }
}

const renderRouter = () => (
  <ApiUrlContext.Provider value={{
    apiUrl: apiUrl || window.location.origin,
    publicUrl: publicUrl || "",
    imageBase: imageBase || "",
    bridgeApplyBlocked: bridgeApplyBlocked
  }}>
    <BrowserRouter >
    {/* <Helmet prioritizeSeoTags>
                    <title>**Challenge.Gov</title>
                    <meta name="description" content="**** Here, members of the public compete to help the U.S. government solve problems big and small. Browse through challenges and submit your ideas for a chance to win." />
                    <meta property="og:title" key="og:title" content="**** Challenge.Gov" />
                    <meta property="og:description" content="** Here, members of the public compete to help the U.S. government solve problems big and small. Browse through challenges and submit your ideas for a chance to win." />
                    <meta property="og:type" content="article"></meta>
                    <meta property="og:image" content="/assets/images/cards/challenge-gov.png" />
                    <meta property="og:url" content="/?challenge=challenge-title-ii7" />
      </Helmet> */}
      <Application />
    </BrowserRouter>
  </ApiUrlContext.Provider>
)

const rootElement = document.getElementById('challenge-gov-react-app')
const apiUrl = rootElement.getAttribute('data-api-url')
const publicUrl = rootElement.getAttribute('data-public-url')
const imageBase = rootElement.getAttribute('data-image-base')
const bridgeApplyBlocked = rootElement.getAttribute('data-bridge-apply-blocked') != 'false'

ReactDOM.render(renderRouter(), rootElement);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
