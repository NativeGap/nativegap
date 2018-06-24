document.addEventListener( 'turbolinks:load', () => {
  if (document.querySelector('body#application')) {
    document.querySelector('.mdc-toolbar__section.mdc-toolbar__section--align-end.mobile > a > svg').addEventListener( 'click', () => mygDrawer.open() );
    window.addEventListener( 'scroll', () => {
      let element = document.querySelector('section#head'),
        toolbar = document.querySelector('.myg-toolbar');
      if (toolbar.classList.contains('scrolled')) {
        if (element && ((window.pageYOffset || document.documentElement.scrollTop) < (element.offsetHeight + element.getBoundingClientRect().top))) {
          toolbar.classList.remove('scrolled');
        }
      } else {
        if (element && ((window.pageYOffset || document.documentElement.scrollTop) > (element.offsetHeight + element.getBoundingClientRect().top))) {
          toolbar.classList.add('scrolled');
        }
      }
    })
  }
})
