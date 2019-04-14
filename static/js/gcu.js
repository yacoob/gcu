/* jshint browser: true, strict: implied */
/* globals lightGallery */

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
  // Set helper vars.
  gcu.lg_data = window.lgData[lg.getAttribute("lg-uid")];
  // Bind lightbox events.
  lg.addEventListener("onAfterSlide", function(event) {
    gcu.setHashIdx(event.detail.index + 1);
  });
  lg.addEventListener("onCloseAfter", function(event) {
    gcu.setHashIdx("");
  });
  // Inhibit hashchange-triggered updates to avoid double updates when user
  // clicks on the a.
  var gallery_selector = "a" + gcu.lgOptions.selector;
  var gallery_elements = document.querySelectorAll(gallery_selector);
  gallery_elements.forEach(function(item, idx) {
    item.addEventListener("click", function() {
      gcu.inhibitHashChange = true;
    });
  });
  // We'll be clicking on things.
  // FIXME: verify whether this behaves as expected (eg. doesn't actually open
  // the image).
  var click = new MouseEvent("click", {
    view: window,
    bubbles: true,
    cancelable: true
  });
  // Handle hashchange event (user typing, history navigation, etc.)
  window.addEventListener(
    "hashchange",
    function() {
      var idx = gcu.getHashIdx();
      if (!gcu.inhibitHashChange) {
        if (idx > 0 && idx <= gallery_elements.length) {
          if (gcu.lg_data.lGalleryOn) {
            gcu.lg_data.slide(idx - 1);
          } else {
            gallery_elements[idx - 1].dispatchEvent(click);
          }
        } else {
          gcu.lg_data.destroy();
        }
      }
      gcu.inhibitHashChange = false;
    },
    false
  );
  // If a date hash was set, bring up lightbox for the first photo of that day.
  var hash_string = location.hash.substr(1);
  if (hash_string.match(gcu.dateHashPrefix)) {
    var first_photo_of_day = document
      .getElementById(hash_string)
      .parentNode.nextElementSibling.querySelector(gallery_selector);
    if (first_photo_of_day) {
      var pos = -1;
      for (var i = 0; i < gallery_elements.length; i++) {
        if (gallery_elements[i] == first_photo_of_day) {
          pos = i;
        }
      }
      if (pos >= 0) {
        gallery_elements[pos].dispatchEvent(click);
      }
    }
  }
  // // If a photo has was set, bring up lightbox for that photo.
  // var idx = gcu.getHashIdx();
  // if (idx > 0 && idx <= gallery_elements.length) {
  //   gallery_elements[idx - 1].dispatchEvent(click);
  // }
};
