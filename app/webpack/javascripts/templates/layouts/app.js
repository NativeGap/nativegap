document.addEventListener( 'turbolinks:load', () => {
  if (document.querySelector('body#app')) {
    document.querySelector('.mdc-toolbar__section.mdc-toolbar__section--align-end.mobile > a > svg').addEventListener( 'click', () => mygDrawer.open() );
  }
})
