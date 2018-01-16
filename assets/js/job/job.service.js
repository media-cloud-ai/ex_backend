
function JobService(
  $http,
  JobFactory
) {
  function Service() {
  }

  Service.prototype = {
    getJobs: getJobs,
    getJob: getJob,
    newJob: newJob,
    deleteJob: deleteJob,
  }

  return new Service();

  function getJobs(params){
    return JobFactory.getJobs(params).$promise;
  }

  function getJob(id){
    return JobFactory.getJob({id: id}).$promise;
  }
  function newJob(params){
    return JobFactory.newJob({job: params}).$promise;
  }
  function deleteJob(id){
    return JobFactory.deleteJob({id: id}).$promise;
  }
}

export default JobService;
