document.addEventListener( 'modalist:render', () => {
    if (document.querySelector('.modalist--content-body.users.payment_methods.edit')) {
        let stripe = Stripe(stripePublishableKey),
            elements = stripe.elements(),
            style = {
                base: {
                    color: '#3d4553',
                    lineHeight: '18px',
                    fontFamily: '"Inter UI", sans-serif',
                    fontSmoothing: 'antialiased',
                    fontSize: '16px',
                    '::placeholder': {
                        color: '#657786'
                    }
                },
                invalid: {
                    color: '#f6809a',
                    iconColor: '#f6809a'
                }
            },
            card = elements.create( 'card', { style: style } ),
            form = document.querySelector('.modalist--content-body.users.payment_methods.edit form'),
            hiddenInput = form.querySelector('input[name="stripeToken"]');

        card.mount('#card-element');

        form.addEventListener( 'submit', function(event) {
            if (!hiddenInput.value) {
                event.preventDefault();
                stripe.createToken(card).then(function(result) {
                    hiddenInput.value = result.token.id;
                    Rails.fire( form, 'submit' );
                    if (form.querySelector('input[type="submit"]').dataset.modalistUrl) {
                        mygModals[0].modalist.open({ url: form.querySelector('input[type="submit"]').dataset.modalistUrl, modalIsAlreadyOpen: true });
                    }
                });
                return false;
            }
        });
    }
})
