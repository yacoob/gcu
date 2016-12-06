var gcu = gcu || {
  ytRegexp: /youtu\.?be/,
  hashPrefix: 'p/',
  dateHashPrefix: /\d\d\d\d-\d\d-\d\d/,
  isMobile: (typeof window.orientation !== "undefined") || (navigator.userAgent.indexOf('IEMobile') !== -1),
  lgOptions: {
    selector: '.gallery',
    speed: 200,
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
  var container = $('.container');
  container.lightGallery(gcu.lgOptions);
  gcu.lg = container.data('lightGallery')
  // Inhibit hashchange-triggered updates to avoid double updates when user
  // clicks on the a.
  // gallery.click(function() {
  //   gcu.inhibitHashChange = true;
  // });
  // Handle hashchange event (user typing, history navigation, etc.)
  // TODO: if needed with new lightbox.
  // Bring up lightbox for the first photo, if date hash was set.
  var hash_string = location.hash.substr(1);
  if (hash_string.match(gcu.dateHashPrefix)) {
    var gallery = $('a.gallery');
    var first_photo_of_day = $('#' + hash_string).parent().next().find('a.gallery').first();
    if (first_photo_of_day) {
      var pos = gallery.index(first_photo_of_day);
      if (pos >= 0) {
        gallery.eq(pos).trigger('click');
      }
    }
  }
  // Bring up lightbox with specific image, if required.
  // var idx = gcu.getHashIdx();
  // if (idx) {
  //   gallery.eq(idx - 1).trigger('click');
  // }
};
