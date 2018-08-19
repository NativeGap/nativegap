import MygProgress from 'myg-progress';

['turbolinks:load', 'modalist:render', 'myg-tabs:render'].forEach((event) => {
  document.removeEventListener(event, init);
  document.addEventListener(event, init);
});
function init() {
  window.MygProgress = MygProgress;
  const mygProgresses = MygProgress.initAll(document.querySelectorAll('.myg-progress'), {});
}
