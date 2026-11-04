#!/usr/bin/env python3
"""Assemble the site from tools/outline.py and the fragments in _src/.

    python3 tools/build_docs.py          # build everything
    python3 tools/build_docs.py --check  # build to memory, fail if committed pages differ
    python3 tools/build_docs.py --allow-missing   # while writing: skip fragments not yet written

Layout produced (all committed; the published site has no build step):

    index.html                      <- _src/index.html            (the one entry point)
    start/<slug>.html               <- _src/start/<slug>.html
    lessons/<NN-slug>.html          <- _src/lessons/<NN-slug>.html
    appendices/<slug>.html          <- _src/appendices/<slug>.html
    assets/js/search-index.js       generated

A fragment is just the page body. The builder supplies <head>, the topbar, the
sidebar, the eyebrow/<h1> (lessons, annexes), the pager and the 'mark complete'
footer, all from the outline. Two placeholders pull exercise files into a page so
that the repository files stay the single source of truth:

    {{stub 03 1}}       the contents of exercises/03/1.sql    as a code block
    {{solution 03 1}}   the contents of solutions/03/1.sql    in a <details>

The home page fragment may contain <!--LESSON_LIST--> which expands to the
generated part-by-part lesson list.
"""

from __future__ import annotations

import html
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
import outline as O  # noqa: E402

SITE = "Learning PostgreSQL"
TAG_RE = re.compile(r"<[^>]+>")
H_RE = re.compile(r'<h([23])\s+id="([^"]+)"[^>]*>(.*?)</h\1>', re.S)
LEDE_RE = re.compile(r'<p class="lede">(.*?)</p>', re.S)
STUB_RE = re.compile(r"\{\{\s*stub\s+(\d+)\s+(\d+)\s*\}\}")
SOL_RE = re.compile(r"\{\{\s*solution\s+(\d+)\s+(\d+)\s*\}\}")


def text_of(fragment: str) -> str:
    return re.sub(r"\s+", " ", html.unescape(TAG_RE.sub(" ", fragment))).strip()


def esc(s: str) -> str:
    return html.escape(s, quote=False)


# --------------------------------------------------------------------- pages

class Page:
    def __init__(self, kind, slug, title, desc, tags, out, src, group, num=None):
        self.kind, self.slug, self.title, self.desc, self.tags = kind, slug, title, desc, tags
        self.out, self.src, self.group, self.num = out, src, group, num

    @property
    def depth_prefix(self) -> str:
        return "../" * self.out.count("/")


def has_playground(src: str) -> bool:
    f = ROOT / src
    return f.exists() and 'class="lab pg"' in f.read_text()


def derive_tags(tags: list[str], src: str) -> list[str]:
    """'pgl' (live playground) is derived from the page itself, so it cannot drift."""
    base = [t for t in tags if t != "pgl"]
    return base + (["pgl"] if has_playground(src) else [])


def all_pages() -> list[Page]:
    pages: list[Page] = [Page("home", "index", "Learning PostgreSQL", "", [], "index.html", "_src/index.html", "Home")]
    for slug, title, desc, tags in O.START:
        pages.append(Page("start", slug, title, desc, derive_tags(tags, f"_src/start/{slug}.html"), f"start/{slug}.html", f"_src/start/{slug}.html", "Start here"))
    for part, _blurb, lessons in O.PARTS:
        for slug, title, desc, tags in lessons:
            pages.append(Page("lesson", slug, title, desc, derive_tags(tags, f"_src/lessons/{slug}.html"), f"lessons/{slug}.html",
                              f"_src/lessons/{slug}.html", part, O.lesson_number(slug)))
    for slug, title, desc, tags in O.ANNEXES:
        pages.append(Page("annex", slug, title, desc, derive_tags(tags, f"_src/appendices/{slug}.html"), f"appendices/{slug}.html",
                          f"_src/appendices/{slug}.html", "Annexes"))
    return pages


# ------------------------------------------------------------------- chrome

def href(page: Page, target: Page) -> str:
    return page.depth_prefix + target.out


def sidebar(pages: list[Page], here: Page) -> str:
    out = ['<nav class="sidebar" id="sidebar" aria-label="Course contents">']
    group = None
    open_ol = False
    for p in pages:
        if p.kind == "home":
            continue
        if p.group != group:
            if open_ol:
                out.append("  </ol>")
            group = p.group
            out.append(f"  <h4>{esc(group)}</h4>\n  <ol>")
            open_ol = True
        label = p.title
        num_html = ""
        if p.kind == "lesson":
            num_html = f'<span class="n">{p.num}</span>'
        elif p.kind == "annex":
            m = re.match(r"^([A-Z]\d?)\.\s+(.*)$", p.title)
            if m:
                num_html, label = f'<span class="n">{m.group(1)}</span>', m.group(2)
        else:
            num_html = '<span class="n">00</span>'
        out.append(f'    <li><a href="{href(here, p)}" data-page="{p.slug}">{num_html}<span>{esc(label)}</span></a></li>')
    if open_ol:
        out.append("  </ol>")
    out.append("</nav>")
    return "\n".join(out)


