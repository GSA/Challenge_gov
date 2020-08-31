import React from 'react';
import ReactDOM from 'react-dom';
import { HashRouter, Redirect, Switch, Route } from "react-router-dom";
import { IndexRoutes } from "./routes/index";
import * as serviceWorker from './serviceWorker';
import { useTracking } from './useTracking'
import { ApiUrlContext } from "./ApiUrlContext"

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

  return (
    <Switch>{getRoutes()}</Switch>
  )
}

const renderRouter = (apiUrl) => (
  <ApiUrlContext.Provider value={apiUrl}>
    <HashRouter>
      <Application />
    </HashRouter>
  </ApiUrlContext.Provider>
)

const rootElement = document.getElementById('challenge-gov-react-app')
const apiUrl = rootElement.getAttribute('data-api-url')

ReactDOM.render(renderRouter(apiUrl), rootElement);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
