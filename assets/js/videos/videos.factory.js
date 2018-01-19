
function VideosFactory($resource) {
  return $resource('/api/videos', {}, {
    getVideos: {
      method: 'GET'
    }
  });
}

export default VideosFactory;
