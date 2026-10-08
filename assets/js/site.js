(function () {
  // Search, filter and sort on the tools page.
  var controls = document.getElementById('controls');
  var grid = document.getElementById('grid');
  if (controls && grid) {
    var search = document.getElementById('search');
    var typeFilter = document.getElementById('type-filter');
    var sort = document.getElementById('sort');
    var count = document.getElementById('count');
    var cards = Array.prototype.slice.call(grid.querySelectorAll('.card'));

    controls.hidden = false;

    var sorters = {
      'default': function (a, b) { return a.dataset.index - b.dataset.index; },
      name: function (a, b) { return a.dataset.name.localeCompare(b.dataset.name, 'en-GB'); },
      type: function (a, b) {
        return a.dataset.type.localeCompare(b.dataset.type, 'en-GB') ||
               a.dataset.name.localeCompare(b.dataset.name, 'en-GB');
      },
      updated: function (a, b) {
        // Newest first; tools without a date go last.
        return (b.dataset.updated || '').localeCompare(a.dataset.updated || '') ||
               a.dataset.name.localeCompare(b.dataset.name, 'en-GB');
      }
    };

    var update = function () {
      var q = search.value.trim().toLowerCase();
      var t = typeFilter.value;
      var shown = 0;
      cards.slice().sort(sorters[sort.value] || sorters['default']).forEach(function (card) {
        grid.appendChild(card);
        var ok = (!t || card.dataset.type === t) &&
                 (!q || card.dataset.text.indexOf(q) !== -1);
        card.hidden = !ok;
        if (ok) { shown += 1; }
      });
      if (shown === 0) {
        count.textContent = 'No tools match your search.';
      } else if (shown === cards.length) {
        count.textContent = '';
      } else {
        count.textContent = 'Showing ' + shown + ' of ' + cards.length + ' tools.';
      }
    };

    search.addEventListener('input', update);
    typeFilter.addEventListener('change', update);
    sort.addEventListener('change', update);
  }

  // Copy buttons for citations.
  Array.prototype.forEach.call(document.querySelectorAll('[data-copy]'), function (button) {
    var text = button.parentNode.querySelector('.cite-text');
    if (!text) { return; }
    button.hidden = false;
    button.addEventListener('click', function () {
      var done = function () {
        button.textContent = 'Copied';
        setTimeout(function () { button.textContent = 'Copy citation'; }, 2000);
      };
      if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text.textContent.trim()).then(done);
      } else {
        var range = document.createRange();
        range.selectNodeContents(text);
        var sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
        try { document.execCommand('copy'); done(); } catch (e) { /* text stays selected */ }
      }
    });
  });
})();
