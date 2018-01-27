
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
    params["type.id"] = "integrale"
    params["channels[]"] = ["france-2", "france-3", "france-5", "france-o"]
    return VideosFactory.getVideos(params).$promise;
  }

}

export default VideosService;
