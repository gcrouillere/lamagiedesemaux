$(document).ready(function() {
  $('.contact-default').on('click', function(e) {
    e.stopPropagation();
    $('.info-text').addClass('visible').focus();
    $('i').addClass('visible');
  });

  $(document).on('click', function(e) {
    $('.info-text').removeClass('visible').val();
    $('i').addClass('visible');
  });
})
