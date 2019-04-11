var gcu = gcu || {
  hashPrefix: 'p/',
  dateHashPrefix: /\d\d\d\d-\d\d-\d\d/,
  lgOptions: {
    hideBarsDelay: 2000,
    keyPress: true,
    selector: '.gallery',
    showThumbByDefault: false,
    speed: 200,
    youtubePlayerParams: {
      autoplay: 0,
      controls: 0,
      modestbranding: 1,
      rel: 0,
      showinfo: 0,
    }
  },
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
    history.pushState("", document.title, window.location.pathname + window.location.search);
  }
};


gcu.getHashIdx = function() {
  /* Returns hash value, with prefix stripped.
   */
  var hash_string = location.hash.substr(1);
  if (hash_string.indexOf(gcu.hashPrefix) === 0) {
    return hash_string.substring(gcu.hashPrefix.length);
  } else {
    return '';
  }
};


gcu.postPageHandler = function() {
  /* Set up kit page.
   */
  // Enable lightbox.
  var lg = $('.container');
  lg.lightGallery(gcu.lgOptions);
  // Set helper vars.
  gcu.lg_data = lg.data('lightGallery');
  var gallery_elements = $('a' + gcu.lgOptions.selector);
  // Bind lightbox events.
  lg.on('onAfterSlide.lg', function(event, prevIndex, index, fromTouch, fromThumb) {
    gcu.setHashIdx(index + 1);
  });
  lg.on('onCloseAfter.lg', function(event) {
    gcu.setHashIdx('');
  });
  // Inhibit hashchange-triggered updates to avoid double updates when user
  // clicks on the a.
  gallery_elements.click(function() {
    gcu.inhibitHashChange = true;
  });
  // Handle hashchange event (user typing, history navigation, etc.)
  $(window).bind('hashchange', function() {
    var idx = gcu.getHashIdx();
    if (!gcu.inhibitHashChange) {
      if (idx > 0 && idx <= gallery_elements.length) {
        if (gcu.lg_data.lGalleryOn) {
          gcu.lg_data.slide(idx - 1);
        } else {
          gallery_elements.eq(idx - 1).trigger('click');
        }
      } else {
        gcu.lg_data.destroy();
      }
    }
    gcu.inhibitHashChange = false;
  });
  // If a date hash was set, bring up lightbox for the first photo of that day.
  var hash_string = location.hash.substr(1);
  if (hash_string.match(gcu.dateHashPrefix)) {
    var first_photo_of_day = $('#' + hash_string).parent().next().find('a.gallery').first();
    if (first_photo_of_day) {
      var pos = gallery_elements.index(first_photo_of_day);
      if (pos >= 0) {
        gallery_elements.eq(pos).trigger('click');
      }
    }
  }
  // If a photo has was set, bring up lightbox for that photo.
  var idx = gcu.getHashIdx();
  if (idx > 0 && idx <= gallery_elements.length) {
    gallery_elements.eq(idx - 1).trigger('click');
  }
};
