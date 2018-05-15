$(document).ready(function() {
  $('#footer i').on('click', function(e) {
    e.stopPropagation();
    if ($('h6').hasClass('visible')) {
      $('h6').removeClass('visible');
    } else {
      $('h6').addClass('visible');
    }
  });
  $('body').on('click', function(e) {
    if ($('h6.info-text').hasClass('visible')) {
      $('h6.info-text').removeClass('visible');
    }
  });
})
