import MygModal from 'myg-modal';
import Modalist from 'modalist';

['turbolinks:load', 'modalist:render', 'myg-tabs:render'].forEach((event) => {
  document.removeEventListener(event, init);
  document.addEventListener(event, init);
});
function init() {
  window.mygModals = MygModal.initAll(document.querySelectorAll('.modalist'), {});
}
