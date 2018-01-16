function JobController(
  $http,
  $scope,
  JobService)
{
  var vm = this;
  vm.iterations = 1;
  vm.completed = 0;
  vm.total = 0;
  vm.start = start;
  vm.deleteJob = deleteJob;
  vm.deleteAllJobs = deleteAllJobs;

  (function initController() {
    updateJobs();
    $scope.$on('JOB_EVENT', function (_event, data) {
      console.log("done");
      vm.completed += 1;
      $scope.$apply();
      // for (var i = vm.jobs.length - 1; i >= 0; i--) {
      //   if(vm.jobs[i].id == data.job_id) {
      //     // vm.jobs[i].status.push({
      //     //   state: data.status
      //     // });

      //     // console.log("done");
      //     // vm.completed += 1;
      //     // $scope.$apply();
      //   }
      // }
    });
  })();

  function start() {
    var params = vm.job;
    params.params = {
      iterations: vm.iterations
    };
    vm.completed = 0; //reset counter
    vm.total = vm.iterations; //reset counter

    JobService.newJob(params).then(
    function(response) {
      updateJobs();
    },
    function(message) {
      console.log("error", message);
    });
  }

  function deleteJob(job_id) {
    JobService.deleteJob(job_id);
    updateJobs();
  }

  function deleteAllJobs(job_id) {
    // for (var i = vm.jobs.length - 1; i >= 0; i--) {
      JobService.deleteJob(1).then(
      function(response) {
        updateJobs();
      });
    // }
  }

  function updateJobs(){
    JobService.getJobs().then(
    function(response) {
      vm.jobs = response.data;
      vm.jobs_in_db = response.data.length;
    },
    function(message) {
      console.log("error", message);
    });
  }
}

export default JobController;
