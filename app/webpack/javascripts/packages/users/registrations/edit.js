document.addEventListener( 'turbolinks:load', () => {
    if (document.querySelector('body.users.registrations.edit')) {
        if (!onSignal.isSubscribed()) {
            document.querySelector('.myg-button.modalist--trigger').parentElement.classList.remove('hidden');
        }
    }
})
