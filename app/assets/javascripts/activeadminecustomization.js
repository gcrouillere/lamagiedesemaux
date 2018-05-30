$(document).ready(function() {
  var imglength = $('tr:last-child td:last-child span').length;
  var htmlcontent = "";

  if (imglength > 0) {
    for (var i = 0; i <= imglength - 1; i +=1) {
      htmlcontent += $('tr.row-images:last-child td:last-child span').eq(i).html();
    }
  }

  $('tr.row-images:last-child td:last-child').text("");
  $('tr.row-images:last-child td:last-child').html(htmlcontent);
});


$(document).ready(function() {
  $('.display-one-month').on('click', function() {
    if ($('.display-one-month').hasClass('clicked')) {
      $('.inner-CA').css({'display': 'none'});
      $('.display-one-month').removeClass('clicked');
    } else {
      $('.inner-CA').css({'display': 'block'});
      $('.display-one-month').addClass('clicked');
    }
  });
});
