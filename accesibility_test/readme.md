Axe test is a tool that helps to test the accessibility of the app. It is a JavaScript library that uses the axe-core library to test the accessibility of the app and uses puppeteer to run the test.

#Using Node

1. Run the following command to run the server that puppeteer will use to test the accessibility of the app:

mix phx.server

2. Run the following command to test the accessibility of the app in browser:

node axe_test.js super_admin_active or node axe_test.js solver_active

#Using Elixir

1. To run Phoenix test execute the following command:

mix test test/accesibility/accesibility_test.exs --only super_admin_active or mix test test/accesibility/accesibility_test.exs --only solver_active