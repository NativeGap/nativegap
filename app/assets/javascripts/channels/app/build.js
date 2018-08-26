App['app/build'] = App.cable.subscriptions.create('App::BuildChannel', {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    // Update manage card for platorm
    let parent = document.querySelector('body.apps.show .myg-tabs--panel .myg-grid__grid[data-build-id="' + data['id'] + '"]'),
      manage = parent.querySelector('#manage'),
      update = parent.querySelector('#update'),
      wrapper = document.createElement('div');
    wrapper.innerHTML= data['manage'];
    let m = wrapper.firstChild;
    manage.replaceWith(m);
    wrapper.innerHTML= data['update'];
    let u = wrapper.firstChild;
    update.replaceWith(u);
    MygProgress.initAll(document.querySelectorAll('.myg-progress'), {});
  }
});
