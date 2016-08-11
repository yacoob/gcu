var gcu = gcu || {
  ytRegexp: /youtu\.?be/,
  hashPrefix: 'p/',
  dateHashPrefix: /\d\d\d\d-\d\d-\d\d/,
  isMobile: (typeof window.orientation !== "undefined") || (navigator.userAgent.indexOf('IEMobile') !== -1),
  lbSettings: {
    nextEffect: 'none',
    prevEffect: 'none',
    padding: 0,
    closeBtn: false,
    keys: {
      next : {
        74 : 'J',
        76 : 'L',
        13 : 'left', // enter
        34 : 'up',   // page down
        39 : 'left', // right arrow
        40 : 'up'    // down arrow
      },
      prev : {
        72 : 'H',
        75 : 'K',
        8  : 'right',  // backspace
        33 : 'down',   // page up
        37 : 'right',  // left arrow
        38 : 'down'    // up arrow
      },
      close  : [27], // escape key
      play   : [32], // space - start/stop slideshow
      toggle : [70]  // letter "f" - toggle fullscreen
    },
    helpers: {
      media: {
        youtube: {
          params: {
            autoplay: 0,
          },
        },
      },
      title: {
        type: 'over',
      },
    },
    beforeLoad: function() {
      this.title = $(this.element).find('img').attr('title');
    },
    afterLoad: function(current) {
      gcu.setHashIdx(current.index + 1);
    },
    afterClose: function() {
      if (screenfull.enabled) {
        screenfull.exit();
      }
      gcu.setHashIdx('');
    },
    afterShow: function() {
      var isImage = $(this.wrap).hasClass('fancybox-type-image')
      if (screenfull.enabled && !gcu.isMobile && isImage) {
        var fs_icon = $('<div class="expander"><span class="glyphicon glyphicon-fullscreen img-rounded"></span></div>');
        fs_icon.find('span').click(function() {
          screenfull.toggle($('div.fancybox-overlay')[0]);
        });
        fs_icon.appendTo(this.inner);
      }
    },
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
  // Add play button to youtube thumbs
  var playbtn = $('<img class="playbtn" src="/i/playbtn.png">');
  $('a.gallery[href*=youtu]').each(function(idx, elem) {
      $(elem).append(playbtn);
  });
  // Enable lightbox.
  var gallery = $('a.gallery');
  gallery.fancybox(gcu.lbSettings);
  // Inhibit hashchange-triggered updates to avoid double updates when user
  // clicks on the a.
  gallery.click(function() {
    gcu.inhibitHashChange = true;
  });
  // Handle hashchange event (user typing, history navigation, etc.)
  $(window).bind('hashchange', function() {
    var idx = gcu.getHashIdx();
    if (!gcu.inhibitHashChange) {
      if (idx) {
        if ($.fancybox.isOpened) {
          $.fancybox.jumpto(idx - 1);
        } else {
          gallery.eq(idx - 1).trigger('click');
        }
      } else {
        $.fancybox.close();
      }
    }
    gcu.inhibitHashChange = false;
  });
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
  var idx = gcu.getHashIdx();
  if (idx) {
    gallery.eq(idx - 1).trigger('click');
  }
};
