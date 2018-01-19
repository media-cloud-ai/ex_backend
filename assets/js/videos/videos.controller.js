function VideosController(
  $scope,
  VideosService
  )
{
  var vm = this;
  vm.videos = {};

  (function initController() {
    getVideos();
  })();

  function getVideos(){
    VideosService.getVideos().then(
    function(response) {
      vm.videos = response.data;
    },
    function(message) {
      console.log("error", message);
    });
  }
}

export default VideosController;
