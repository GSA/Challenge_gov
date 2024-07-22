---
name: Definition of Done
about: Definition of Done
title: ''
labels: ''
assignees: ''
---
## Definition of Done Checklist

## Doing (dev team)
- [ ] Code complete 
- [ ] Code is organized appropriately
- [ ] Any known trade offs are documented in the associated GH issue
- [ ] Code is documented, modules, shared functions, etc.
- [ ] Automated testing has been added or updated in response to changes in this PR
- [ ] The feature is smoke tested to confirm it meets requirements
- [ ] Database changes have been peer reviewed for index changes and performance bottlenecks
- [ ] PR that changes or adds UI
    - [ ] Include a screenshot of the WAVE report for the altered pages
    - [ ] Confirm changes were validated for mobile responsiveness
- [ ] PR approved / Peer reviewed 
- [ ] Card moved to testing column in the board

## Testing (dev team)
- [ ] Security scans passed
- [ ] Automate accessibility tests passed
- [ ] Build process and deployment is automated and repeatable
- [ ] Feature toggles if appropriate
- [ ] Deploy to staging


## Staging (Tracy / Marni / Renata)
- [ ] Accessibility tested (Marni)
    - [ ] Keyboard navigation
    - [ ] Focus confirmed
    - [ ] Color contrast compliance
    - [ ] Screen reader testing 
- [ ] Usability testing: mobile and desktop (Tracy or Marni)
- [ ] Cross browser testing (tool to be determined) (Tracy or Marni)
    - [ ] UI rendering is performant
- [ ] AC review (Renata)
- [ ] Deploy to production (production-like environment for eval capability)
- [ ] Move to production column in the board

## Production (Jarah / Renata)
- [ ] User and security documentation has been reviewed for necessary updates (Renata and Michelle) 
- [ ] PO / PM approved (Jarah or Renata)
- [ ] AC is met and it works as expected (Jarah or Renata)
- [ ] Move to done column in the board