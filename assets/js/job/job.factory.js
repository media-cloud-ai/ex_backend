
function JobFactory($resource) {
  return $resource('/api/jobs', {}, {
    getJobs: {
      method: 'GET',
    },
    newJob: {
      method: 'POST',
    },
    getJob: {
      method: 'GET',
      url: '/api/jobs/:id',
      params: {id: '@id'}
    },
    deleteJob: {
      method: 'DELETE',
      url: '/api/jobs/:id',
      params: {id: '@id'}
    },
  });
}

export default JobFactory;