def topbar(here: Page) -> str:
    root = here.depth_prefix + "index.html"
    return f"""<header class="topbar">
  <button class="icon-btn menu-btn" type="button" aria-label="Toggle navigation" aria-expanded="false" aria-controls="sidebar">&#9776;</button>
  <a class="brand" href="{root}"><span class="mark pgm">PG</span> {SITE} <span class="sub">PostgreSQL 18</span></a>
  <span class="spacer"></span>
  <div class="search" role="search">
    <span class="glyph" aria-hidden="true">&#9906;</span>
    <input type="search" placeholder="Search the course&#8230;" aria-label="Search the course" autocomplete="off" spellcheck="false">
    <kbd>/</kbd>
    <div class="search-results" role="listbox"></div>
  </div>
  <nav class="topbar-links">
    <a class="hide-sm" href="{here.depth_prefix}appendices/d-glossary.html">Glossary</a>
    <a class="hide-sm" href="{here.depth_prefix}appendices/b-psql.html">psql</a>
  </nav>
  <button class="icon-btn theme-btn" type="button" aria-label="Toggle theme">&#9790;</button>
</header>
<div class="scrim"></div>"""


def pager(pages: list[Page], i: int) -> str:
    here = pages[i]
    parts = []
    for direction, label, j in (("prev", "Previous", i - 1), ("next", "Next", i + 1)):
        if j < 0 or j >= len(pages):
            continue
        t = pages[j]
        name = t.title if t.kind != "lesson" else f"{t.num} · {t.title}"
        if t.kind == "home":
            name = "Course home"
        parts.append(f'<a class="{direction}" href="{href(here, t)}"><span class="dir">{label}</span><span class="lbl">{esc(name)}</span></a>')
    if len(parts) == 1 and parts[0].startswith('<a class="next"'):
        parts.insert(0, '<span style="flex:1 1 0"></span>')
    return '<nav class="pager">' + "".join(parts) + "</nav>" if parts else ""


def expand_files(body: str, page: Page) -> str:
    def read(kind: str, lesson: str, n: str) -> str:
        p = ROOT / ("exercises" if kind == "stub" else "solutions") / lesson / f"{n}.sql"
        if not p.exists():
            sys.exit(f"{page.src}: {{{{{kind} {lesson} {n}}}}} -> {p.relative_to(ROOT)} does not exist")
        return p.read_text().rstrip("\n")

    def stub(m):
        txt = read("stub", m[1], m[2])
        return (f'<figure class="code" data-lang="sql">\n  <figcaption><span class="path">exercises/{m[1]}/{m[2]}.sql'
                f'</span><span class="grow"></span><span class="lang">your starting file</span></figcaption>\n'
                f'<pre><code>{esc(txt)}</code></pre>\n</figure>')

    def sol(m):
        txt = read("solution", m[1], m[2])
        return (f'<details class="solution"><summary>Show a model solution for exercise {int(m[2])} (try first!)</summary>\n'
                f'<figure class="code" data-lang="sql">\n  <figcaption><span class="path">solutions/{m[1]}/{m[2]}.sql'
                f'</span><span class="grow"></span><span class="lang">sql</span></figcaption>\n'
                f'<pre><code>{esc(txt)}</code></pre>\n</figure>\n</details>')

    return SOL_RE.sub(sol, STUB_RE.sub(stub, body))


def lesson_list(pages: list[Page]) -> str:
    out = []
    by_slug = {p.slug: p for p in pages}
    for part, blurb, lessons in O.PARTS:
        out.append(f'<section class="path-part">\n<h2 id="{re.sub(r"[^a-z0-9]+", "-", part.lower().split("—")[0]).strip("-")}">{esc(part)}</h2>\n<p class="blurb">{esc(blurb)}</p>\n<ul class="lesson-list">')
        for slug, title, desc, _outline_tags in lessons:
            tags = by_slug[slug].tags
            tg = ""
            if "ex" in tags:
                tg += '<span class="tag ex">Docker exercises</span>'
            if "pgl" in tags:
                tg += '<span class="tag pgl">live playground</span>'
            out.append(f'  <li><a href="lessons/{slug}.html" data-page="{slug}"><span class="n">{O.lesson_number(slug)}</span>'
                       f'<span class="t">{esc(title)}</span><span class="d">{esc(desc)}</span><span class="tags">{tg}</span></a></li>')
        out.append("</ul>\n</section>")
    return "\n".join(out)


