// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import channel from "./socket"

import JobController from "./job/job.controller"
import JobFactory from "./job/job.factory"
import JobService from "./job/job.service"

module = angular.module('ExSubtilBackend', [
  'ngResource',
]);

module
  .factory('JobFactory', JobFactory)
  .factory('JobService', JobService)
  .controller('JobController', JobController);


JobService.$inject = [
  '$http',
  'JobFactory'
];
JobFactory.$inject = ['$resource'];
JobController.$inject = [
  '$http',
  '$rootScope',
  'JobService',
];

module.run(run);

run.$inject = [
  '$rootScope'
];

function run($rootScope){
  channel.on("job_status", payload => {
    $rootScope.$emit('JOB_EVENT', payload);
  });
};
