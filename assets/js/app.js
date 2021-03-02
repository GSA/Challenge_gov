// USWDS
import "uswds/dist/scss/uswds.scss";
import "uswds/dist/js/uswds.js";

// Bootstrap
import "bootstrap/dist/css/bootstrap.css";
import "bootstrap/dist/js/bootstrap.js";

// Admin LTE
import "admin-lte/dist/css/adminlte.css";
import "admin-lte/dist/js/adminlte.js";

// Rich Text Editor
import "quill/dist/quill.core.css";
import "quill/dist/quill.snow.css";

// Import dependencies
import "@fortawesome/fontawesome-free/css/all.css";

import jquery from  "jquery";
import "popper.js";
import "select2";
import "phoenix_html";

// Import CSS
require("../css/app/index.scss");

// Import JS
import "./app/index.js";
import "./shared/index.js";

import {Socket} from "phoenix";
import LiveSocket from "phoenix_live_view";

let Hooks = {};
Hooks.WYSIWYG = {
    mounted() {
        location.reload();
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {params: { _csrf_token: csrfToken}, hooks: Hooks});
liveSocket.connect();
window.liveSocket = liveSocket;
