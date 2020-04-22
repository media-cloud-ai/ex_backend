<a name="unreleased"></a>
## [Unreleased]

### Add
- Add endpoint launch_workflow in config.exs

### Add
- add json loader to config

### Modified
- Modified createWorkflows to use the correct stepFlow API endpoint

### Update
- Update the launching of workflows from the UI to match the new StepFlow version 0.1.3. Deprecated unused workflows

### Update
- update step_flow to 0.1.3


<a name="0.1.0"></a>
## [0.1.0] - 2020-04-08
### Update
- update workflows definitions to match to the new version
- update mix.lock
- update step_flow to 0.1.2
- update elixir dependencies


<a name="0.0.13"></a>
## [0.0.13] - 2020-03-27
### Fix
- fix production configuration for Workflow dorectory


<a name="0.0.12"></a>
## [0.0.12] - 2020-03-26
### Add
- Add job_transfer_option in add of job_transfer.

### Export
- export DATABASE_PORT

### Format
- format code

### Hardcode
- hardcode pool size for prod

### Hide
- Hide source & synchronised links because they don't works anymore.

### Remove
- Remove commented line.

### Update
- update configiration for workers work directory
- update test configuration
- update step flow
- update configuration for DATABASE_POOL_SIZE
- update production configuration
- update configuration


<a name="0.0.11"></a>
## [0.0.11] - 2020-03-23
### Update
- update step flow


<a name="0.0.10"></a>
## [0.0.10] - 2020-03-19
### Fix
- fix elixir syntax
- fix email link
- fix unit tests
- fix update word entities

### Format
- format code

### Merge
- Merge remote-tracking branch 'origin/master' into feature/Update_NLP_front
- Merge branch 'master' into feature/Update_NLP_front

### Remove
- remove empty ngOnInt & Constructor

### Update
- Update entity.component.less
- Update nlp_entity.ts

### Update
- update topics/categories


<a name="0.0.9"></a>
## [0.0.9] - 2020-03-16
### Update
- update step_flow


<a name="0.0.8"></a>
## [0.0.8] - 2020-03-13
### Format
- format code

### List
- list 200 jobs, temporary fix

### Update
- update rosetta workflow and fix notification


<a name="0.0.7"></a>
## [0.0.7] - 2020-03-12
### Add
- add parameters for the API too

### Fix
- fix unit tests

### Prevent
- prevent errors if the query is not an UUID

### Remove
- remove deprecated httpotion, use httpoison

### Return
- return message on 404

### Udpate
- udpate dependencies

### Update
- update rosetta workflow with notification test and unit tests


<a name="0.0.6"></a>
## [0.0.6] - 2020-03-09
### Add
- add progression bar when job status is processing
- add new line
- add newline
- add subclass in css
- add visualisation of named entity
- add region in parameters to sign for evaporate
- add a download button for transcript text
- add provider parameter required by speech to text worker

### Add
- Add visualisation page for NER
- Add play buttons for Dialog Enhancement workflows
- Add audio conversion and extraction steps to FTV Audio workflow

### Allow
- allow to upload MP4 to be process by STT workflow

### Allowed
- Allowed use of Magneto for ACS/ASP/ACS+ASP and improved getDestinationFilename algo

