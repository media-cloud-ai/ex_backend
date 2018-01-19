function VideosController(
  $scope,
  VideosService
  )
{
  var vm = this;
  vm.videos = {};
  vm.perPageOptions = [10, 20, 50, 100];
  vm.perPage = vm.perPageOptions[1];

  (function initController() {
    getVideos();
    $scope.reloadVideos = function() {
        getVideos();
      };
  })();


  function getVideos(){
    VideosService.getVideos({per_page: vm.perPage}).then(
    function(response) {
      vm.videos = response.data;
    },
    function(message) {
      console.log("error", message);
    });
  }
}

export default VideosController;