ALLOW_MISSING = "--allow-missing" in sys.argv[1:]


def render(pages: list[Page], i: int) -> str:
    p = pages[i]
    src = ROOT / p.src
    if not src.exists():
        if not ALLOW_MISSING:
            sys.exit(f"missing fragment {p.src} (listed in tools/outline.py)")
        print(f"  (skipped: {p.src} not written yet)", file=sys.stderr)
        return ""
    body = expand_files(src.read_text().strip(), p)
    body = body.replace("<!--LESSON_LIST-->", lesson_list(pages))

    head = ""
    if p.kind == "lesson":
        part_no = [x[0] for x in O.PARTS].index(p.group) + 1
        tags = ['<span class="tag">lesson ' + p.num + "</span>"]
        if "ex" in p.tags:
            tags.append('<span class="tag">Docker exercises</span>')
        if "pgl" in p.tags:
            tags.append('<span class="tag">live playground</span>')
        head = (f'<p class="eyebrow">Lesson {p.num} &middot; {esc(p.group.split(" — ")[0])}</p>\n<h1>{esc(p.title)}</h1>\n'
                f'<div class="meta-row">{"".join(tags)}</div>\n')
    elif p.kind == "annex":
        head = f'<p class="eyebrow">Annex</p>\n<h1>{esc(p.title)}</h1>\n'
    elif p.kind == "start":
        head = f'<p class="eyebrow">Start here</p>\n<h1>{esc(p.title)}</h1>\n'

    foot = ""
    if p.kind == "lesson":
        foot = f'<div class="lesson-done" data-lesson="{p.slug}"></div>\n'

    title_tag = SITE if p.kind == "home" else f"{p.title} &mdash; {SITE}"
    desc = p.desc or "A hands-on PostgreSQL 18 course: interactive pages, a live in-browser playground and exercises that run on a local Docker database."
    pre = p.depth_prefix
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title_tag if p.kind == "home" else html.escape(p.title) + " &mdash; " + SITE}</title>
<meta name="description" content="{html.escape(desc)}">
<link rel="stylesheet" href="{pre}assets/css/course.css">
</head>
<body data-root="{pre}" data-page="{p.slug}">
<a class="skip-link" href="#content">Skip to content</a>
{topbar(p)}
<div class="shell">
{sidebar(pages, p)}
<div class="main">
<main class="content" id="content">
{head}{body}
{foot}{pager(pages, i)}
</main>
<aside class="toc" aria-label="On this page"></aside>
</div>
</div>
<script src="{pre}assets/js/search-index.js"></script>
<script src="{pre}assets/js/mini-seed.js"></script>
<script src="{pre}assets/js/course.js"></script>
</body>
</html>
"""


def index_entries(p: Page, body: str) -> list[dict]:
    url = p.out
    lede = LEDE_RE.search(body)
    entries = [{"t": p.title, "s": p.title, "u": url, "b": text_of(lede.group(1))[:300] if lede else p.desc}]
    for _lvl, anchor, heading in H_RE.findall(body):
        entries.append({"t": p.title, "s": text_of(heading), "u": f"{url}#{anchor}", "b": ""})
    return entries


def build(check: bool) -> int:
    pages = all_pages()
    outputs: dict[Path, str] = {}
    search: list[dict] = []
    for i, p in enumerate(pages):
        if not (ROOT / p.src).exists() and ALLOW_MISSING:
            continue
        outputs[ROOT / p.out] = render(pages, i)
        search.extend(index_entries(p, (ROOT / p.src).read_text()))
    payload = json.dumps(search, separators=(",", ":"), ensure_ascii=False)
    outputs[ROOT / "assets/js/search-index.js"] = (
        "/* Generated by tools/build_docs.py -- do not edit. */\n"
        f"window.DOCS_SEARCH_INDEX = {payload};\n")

    stale = [str(f.relative_to(ROOT)) for f, text in outputs.items() if not f.exists() or f.read_text() != text]
    if check:
        if stale:
            print("generated files are out of date:\n  " + "\n  ".join(stale), file=sys.stderr)
            print("run: python3 tools/build_docs.py   and commit the result", file=sys.stderr)
            return 1
        print(f"all {len(outputs)} generated files are up to date")
        return 0
    for f, text in outputs.items():
        f.parent.mkdir(parents=True, exist_ok=True)
        f.write_text(text)
    print(f"built {len(pages)} pages + search index ({len(search)} entries)")
    return 0


if __name__ == "__main__":
    sys.exit(build("--check" in sys.argv[1:]))