### Bump
- Bump ecto from 3.3.2 to 3.3.4
- Bump [@types](https://github.com/types)/jasmine from 3.5.2 to 3.5.7 in /assets
- Bump ex_aws from 2.1.1 to 2.1.2
- Bump phoenix from 1.4.13 to 1.4.14
- Bump cors_plug from 2.0.1 to 2.0.2
- Bump webpack from 4.41.5 to 4.41.6 in /assets
- Bump standard from 12.0.1 to 14.3.1 in /assets
- Bump plug from 1.8.3 to 1.9.0
- Bump tesla from 1.3.1 to 1.3.2
- Bump amqp from 1.2.0 to 1.3.2
- Bump phoenix from 1.4.12 to 1.4.13
- Bump [@types](https://github.com/types)/node from 13.7.0 to 13.7.1 in /assets
- Bump less from 3.10.3 to 3.11.1 in /assets
- Bump lodash from 4.17.11 to 4.17.15 in /assets
- Bump to-string-loader from 1.1.5 to 1.1.6 in /assets
- Bump [@types](https://github.com/types)/node from 12.0.2 to 13.7.0 in /assets
- Bump credo from 1.2.1 to 1.2.2
- Bump phoenix_html from 2.13.3 to 2.14.0
- Bump ecto_sql from 3.3.2 to 3.3.3
- Bump ecto from 3.3.1 to 3.3.2
- Bump plug_cowboy from 2.1.1 to 2.1.2
- Bump [@types](https://github.com/types)/jasmine from 3.3.12 to 3.5.2 in /assets
- Bump credo from 1.2.0 to 1.2.1
- Bump cors_plug from 2.0.0 to 2.0.1
- Bump credo from 1.1.5 to 1.2.0
- Bump bamboo from 1.3.0 to 1.4.0
- Bump phoenix from 1.4.11 to 1.4.12
- Bump phauxth from 2.3.0 to 2.3.1
- Bump bcrypt_elixir from 2.0.3 to 2.1.0
- Bump comeonin from 5.1.3 to 5.2.0
- Bump gettext from 0.17.1 to 0.17.4
- Bump css-loader from 2.1.1 to 3.4.2 in /assets
- Bump tesla from 1.3.0 to 1.3.1
- Bump rxjs from 6.5.2 to 6.5.4 in /assets
- Bump ecto from 3.3.0 to 3.3.1
- Bump ecto_sql from 3.3.0 to 3.3.2
- Bump ts-loader from 6.0.1 to 6.2.1 in /assets
- Bump sass-loader from 7.1.0 to 7.3.1 in /assets
- Bump zone.js from 0.9.1 to 0.10.2 in /assets
- Bump lodash from 4.17.11 to 4.17.15 in /assets

### Change
- change to S3 prefix (instead of AWS) and manage errors on presign call

### Clean
- clean nlp viewer

### Clean
- Clean nlp_viewer front

### Code
- code review m-a

### Complete
- Complete FTV dialog enhancement worflow

### Delete
- delete space

### Disable
- disable ACS as it's not tested right now

### Display
- display workflow parameters on detailed view

### Do
- do not encode video, simply copy it

### Fix
- fix configuration getter
- fix nlp orders
- fix typescript error
- fix format - trailing coma
- fix step_flow version

### Fix
- Fix issue when retrieving audio & video files into ffmpeg job.
- Fix orders views when there is no workflow
- Fix code format
- Fix login UI error message before logo loading

### Format
- format code

### Format
- Format code.

### Merge
- Merge remote-tracking branch 'origin' into feature/add_progression_job
- Merge branch 'master' into dependabot/npm_and_yarn/assets/lodash-4.17.15
- Merge branch 'dependabot/npm_and_yarn/assets/lodash-4.17.15' of github.com:media-cloud-ai/ex_backend into dependabot/npm_and_yarn/assets/lodash-4.17.15
- Merge branch 'master' into dependabot/npm_and_yarn/assets/types/jasmine-3.5.2
- Merge branch 'feature/Add_NLP_front' of https://github.com/media-cloud-ai/ex_backend into feature/Add_NLP_front

### Minor
- Minor order GUI refactoring

### Modified
- Modified the command GUI to show ACS/ASP/ACS+ASP commands, their results and also beautify the GUI

### Remove
- remove unused lines of code

### Rename
- rename add france TV DaIA

### Specify
- specify version

### Switch
- switch to FTP_ROSETTA_* credentials
- switch spinner to green colors

### Udate
- udate & add feature timecode mouse over

### Update
- Update ex_step_flow dependency version
- Update orders.component.html
- Update orders.component.ts

### Update
- update dependencies
- update dependencies
- update step flow
- update order to use static definition of workflows
- update step flow configutation
- update step flow
- update loading view with new color

### Use
- use every time a string as start parameter
- use newest version of step flow

### Workflows
- Workflows and jobs views subscribe to "retry_job" notifications


<a name="0.0.5"></a>
## [0.0.5] - 2019-12-12
### Add
- add view to display transcript

### Be
- be able to start Speech to Text Workflow via the API

### Format
- format code

### Update
- update Command user interface (rename from Orders)


<a name="0.0.4"></a>
## [0.0.4] - 2019-12-12
### Ad
- ad method to get credential

### Add
- add cors and update S3 endpoint
- add view of declared workers
- add wildcard domain name checker
- add valid domain names for websocket
- add DB configuration for StepFlow
- add ex_aws dependencies to generate presigned url
- add route to generate presigned_url
- add documentation to start a generic workflow
- add order and start workflow at the end of the upload
- add first upload with evaporate
- add id field in notification
- add TLS parameter to enable AMQP TLS connection
- add first version of script to reprocess workflow notification per day
- add migration to store long value in credential (required to store tokens)
- add notification for FranceTV studio Rosetta project
- add missing parameter to push to PM
- add ability to retry job from workflows view
- add spinner on dashboard
- add Media-IO spinners
- add filtering per workflow ids issue [#2](https://github.com/media-cloud-ai/ex_backend/issues/2)
- add curve per workflow identifier
- add sort order filter
- add all france télévisions channels
- add scale on workflow history
- add FTV Studio right and workflow count history on dashboard
- add Perfect Memory event name
- add example to start RDF workflow
- add loading spinner based on Media-IO logo
- add DASH ingest workflow to be able to start via API
- add script examples to start workflows
- add prefix path for ftp tasks
- add missing queue declaration
- add notifications
- add blue bird dependency to generate documentation
- add list of endpoints
- add rdf worker as a docker image
- add credential module & view
- add Logger module
- add some debug informations
- add headers for HEAD query to test playout with FranceTV player Magneto
- add link to perfect memory
- add step_id on ACS steps
- add Speech to text queue name
- add play cue button
- add feature to save the new version of the subtitle
- add feature to delete a subtitle
- add registery interface and link with the player
- add register assets step
- add video encoding for DASH in EBU ingest workflow
- add speech to text step
- add VERSION file to build on travis
- add more elixir versions
- add unit test for FranceTV Workflow and fix some related bugs
- add copy, start to implement and test EBU workflow
- add name to identify containers
- add step to upload file via triggerred event
- add logs if test is in error
- add cue feature
- add split cue feature
- add yarn check and build with travis
- add first player version with DASH.js

### Add
- Add new line at the end of gitlab pipeline file and dist env file.
- Add example .env.dist file + add .env to git ignore file.
- Add Makefile.
- Add push to registry using commit_sha.
- Add new blank line at the end of README.md.
- Add example .env.dist file + add .env to git ignore file.
- Add target in Makefile to run locally the server.
- Add Makefile.
- Add gitlab pipeline file.
- Add missing function for ASP retry event
- Add a few unit tests for ASP process step
- Add ASP process workflow step definition
- Add HEALTHCHECK command to test if the container is ready or not. This needs to add curl.
- Add new get_step_requirements() function to Requirements
- Add ACS standalone workflow
- Add ISM support into workflows

### Allow
- allow failure for credo

### Allows
- Allows to pass a custom port for healthcheck when building docker image.

### Be
- be able to query workflows by IDs
- be able to create specific workflow for ACS standalone
- be able to retart clean_workspace task
- be able to delete a workflow:
- be able to process same task for different steps

### Bump
- Bump postgrex from 0.15.2 to 0.15.3
- Bump ecto_sql from 3.2.2 to 3.3.0
- Bump postgrex from 0.15.1 to 0.15.2
- Bump imsc from 1.0.2 to 1.1.1 in /assets
- Bump blue_bird from 0.4.1 to 0.4.2
- Bump ecto_sql from 3.2.0 to 3.2.2
- Bump phoenix from 1.4.10 to 1.4.11
- Bump typescript from 3.4.5 to 3.7.2 in /assets
- Bump ecto from 3.2.3 to 3.2.5
- Bump phoenix_ecto from 4.0.0 to 4.1.0
- Bump comeonin from 5.1.2 to 5.1.3
- Bump bamboo from 1.2.0 to 1.3.0
- Bump mixin-deep from 1.3.1 to 1.3.2 in /assets

### Bump
- bump ex_video_factory to 0.3.13
- bump elixir version to 1.8.1

### Catch
- catch error and update transfer job

### Center
- center player editor

### Change
- change number of maximum items to retrieve
- change all paths to array_of_strings
- change destination directory
- change channel filter
- change default rabbitmq configuration
- change rights for vidtext platform

### Change
- Change configuration to not check origin.

### Changes
- changes from valentin feedbacks

### Check
- check right to create a workflow
- check all queues and final messages
- check error message
- check generated path for EBU workflow
- check lint during docker build

### Comment
- comment future usage of Vault

### Configure
- configure graph scale to hour

### Continue
- continue on unit test for FranceTV

### Create
- create empty dev configuration file

### Debug
- Debug pipeline to generate good version in semver format.
- Debug build raising an error about semver: ** (Mix) Expected :version to be a SemVer version, got: '085c55d'

### Define
- define VIDEO_FACTORY_ENDPOINT as parameter
- define OPTIONS route for dash player
- define spacebar as play/pause if not editing mode
- define workflow in the backend

### Describe
- describe parameters on workers

### Disable
- disable check origin in production as it's done by nginx

### Disable
- Disable build job fully to test deployement.
- Disable build only on master for dev.

### Display
- display containers per selected node

### Display
- Display job errors instead of failed workflows in charts

### Enable
- enable search workflow by date range
- enable multi-agent watchers

### Filter
- filter on wav not mp4

### Finish
- finish credentials view

### Fix
- fix syntax
- fix de.secret.exs creation
- fix unit steps using StepFlow instead of ExBackend.Workflow
- fix workflow rendering if parent_ids is undefined
- fix link generator: filter on S3 upload only
- fix S3 Signer
- fix links to magneto and to download TTML
- fix unit tests for path requirements
- fix pattern matching on FTP error message
- fix updates based on unit tests
- fix rdf worker parameters
- fix parameters for ACS and DASH Workflows
- fix deprecated seconds
- fix syntax
- fix link to catalog
- fix typescript typing
- fix workflow parameters
- fix typescript syntax
- fix unit test
- fix unit tests
- fix build
- fix error for Perfect Memory configuration
- fix manifest reference: get also from uploaded job
- fix compatibility with ffmpeg worker
- fix clean workspace step with generic getter
- fix start FranceTV workflows
- fix unit tests
- fix reference table name
- fix redirect URLs for catalog browsing
- fix overlap button with timecode
- fix prev next cue displayed
- fix initial status of subtitle
- fix unit tests
- fix get agent on upload file step
- fix watcher creation to get info on it after
- fix endpoint app => /app
- fix syntax
- fix include order
- fix test config
- fix unit tests
- fix dashjs error in release

### Fix
- Fix AspProcess function name
- Fix FTV Subtil ACS workflow parameters
- Fix FTV Subtil ACS workflow parameters
- Fix ACS Standalone workflow definition
- Fix Requirements tests
- Fix ACS destination path parameter, for workflow sequence
- Fix FTP download requirements
- Fix job parameters view
- Fix audio extraction step, filtering "output_extension" parameter
- Fix notification test into FTV Studio Rosetta workflow

### Format
- format code
- format code
- format code
- format code
- format code
- format code

### Get
- get steps by atom or string
- get parameter including credential stored
- get atom or string parameter key
- get all files to generate dash
- get file system message if no file are mentionned

### Get
- Get failed workflows from history and display them in the dashboard charts

### Ident
- ident documentation and describe parameters to start a workflow

### Ignore
- ignore node dependencies to build docker image

### Improve
- improve code quality

### Insert
- insert content in dev secret configuration

### Let
- let workers to create queues

### List
- list 100 credentials by default

### Make
- Make ACS standalone workflow definition dynamic, using input and output URLs

### Manage
- manage return message
- manage subtitle versions

### Match
- match new error message for FTP error queue
- match to any upload error message

### Merge
- Merge remote-tracking branch 'origin/master' into setup_demo_acs
- Merge remote-tracking branch 'origin/master' into setup_demo_acs
- Merge branch 'master' into improve_startup
- Merge branch 'dev/order' into 'master'
- Merge branch 'master' of github.com:media-cloud-ai/ex_backend
- Merge branch 'fix/download_requirements' into 'master'
- Merge branch 'dev/add_acs_standalone_workflow' into 'master'
- Merge branch 'master_github'
- Merge branch 'fix_notification' into 'master'
- Merge branch 'fix/job_details_view' into 'master'
- Merge branch 'fix_notification' into 'master'
- Merge branch 'test_notification' into 'master'
- Merge branch 'dev/migrate_job_parameters' into 'master'
- Merge branch 'dev/add_ism_support_into_workflows' into 'master'
- Merge branch 'dev/sort_credentials' into 'master'
- Merge branch 'master' of github.com:FTV-Subtil/ex_subtil_backend
- Merge branch 'master' of gitlab.com:ftvsubtil/ex_subtil_backend
- Merge branch 'update-notification' into 'master'
- Merge branch 'fix_ftp_error' into 'master'
- Merge branch 'fix_ftp_error' into 'master'
- Merge branch 'switch_http_worker_to_tranfer_worker' into 'master'
- Merge branch 'fix/workflows_tests' into 'master'
- Merge branch 'add_sdk_scripts' into 'master'
- Merge branch 'dev_notification' into 'master'
- Merge branch 'dev/fix_workflows_error_filtering' into 'master'
- Merge branch 'dev/display_failed_workflows_in_dashboard_charts' into 'master'
- Merge branch 'fix/do_not_request_for_queues_outside_dashboard' into 'master'
- Merge branch 'master' of github.com:FTV-Subtil/ex_subtil_backend
- Merge remote-tracking branch 'github/master'
- Merge remote-tracking branch 'github/master'
- Merge remote-tracking branch 'github/master'
- Merge remote-tracking branch 'github/master'
- Merge branch 'master' of github.com:FTV-Subtil/ex_subtil_backend

### Migrate
- Migrate job parameters

### Minor
- minor fix
- minor update

### Move
- move ACS task outside of the folder

### New
- New commit to test deployement.

### Only
- only display persons for Subtil app

### Pass
- pass job instead of job_id to retry

### Reactivate
- Reactivate build in gitlab pipeline.

### Refactor
- refactor some code

### Release
- release documentation for deployment environment

### Remove
- remove unused files as StepFlow now manage workflow, AMQP, etc.
- remove unused variable
- remove specific configuration, use already defined check origin enpoints
- remove status link for old job
- remove massive ingest view
- remove migration which fails with new model
- remove specific emitters
- remove unused People
- remove warning for elixir compiler
- remove watchers for FranceTV
- remove not necessary check
- remove new line with echo
- remove bad } in log
- remove version file

### Remove
- Remove unwanted echo in gitlab pipeline.
- Remove limitation in gitlab pipeline to build only on master.
- Remove Elixir 1.6.0 Travis builds, and exclude Elixir 1.6.1 builds with OTP 21

### Rename
- Rename Requirements.add_required_paths/1 to Requirements.new_required_paths/1

### Rename
- rename mix task filename
- rename button label

### Reorder
- reorder ACS paths to provide wav first anytime

### Retrieve
- Retrieve workflows with error status from database, excluding completed workflows

### Return
- return an error
- return 422 on missing parameters
- return error on missing parameters for ingest-dash workflow
- return partial content with more headers

### Revert
- Revert Angular dependencies

### Revert
- revert virtual host for travis
- revert raw-loader to old version to fix templateUrl access, fix websocket authentication

### Select
- select workflows on dashboard

### Send
- send notification only if legacy_id exists (not if oscar_id exists)

### Set
- set configurable check origin domain name
- set virtual host to "" for test environment
- set step_id on audio process tasks
- set upload filename and manage end of upload
- set expired status if token is outdated
- set image tag with server

### Set
- Set a new gitlab pipeline example + restore initial pipeline.

### Some
- some fixes

### Sort
- Sort credentials

### Split
- split queued messages and processing messages
- split into image component
- split configuration for docker containers AMQP
- split player into a module
- split events to send right type

### Start
- start AMQP consumming via a supervisor, move migration in a function
- start workflow with S3 configuration
- start to add order view
- start to generate delivery filename
- start to define Rosetta delivery workflow
- start to add new FranceTV ACS workflow
- start to define massive ingest view
- start to edit timecode

### Store
- store versions of subtitles

### Support
- support new error message
- support notification on retry API
- support any message type to not crash channel
- support docker connection with Certificate Authority

### Swap
- swap buttons around timecode player

### Switch
- switch HTTP download with Tranfer worker
- switch steps to remove files asap

### Take
- Take comments into account.
- Take comments into account.

### Test
- Test notification

### Try
- Try Travis building with Elixir 1.6.1 for DynamicSupervisor.child_spec/1 implementation bug in 1.6.0

### Update
- update Rosetta Workflow
- update step flow dependencies
- update prod configuration
- update step flow
- update user interface to improve order view
- update ex_video_factory to 0.3.14
- update video_factory dependency
- update UI for order
- update workflows
- update angular dependencies
- update dependencies
- update login colors
- update script for rosetta notification
- update developement configuration and variables names
- update Rosetta workflow with notification step
- update status response on workflow creation
- update documentation generation
- update elixir dependencies and fix startup and build warnings
- update UI dependencies
- update queue model
- update AMQP component - auto-refresh
- update ACS workflow
- update login page with new animated Media-IO logo
- update start workfloow from the API
- update string name generation for Rosetta filename
- update query for error workflow
- update groupe registery
- update CI configuration
- update rosetta workflow and expose rdf ingest for massive ingest
- update backend with workflow identifiers and update RDF ingest workflow
- update uploading directory into Rosetta NAS
- update workflow to skip ttml if no subtitle file is present
- update worklow parameters
- update snackbar
- update user interface
- update production workflow
- update EBU workflow
- update Rosetta workflow
- update Rest API documentation
- update remote docker
- update Worker to be able to delete and update images
- update backend with FranceTV Workflows
- update workflow to process dash only
- update backend
- update interface
- update indentation
- update tests to match with the new workflow definition
- update documentation endpoint
- update documentaion - include cURL examples
- update prefix path for ACS workflow
- update backend to process ACS worklow
- update dependency
- update catalog default values
- update node dependencies
- update backend with new message model
- update ACS task and other tasks to support new message model
- update format messages
- update unit tests
- update remote docker library
- update remote docker and add DNS for Subtil
- update container configuration
- update Perfect Memory integration and creadentials
- update headers to send TTML files
- update response content
- update OPTIONS route for player
- update headers for player
- update rdf job
- update dependencies
- update dependencies
- update configuration
- update minor dependency
- update dependencies
- update workdir for production
- update video factory dependency
- update registery view
- update player with registery elements
- update test configuration
- update unit tests
- update model
- update ebu workflow and related unit tests
- update process path and fix speech to text step
- update webvtt output filename, checked with unit tests
- update unit test for speech to text step
- update EBU workflow
- update EBU ingest workflow test
- update columns on workers view
- update shortcuts
- update player editor
- update player to edit subtitles
- update node dependencies
- update minor versions
- update test configuration
- update dockerfile
- update application to display subtitles
- update user model
- update to trigger workflow from watcher
- update watchers, store last event datetime in database
- update ariane style
- update style for folder

### Update
- Update README.md for backend installation locally.
- Update README.md to list all environment variables which allows to customize application settings.
- Update Makefile to push image with short commit sha.
- Update ACS worker message consumers
- Update ACS job message
- Update mix release commands from Dockerfile
- Update strings array types into workflows tests

### Upgrade
- Upgrade Ecto version

### Use
- Use command template for program into ASP job parameters

### Use
- use StepFlow as dependency
- use right credentials to upload files to Akamai FTP
- use extra host to configure PM access
- use localhost as rabbitmq hostname
- use elixir 1.7 to check the code format
- use unique workflow definition


<a name="0.0.3"></a>
## [0.0.3] - 2018-08-07
### Add
- add optional output_extension for step model

### Change
- change default database name for production

### First
- first browsing version

### Fix
- fix warning messages
- fix port usage for emails

### Update
- update dependencies version
- update ingest view, and workflow related to EBU integration
- update ui dependencies
- update minor dependencies


<a name="0.0.2"></a>
## [0.0.2] - 2018-07-20
### Add
- add gitlab configuration
- add ingest page
- add watcher connection anddisplay them on dashboard

### Be
- be able to configure database via env vars

### Change
- change tag naming based on git describe

### Define
- define more docker containers

### Fix
- fix subcommand syntax
- fix gitlab CI tags
- fix some compile warnings
- fix endpoint renaming
- fix root account creation
- fix test due to authentication changes
- fix RDF view and push to PM actions

### Get
- get var from env vars first

### List
- list node on the top of workers

### Merge
- Merge branch 'master' of https://github.com/FTV-Subtil/ex_subtil_backend

### Optimize
- optimize web ui chunk size

### Print
- print docker image pushed

### Remove
- remove some logs
- remove language qad on synchronised content
- remove cookie usage to store search query

### Rename
- rename docker image
- rename videos as catalog

### Rollback
- rollback rabbitmq ip address for test

### Set
- set configurable docker nodes from UI
- set dynamic menu, based on application identification and user rights
- set minimal version of elixir to 1.6
- set configurable application (logo and text)

### Update
- update configuration to configure hostname with check_origin enabled
- update email lookup
- update unit test checks
- update dockerfile
- update docker configuration to support versions
- update invititation workflow

### Use
- use commit sha as container tag


<a name="0.0.1"></a>
## 0.0.1 - 2018-07-09
### ACS
- ACS steps refactoring

### Adapt
- adapt footer of page

### Add
- add lock file
- add missing imdb_sniffer dependency
- add favicon
- add logs
- add logs with PerfectMemory integration
- add workflow status filter
- add missing alias
- add method to send notification based on job id
- add declaration to the main app module
- add new dependencies for websocket and cookie
- add missing fields in Workflow model
- add returned models for a single resource
- add more information to convert into rdf
- add right on setup for authentication
- add migration to create person
- add user rights on model
- add g++ to build as bcrypt_elixir
- add message if no root user in created
- add authentication layer
- add travis and formatter description
- add description to Status view
- add description mapto status
- add ACS docker image definition
- add FFmpeg worker in Docker images
- add component to be able to hide/show parameters on steps
- add unit tests to generate DASH parameters
- add env var for Perfect Memory secret fields
- add routes to get and ingest RDF
- add buttons to display RDF and ingest it
- add workflow id in job view
- add file system image
- add search by video id
- add added and moved files during refactoring
- add seconds in output path
- add informations about text and audio tracks
- add some omments
- add secret section for dev environement
- add steps to process TTML source file
- add support of new steps in workflow
- add pipe for queue re-naming
- add missing ending line
- add dependencies
- add Amqp controller to list queues and connections
- add correct options for generation DASH with GPAC
- add root resource directory for prod environment
- add ftp download job managment
- add missing channel france-4

### Add
- Add "keep_original" parameter to acs_synchonization workflow step
- Add readlonly person view as a dialog
- Add link access button
- Add new PersonLinkImportComponent
- Add gender attribute to person model
- Add input-list-component title field
- Add an effective "abort" button to GUI workflow components
- Add controller to handle workflow events (abort and skip)
- Add first/last page buttons to workflows, users, and people pages
- Add first and last page button in the videos catalog page paginator
- Add newline at end of file
- Add the "params" attribute to the Job model
- Add a details dialog containing the jobs in/out paths
- Add details button in jobs component
- Add database migration for workflow steps
- Add administrator rights for root user
- Add simple worker errors handling to error queues consumers
- Add ACS synchronization threads number parameter in workflow
- Add hard coded ACS queue name
- Add get_jobs_destination_paths() to every workflow steps
- Add command_line queues emitters and consumers
- Add first version of ACS synchronization step into workflow
- Add audio encoding workflow step
- Add ACS audio preparation workflow step
- Add audio decoding workflow step
- Add audio extraction to workflow and adapt following steps
- Add audio extraction workflow step
- Add FFmpeg AMQP emitter and consumers
- Add ellipsis and disable word wrapping on overflow
- Add missing IsoDurationPipe import
- Add icons CSS class to fix video icons vertical alignment on Firefox
- Add a selection checkbox to each video
- Add link tooltips
- Add parent icon link
- Add videos column names
- Add selector to set videos page size
- Add CleanWorkspace module to trigger clean worker messages
- Add a button to hide/show the sidenav
- Add new Requirements module
- Add Language setting step to workflow for audio and subtitles
- Add a deletion button to each non-running containers
- Add controller to retrieve containers from remote docker hosts
- Add controller to return docker hosts from configuration
- Add a message if no search result was found
- Add a label search input to filter titles
- Add videos page size selection

### Adding
- adding new steps definitions

### Ading
- ading new emitter and consumers for HTTP jobs

### Allow
- Allow workflow steps and jobs to be skipped
- Allow user to start and stop containers

### Alphabetical
- alphabetical reoder

### Apply
- apply code formatter

### Audio
- Audio steps refactoring

### Be
- be able to update any users
- be able to update rights for user
- be able to manage users
- be able to expand job view
- be able to disable tasks from workflow
- be able to configure WORK_DIR on workers

### Bind
- Bind the paginator index to the component page attribute

### Build
- build interface before digest the application

### Bump
- bump to ACS 0.6

### Call
- Call ExVideoFactory to retrieve videos

### Cast
- cast description and store it

### Change
- Change default appdir

### Change
- change sender email: use no-reply
- change model, use node_config
- change host mount point
- change workdir to facilitate TTML integration
- change variables to get AKAMAI video FTP properties
- change few ergonomics things
- change application name

### Channel
- Channel filter: fix channel icons display into select options
- Channel Filter: get videos filtered by channel
- Channel filter: add channels select widget

### Check
- check user token on connection opening

### Clean
- Clean JS videos controller (AngularJS)

### Code
- code format changes

### Compute
- Compute step weight in graph lines

### Configure
- configure workdir for production env
- configure environment variables and volumes to start containers
- configure dependency remote_docker

### Containers
- Containers controller returns a list of every containers from every hosts

### Convert
- Convert first names to array

### Count
- count jobs in state to make progress bar

### Create
- Create graph from workflow steps
- Create track language parameters struct directly

### Create
- create user if not exists at the start of the application
- create default migrations dir

### Date
- Date filter: bind date filters values to query parameters
- Date filter: add "before" and "after" filters for video broadcasting date

### Debug
- debug socket connection

### Declare
- declare interceptor to check token timeout

### Decode
- Decode audio using FDK AAC

### Define
- define WorkflowRender class
- define step progress bar component
- define rights on controllers
- define right checker for controller
- define person on backend side (route, model and controller)
- define default user for dev environment
- define ffmpeg queues

### Defines
- defines host to validate check_origin for websocket connection
- defines socket models and module and service

### Disable
- disable ingest if content is not an integral

### Disable
- Disable video workflows button if none is found
- Disable Jarvis button if no manifest available

### Display
- Display disabled abort button in workflow details view
- Display workflow details into a specific page
- Display job time information in the details dialog
- Display job status in details dialog
- Display workflow step parameters value instead of default
- Display workflow duration (even without manifest upload)
- Display human readable workflow duration in tooltip
- Display workflow duration milliseconds (instead of frames)
- Display workflow duration as timecode
- Display videos duration as timecode
- Display track index into language step parameters
- Display containers as a formatted list instead of a table
- Display short IDs for containers
- Display every containers into a single list (with a new host column)
- Display running containers
- Display videos offset retrieved from connector response
- Display a few more info on videos

### Display
- display creation date
- display for processing job too
- display related menu to user rights
- display job status and description
- display processing duration (between start en artifact creation)
- display jobs for a workflow view
- display skipped jobs
- display broadcasted date, not creation date
- display number of workflow for a video and link to workflow view
- display step status on workflow view
- display AMQP monitoring

### Do
- do not commit secret file

### Enable
- Enable ACS workflow
- Enable workspace clean at the end of the ingest workflow
- Enable worker containers creation

### Enable
- enable dev environment for devevelopment
- enable clear date query

### Encode
- Encode audio to HE-AAC using FDK AAC

### Execute
- Execute ACS command instead of a simple copy

### Filter
- Filter videos by type and channels

### Filters
- Filters bar: improve style

### Fix
- fix syntax
- fix dependencies
- fix to ingest multiple content in one time
- fix environment
- fix variable name
- fix get workflow without status filter
- fix deps versions
- fix button style and icon style
- fix access to login if not logged in
- fix code formatting
- fix rights enabling
- fix syntax
- fix if not root user are configured
- fix test environment amqp hostname
- fix default parameter syntax
- fix dev configuration
- fix english naming
- fix worker creation based on image
- fix responsive layout
- fix [@nagular](https://github.com/nagular)/cdk version
- fix vhost worker parameter
- fix amqp hostname for production env
- fix link between views and remove icon for queued job
- fix queries with date and channels
- fix url query for only one channel
- fix yarn app name
- fix configuration file
- fix dependencies
- fix naming host -> node
- fix node naming
- fix yarn path
- fix rendering of a Container
- fix list workflow for all video
- fix dependency version
- fix clear selection of date
- fix syntax to build with Docker
- fix unit tests for job controller issue [#4](https://github.com/media-cloud-ai/ex_backend/issues/4)

### Fix
- Fix ACS worker queue
- Fix the way to retrieve the original ttml file
- Fix workflows details view
- Fix Person birth location fields
- Fix nationalities inputs list bug
- Fix abort button display
- Fix ACS job error consumer
- Fix jobs info alignment
- Fix step selection/unselection in videos workflow dialog
- Fix workflows unit tests
- Fix workflow steps width
- Fix processing and error jobs display
- Fix human style duration pipe
- Fix step line assignment
- Fix parameters binding
- Fix get_jobs_destination_paths() functions in workflow steps
- Fix default app_dir in ACS synchro workflow step
- Fix clean workspace workflow step
- Fix indentation
- Fix audio order in DASH generation
- Fix video catalog columns width
- Fix GenerateDash.build_step_parameters/2 returned value
- Fix select all button alignment
- Fix HTTP download path requirement
- Fix sidenav content padding
- Fix FTP and HTTP download file requirements
- Fix path requirements for DASH generation with the GPAC worker
- Fix no QAD case setting language
- Fix compilation warnings
- Fix workflow dialog
- Fix FTP upload workflow step
- Fix indentation
- Fix search & filter bar widgets responsiveness
- Fix webpack watch parameter
- Fix total number of video pages

### For
- for each video, search related workflows

### Force
- force resource as subtitle

### Get
- get UTC time instead of local time
- get files from FTP but also TTML to generate DASH content

### Get
- Get info from IMDb and prefill Person form
- Get workflow artifacts from database to display duration
- Get ACS app name from configuration variable
- Get first folder file path instead of filtering on quality suffix

### Handle
- Handle ACS worker error messages with no error code
- Handle broadcasted_live metadata, and display an icon if true

### Hide
- hide parameters on API
- hide menu by default on small screens
- hide videos during query

### Hide
- Hide video duration and date on overflow

### Ignore
- ignore log folder

### Improve
- Improve person birth date display in dialog
- Improve parameters display
- Improve workflow step parameters display
- Improve workflow step jobs display
- Improve workflow steps line display
- Improve Acs.PrepareAudio.is_subtitle_file_present?/1 function
- Improve containers creation response handling

### Improve
- improve user interface

### Initial
- Initial commit

### Initialize
- Initialize ACS workflow display

### Insert
- Insert InputListComponent into PersonFormComponent

### Keep
- Keep synchronized subtitles on DASH generation

### Launch
- Launch ingest for all selected videos

### Let
- let throw exceptions on render, and halt conn if error

### List
- list images from nodes

### List
- List all containers (running or not)

### Make
- Make checkbox labels clickable in workflow dialog
- Make quotes uniform into video-related .ts files

### Manage
- manage person on interface side
- manage workflow process with multi-jobs

### Manage
- Manage workflow steps requirements

### Merge
- Merge remote-tracking branch 'origin/master' into websocket
- Merge conflict in lib/ex_subtil_backend/amqp/job_acs_error_consumer.ex Merge conflict in lib/ex_subtil_backend/amqp/job_acs_error_consumer.ex
- Merge branch 'master' into dev/skip_and_abort_workflows
- Merge branch 'master' of github.com:FTV-Subtil/ex_subtil_backend
- Merge branch 'master' into dev/display_jobs_details
- Merge branch 'master' into dev/display_workflow_as_graph
- Merge branch 'master' into dev/display_workflow_as_graph
- Merge remote-tracking branch 'origin/master' into add_authentication
- Merge remote-tracking branch 'origin/master' into dev_improve_job_view
- Merge branch 'master' into dev/extract_audio
- Merge timecode with duration pipe
- Merge branch 'master' into dev/add_clean_worker
- Merge remote-tracking branch 'origin/master' into dev/create_start_stop_remove_containers
- Merge branch 'master' into workflow_for_videos
- Merge branch 'dev_ttml' of github.com:FTV-Subtil/ex_subtil_backend into dev_ttml
- Merge branch 'master' into dev_ttml
- Merge branch 'develop' into feature/videos_search
- Merge remote-tracking branch 'origin/develop' into angular5_with_typescriptwq
- Merge remote-tracking branch 'origin/develop' into angular5_with_typescriptwq
- Merge remote-tracking branch 'origin/develop' into angular5_with_typescriptwq

### Minor
- minor naming change
- minor changes

### Minor
- Minor display fixes
- Minor fix in PersonLinkImportComponent
- Minor clean in person form
- Minor format fixes
- Minor clean
- Minor fixes in workflow display
- Minor code format
- Minor format fix
- Minor TtmlToMp4 refactoring
- Minor clean in videos component

### Move
- move dependencies to devDependencies

### Move
- Move parameters and duration components into the workflow details directory

### Navigate
- Navigate through pages and display items index, size and total

### Only
- Only the workflow reference is clickable

### Pass
- pass into auth guard also for /login route

### Paths
- Paths requirements can be merged

### Preload
- Preload jobs status on getting workflows, and fix steps status

### Prevent
- prevent for empty artifact content

### Put
- put query filters in URL to fix pagination issue
- put uploaded file in artifact, and fix link with jarvis

### Redirect
- redirect to dashboard on /login URI and user is logged in

### Refactor
- Refactor workflow details page

### Refactor
- refactor image listing and support versionning

### Refactoring
- Refactoring of the language setting workflow step

### Reformat
- reformat code

### Remove
- remove ui log
- remove href, replace with navigate method
- remove unsupported old elixir versions
- remove merge residu
- remove unused alias
- remove unused definitions
- remove log
- remove file pushed in wrong PR
- remove unused lines
- remove unused section
- remove test controller
- remove unused alias and comment unused variables
- remove unused files
- remove console.logs ...

### Remove
- Remove warnings
- Remove empty error code from stored job status
- Remove useless "kind" parameter from messages
- Remove missing jobs params from view
- Remove link decoration
- Remove _ on Requirements.get_required_paths() function definition
- Remove ex_remote_dockers dependency

### Rename
- rename application
- rename folders
- rename containers to workers

### Rename
- Rename WorkflowRender to WorkflowRenderer
- Rename ACS queues, emitters and consumers, and handle error code messages
- Rename SetLanguage get_audio_jobs() function to get_related_jobs()
- Rename file system worker queues
- Rename AMQP emitters and consumers
- Rename Requirements module functions
- Rename requirements worker messages key
- Rename Containers page title to Workers

### Reorder
- reorder applications
- reorder by alphabetical order

### Replace
- Replace short_id pipe by a simplie ID string slice pipe

### Requirements
- Requirements refactoring

### Retreive
- retreive manifest URL and link with Jarvis player

### Return
- return WorkflowData instead of Workflow model
- return user information when opening session

### Revert
- revert test environment
- revert configuration for travis

### Send
- send events on websocket

### Set
- set qad language for re-synchronised content
- set environment var for ACS specific worker
- set default maileras sendgrid
- set job in error if needed
- set label work prod workers
- set buttons with color and icons
- set default DASH segment and fragment to 2000
- set pointer for cross
- set min size for channels selector

### Set
- Set action to file system worker message
- Set more specific path requirements for workflow step workers
- Set path requirements to workflow steps message

### Setup
- setup custom theming and use common colors
- setup databse for travis
- setup the base of the application

### Simplify
- Simplify person form moving it into a specific component
- Simplify how to get workflow steps status
- Simplify CleanWorkspace.get_paths_directory() function
- Simplify workflows view
- Simplify audio source files search into the set_language workflow step

### Simplify
- simplify job component rendering
- simplify some code

### Skip
- Skip workspace clean step if no directory exists
- Skip ACS if no TTML file available

### Skip
- skip task if required and add artifact at the end of the workflow

### Small
- small look and feel

### Sort
- Sort videos by reversed broadcasting dates

### Store
- store workflow query in cookie
- store FTP error message

### Store
- Store ACS error code in database

### Support
- support user rights in frontend
- support VO audio source

### Swithc
- swithc to english user interface
- swithc to Angular5 with typescript

### The
- The view needs the whole data from the connector to get size and total

### Unavailable
- Unavailable videos cannot be selected

### Uncheck
- Uncheck all selection checkbox on videos reload

### Unused
- unused variable

### Update
- Update README.md
- Update SynchroSubtilTSP application version into config
- Update code format
- Update workflows view with new step structs
- Update workflow steps code format
- Update unit tests
- Update dashboard ACS queues
- Update ACS executable version
- Update test.exs
- Update production configuration with appdir parameter
- Update set language workflow step
- Update TTML to MP4 workflow step
- Update GenerateDashTest
- Update queues names in GUI dashboard
- Update after Requirements refactoring
- Update ex_video_factory dependency version to 0.3.4
- Update back-end controllers with new ex_remote_dockers API
- Update ex_remote_dockers dependency version

### Update
- update matrix of elixir/OTP supported versions
- update travis matrix
- update elixir version in docker
- update Perfect Memory hostname default
- update backend to manage long response time on video factory
- update dependencies
- update person form
- update prod configuration
- update user interface dependencies
- update some checks on received event
- update event message content
- update workflow event model
- update dialog message and look
- update workflow event processing
- update workflow event endpoint
- update ex_video_factory dependency
- update homepage look
- update home page with mediaio logo
- update dependencies
- update minor dependencies
- update step details component
- update Workflow component
- update Workflow model with optional parameters
- update job details rendering
- update code format
- update prod endpoint
- update dashbord with right management
- update user tests
- update rights for docker controllers
- update unit tests
- update elixir code format
- update bamboo configuration
- update unit tests for users and messages
- update code format
- update confto try to support jsonb
- update test config with rabbitmq
- update default dev configuration
- update selection of new image to start a worker
- update test configuration
- update and add workflow unit tests
- update worker view
- update direct icon and order of informations
- update build with yarn
- update remote_dockers, rename HostConfig to NodeConfig
- update column labels
- update lock file
- update dependencies
- update Dockerfile
- update build instructions
- update build with docker
- update docker build
- update Dockerfile
- update interface to diplay channels and availability

### Updte
- updte backend to add rdf step and reduce AMQP connections

### Upgrade
- upgrade with minor version some dependencies
- upgrade phoenix
- upgrade Video Factory and use new File API

### Use
- Use template colors
- Use ES7 Array.includes() method
- Use simple buttons (instead of raised buttons)
- Use the workflow ID in the working directory name
- Use external variable for setting path requirements
- Use france-tv ID logo
- Use files with languages to generate DASH
- Use ngModel in view, instead of change event listener

### Use
- use npm package instead of local elixir dependency
- use socket events to update workflow status
- use cookie instead of sessionStorage
- use raised button
- use Workflow Render and some display updates
- use WorkflowRender
- use humanize method from moment
- use test environment
- use component API to drive per items per page
- use reference as string, not required to parse it
- use icon instead of character X

### User
- user styling per component

### Workflow
- Workflow end steps refactoring


[Unreleased]: https://github.com/media-cloud-ai/ex_backend/compare/0.1.0...HEAD
[0.1.0]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.13...0.1.0
[0.0.13]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.12...0.0.13
[0.0.12]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.11...0.0.12
[0.0.11]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.10...0.0.11
[0.0.10]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.9...0.0.10
[0.0.9]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.8...0.0.9
[0.0.8]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.7...0.0.8
[0.0.7]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.6...0.0.7
[0.0.6]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.5...0.0.6
[0.0.5]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/media-cloud-ai/ex_backend/compare/0.0.1...0.0.2
