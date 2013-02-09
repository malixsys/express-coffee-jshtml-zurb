  var domStarted = false;
  var googleStarted = false;
  
  google.maps.event.addDomListener(window, 'load', onGoogleStarted);
  
  $(document).ready(function(){
    onDomStarted();

    var ab = $("#address");
    ab.keypress(function(e) {
      if (e.which == 13) {
        return false;
      }
    }).focus();
    if(ab.val() == "") {
    }    
  });

function onGoogleStarted() {
  googleStarted = true;
  if(domStarted) {
    googleStarted = false;
    onStarted();
  }
}

function onDomStarted() {
  domStarted = true;
  if(domStarted) {
    domStarted = false;
    onStarted();
  }
}

var quebec =
{ ne: { lat: 62.5830552, lng: -57.1054859 },
  sw: { lat: 44.9913581, lng: -79.7627986 }};
  
function onStarted() {
  var map;
  window.map = map = new google.maps.Map(document.getElementById('map_canvas'), mapOptions);

  var input = document.getElementById('address');
  var defaultBounds = new google.maps.LatLngBounds(
      new google.maps.LatLng(quebec.sw.lat, quebec.sw.lng),
      new google.maps.LatLng(quebec.ne.lat, quebec.ne.lng));
  var options = {
    bounds: defaultBounds,
    componentRestrictions: {country: 'ca'}
  };
  window.autocomplete = new google.maps.places.Autocomplete(input, options);

  window.autocomplete.bindTo('bounds', map);

  var infowindow = new google.maps.InfoWindow();

  var marker = new google.maps.Marker({
    map: map
  });

  if(marker_location) {
    marker.setPosition(marker_location);
    marker.setVisible(true);
  }

  google.maps.event.addListener(window.autocomplete, 'place_changed', function() {
  
    $("#address_found").val("");
          infowindow.close();
          marker.setVisible(false);
          
          var place = window.autocomplete.getPlace() || {};
          if (!place.geometry) {
            // Inform the user that the place was not found and return.
            var grp = $(input).parents("div.control-group");
            grp.removeClass('success').addClass('error');
            return;
          }

          // If the place has a geometry, then present it on a map.
          if (place.geometry.viewport) {
            map.fitBounds(place.geometry.viewport);
          } else {
            map.setCenter(place.geometry.location);
            map.setZoom(17);  // Why 17? Because it looks good.
          }
          marker.setPosition(place.geometry.location);

          var address = '';
          if (place.address_components) {
            address = [
              (place.address_components[0] && place.address_components[0].short_name || ''),
              (place.address_components[1] && place.address_components[1].short_name || ''),
              (place.address_components[2] && place.address_components[2].short_name || '')
            ].join(' ');
          }

          infowindow.setContent('<div><strong>' + place.name + '</strong>');
          $("#address_found").val("OK");
          infowindow.open(map, marker);
          
  });
  
  
  window.autocomplete.setTypes(['geocode']);
}
