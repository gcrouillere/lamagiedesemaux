$(document).ready(function() {
  if ($('.front-image-div').size() > 0) {
    $('.overlay-ok').on('click', function(e) {
      $('.imageoverlay').css("display", "none");
      $('.img-front').css("filter", "brightness(100%)");
    });
  }
});
