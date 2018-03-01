$(document).ready(function() {
  $('body').on('click', '.thumbnail', toggleActiveThumbnail);
  $('body').on('click', '.thumbnail-lighttheme', toggleActiveThumbnailLighttheme);
  $('#zoom01').elevateZoom({
    zoomType: "inner",
    cursor: "crosshair",
    scrollZoom : true
  });
});

function toggleActiveThumbnail(event) {
  // Thumbnail and img-front update
  $('.thumbnail').removeClass('active');
  var source = $(this).attr("src");
  $(this).addClass('active');
  $('.img-front').attr("src", source);
  $('.img-front').attr("data-zoom-image", source);

  // InnerZoom update : destroy then creates
  $('.zoomContainer').remove();
  $('#zoom01').removeData('elevateZoom');
  $('#zoom01').removeData('zoomImage');
  $('#zoom01').elevateZoom({
    zoomType: "inner",
    cursor: "crosshair",
    scrollZoom : true
  });
}

function toggleActiveThumbnailLighttheme(event) {
  // Thumbnail and img-front update
  $('.thumbnail-lighttheme').removeClass('active');
  var source = $(this).attr("src");
  $(this).addClass('active');
  $('.img-front-lighttheme').attr("src", source);
  $('.img-front-lighttheme').attr("data-zoom-image", source);

  // InnerZoom update : destroy then creates
  $('.zoomContainer').remove();
  $('#zoom01').removeData('elevateZoom');
  $('#zoom01').removeData('zoomImage');
  $('#zoom01').elevateZoom({
    zoomType: "inner",
    cursor: "crosshair",
    scrollZoom : true
  });
}
