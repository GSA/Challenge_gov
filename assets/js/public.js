// USWDS Import
import "uswds/dist/css/uswds.css";
import "uswds/dist/js/uswds.js";

// Bootstrap Import
import "bootstrap/dist/css/bootstrap.css";
import "bootstrap/dist/js/bootstrap.js";

// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import jquery from  "jquery";
import "popper.js";
import "@fortawesome/fontawesome-free/css/all.css";

require("../css/public.scss");

// TODO: Add this back after font size fixes
// import "uswds/dist/css/uswds.css";
// import "uswds/dist/js/uswds.js";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import "./custom.js";
import "./scroll_to_anchor.js";

window.$ = jquery;
