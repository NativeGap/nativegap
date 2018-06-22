document.addEventListener( 'turbolinks:load', () => {
    if (document.querySelector('body.apps.show')) {
        if (!onSignal.isSubscribed() && paramIsPresent('notify')) {
            setTimeout( () => mygModals[0].modalist.open({ url: '/notify' }), 1000 );
        }
    }
})


function paramIsPresent(field) {
    let url = window.location.href;
    if(url.indexOf('?' + field + '=') != -1)
        return true;
    else if(url.indexOf('&' + field + '=') != -1)
        return true;
    return false;
}
