var gcu = gcu || {
  ytRegexp: /youtu\.?be/,
  hashPrefix: 'p/',
  dateHashPrefix: /\d\d\d\d-\d\d-\d\d/,
  isMobile: (typeof window.orientation !== "undefined") || (navigator.userAgent.indexOf('IEMobile') !== -1),
  lgOptions: {
    selector: '.gallery',
    speed: 200,
    hideBarsDelay: 2000,
    keyPress: true,
    showThumbByDefault: false,
    youtubePlayerParams: {
      autoplay: 0,
      modestbranding: 0,
      showinfo: 0,
      rel: 0,
      controls: 0,
    }
  },
};


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
  var lg = $('.container')
  lg.lightGallery(gcu.lgOptions);
  gcu.lg_data = lg.data('lightGallery');
  lg.on('onAfterSlide.lg', function(event, prevIndex, index, fromTouch, fromThumb) {
    gcu.setHashIdx(index + 1);
  });
  lg.on('onCloseAfter.lg', function(event) {
    gcu.setHashIdx('');
  })
  var gallery_elements = $('a' + gcu.lgOptions.selector);
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
  // TODO: if needed with new lightbox.
  // Bring up lightbox for the first photo, if date hash was set.
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
  // Bring up lightbox with specific image, if required.
  var idx = gcu.getHashIdx();
  if (idx > 0 && idx <= gallery_elements.length) {
    gallery_elements.eq(idx - 1).trigger('click');
  }
};
