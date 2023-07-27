<a name="1.7.3"></a>
## [1.7.3] - 2023-07-27

### Feat
- disable stopping live when pendint
- update step_flow version
- duplicate workflows by sending event
- new password component
- improve add user form error handling

### Fix
- inet protocol config with env var
- Webpack stops watching when the backend stops
- add password-validator in package dependancies

<a name="1.7.2"></a>
## [1.7.2] - 2023-06-08

### Feat
- add password change in user administration
- add password change route to api
- add configuration fields for AMQP message persistence in queues
- Improve CSS on user page
- open a dialog box when adding a user
- Display confirmation dialog when deleting a user
- add user search bar in ui

### Fix
- correct the css style of roles tab
- root account creation and password reset

### Perf
- trigger user search on enter key only

### Refactor
- harmonize title of dialog box
- change search bar display in user page

<a name="1.7.1"></a>
## [1.7.1] - 2023-03-08
### Feat
- add password change in user administration
- add password change route to api

### Fix
- root account creation and password reset

### Tests
- add test for root creation and root reset

<a name="1.7.0"></a>
## [1.7.0] - 2023-02-13

### Feat
- display headers as checkbox
- Display header as chips and update view
- Added Headers informations in workflow page
- Added Headers in Filter parameters
- Added headers param
- add nested workflow support in ui
- Timerange on today considers full day
- check whitespaces only and more explicit var naming
- Notification Endpoint disable when edit
- deleting and adding behaviour on edit
- disable on event selected
- edit button and controller
- colorful and meaningful status chips
- refactor workflow action buttons
- update to angular 12 and webpack 5.75.0
- Refresh only necessary information in workflow view
- add error handling snackbars duplicate button and navigate to duplicated workflows
- add duplicate button workflow
- Add searchbar on order page
- allow editing rights and saving changes in roles
- Close right menu when clicking

### Fix
- load new object after save from edit to avoid editing saved object
- load new object after insert to avoid editing saved object
- add mising jsoneditor in assets package
- unable selection of no header
- properly get controls on checkbox formgroup
- Proper display on JSON editor
- Searchbar form throwing errors
- change response for save_workflow_filters
- operation for swagger
- date display in secrets
- style issues
- remove unused registry and player components/modules
- correct compile issues listed by webpack5
- revert start workflow to form before facto
- simplify navigate url change duplicate button
- start workflow with identifier as reference if necessary
- notification endpoint credentials typo

### Ci
- remove travis leftovers
- check for openapi doc
- change git diff to prettier --check for format
- apply lint on project
- add .git-blame-ignore-revs
- angular format
- add eslint and prettier config and npm scripts

### Docs
- fix openapi description and version fetch

<a name="1.6.1"></a>
## [1.6.1] - 2022-11-04
### Ci
- generate documentation in image building
- build swagger doc in docker image

### Docs
- document all api endpoints
- add open api schemas
- use open api spex instead of phoenix swagger
- document backend for swagger doc

### Feat
- add reset password ui
- add swagger ui in documentation page
- add ui notification endpoints
- add a more actions button to regroup actions on workflow
- add workflow delete button in wrkf details

### Fix
- avoid breaking credentials api
- app name as env var
- url for swagger
- format and no doc in module stepflow swagger
- add email in auth structure
- fix confirmation mail user

### Ux
- improvement to navigation bar
- clean views and enhance color palette
- enhance navigation bars
- improve search bar style and experience


<a name="1.6.0"></a>
## [1.6.0] - 2022-09-13
### Authentication
- check authorization request header if no cookie is present

### CI
- Add dependencies security audit

### Clean
- removing unused components

### Deps
- update bamboo for hut to use rebar3

### Feat
- bump to 1.6.0
- add arobase for username in user page and username hovering
- add view to edit user first and last name
- add first and last name to user
- print username in workflows
- add new user with name and email
- add name to user
- show email instead of uuid in detailed workflow view
- show email instead of uuid in ui
- hooks views
- colors
- backend update for notification hooks
- get the validate account link

### Fix
- get roles by names for rights checking
- allow root to modify its name in ui
- changed has right method calling
- bring modification to administrator name
- fix form values references
- correct views containing user with username
- fix the identifier, version and date filters for the workflows duration statistics table
- remove lines related to deleted workflows treatment in assets
- color on statuses

### Mix
- add dependencies audit step in checks alias
- add the checks alias to run multiple code analyzis

### README
- describe security audit command line

