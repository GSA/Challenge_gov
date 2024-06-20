---
name: Restage application
about: 
title: Restage Application on Cloud.gov
labels: ''
assignees: ''
---
## User Story

As a Challenge.gov engineer, in order to take advantage of the recent Cloud.gov buildpack updates and security fixes, I need to restage or redeploy challenge.gov application.

## Process

1. Login to cloud.gov 
2. Restage Staging or Dev environment before restaging Production 
3. After the test on the other environments, proceed to restage Production
4. Check that the application is up and running


## QA Checklist:

Check that the application is fully functional and online, using the below checklist for reference:
- [ ] Within Cloud.gov navigate to the application dashboard -> View that the instance is in the running state
- [ ] Log in as a Login.gov user with access to the system -> View the welcome dashboard for the user role
- [ ] Navigate to challenge.gov -> View an accurate listing of open challenges
- [ ] Create a draft challenge with logo -> Challenge is able to be saved as a draft and display the logo when the details are viewed
- [ ] Verify that you can see the active challenges -> View a list of tails with the active challenges on the front page of challenge.gov 

## Reference Information:

https://cloud.gov/docs/deployment/app-maintenance/#restaging-your-app

