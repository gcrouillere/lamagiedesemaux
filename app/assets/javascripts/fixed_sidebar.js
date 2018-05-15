$(document).ready(function() {

  function changeButtonFixeNav(filter_name, navbar_name, list_header_name) {
    if($(document).scrollTop() + $(navbar_name).height() > $('.ceramique-list').offset().top) {
      if($(document).scrollTop() + $(navbar_name).height() + 40 > $(".last-ceramique").offset().top) {
          $(filter_name).css({
            position: 'absolute',
            top: checkOffset(list_header_name, navbar_name),
         });
      } else {
        $(filter_name).css({
          position: 'fixed',
          top: 70,
        });
      }
    } else {
      $(filter_name).css({
        position: '',
        top: '',
      });
    }
  }

  function checkOffset(list_header_name, navbar_name) {
    var offset = $('.last-ceramique').offset().top - $(navbar_name).height() - 40
    if ($(list_header_name).size() > 0) {
      offset -=  312
    }
    return offset
  }

  $(document).scroll(function() {
    if ($('#ceramique-filters-content').size() > 0) {
      changeButtonFixeNav('#ceramique-filters-content', '.navbar-laptop', '.list-header-1')
    } else if ($('#ceramique-filters-content-darktheme').size() > 0) {
      changeButtonFixeNav('#ceramique-filters-content-darktheme', '.navbar-laptop-darktheme', '.list-header-1-darktheme')
    }
  });

})
