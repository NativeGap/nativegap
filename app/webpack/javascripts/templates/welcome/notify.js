document.addEventListener('modalist:render', () => {
  if (document.querySelector('.modalist--content-body.welcome.notify')) {
    let trigger = document.querySelector('.modalist--content-body.welcome.notify .myg-button');
    trigger.addEventListener('click', () => {
      onSignal.subscribe();
    });
  }
});