### Style
- reduce complexity of structure

### Test
- reflect first and last names in tests
- repercuting modification to dev seed
- add usernames in test


<a name="1.5.0"></a>
## [1.5.0] - 2022-05-11
### Feat
- bump to 1.5.0
- add changelog

### Fix
- elixir templating bug


<a name="1.4.0"></a>
## [1.4.0] - 2022-01-25
### Feat
- bump to stepflow 1.4.0
- bump to 1.4.0-rc3
- bump to 1.4.0-rc2
- bump to 1.4.0-rc3
- bump stepflow version to 1.4.0-rc2

### Fix
- fetch all role for user not only current page
- rights check in ui

### Style
- format


<a name="1.3.1"></a>
## [1.3.1] - 2021-12-16
### Fix
- hotfix stepflow to 1.3.1


<a name="1.3.0"></a>
## [1.3.0] - 2021-10-25
### Feat
- bump step flow and overall to 1.3.0-rc
- add access key in the ui
- add credentials session authentication
- add generate credentials endpoints and views
- add uuid in workflow view
- modify rendering to include uuid and credentials
- add endpoint to generate credentials for given user
- add uuid and credential to user

### Fix
- fix user uuid generation
- split alter in uuid migration
- add rights in condition check

### Style
- styling accounts files

### Test
- add uuid format test
- add alphanumeric test for access key
- update test files with uuid
- add tests for credential generation endpoint
- add uuid and credentials user tests


<a name="1.2.0"></a>
## [1.2.0] - 2021-08-27
### Feat
- bump stepflow and bump version
- add notification on job error and support teams
- add ctrl click and cmd click to workflow detail button
- add timezone configuration and local timezone formatting of date

### Fix
- fix hour format to 24h for detailed job


<a name="1.1.0"></a>
## [1.1.0] - 2021-07-22
### Fix
- slow queue pooling and remove direct messaging queues
- user pagination had an unjustified increment


<a name="1.0.0"></a>
## [1.0.0] - 2021-06-29
### Feat
- transport workflow infos
- add stop button
- display latest version of workflow in orders
- switch to chartjs
- search bar module
- worflow_control component to query dashboard
- add mix version
- add integrated ci
- transport workflow infos
- add stop button
- get definitions rights are defined by workflow
- retry button on progress bar use workflow right
- let workflow rights manage authorization on job and event
- use workflow rights to display jobs action
- replace technician right by workflow rights
- right retry button on progress view
- right retry button on details workflow view
- right retry button on jobs view
- upgrade step_flow to 0.2.5
- display abort and delete button if user has the right on worflow view
- check user has right to abort or delete a workflow
- create right model
- check user has any specified rights

### Fix
- fix broken start param from file upload
- fix research bar for live
- replace deprecated mat file input by official angular mat file input
- correct selection of all workflows
- bump to stable angular 9
- progress bar for live
- bump to stable angular 9
- angular version bump to 10.1.3
- progress bar for live

### Refactor
- reduce complexity

### Style
- credo suggestions

### UI
- fix worker status objects definition


<a name="0.1.18"></a>
## [0.1.18] - 2021-04-15
### Feat
- display latest version of workflow in orders
- switch to chartjs
- search bar module
- worflow_control component to query dashboard


<a name="0.1.17"></a>
## [0.1.17] - 2021-03-24
### Fix
- plug to check enabled metrics


<a name="0.1.16"></a>
## [0.1.16] - 2021-01-21

<a name="0.1.15"></a>
## [0.1.15] - 2021-01-19
### Feat
- get definitions rights are defined by workflow
- retry button on progress bar use workflow right
- let workflow rights manage authorization on job and event
- use workflow rights to display jobs action
- replace technician right by workflow rights
- right retry button on progress view
- right retry button on details workflow view
- right retry button on jobs view
- upgrade step_flow to 0.2.5
- display abort and delete button if user has the right on worflow view
- check user has right to abort or delete a workflow
- create right model
- check user has any specified rights
- suscribe get jobs requires technician rights
- backend  orders and workflows menu only requires to log in
- backend orders and workflows routes only requires to log in
- stepflow workflows route only requires to log in


<a name="0.1.14"></a>
## [0.1.14] - 2020-12-17

<a name="0.1.13"></a>
## [0.1.13] - 2020-11-26

<a name="0.1.12"></a>
## [0.1.12] - 2020-11-18

<a name="0.1.10"></a>
## [0.1.10] - 2020-11-04

