function load_disqus() {
    $('body').append($('<script></script>').attr({ src: 'http://mxkelsin.disqus.com/embed.js',
                                                   async: 'true',
                                                   type: 'text/javascript' }));
}

function load_comment_links() {
    var query = '?';
    $('.number_comments a').each(function(index, ele) {
        query += 'url' + index + '=' + encodeURIComponent($(ele).attr('href')) + '&';
    });
    $('body').append($('<script></script>').attr({ src: 'http://disqus.com/forums/mxkelsin/get_num_replies.js' + query,
                                                   type: 'text/javascript' }));

    return query;
}

$(function() {
    // Hide Comments at start
    $('.comments').hide();
    $('.show_comments a').click(function() {
        if($('.comments').is(':visible')) {
            $('.show_comments a').html('Show Comments');
            $('.comments').slideUp();
        } else {
            $('.show_comments a').html('Hide Comments');
            $('.comments').slideDown();
        }

        // $('.show_comments').hide();
        return false;
    });
    $('.show_comments').show();

    // Lightbox
    $('.post .body a:has(img)').lightBox({ imageLoading: '/images/loading.gif',
	                                       imageBlank: '/images/blank.gif',
                                           imageBtnClose: '/images/close.gif',
	                                       imageBtnPrev: '/images/prev.gif',
	                                       imageBtnNext: '/images/next.gif' });

});
