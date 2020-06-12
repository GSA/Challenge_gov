import React from 'react';
import ReactDOM from 'react-dom';
import '../../css/sass/main.scss'
import { BrowserRouter, Redirect, Switch, Route } from "react-router-dom";
import { IndexRoutes } from "./routes/index";
import * as serviceWorker from './serviceWorker';
import { useTracking } from './useTracking'
import { DetailsPage } from "./pages/DetailsPage"

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

const renderPreview = () => (
  <BrowserRouter>
    <Route
      path={"/public/previews/challenges/:challengeId"}
      render={(props) => <DetailsPage {...props} preview={true} /> }
      exact={true}
    />
  </BrowserRouter>
)

ReactDOM.render(renderPreview(), document.getElementById('preview'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
