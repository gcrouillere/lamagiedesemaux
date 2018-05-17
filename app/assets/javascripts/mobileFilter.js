  $('#mobile-filter-search').on('click', function() {
    $('#ceramique-filters-content-mobile').css({'top':0});
    $('body').addClass('filter-opened');
  });

  $('#mobile-filter-search-darktheme').on('click', function() {
    $('#ceramique-filters-content-mobile-darktheme').css({'top':0});
    $('body').addClass('filter-opened');
  });

  $('#lighttheme-filter-search').on('click', function() {
    $('#ceramique-filters-content-lighttheme').css({'top':0});
    $('body').addClass('filter-opened');
  });

  $('#lighttheme-filter-search-mobile').on('click', function() {
    $('#ceramique-filters-content-lighttheme').css({'top':0});
    $('.navbar-mobile-lighttheme').css({'display': 'none'});
    $('body').addClass('filter-opened');
  });

  $('#darktheme-filter-search').on('click', function() {
    $('#ceramique-filters-content-darktheme-nav').css({'top':0});
    $('.navbar-mobile-darktheme').css({'display': 'none'});
    $('body').addClass('filter-opened');
  });

  $('#mobile-filter-search-darktheme').on('click', function() {
    $('#ceramique-filters-content-mobile-darktheme').css({'top':0});
    $('body').addClass('filter-opened');
  });

$('#close-search, #close-search-darktheme').on('click', function() {
  $('#ceramique-filters-content-mobile').css({'top': '100vh'});
  $('#ceramique-filters-content-lighttheme').css({'top': '100vh'});
  $('.navbar-mobile-lighttheme').css({'display': 'flex'});
  $('#ceramique-filters-content-mobile-darktheme').css({'top': '100vh'});
  $('#ceramique-filters-content-darktheme-nav').css({'top': '100vh'});
  $('.navbar-mobile-darktheme').css({'display': 'flex'});
  $('body').removeClass('filter-opened');
});