<a name="0.1.9"></a>
## [0.1.9] - 2020-11-04

<a name="0.1.8"></a>
## [0.1.8] - 2020-10-27

<a name="0.1.7"></a>
## [0.1.7] - 2020-10-22
### Travis
- exclude OTP 23 for elixir < 1.10.3


<a name="0.1.11"></a>
## [0.1.11] - 2020-10-02

<a name="0.1.6"></a>
## [0.1.6] - 2020-09-16
### Travis
- exclude OTP 23 for elixir < 1.10.3


<a name="0.1.5"></a>
## [0.1.5] - 2020-07-10

<a name="0.1.4"></a>
## [0.1.4] - 2020-07-10

<a name="0.1.3"></a>
## [0.1.3] - 2020-07-07

<a name="0.1.2"></a>
## [0.1.2] - 2020-05-28

<a name="0.1.1"></a>
## [0.1.1] - 2020-04-22

<a name="0.1.0"></a>
## [0.1.0] - 2020-04-08

<a name="0.0.13"></a>
## [0.0.13] - 2020-03-27

<a name="0.0.12"></a>
## [0.0.12] - 2020-03-26

<a name="0.0.11"></a>
## [0.0.11] - 2020-03-23

<a name="0.0.10"></a>
## [0.0.10] - 2020-03-19

<a name="0.0.9"></a>
## [0.0.9] - 2020-03-16

<a name="0.0.8"></a>
## [0.0.8] - 2020-03-13

<a name="0.0.7"></a>
## [0.0.7] - 2020-03-12

<a name="0.0.6"></a>
## [0.0.6] - 2020-03-09
### Order
- fix html material binding
- display "FranceTélévisions Audio" workflows download button
- add first version of FTV dialog enhancement workflow
- display process status on start
- handle number type parameters


<a name="0.0.5"></a>
## [0.0.5] - 2019-12-12

<a name="0.0.4"></a>
## [0.0.4] - 2019-12-12
### Docker
- fix Dockerfile and add .dockerignore file

### Dockerfile
- Add huge timemout on yarn install

### QueuesComponent
- unsubscribe queues updater


<a name="0.0.3"></a>
## [0.0.3] - 2018-08-07

<a name="0.0.2"></a>
## [0.0.2] - 2018-07-20

<a name="0.0.1"></a>
## 0.0.1 - 2018-07-09
### Fix
- generate only one time the datetime of uploaded content

[1.7.3]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.7.2...1.7.3
[1.7.2]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.7.1...1.7.2
[1.7.1]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.7.0...1.7.1
[1.7.0]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.6.1...1.7.0
[1.6.1]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.6.0...1.6.1
[1.6.0]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.5.0...1.6.0
[1.5.0]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.4.0...1.5.0
[1.4.0]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.3.1...1.4.0
[1.3.1]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.3.0...1.3.1
[1.3.0]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.2.0...1.3.0
[1.2.0]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.1.0...1.2.0
[1.1.0]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/1.0.0...1.1.0
[1.0.0]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.18...1.0.0
[0.1.18]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.17...0.1.18
[0.1.17]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.16...0.1.17
[0.1.16]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.15...0.1.16
[0.1.15]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.14...0.1.15
[0.1.14]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.13...0.1.14
[0.1.13]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.12...0.1.13
[0.1.12]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.10...0.1.12
[0.1.10]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.9...0.1.10
[0.1.9]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.8...0.1.9
[0.1.8]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.7...0.1.8
[0.1.7]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.11...0.1.7
[0.1.11]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.6...0.1.11
[0.1.6]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.5...0.1.6
[0.1.5]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.4...0.1.5
[0.1.4]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.3...0.1.4
[0.1.3]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.2...0.1.3
[0.1.2]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.1...0.1.2
[0.1.1]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.1.0...0.1.1
[0.1.0]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.13...0.1.0
[0.0.13]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.12...0.0.13
[0.0.12]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.11...0.0.12
[0.0.11]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.10...0.0.11
[0.0.10]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.9...0.0.10
[0.0.9]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.8...0.0.9
[0.0.8]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.7...0.0.8
[0.0.7]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.6...0.0.7
[0.0.6]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.5...0.0.6
[0.0.5]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.4...0.0.5
[0.0.4]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.3...0.0.4
[0.0.3]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.2...0.0.3
[0.0.2]: https://gitlab.com/media-cloud-ai/backend/ex_backend/compare/0.0.1...0.0.2
