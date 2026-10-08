(function () {
  var controls = document.getElementById('controls');
  var search = document.getElementById('search');
  var typeFilter = document.getElementById('type-filter');
  var count = document.getElementById('count');
  var cards = Array.prototype.slice.call(document.querySelectorAll('#grid .card'));
  if (!controls || !search || !typeFilter || !cards.length) { return; }

  controls.hidden = false;

  function update() {
    var q = search.value.trim().toLowerCase();
    var t = typeFilter.value;
    var shown = 0;
    cards.forEach(function (card) {
      var ok = (!t || card.getAttribute('data-type') === t) &&
               (!q || card.getAttribute('data-text').indexOf(q) !== -1);
      card.hidden = !ok;
      if (ok) { shown += 1; }
    });
    count.textContent = shown === cards.length
      ? ''
      : 'Showing ' + shown + ' of ' + cards.length + ' tools.';
    if (shown === 0) { count.textContent = 'No tools match your search.'; }
  }

  search.addEventListener('input', update);
  typeFilter.addEventListener('change', update);
})();
