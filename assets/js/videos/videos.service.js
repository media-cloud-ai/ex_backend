
function VideosService(
  $http,
  VideosFactory
) {
  function Service() {
  }

  Service.prototype = {
    getVideos: getVideos
  }

  return new Service();

  function getVideos(params){
    return VideosFactory.getVideos(params).$promise;
  }

}

export default VideosService;
