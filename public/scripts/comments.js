function load_disqus() {
    $('body').append($('<script></script>').attr({ src: 'http://mxkelsin.disqus.com/embed.js',
                                                   async: 'true',
                                                   type: 'text/javascript' }));
}
