import React from 'react';
import ReactDOM from 'react-dom';
import queryString from 'query-string'
import { BrowserRouter, Redirect, Route, useLocation } from "react-router-dom";
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
    return <DetailsPage challengeId={challenge} />
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
    <BrowserRouter>
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
