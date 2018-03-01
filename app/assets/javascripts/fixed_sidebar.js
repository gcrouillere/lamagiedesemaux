$(document).ready(function() {

  function changeButtonFixeNav() {
    if($('#ceramique-filters-content').size() > 0) {
      if($(document).scrollTop() + $('.navbar-laptop').height() > $('.ceramique-list').offset().top) {
        $('#ceramique-filters-content').css({
          position: 'fixed',
          top: 70,
        });
      } else {
        $('#ceramique-filters-content').css({
          position: '',
          top: '',
        });
      }
    }
    else if($('#ceramique-filters-content-darktheme').size() > 0) {
      if($(document).scrollTop() + $('.navbar-laptop-darktheme').height() > $('.ceramique-list').offset().top)  {
        $('#ceramique-filters-content-darktheme').css({
          position: 'fixed',
          top: 70,
        });
      } else {
        $('#ceramique-filters-content-darktheme').css({
          position: '',
          top: '',
        });
      }
    }
  }

    function changeButton() {
      if($('#ceramique-filters-content').size() > 0) {
        if($(document).scrollTop() > $('.ceramique-list').offset().top) {
          $('#ceramique-filters-content').css({
            position: 'fixed',
            top: 20,
          });
        } else {
          $('#ceramique-filters-content').css({
            position: '',
            top: '',
          });
        }
      }
    }

  $(document).scroll(function() {
    // changeButton();
    changeButtonFixeNav();
  });
})


// Without jquery:

// function changeButton() {
//   if ( document.querySelector(".ui.builder_button.light-green") ) {
//   var imageOffset = offset(document.querySelector("#image-3400-0-0-0"))
//     if((imageOffset.top - document.querySelector("#header.header-on-scroll").offsetHeight) * (- 1) > document.querySelector("#image-3400-0-0-0").offsetHeight) {
//       document.querySelector(".ui.builder_button.light-green").style.cssText = " position: fixed; top: 142px; left: calc(18%);"
//     } else {
//       document.querySelector(".ui.builder_button.light-green").style.cssText = " position: ''; top: ''; left: '';"
//         };
//       };
//     };

//   function offset(elt) {
//     var rect = elt.getBoundingClientRect(), bodyElt = document.body;
//     return {
//         top: rect.top + bodyElt .scrollTop,
//         left: rect.left + bodyElt .scrollLeft
//     }
//   }

//   window.addEventListener('scroll', (event) => {
//     changeButton();
//   });

