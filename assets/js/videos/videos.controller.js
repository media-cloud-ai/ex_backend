function VideosController(
  $scope,
  VideosService
  )
{
  var vm = this;
  vm.videos = {};
  vm.size = 0;
  vm.total = 0;
  vm.perPageOptions = [10, 20, 50, 100];
  vm.perPage = vm.perPageOptions[1];
  vm.page = 1;

  (function initController() {
    getVideos();
    $scope.reloadVideos = function() {
      getVideos();
    };
    $scope.nextPage = function() {
      vm.page++;
      getVideos();
    };
    $scope.previousPage = function() {
      vm.page--;
      getVideos();
    };
  })();


  function getVideos(){
    VideosService.getVideos({per_page: vm.perPage, page: vm.page}).then(
    function(response) {
      vm.videos = response.data;
      vm.size = response.size;
      vm.total = response.total;
    },
    function(message) {
      console.log("error", message);
    });
  }
}

export default VideosController;
