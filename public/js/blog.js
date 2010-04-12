function load_disqus() {
  $('body').append($('<script></script>').attr({ src: 'http://mxkelsin.disqus.com/embed.js',
                                                 async: 'true',
                                                 type: 'text/javascript' }));
}

function load_comment_links() {
  $('.number_comments a').html('Loading Comments ...');

  var query = '?';
  $('.number_comments a').each(function(index, ele) {
    query += 'url' + index + '=' + encodeURIComponent($(ele).attr('href')) + '&';
  });

  $('body').append($('<script></script>').attr({ src: 'http://disqus.com/forums/mxkelsin/get_num_replies.js' + query,
                                                 type: 'text/javascript' }));
  return query;
}

$(function() {
  // Lightbox
  $('.post .body a:has(img)').lightBox({ imageLoading: '/images/loading.gif',
	                                     imageBlank: '/images/blank.gif',
                                         imageBtnClose: '/images/close.gif',
	                                     imageBtnPrev: '/images/prev.gif',
	                                     imageBtnNext: '/images/next.gif' });
});
