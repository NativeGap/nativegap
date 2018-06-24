document.addEventListener( 'turbolinks:load', () => {
  if (document.querySelector('body.apps.new') || document.querySelector('body.apps.edit')) {
    let form = document.querySelector('form');
    form.querySelector('input[type="submit"]').addEventListener( 'click', () => {
      if (!form.checkValidity())
        mygToast.error({ message: form.querySelector('p#error').innerHTML });
    })
  }
})
