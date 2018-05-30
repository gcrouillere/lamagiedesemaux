initAutocomplete();

var placeSearch, autocomplete;

var componentForm = {
  locality: 'long_name',
  postal_code: 'short_name',
  country: 'short_name'
};

var adressLevels = ["route", "street_number"]

function initAutocomplete() {
  var userAdress = document.getElementById('user_adress')
  if (userAdress) {
    autocomplete = new google.maps.places.Autocomplete((userAdress), {types: ['geocode']});
    google.maps.event.addDomListener(userAdress, 'keydown', function(e) {
      if (e.key === "Enter") {
        e.preventDefault(); // Do not submit the form on Enter.
      }
    });
    autocomplete.addListener('place_changed', fillInAddress);
  }
}

function fillInAddress() {
  // Get the place details from the autocomplete object.
  var place = autocomplete.getPlace();
  for (var component in componentForm) {
    document.getElementById(component).value = '';
    document.getElementById(component).disabled = false;
  }

  // Get each component of the address from the place details and fill the corresponding field on the form.
  var concatenatedAdress = [];
  for (var i = 0; i < place.address_components.length; i++) {
    var addressType = place.address_components[i].types[0];
    if (adressLevels.indexOf(addressType) >= 0) {
      concatenatedAdress.push(place.address_components[i]['long_name'])
    }
    if (componentForm[addressType]) {
      var val = place.address_components[i][componentForm[addressType]];
      document.getElementById(addressType).value = val;
    }
  }
  document.getElementById('user_adress').value = concatenatedAdress.join(' ');
}

