/* jshint browser: true, strict: implied */
/* globals lightGallery,HashChangeEvent */

var gcu = gcu || {
  hashPrefix: "p/",
  dateHashPrefix: /\d\d\d\d-\d\d-\d\d/,
  // FIXME: captions seem to be gone :(
  lgOptions: {
    hideBarsDelay: 2000,
    keyPress: true,
    selector: ".gallery",
    speed: 200,
    youtubePlayerParams: {
      autoplay: 0,
      controls: 0,
      modestbranding: 1,
      rel: 0,
      showinfo: 0
    }
  }
};

/*
 * While Lightgallery has its own hash plugin, it's not customizable enough (eg.
 * prefix string), so I'm rolling my own.
 */

gcu.setHashIdx = function(value) {
  /* Set location's hash to prefixed value.
   */
  var hash_string;
  if (value) {
    hash_string = gcu.hashPrefix + value;
    location.hash = hash_string;
  } else {
    history.pushState(
      "",
      document.title,
      window.location.pathname + window.location.search
    );
  }
};

gcu.getHashIdx = function() {
  /* Returns hash value, with prefix stripped.
   */
  var hash_string = location.hash.substr(1);
  // Handle #YYYY-MM-DD; translate it to index of first photo for that date.
  if (hash_string.match(gcu.dateHashPrefix)) {
    var first_photo_of_day = document
      .getElementById(hash_string)
      .parentNode.nextElementSibling.querySelector(gcu.lgOptions.selector);
    if (first_photo_of_day) {
      var pos = -1;
      for (var i = 0; i < gcu.lg_data.items.length; i++) {
        if (gcu.lg_data.items[i] == first_photo_of_day) {
          pos = i;
        }
      }
      if (pos >= 0) {
        return pos + 1;
      }
    }
  }
  // Handle normal prefix.
  if (hash_string.indexOf(gcu.hashPrefix) === 0) {
    return hash_string.substring(gcu.hashPrefix.length);
  } else {
    return "";
  }
};

gcu.postPageHandler = function() {
  /* Set up kit page.
   */
  // Enable lightbox.
  var lg = document.querySelector(".container");
  lightGallery(lg, gcu.lgOptions);
  gcu.lg_data = window.lgData[lg.getAttribute("lg-uid")];
  // Bind lightbox events for hash updating.
  lg.addEventListener("onAfterSlide", function(event) {
    gcu.setHashIdx(event.detail.index + 1);
  });
  lg.addEventListener("onCloseAfter", function(event) {
    gcu.setHashIdx("");
  });
  // Handle hashchange event (user typing, history navigation, etc.)
  window.addEventListener(
    "hashchange",
    function() {
      var idx = gcu.getHashIdx();
      if (idx > 0 && idx <= gcu.lg_data.items.length) {
        if (gcu.lg_data.lGalleryOn) {
          gcu.lg_data.slide(idx - 1);
        } else {
          gcu.lg_data.items[idx - 1].dispatchEvent(
            new MouseEvent("click", {
              view: window,
              bubbles: true,
              cancelable: true
            })
          );
        }
      } else {
        // Hide the lightbox.
        gcu.lg_data.destroy();
      }
    },
    false
  );
  // Trigger handler once to handle first load.
  window.dispatchEvent(new HashChangeEvent("hashchange"));
};
