/* ==========================================================================
   Learning PostgreSQL — course behaviour. Zero dependencies except the
   in-browser PostgreSQL (PGlite) that is loaded on demand from jsDelivr.
   Parts:
     1. chrome: theme, highlighting (incl. SQL), code copy buttons, TOC,
        scrollspy, search, sidebar
     2. components: tabs, steppers, checklists
     3. the playground: a real PostgreSQL 18 (PGlite, WebAssembly) in the page,
        seeded with a small version of the shop dataset, with EXPLAIN rendering
     4. progress: lessons marked as done, shown in the sidebar and on the home page
   Every page remains readable with JavaScript disabled.
   ========================================================================== */
(function () {
  'use strict';

  var root = document.documentElement;
  var STORE = 'pg-course-theme';
  try {
    var saved = localStorage.getItem(STORE);
    if (saved === 'light' || saved === 'dark') root.setAttribute('data-theme', saved);
  } catch (e) { /* private mode */ }

  function currentTheme() {
    var explicit = root.getAttribute('data-theme');
    if (explicit) return explicit;
    return matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  function paintThemeButton(btn) {
    var dark = currentTheme() === 'dark';
    btn.textContent = dark ? '☀' : '☾';
    btn.setAttribute('aria-label', dark ? 'Switch to light theme' : 'Switch to dark theme');
    btn.title = btn.getAttribute('aria-label');
  }

  /* --------------------------------------------------------------- escaping */

  function esc(s) {
    return s.replace(/[&<>]/g, function (c) {
      return c === '&' ? '&amp;' : c === '<' ? '&lt;' : '&gt;';
    });
  }

  /* ---------------------------------------------------------- highlighting */

  // Ordered rules per language. Each rule is [sticky-regex, token-class].
  // The scanner tries rules in order at every position; first match wins.
  var WORD = /^[A-Za-z_]/;

  function kw(words) {
    return new RegExp('(?:' + words.join('|') + ')\\b', 'y');
  }

  var GO_KW = ['break', 'case', 'chan', 'const', 'continue', 'default', 'defer', 'else',
    'fallthrough', 'for', 'func', 'go', 'goto', 'if', 'import', 'interface', 'map',
    'package', 'range', 'return', 'select', 'struct', 'switch', 'type', 'var'];
  var GO_LIT = ['nil', 'true', 'false', 'iota'];
  var GO_TYPE = ['string', 'bool', 'error', 'byte', 'rune', 'int', 'int8', 'int16', 'int32',
    'int64', 'uint', 'uint8', 'uint16', 'uint32', 'uint64', 'float32', 'float64', 'any'];

  var HCL_KW = ['resource', 'data', 'variable', 'output', 'module', 'provider', 'terraform',
    'locals', 'backend', 'required_providers', 'required_version', 'moved', 'import',
    'check', 'removed', 'run', 'mock_provider', 'override_resource', 'dynamic',
    'provisioner', 'connection', 'lifecycle', 'build', 'source', 'packer', 'variables'];
  var HCL_LIT = ['true', 'false', 'null'];
  var HCL_META = ['for_each', 'count', 'depends_on', 'providers', 'for', 'in', 'if', 'else', 'endfor', 'endif'];

  var SH_KW = ['if', 'then', 'elif', 'else', 'fi', 'for', 'while', 'until', 'do', 'done',
    'case', 'esac', 'in', 'function', 'return', 'exit', 'export', 'local', 'readonly',
    'set', 'unset', 'source', 'trap', 'shift', 'declare'];
  var SH_CMD = ['go', 'terraform', 'terragrunt', 'packer', 'ansible', 'ansible-playbook',
    'ansible-galaxy', 'aws', 'make', 'just', 'docker', 'git', 'ssh', 'ssh-keygen',
    'ssh-add', 'scp', 'echo', 'cd', 'mkdir', 'rm', 'cp', 'mv', 'cat', 'grep', 'sed',
    'awk', 'jq', 'curl', 'sudo', 'chmod', 'env', 'gofmt', 'golangci-lint', 'tflint',
    'pre-commit', 'python', 'pip', 'uv', 'yq', 'tofu'];

  var RULES = {
    go: [
      [/\/\/[^\n]*/y, 'tok-c'],
      [/\/\*[\s\S]*?\*\//y, 'tok-c'],
      [/`[^`]*`/y, 'tok-s'],
      [/"(?:\\.|[^"\\\n])*"?/y, 'tok-s'],
      [/'(?:\\.|[^'\\\n])*'/y, 'tok-s'],
      [kw(GO_KW), 'tok-k'],
      [kw(GO_LIT), 'tok-n'],
      [kw(GO_TYPE), 'tok-t'],
      [/[A-Za-z_][A-Za-z0-9_]*(?=\s*\()/y, 'tok-f'],
      [/[A-Z][A-Za-z0-9_]*/y, 'tok-t'],
      [/0[xX][0-9a-fA-F]+|\d+(?:\.\d+)?(?:[eE][-+]?\d+)?/y, 'tok-n']
    ],
    hcl: [
      [/#[^\n]*/y, 'tok-c'],
      [/\/\/[^\n]*/y, 'tok-c'],
      [/\/\*[\s\S]*?\*\//y, 'tok-c'],
      [/<<-?[A-Z]+[\s\S]*?^\s*[A-Z]+/my, 'tok-s'],
      [/"(?:\\.|[^"\\\n])*"?/y, 'tok-s'],
      [kw(HCL_KW), 'tok-k'],
      [kw(HCL_META), 'tok-k'],
      [kw(HCL_LIT), 'tok-n'],
      [/[a-zA-Z_][a-zA-Z0-9_-]*(?=\s*=[^=])/y, 'tok-a'],
      [/[a-zA-Z_][a-zA-Z0-9_]*(?=\s*\()/y, 'tok-f'],
      [/\d+(?:\.\d+)*/y, 'tok-n']
    ],
    bash: [
      [/#[^\n]*/y, 'tok-c'],
      [/'[^'\n]*'/y, 'tok-s'],
      [/"(?:\\.|[^"\\])*"?/y, 'tok-s'],
      [/\$\{[^}\n]*\}|\$[A-Za-z_][A-Za-z0-9_]*|\$\d/y, 'tok-n'],
      [kw(SH_KW), 'tok-k'],
      [kw(SH_CMD), 'tok-f'],
      [/--?[A-Za-z][A-Za-z0-9-]*/y, 'tok-a'],
      [/\b[A-Z][A-Z0-9_]{2,}\b/y, 'tok-t']
    ],
    yaml: [
      [/#[^\n]*/y, 'tok-c'],
      [/'[^'\n]*'/y, 'tok-s'],
      [/"(?:\\.|[^"\\\n])*"?/y, 'tok-s'],
      [/(?:^|(?<=[\s{,]))[A-Za-z_][\w.-]*(?=\s*:(?:\s|$))/my, 'tok-a'],
      [/\$\{\{[^}]*\}\}/y, 'tok-n'],
      [/\b(?:true|false|null|yes|no|on|off)\b/y, 'tok-n'],
      [/\b\d+(?:\.\d+)*\b/y, 'tok-n'],
      [/^\s*-(?=\s)/my, 'tok-k']
    ],
    json: [
      [/"(?:\\.|[^"\\])*"(?=\s*:)/y, 'tok-a'],
      [/"(?:\\.|[^"\\])*"/y, 'tok-s'],
      [/\b(?:true|false|null)\b/y, 'tok-n'],
      [/-?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?/y, 'tok-n']
    ],
    make: [
      [/#[^\n]*/y, 'tok-c'],
      [/'[^'\n]*'/y, 'tok-s'],
      [/"(?:\\.|[^"\\\n])*"/y, 'tok-s'],
      [/\$\([^)\n]*\)|\$\{[^}\n]*\}/y, 'tok-n'],
      [/^[A-Za-z0-9_.\/%-]+(?=\s*:(?!=))/my, 'tok-f'],
      [/^\.[A-Z]+\b/my, 'tok-k'],
      [kw(SH_CMD), 'tok-f'],
      [/--?[A-Za-z][A-Za-z0-9-]*/y, 'tok-a']
    ],
    ini: [
      [/[#;][^\n]*/y, 'tok-c'],
      [/^\s*\[[^\]\n]*\]/my, 'tok-k'],
      [/^\s*[A-Za-z_][\w.-]*(?=\s*=)/my, 'tok-a'],
      [/"(?:\\.|[^"\\\n])*"/y, 'tok-s']
    ]
  };
  RULES.tf = RULES.hcl;
  RULES.hcl2 = RULES.hcl;
  RULES.sh = RULES.bash;
  RULES.shell = RULES.bash;
  RULES.console = RULES.bash;
  RULES.dockerfile = RULES.bash;
  RULES.justfile = RULES.make;
  RULES.makefile = RULES.make;
  RULES.yml = RULES.yaml;
  RULES.gomod = [
    [/\/\/[^\n]*/y, 'tok-c'],
    [kw(['require', 'module', 'toolchain', 'replace', 'exclude', 'retract', 'go']), 'tok-k'],
    [/\bv\d+[\w.+-]*/y, 'tok-n'],
    [/\bindirect\b/y, 'tok-a']
  ];

  /* Added for this section: Python, TypeScript/TSX, TOML and raw HTTP. */

  var PY_KW = ['and', 'as', 'assert', 'async', 'await', 'break', 'case', 'class', 'continue',
    'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from', 'global', 'if',
    'import', 'in', 'is', 'lambda', 'match', 'nonlocal', 'not', 'or', 'pass', 'raise',
    'return', 'try', 'while', 'with', 'yield'];
  var PY_LIT = ['True', 'False', 'None', 'self', 'cls'];
  var PY_TYPE = ['str', 'int', 'bool', 'float', 'bytes', 'dict', 'list', 'set', 'tuple',
    'Optional', 'Any', 'Callable', 'Awaitable', 'Union'];

  var TS_KW = ['abstract', 'as', 'async', 'await', 'break', 'case', 'catch', 'class', 'const',
    'continue', 'declare', 'default', 'delete', 'do', 'else', 'enum', 'export', 'extends',
    'finally', 'for', 'from', 'function', 'if', 'implements', 'import', 'in', 'instanceof',
    'interface', 'keyof', 'let', 'new', 'of', 'private', 'protected', 'public', 'readonly',
    'return', 'satisfies', 'static', 'switch', 'throw', 'try', 'type', 'typeof', 'var',
    'void', 'while', 'yield'];
  var TS_LIT = ['true', 'false', 'null', 'undefined', 'NaN', 'this'];
  var TS_TYPE = ['string', 'number', 'boolean', 'any', 'unknown', 'never', 'Promise', 'Array',
    'Record', 'Uint8Array', 'TextEncoder', 'URLSearchParams', 'JSX'];

  RULES.python = [
    [/#[^\n]*/y, 'tok-c'],
    [/[rbfu]{0,2}"""[\s\S]*?"""/y, 'tok-s'],
    [/[rbfu]{0,2}'''[\s\S]*?'''/y, 'tok-s'],
    [/[rbfu]{0,2}"(?:\\.|[^"\\\n])*"?/y, 'tok-s'],
    [/[rbfu]{0,2}'(?:\\.|[^'\\\n])*'/y, 'tok-s'],
    [/@[A-Za-z_][\w.]*/y, 'tok-a'],
    [kw(PY_KW), 'tok-k'],
    [kw(PY_LIT), 'tok-n'],
    [kw(PY_TYPE), 'tok-t'],
    [/[A-Za-z_]\w*(?=\s*\()/y, 'tok-f'],
    [/[A-Z][A-Za-z0-9_]*/y, 'tok-t'],
    [/\b[A-Z][A-Z0-9_]{2,}\b/y, 'tok-t'],
    [/0[xX][0-9a-fA-F]+|\d+(?:\.\d+)?(?:[eE][-+]?\d+)?/y, 'tok-n']
  ];
  RULES.py = RULES.python;

  RULES.ts = [
    [/\/\/[^\n]*/y, 'tok-c'],
    [/\/\*[\s\S]*?\*\//y, 'tok-c'],
    [/`(?:\\.|[^`\\])*`/y, 'tok-s'],
    [/"(?:\\.|[^"\\\n])*"?/y, 'tok-s'],
    [/'(?:\\.|[^'\\\n])*'/y, 'tok-s'],
    [kw(TS_KW), 'tok-k'],
    [kw(TS_LIT), 'tok-n'],
    [kw(TS_TYPE), 'tok-t'],
    [/[A-Za-z_$][\w$]*(?=\s*\()/y, 'tok-f'],
    [/[A-Z][A-Za-z0-9_]*/y, 'tok-t'],
    [/0[xX][0-9a-fA-F]+|\d+(?:\.\d+)?/y, 'tok-n']
  ];
  RULES.tsx = RULES.ts;
  RULES.js = RULES.ts;
  RULES.jsx = RULES.ts;

  RULES.toml = [
    [/#[^\n]*/y, 'tok-c'],
    [/^\s*\[\[?[^\]\n]*\]\]?/my, 'tok-k'],
    [/"""[\s\S]*?"""/y, 'tok-s'],
    [/"(?:\\.|[^"\\\n])*"/y, 'tok-s'],
    [/'[^'\n]*'/y, 'tok-s'],
    [/^\s*[A-Za-z_][\w.-]*(?=\s*=)/my, 'tok-a'],
    [/\b(?:true|false)\b/y, 'tok-n'],
    [/\b\d[\d.:+-]*\b/y, 'tok-n']
  ];

  RULES.http = [
    [/^(?:GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)\b/my, 'tok-k'],
    [/^HTTP\/[\d.]+/my, 'tok-t'],
    [/^[A-Za-z][A-Za-z0-9-]*(?=:)/my, 'tok-a'],
    [/#[^\n]*/y, 'tok-c'],
    [/\b(?:Bearer|Basic)\b/y, 'tok-k'],
    [/"(?:\\.|[^"\\\n])*"/y, 'tok-s'],
    [/\b[1-5]\d\d\b/y, 'tok-n']
  ];

  function highlight(src, lang) {
    var rules = RULES[lang];
    if (!rules) return esc(src);

    var out = '';
    var i = 0;
    var n = src.length;

    while (i < n) {
      var matched = false;

      for (var r = 0; r < rules.length; r++) {
        var re = rules[r][0];
        // A word-shaped rule must start at a word boundary, otherwise `for` in
        // `terraform` would be styled as a keyword.
        if (i > 0 && WORD.test(src[i]) && /[A-Za-z0-9_]/.test(src[i - 1])) {
          var lit = re.source[0];
          if (/[A-Za-z(]/.test(lit)) continue;
        }
        re.lastIndex = i;
        var m = re.exec(src);
        if (m && m.index === i && m[0].length > 0) {
          out += '<span class="' + rules[r][1] + '">' + esc(m[0]) + '</span>';
          i += m[0].length;
          matched = true;
          break;
        }
      }

      if (!matched) {
        // Consume a whole identifier at once so word rules can't match mid-word.
        if (WORD.test(src[i])) {
          var j = i;
          while (j < n && /[A-Za-z0-9_]/.test(src[j])) j++;
          out += esc(src.slice(i, j));
          i = j;
        } else {
          out += esc(src[i]);
          i++;
        }
      }
    }

    return out;
  }

  /* -------------------------------------------------------------- codeblocks */

  function decorateCode() {
    // .prompt cards are code-block-shaped on purpose: they get the same copy
    // button, and no highlighting because they carry no data-lang.
    var blocks = document.querySelectorAll('.code, .prompt');

    for (var b = 0; b < blocks.length; b++) {
      var fig = blocks[b];
      var pre = fig.querySelector('pre');
      if (!pre) continue;

      var code = pre.querySelector('code') || pre;
      var lang = (fig.getAttribute('data-lang') || '').toLowerCase();
      var src = code.textContent.replace(/^\n/, '').replace(/\s+$/, '');

      if (RULES[lang]) code.innerHTML = highlight(src, lang);

      if (fig.querySelector('figcaption')) fig.classList.add('has-caption');

      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'copy-btn';
      btn.textContent = 'copy';
      btn.setAttribute('aria-label', 'Copy code to clipboard');
      (function (button, text) {
        button.addEventListener('click', function () {
          var write = navigator.clipboard
            ? navigator.clipboard.writeText(text)
            : Promise.reject();
          write.then(function () {
            button.textContent = 'copied';
            button.classList.add('done');
          }, function () {
            button.textContent = 'failed';
          }).then(function () {
            setTimeout(function () {
              button.textContent = 'copy';
              button.classList.remove('done');
            }, 1400);
          });
        });
      })(btn, src);

      fig.appendChild(btn);
    }
  }

  /* --------------------------------------------------------------------- toc */

  function buildToc() {
    var host = document.querySelector('.toc');
    var content = document.querySelector('.content');
    if (!host || !content) return [];

    var heads = content.querySelectorAll('h2[id], h3[id]');
    if (heads.length < 2) { host.style.display = 'none'; return []; }

    var ul = document.createElement('ul');
    var links = [];

    for (var i = 0; i < heads.length; i++) {
      var h = heads[i];
      var li = document.createElement('li');
      var a = document.createElement('a');
      a.href = '#' + h.id;
      a.textContent = (h.getAttribute('data-toc') || h.textContent).trim();
      if (h.tagName === 'H3') a.className = 'lvl3';
      li.appendChild(a);
      ul.appendChild(li);
      links.push({ a: a, el: h });

      // Clickable anchor beside the heading itself.
      var anchor = document.createElement('a');
      anchor.className = 'anchor';
      anchor.href = '#' + h.id;
      anchor.textContent = '#';
      anchor.setAttribute('aria-hidden', 'true');
      anchor.tabIndex = -1;
      h.insertBefore(anchor, h.firstChild);
    }

    var title = document.createElement('div');
    title.className = 'toc-title';
    title.textContent = 'On this page';
    host.appendChild(title);
    host.appendChild(ul);

    return links;
  }

  function scrollspy(links) {
    if (!links.length) return;

    var ticking = false;

    function update() {
      ticking = false;
      var top = window.scrollY + parseInt(getComputedStyle(document.documentElement).scrollPaddingTop || '0', 10) + 8;
      var active = links[0];

      for (var i = 0; i < links.length; i++) {
        if (links[i].el.offsetTop <= top) active = links[i]; else break;
      }

      // At the very bottom, highlight the last entry regardless of offsets.
      if (window.innerHeight + window.scrollY >= document.body.offsetHeight - 4) {
        active = links[links.length - 1];
      }

      for (var j = 0; j < links.length; j++) {
        links[j].a.classList.toggle('active', links[j] === active);
      }
    }

    addEventListener('scroll', function () {
      if (!ticking) { ticking = true; requestAnimationFrame(update); }
    }, { passive: true });

    addEventListener('resize', update, { passive: true });
    update();
  }

  /* ------------------------------------------------------------------ search */

  function initSearch() {
    var box = document.querySelector('.search input');
    var panel = document.querySelector('.search-results');
    if (!box || !panel || !window.DOCS_SEARCH_INDEX) return;

    var index = window.DOCS_SEARCH_INDEX;
    var sel = -1;
    var shown = [];

    function score(entry, terms) {
      var hay = (entry.t + ' ' + entry.s + ' ' + (entry.b || '')).toLowerCase();
      var total = 0;
      for (var i = 0; i < terms.length; i++) {
        var at = hay.indexOf(terms[i]);
        if (at < 0) return -1;
        total += (entry.t.toLowerCase().indexOf(terms[i]) >= 0 ? 12 : 0)
               + (entry.s.toLowerCase().indexOf(terms[i]) >= 0 ? 6 : 0)
               + Math.max(0, 5 - at / 60);
      }
      return total;
    }

    function render(q) {
      var terms = q.toLowerCase().split(/\s+/).filter(Boolean);
      shown = [];
      sel = -1;

      if (!terms.length) { panel.classList.remove('open'); panel.innerHTML = ''; return; }

      var hits = [];
      for (var i = 0; i < index.length; i++) {
        var s = score(index[i], terms);
        if (s >= 0) hits.push({ e: index[i], s: s });
      }

      hits.sort(function (a, b) { return b.s - a.s; });
      hits = hits.slice(0, 12);

      if (!hits.length) {
        panel.innerHTML = '<div class="empty">No matches for “' + esc(q) + '”.</div>';
        panel.classList.add('open');
        return;
      }

      var html = '';
      for (var h = 0; h < hits.length; h++) {
        var e = hits[h].e;
        var href = e.u;
        shown.push(href);
        html += '<a href="' + esc(href) + '">' + esc(e.s || e.t)
             + '<small>' + esc(e.t) + '</small></a>';
      }

      panel.innerHTML = html;
      panel.classList.add('open');
    }

    box.addEventListener('input', function () { render(box.value); });

    box.addEventListener('keydown', function (ev) {
      var items = panel.querySelectorAll('a');

      if (ev.key === 'Escape') { box.blur(); panel.classList.remove('open'); return; }
      if (!items.length) return;

      if (ev.key === 'ArrowDown' || ev.key === 'ArrowUp') {
        ev.preventDefault();
        sel += ev.key === 'ArrowDown' ? 1 : -1;
        if (sel < 0) sel = items.length - 1;
        if (sel >= items.length) sel = 0;
        for (var i = 0; i < items.length; i++) items[i].classList.toggle('sel', i === sel);
        items[sel].scrollIntoView({ block: 'nearest' });
      } else if (ev.key === 'Enter') {
        ev.preventDefault();
        location.href = items[sel < 0 ? 0 : sel].getAttribute('href');
      }
    });

    document.addEventListener('click', function (ev) {
      if (!ev.target.closest('.search')) panel.classList.remove('open');
    });

    addEventListener('keydown', function (ev) {
      if (ev.key === '/' && document.activeElement !== box &&
          !/^(INPUT|TEXTAREA)$/.test(document.activeElement.tagName)) {
        ev.preventDefault();
        box.focus();
      }
    });
  }

  /* ------------------------------------------------------------- chrome wiring */

  function initChrome() {
    var themeBtn = document.querySelector('.theme-btn');
    if (themeBtn) {
      paintThemeButton(themeBtn);
      themeBtn.addEventListener('click', function () {
        var next = currentTheme() === 'dark' ? 'light' : 'dark';
        root.setAttribute('data-theme', next);
        try { localStorage.setItem(STORE, next); } catch (e) { /* ignore */ }
        paintThemeButton(themeBtn);
      });
    }

    var menuBtn = document.querySelector('.menu-btn');
    var sidebar = document.querySelector('.sidebar');
    var scrim = document.querySelector('.scrim');

    function closeNav() {
      document.body.classList.remove('nav-open');
      if (sidebar) sidebar.classList.remove('open');
      if (menuBtn) menuBtn.setAttribute('aria-expanded', 'false');
    }

    if (menuBtn && sidebar) {
      menuBtn.addEventListener('click', function () {
        var open = sidebar.classList.toggle('open');
        document.body.classList.toggle('nav-open', open);
        menuBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
      });
    }

    if (scrim) scrim.addEventListener('click', closeNav);
    addEventListener('keydown', function (ev) { if (ev.key === 'Escape') closeNav(); });

    // Mark the current page in the sidebar without hand-editing every file.
    var file = location.pathname.replace(/.*\//, '') || 'index.html';
    var navLinks = document.querySelectorAll('.sidebar a[href]');
    for (var i = 0; i < navLinks.length; i++) {
      var href = navLinks[i].getAttribute('href').replace(/#.*$/, '');
      if (href === file || (file === 'index.html' && href === './')) {
        navLinks[i].setAttribute('aria-current', 'page');
      }
    }

    var current = document.querySelector('.sidebar a[aria-current="page"]');
    if (current && sidebar) {
      var offset = current.offsetTop - sidebar.clientHeight / 2;
      if (offset > 0) sidebar.scrollTop = offset;
    }
  }

  /* --------------------------------------------------------------- helpers */

  var uid = 0;

  function make(tag, cls, text) {
    var node = document.createElement(tag);
    if (cls) node.className = cls;
    if (text != null) node.textContent = text;
    return node;
  }

  function kids(parent, cls) {
    var out = [];
    for (var i = 0; i < parent.children.length; i++) {
      if (parent.children[i].classList.contains(cls)) out.push(parent.children[i]);
    }
    return out;
  }

  function read(key) {
    try { return localStorage.getItem(key); } catch (e) { return null; }
  }

  function write(key, value) {
    try { localStorage.setItem(key, value); } catch (e) { /* private mode */ }
  }

  /* -------------------------------------------------------------------- tabs */

  function initTabs() {
    var groups = document.querySelectorAll('.tabs');

    for (var g = 0; g < groups.length; g++) {
      (function (group) {
        var panels = kids(group, 'tab-panel');
        if (panels.length < 2) return;

        var list = make('div', 'tab-list');
        list.setAttribute('role', 'tablist');
        var buttons = [];
        uid++;

        function select(i, focus) {
          for (var k = 0; k < panels.length; k++) {
            var on = k === i;
            buttons[k].setAttribute('aria-selected', on ? 'true' : 'false');
            buttons[k].tabIndex = on ? 0 : -1;
            panels[k].hidden = !on;
          }
          if (focus) buttons[i].focus();
        }

        for (var i = 0; i < panels.length; i++) {
          (function (panel, index) {
            var btn = make('button', 'tab-btn', panel.getAttribute('data-tab') || ('Option ' + (index + 1)));
            btn.type = 'button';
            btn.id = 'tab-' + uid + '-' + index;
            btn.setAttribute('role', 'tab');
            panel.id = 'panel-' + uid + '-' + index;
            panel.setAttribute('role', 'tabpanel');
            panel.setAttribute('aria-labelledby', btn.id);
            btn.setAttribute('aria-controls', panel.id);

            btn.addEventListener('click', function () { select(index); });
            btn.addEventListener('keydown', function (ev) {
              var d = ev.key === 'ArrowRight' ? 1 : ev.key === 'ArrowLeft' ? -1 : 0;
              if (!d) return;
              ev.preventDefault();
              select((index + d + panels.length) % panels.length, true);
            });

            list.appendChild(btn);
            buttons.push(btn);
          })(panels[i], i);
        }

        group.insertBefore(list, panels[0]);
        select(0);
      })(groups[g]);
    }
  }

  /* ----------------------------------------------------------------- stepper */

  function initSteppers() {
    var all = document.querySelectorAll('.stepper');

    for (var s = 0; s < all.length; s++) {
      (function (st) {
        var notes = st.querySelectorAll('.step-notes > li');
        if (notes.length < 2) return;

        var total = notes.length;
        for (var n = 0; n < notes.length; n++) {
          if (!notes[n].getAttribute('data-step')) notes[n].setAttribute('data-step', String(n + 1));
        }

        var marks = st.querySelectorAll('[data-step]');
        var active = 'all';
        var timer = null;

        function ctl(text, label) {
          var b = make('button', null, text);
          b.type = 'button';
          b.setAttribute('aria-label', label);
          return b;
        }

        var bar = make('div', 'step-bar');
        var prev = ctl('\u2039', 'Previous step');
        var next = ctl('\u203a', 'Next step');
        var allBtn = ctl('all', 'Show every step at once');
        var playBtn = ctl('\u25b6 play', 'Play the flow step by step');
        var pills = [];

        bar.appendChild(make('span', 'lbl', 'Walk it'));
        bar.appendChild(prev);
        for (var p = 1; p <= total; p++) {
          (function (step) {
            var pill = ctl(String(step), 'Step ' + step);
            pill.className = 'pill';
            pill.addEventListener('click', function () { go(step); });
            pills.push(pill);
            bar.appendChild(pill);
          })(p);
        }
        bar.appendChild(next);
        bar.appendChild(make('span', 'grow'));
        bar.appendChild(allBtn);
        bar.appendChild(playBtn);

        function paint() {
          for (var m = 0; m < marks.length; m++) {
            var el = marks[m];
            var steps = el.getAttribute('data-step').split(',');
            var on = false, past = false;

            for (var k = 0; k < steps.length; k++) {
              var value = parseInt(steps[k], 10);
              if (active === value) on = true;
              else if (typeof active === 'number' && value < active) past = true;
            }

            el.classList.toggle('on', on);
            el.classList.toggle('past', !on && past);
          }

          for (var q = 0; q < pills.length; q++) {
            if (active === q + 1) pills[q].setAttribute('aria-current', 'step');
            else pills[q].removeAttribute('aria-current');
          }

          allBtn.setAttribute('aria-pressed', active === 'all' ? 'true' : 'false');
          st.setAttribute('data-active', String(active));
        }

        function stop() {
          if (timer) clearInterval(timer);
          timer = null;
          playBtn.textContent = '\u25b6 play';
          playBtn.setAttribute('aria-pressed', 'false');
        }

        function go(step) {
          stop();
          active = step;
          paint();
        }

        function step(delta) {
          var from = typeof active === 'number' ? active : (delta > 0 ? 0 : total + 1);
          var to = from + delta;
          if (to < 1) to = total;
          if (to > total) to = 1;
          go(to);
        }

        prev.addEventListener('click', function () { step(-1); });
        next.addEventListener('click', function () { step(1); });
        allBtn.addEventListener('click', function () { stop(); active = 'all'; paint(); });

        playBtn.addEventListener('click', function () {
          if (timer) { stop(); return; }
          active = 1;
          paint();
          playBtn.textContent = '\u275a\u275a pause';
          playBtn.setAttribute('aria-pressed', 'true');
          timer = setInterval(function () {
            if (typeof active === 'number' && active >= total) {
              active = 'all';
              paint();
              stop();
              return;
            }
            active = (typeof active === 'number' ? active : 0) + 1;
            paint();
          }, 2100);
        });

        for (var i = 0; i < notes.length; i++) {
          (function (note, index) {
            note.addEventListener('click', function () { go(index + 1); });
          })(notes[i], i);
        }

        st.addEventListener('keydown', function (ev) {
          if (/^(INPUT|TEXTAREA)$/.test(ev.target.tagName)) return;
          if (ev.key === 'ArrowRight') { ev.preventDefault(); step(1); }
          if (ev.key === 'ArrowLeft') { ev.preventDefault(); step(-1); }
        });

        var figure = st.querySelector('.dia');
        st.insertBefore(bar, figure || st.firstChild);
        paint();
      })(all[s]);
    }
  }

  function initChecklists() {
    var lists = document.querySelectorAll('ul.checklist[data-key]');

    for (var l = 0; l < lists.length; l++) {
      (function (list) {
        var key = 'pg.checklist.' + list.getAttribute('data-key');
        var items = [];
        for (var i = 0; i < list.children.length; i++) {
          if (list.children[i].tagName === 'LI') items.push(list.children[i]);
        }
        if (!items.length) return;

        var saved = [];
        try { saved = JSON.parse(read(key) || '[]') || []; } catch (e) { saved = []; }

        var boxes = [];
        var foot = make('li', 'checklist-foot');
        var bar = make('span', 'bar');
        var fill = make('i');
        var count = make('span', null, '');
        var reset = make('button', null, 'reset');
        reset.type = 'button';

        bar.appendChild(fill);
        foot.appendChild(bar);
        foot.appendChild(count);
        foot.appendChild(make('span', 'grow'));
        foot.appendChild(reset);

        function sync(persist) {
          var done = 0;
          for (var i = 0; i < boxes.length; i++) {
            if (boxes[i].checked) done++;
            items[i].classList.toggle('done', boxes[i].checked);
          }
          fill.style.width = Math.round((done / boxes.length) * 100) + '%';
          count.textContent = done + ' of ' + boxes.length + ' done';
          if (persist) {
            write(key, JSON.stringify(boxes.map(function (b) { return b.checked; })));
          }
        }

        for (var n = 0; n < items.length; n++) {
          (function (item, index) {
            var label = make('label');
            var box = make('input');
            box.type = 'checkbox';
            box.checked = !!saved[index];

            var body = make('span');
            body.innerHTML = item.innerHTML;
            item.innerHTML = '';
            label.appendChild(box);
            label.appendChild(body);
            item.appendChild(label);

            box.addEventListener('change', function () { sync(true); });
            boxes.push(box);
          })(items[n], n);
        }

        reset.addEventListener('click', function () {
          for (var i = 0; i < boxes.length; i++) boxes[i].checked = false;
          sync(true);
        });

        list.appendChild(foot);
        sync(false);
      })(lists[l]);
    }
  }



  /* ------------------------------------------------------------- SQL rules */

  var SQL_KW = ['select', 'from', 'where', 'and', 'or', 'not', 'in', 'is', 'null', 'as', 'on', 'join',
    'inner', 'left', 'right', 'full', 'outer', 'cross', 'lateral', 'using', 'group', 'by', 'order',
    'having', 'limit', 'offset', 'fetch', 'first', 'next', 'rows', 'only', 'distinct', 'all', 'union',
    'intersect', 'except', 'with', 'recursive', 'values', 'insert', 'into', 'update', 'set', 'delete',
    'returning', 'create', 'alter', 'drop', 'table', 'view', 'materialized', 'index', 'unique', 'primary',
    'key', 'foreign', 'references', 'check', 'default', 'constraint', 'cascade', 'restrict', 'schema',
    'database', 'role', 'user', 'grant', 'revoke', 'privileges', 'to', 'public', 'login', 'nologin',
    'begin', 'commit', 'rollback', 'savepoint', 'release', 'transaction', 'isolation', 'level', 'read',
    'write', 'committed', 'uncommitted', 'repeatable', 'serializable', 'explain', 'analyze', 'verbose',
    'buffers', 'case', 'when', 'then', 'else', 'end', 'between', 'like', 'ilike', 'similar', 'exists',
    'any', 'some', 'asc', 'desc', 'nulls', 'last', 'over', 'partition', 'window', 'range', 'filter',
    'within', 'function', 'procedure', 'returns', 'language', 'trigger', 'before', 'after', 'each',
    'for', 'execute', 'perform', 'declare', 'if', 'elsif', 'loop', 'while', 'return', 'raise', 'do',
    'merge', 'matched', 'conflict', 'nothing', 'copy', 'truncate', 'vacuum', 'grouping', 'sets',
    'cube', 'rollup', 'enum', 'domain', 'extension', 'sequence', 'identity', 'generated', 'always',
    'stored', 'owner', 'inherit', 'bypassrls', 'createdb', 'createrole', 'password', 'valid', 'until',
    'policy', 'enable', 'disable', 'force', 'row', 'security', 'definer', 'invoker', 'immutable',
    'stable', 'volatile', 'strict', 'parallel', 'safe', 'unsafe', 'partition', 'attach', 'detach',
    'tablespace', 'show', 'reset', 'listen', 'notify', 'prepare', 'deallocate', 'cluster', 'reindex',
    'lock', 'share', 'mode', 'nowait', 'skip', 'locked', 'of', 'format', 'text', 'json', 'xml'];
  var SQL_LIT = ['true', 'false', 'unknown', 'current_user', 'session_user', 'current_role', 'current_date',
    'current_timestamp', 'localtimestamp', 'localtime', 'current_time', 'default'];
  var SQL_TYPE = ['integer', 'int', 'int2', 'int4', 'int8', 'bigint', 'smallint', 'serial', 'bigserial',
    'numeric', 'decimal', 'real', 'float', 'float4', 'float8', 'double', 'precision', 'boolean', 'bool',
    'text', 'varchar', 'char', 'character', 'varying', 'bytea', 'date', 'time', 'timestamp', 'timestamptz',
    'interval', 'uuid', 'json', 'jsonb', 'money', 'inet', 'cidr', 'macaddr', 'tsvector', 'tsquery',
    'int4range', 'int8range', 'numrange', 'tstzrange', 'daterange', 'point', 'box', 'xml', 'oid', 'name',
    'regclass', 'regtype', 'citext'];

  function sqlKw(words) { return new RegExp('(?:' + words.join('|') + ')\\b', 'iy'); }

  RULES.sql = [
    [/--[^\n]*/y, 'tok-c'],
    [/\/\*[\s\S]*?\*\//y, 'tok-c'],
    [/'(?:[^']|'')*'?/y, 'tok-s'],
    [/"(?:[^"]|"")*"/y, 'tok-a'],
    [/\$([A-Za-z_]\w*)?\$[\s\S]*?\$\1\$/y, 'tok-s'],
    [/\\[a-z?]+[^\n]*/y, 'tok-k'],
    [sqlKw(SQL_KW), 'tok-k'],
    [sqlKw(SQL_LIT), 'tok-n'],
    [sqlKw(SQL_TYPE), 'tok-t'],
    [/[A-Za-z_]\w*(?=\s*\()/y, 'tok-f'],
    [/\b\d+(?:\.\d+)?(?:[eE][-+]?\d+)?\b/y, 'tok-n'],
    [/::\s*[A-Za-z_][\w ]*/y, 'tok-t']
  ];
  RULES.psql = RULES.bash;

  /* ---------------------------------------------------------- lesson progress */

  function initProgress() {
    var KEY = 'pg-course-done';
    function load() {
      try { return JSON.parse(read(KEY) || '{}') || {}; } catch (e) { return {}; }
    }
    function save(d) { write(KEY, JSON.stringify(d)); }
    var done = load();

    var holders = document.querySelectorAll('.lesson-done[data-lesson]');
    for (var h = 0; h < holders.length; h++) {
      (function (holder) {
        var slug = holder.getAttribute('data-lesson');
        var btn = make('button', 'btn ghost done-toggle', '');
        btn.type = 'button';
        function paint() {
          var on = !!done[slug];
          btn.textContent = on ? '✓ Lesson completed (click to undo)' : 'Mark this lesson as completed';
          btn.setAttribute('aria-pressed', on ? 'true' : 'false');
          btn.classList.toggle('on', on);
        }
        btn.addEventListener('click', function () {
          if (done[slug]) delete done[slug]; else done[slug] = true;
          save(done); paint(); mark(); home();
        });
        holder.appendChild(btn);
        paint();
      })(holders[h]);
    }

    function mark() {
      var links = document.querySelectorAll('.sidebar a[data-page]');
      for (var i = 0; i < links.length; i++) {
        var slug = links[i].getAttribute('data-page');
        var tick = links[i].querySelector('.done-mark');
        if (done[slug] && !tick) {
          tick = make('span', 'done-mark', '✓');
          links[i].appendChild(tick);
        } else if (!done[slug] && tick) {
          tick.parentNode.removeChild(tick);
        }
      }
    }

    function home() {
      var line = document.querySelector('[data-progress]');
      if (!line) return;
      var all = document.querySelectorAll('.lesson-list a[data-page]');
      var n = 0;
      for (var i = 0; i < all.length; i++) if (done[all[i].getAttribute('data-page')]) n++;
      line.querySelector('.bar i').style.width = (all.length ? Math.round(100 * n / all.length) : 0) + '%';
      line.querySelector('.count').textContent = n + ' of ' + all.length + ' lessons completed (saved in this browser)';
    }

    mark();
    home();
  }

  /* ----------------------------------------------------------- the playground */

  // One real PostgreSQL 18 per page (PGlite, WebAssembly), seeded with a small,
  // readable copy of the shop dataset. Every lab on the page shares it, so a
  // CREATE in one lab is visible to the next. "Reset data" starts over.
  // date, timestamp, timestamptz: show the text PostgreSQL produced, as psql does,
  // instead of JavaScript Date objects (which would print as quoted ISO strings).
  var RAW_TEXT = { 1082: function (v) { return v; }, 1114: function (v) { return v; }, 1184: function (v) { return v; } };
  var PGLITE_URL = 'https://cdn.jsdelivr.net/npm/@electric-sql/pglite@0.5.10/dist/index.js';
  var dbPromise = null;
  var labs = [];

  function newDb() {
    return import(PGLITE_URL).then(function (mod) {
      var db = new mod.PGlite();
      // UTC, like the Docker database, so quoted timestamps match on every machine.
      return db.exec("set timezone to 'UTC'; " + window.PG_MINI_SEED).then(function () { return db; });
    });
  }

  function getDb() {
    if (!dbPromise) dbPromise = newDb();
    return dbPromise;
  }

  function setLabState(lab, state, text) {
    lab.setAttribute('data-state', state);
    var s = lab.querySelector('.status');
    if (s) s.textContent = text;
  }

  function fmtCell(v, name) {
    if (v === null || v === undefined) return { t: 'NULL', cls: 'null' };
    if (typeof v === 'boolean') return { t: v ? 't' : 'f', cls: v ? 'bool-t' : 'bool-f' };
    if (typeof v === 'number' || typeof v === 'bigint') return { t: String(v), cls: 'num' };
    if (typeof v === 'object') return { t: JSON.stringify(v), cls: '' };
    return { t: String(v), cls: '' };
  }

  function resultTable(res) {
    var wrap = make('div', 'pg-res ok');
    var names = res.fields.map(function (f) { return f.name; });
    var shown = res.rows.slice(0, 200);

    var cap = make('div', 'cap');
    cap.appendChild(make('b', null, res.rows.length + (res.rows.length === 1 ? ' row' : ' rows')));
    cap.appendChild(make('span', 'grow'));
    cap.appendChild(make('span', null, names.length + ' column' + (names.length === 1 ? '' : 's')));
    if (res.rows.length > shown.length) cap.appendChild(make('span', null, 'first ' + shown.length + ' shown'));
    wrap.appendChild(cap);

    var scroll = make('div', 'scroll');
    var table = make('table');
    var thead = make('thead');
    var tr = make('tr');
    names.forEach(function (n) { tr.appendChild(make('th', null, n)); });
    thead.appendChild(tr);
    table.appendChild(thead);
    var tbody = make('tbody');
    shown.forEach(function (row) {
      var r = make('tr');
      names.forEach(function (n) {
        var c = fmtCell(row[n], n);
        var td = make('td', c.cls, c.t);
        td.title = c.t;
        r.appendChild(td);
      });
      tbody.appendChild(r);
    });
    table.appendChild(tbody);
    scroll.appendChild(table);
    wrap.appendChild(scroll);
    return wrap;
  }

  // EXPLAIN (FORMAT JSON) -> a tree you can read. Costs are planner units, not milliseconds.
  function planNode(p, rootTime) {
    var li = make('li');
    var node = make('div', 'node');
    var type = p['Node Type'] || 'Node';
    if (/Seq Scan/.test(type)) node.classList.add('seq');
    if (/Index|Bitmap/.test(type)) node.classList.add('idx');
    var removed = p['Rows Removed by Filter'] || p['Rows Removed by Index Recheck'];
    if (removed && removed > 1000) node.classList.add('hot');

    var op = type;
    if (p['Join Type'] && p['Join Type'] !== 'Inner') op += ' (' + p['Join Type'] + ')';
    if (p['Strategy']) op += ' · ' + p['Strategy'];
    node.appendChild(make('span', 'op', op));
    var rel = p['Relation Name'] || p['Index Name'];
    if (rel) node.appendChild(make('span', 'rel', (p['Relation Name'] ? 'on ' + p['Relation Name'] : '') +
      (p['Index Name'] ? ' using ' + p['Index Name'] : '')));
    var rows = p['Actual Rows'] !== undefined ? p['Actual Rows'] + ' rows' : 'est. ' + p['Plan Rows'] + ' rows';
    node.appendChild(make('span', 'm', rows));
    if (p['Actual Total Time'] !== undefined) {
      var own = p['Actual Total Time'] * (p['Actual Loops'] || 1);
      (p.Plans || []).forEach(function (c) { own -= (c['Actual Total Time'] || 0) * (c['Actual Loops'] || 1); });
      own = Math.max(0, own);
      node.appendChild(make('span', 'm', own.toFixed(2) + ' ms own'));
      var bar = make('span', 'bar');
      bar.style.width = Math.max(2, Math.round(160 * own / Math.max(rootTime, 0.0001))) + 'px';
      node.appendChild(bar);
    } else {
      node.appendChild(make('span', 'm', 'cost ' + p['Startup Cost'] + '..' + p['Total Cost']));
    }
    if (removed) node.appendChild(make('span', 'm', removed + ' removed by filter'));
    li.appendChild(node);
    var extras = [];
    ['Filter', 'Index Cond', 'Hash Cond', 'Join Filter', 'Recheck Cond', 'Sort Key', 'Group Key'].forEach(function (k) {
      if (p[k]) extras.push(k.toLowerCase() + ': ' + (Array.isArray(p[k]) ? p[k].join(', ') : p[k]));
    });
    if (extras.length) li.appendChild(make('div', 'm', extras.join('   ')));
    if (p.Plans && p.Plans.length) {
      var ul = make('ul');
      p.Plans.forEach(function (c) { ul.appendChild(planNode(c, rootTime)); });
      li.appendChild(ul);
    }
    return li;
  }

  function planView(res) {
    var wrap = make('div', 'pg-res ok');
    var cap = make('div', 'cap');
    cap.appendChild(make('b', null, 'query plan'));
    cap.appendChild(make('span', 'grow'));
    cap.appendChild(make('span', null, 'read top-down; the innermost node runs first'));
    wrap.appendChild(cap);
    var box = make('div', 'plan');
    var root = res.rows[0]['QUERY PLAN'][0];
    var ul = make('ul');
    ul.appendChild(planNode(root.Plan, root['Execution Time'] || root.Plan['Actual Total Time'] || 1));
    box.appendChild(ul);
    var legend = make('div', 'legend');
    legend.textContent = 'amber = sequential scan (reads every row)  ·  green = index  ·  red edge = many rows thrown away by a filter';
    box.appendChild(legend);
    if (root['Execution Time'] !== undefined) {
      box.appendChild(make('div', 'legend', 'planning ' + root['Planning Time'].toFixed(2) + ' ms · execution ' + root['Execution Time'].toFixed(2) + ' ms'));
    }
    wrap.appendChild(box);
    return wrap;
  }

  function showOutput(lab, node) {
    var out = lab.querySelector('.pg-out');
    out.innerHTML = '';
    out.appendChild(node);
  }

  function errorView(msg, where) {
    var wrap = make('div', 'pg-res err');
    wrap.appendChild(make('div', 'cap', 'error'));
    var pre = make('pre', 'plain', msg + (where ? '\n' + where : ''));
    wrap.appendChild(pre);
    return wrap;
  }

  // Split a script into statements the way psql does: on semicolons outside
  // quotes, dollar-quoted bodies, quoted identifiers and comments. Each statement
  // then runs on its own (autocommit, like psql), so a later error does not undo
  // the setup that came before it. Explicit BEGIN ... COMMIT still works because
  // the session persists between statements.
  function splitSql(src) {
    var out = [], cur = '', i = 0, n = src.length;
    while (i < n) {
      var c = src[i], d = src[i + 1];
      if (c === '-' && d === '-') {
        var e = src.indexOf('\n', i); if (e < 0) e = n;
        cur += src.slice(i, e); i = e; continue;
      }
      if (c === '/' && d === '*') {
        var e2 = src.indexOf('*/', i + 2); e2 = e2 < 0 ? n : e2 + 2;
        cur += src.slice(i, e2); i = e2; continue;
      }
      if (c === "'" || c === '"') {
        var j = i + 1;
        while (j < n) {
          if (src[j] === c) { if (src[j + 1] === c) { j += 2; continue; } break; }
          j++;
        }
        cur += src.slice(i, j + 1); i = j + 1; continue;
      }
      if (c === '$') {
        var m = /^\$([A-Za-z_][A-Za-z0-9_]*)?\$/.exec(src.slice(i));
        if (m) {
          var tag = m[0], close = src.indexOf(tag, i + tag.length);
          close = close < 0 ? n : close + tag.length;
          cur += src.slice(i, close); i = close; continue;
        }
      }
      if (c === ';') {
        cur += ';';
        if (cur.replace(/--[^\n]*|\/\*[\s\S]*?\*\//g, '').trim() !== ';') out.push(cur);
        cur = ''; i++; continue;
      }
      cur += c; i++;
    }
    if (cur.replace(/--[^\n]*|\/\*[\s\S]*?\*\//g, '').trim()) out.push(cur);
    var pos = 0, res = [];
    for (var k = 0; k < out.length; k++) { res.push({ sql: out[k], offset: pos }); pos += out[k].length; }
    return res;
  }

  function runLab(lab) {
    var ta = lab.querySelector('textarea.sql');
    var sql = ta.value;
    var btn = lab.querySelector('[data-run]');
    btn.disabled = true;
    setLabState(lab, 'loading', 'running');
    var started = performance.now();

    getDb().then(function (db) {
      var stmts = splitSql(sql);
      var results = [];
      var failedAt = null;
      // Every Run starts as the superuser, outside any transaction: a SET ROLE or an
      // open BEGIN left behind by an earlier run (or an earlier error) must not leak
      // into this one. Within one Run, SET ROLE behaves exactly as in psql.
      // Then run one statement at a time, like psql in autocommit mode.
      var chain = db.query('rollback').catch(function () {})
        .then(function () { return db.query('reset role'); })
        .then(function () { return db.query('reset session authorization'); })
        .catch(function () {});
      stmts.forEach(function (st) {
        chain = chain.then(function () {
          if (failedAt) return;
          return db.query(st.sql, [], { parsers: RAW_TEXT }).then(function (r) { results.push(r); }, function (e) { failedAt = st; throw e; });
        });
      });
      return chain.then(function () {
        var ms = (performance.now() - started).toFixed(1);
        setLabState(lab, 'ready', 'ready');
        var shown = results.filter(function (r) { return r.fields && r.fields.length; });
        var out = lab.querySelector('.pg-out');
        out.innerHTML = '';
        if (!shown.length) {
          var n = results.length;
          var affected = results.length ? results[results.length - 1].affectedRows : 0;
          var ok = make('div', 'pg-res ok');
          ok.appendChild(make('div', 'cap', 'ok'));
          ok.appendChild(make('pre', 'plain', (affected ? affected + ' row' + (affected === 1 ? '' : 's') + ' affected' : 'done') +
            '  \u00b7  ' + n + ' statement' + (n === 1 ? '' : 's') + '  \u00b7  ' + ms + ' ms'));
          out.appendChild(ok);
        } else {
          var last = shown[shown.length - 1];
          if (last.fields.length === 1 && last.fields[0].name === 'QUERY PLAN' && Array.isArray(last.rows[0] && last.rows[0]['QUERY PLAN'] && last.rows[0]['QUERY PLAN'][0] && last.rows[0]['QUERY PLAN'][0].Plan)) {
            out.appendChild(planView(last));
          } else {
            out.appendChild(resultTable(last));
          }
          var t = make('div', 'lab-out');
          t.textContent = results.length + ' statement' + (results.length === 1 ? '' : 's') + ' \u00b7 ' + ms + ' ms in your browser' +
            (shown.length > 1 ? ' \u00b7 showing the result of the last query' : '');
          out.appendChild(t);
        }
        btn.disabled = false;
      }).catch(function (err) {
        // Like psql after an error: discard the failed (explicit) transaction.
        return db.query('rollback').catch(function () {}).then(function () {
          setLabState(lab, 'error', 'error');
          var where = '';
          if (err && err.position) {
            var pos = Number(err.position) - 1 + (failedAt ? failedAt.offset : 0);
            var before = sql.slice(0, pos);
            var line = before.split('\n').length;
            var col = pos - before.lastIndexOf('\n');
            where = 'line ' + line + ', column ' + col;
          }
          showOutput(lab, errorView(String(err && err.message ? err.message : err), where));
          btn.disabled = false;
        });
      });
    }).catch(function (err) {
      setLabState(lab, 'error', 'not loaded');
      showOutput(lab, errorView('Could not start PostgreSQL in the browser: ' + (err && err.message ? err.message : err) +
        '. The rest of the page still works; use the Docker setup for the exercises.'));
      btn.disabled = false;
    });
  }

  function initPlaygrounds() {
    var all = document.querySelectorAll('.lab.pg');
    if (!all.length) return;
    if (!window.PG_MINI_SEED) {
      for (var k = 0; k < all.length; k++) setLabState(all[k], 'error', 'unavailable');
      return;
    }

    for (var i = 0; i < all.length; i++) {
      (function (lab) {
        var body = lab.querySelector('.lab-body');
        var ta = lab.querySelector('textarea.sql');
        var run = make('button', 'btn', 'Run');
        run.type = 'button'; run.setAttribute('data-run', '');
        var reset = make('button', 'btn ghost', 'Reset data');
        reset.type = 'button';
        var hint = make('span', 'note-lite', 'Ctrl/⌘ + Enter runs · Tab inserts spaces');
        hint.style.fontSize = '12px'; hint.style.color = 'var(--fg-subtle)';

        var row = make('div', 'btn-row');
        row.appendChild(run); row.appendChild(reset); row.appendChild(hint);
        body.insertBefore(row, body.querySelector('.pg-out'));

        var status = lab.querySelector('.lab-head .status');
        if (!status) {
          status = make('span', 'status', '');
          lab.querySelector('.lab-head').appendChild(status);
        }
        setLabState(lab, 'idle', 'not started');

        run.addEventListener('click', function () { runLab(lab); });
        reset.addEventListener('click', function () {
          if (!window.confirm('Reset the in-browser database to the starting data? Anything you created in the playground is lost.')) return;
          var old = dbPromise;
          dbPromise = null;
          if (old) old.then(function (db) { return db.close(); }).catch(function () {});
          labs.forEach(function (l) { setLabState(l, 'idle', 'reset'); });
          getDb().then(function () { labs.forEach(function (l) { setLabState(l, 'ready', 'ready'); }); })
                 .catch(function () {});
        });
        ta.addEventListener('keydown', function (ev) {
          if (ev.key === 'Enter' && (ev.metaKey || ev.ctrlKey)) { ev.preventDefault(); runLab(lab); }
          if (ev.key === 'Tab') {
            ev.preventDefault();
            var s = ta.selectionStart, e = ta.selectionEnd;
            ta.value = ta.value.slice(0, s) + '  ' + ta.value.slice(e);
            ta.selectionStart = ta.selectionEnd = s + 2;
          }
        });
        labs.push(lab);
      })(all[i]);
    }

    // Start the database as soon as the page is idle, so the first Run is quick.
    var start = function () {
      labs.forEach(function (l) { setLabState(l, 'loading', 'starting PostgreSQL'); });
      getDb().then(function () {
        labs.forEach(function (l) { if (l.getAttribute('data-state') !== 'error') setLabState(l, 'ready', 'ready'); });
      }).catch(function (err) {
        labs.forEach(function (l) { setLabState(l, 'error', 'not loaded'); });
      });
    };
    if ('requestIdleCallback' in window) requestIdleCallback(start); else setTimeout(start, 300);
  }

  /* ------------------------------------------------------------------ bootstrap */

  function boot() {
    initChrome();
    decorateCode();
    scrollspy(buildToc());
    initSearch();
    initTabs();
    initSteppers();
    initChecklists();
    initPlaygrounds();
    initProgress();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
