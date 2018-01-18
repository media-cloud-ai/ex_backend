function VideosController(
  $scope,
  VideosService
  )
{
  var vm = this;
  vm.iterations = 1;
  vm.completed = 0;
  vm.total = 0;
  vm.videos = {};

  (function initController() {
    getVideos();
    $scope.$on('JOB_EVENT', function (_event, data) {
      console.log("done");
      vm.completed += 1;
      $scope.$apply();
    });
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
