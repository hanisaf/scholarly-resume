#!/usr/bin/env python3
"""
Generate a static resume.html from src/assets/data.json,
mirroring the Print CV tab in the Angular app.

Usage:
    python3 generate_resume.py
Output:
    src/assets/resume.html
"""

import json
import os
import html as html_module
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
DATA_FILE = SCRIPT_DIR / "src/assets/data.json"
OUTPUT_FILE = SCRIPT_DIR / "src/assets/resume.html"


# --- Pipe equivalents ---

def tenure(dates):
    """[startdate, enddate] -> 'start—end' or 'start—' or ''"""
    if len(dates) < 2:
        return ""
    start, end = dates[0], dates[1]
    if start and end:
        return f"{start}\u2014{end}"
    elif start:
        return f"{start}\u2014"
    elif end:
        return str(end)
    return ""


def highlight(items, filter_highlighted=True):
    """Filter items by highlight=='yes' (or the inverse)."""
    if not items:
        return []
    if filter_highlighted:
        return [i for i in items if i.get("highlight") == "yes"]
    else:
        return [i for i in items if i.get("highlight") != "yes"]


def keys(obj, showall=False):
    """Return list of {key, value} for object keys, skipping '-' prefixed (hidden) ones."""
    result = []
    for k, v in obj.items():
        if showall or not k.startswith("-"):
            if not k.startswith("--"):
                result.append({"key": k.lstrip("-"), "value": v})
    return result


def listformat(lst):
    """Join list with ', '"""
    if not lst:
        return ""
    return ", ".join(str(x) for x in lst)


def coauthors(authors, me=""):
    """'(joint work with X, Y & Z)' excluding self."""
    if not authors:
        return ""
    others = [a for a in authors if a != me]
    if not others:
        return ""
    if len(others) > 10:
        others = others[:10] + ["other authors"]
    joined = ", ".join(others)
    # Replace last comma with ' &'
    idx = joined.rfind(",")
    if idx != -1:
        joined = joined[:idx] + " &" + joined[idx+1:]
    return f"(joint work with {joined})"


def money(amount):
    """Format amount as '($X)'"""
    if amount:
        return f"(${amount})"
    return ""


def esc(text):
    """HTML-escape a value that might be str, int, float, or None."""
    if text is None:
        return ""
    return html_module.escape(str(text))


# --- HTML generation ---

def paper_li(paper, me=""):
    """Standard (non-APA) paper list item."""
    title = esc(paper.get("title", ""))
    venue = esc(paper.get("venue", ""))
    year = esc(paper.get("year", ""))
    co = esc(coauthors(paper.get("authors", []), me))
    url = paper.get("url", "")
    if url:
        title_html = f'<a href="{esc(url)}">{title}</a>'
    else:
        title_html = title
    parts = [title_html]
    if venue:
        parts.append(f"<b>{venue}</b>")
    if year:
        parts.append(year)
    line = ", ".join(parts)
    if co:
        line += f" <i>{co}</i>"
    return f"<li>{line}</li>"


def section_ol(items, me=""):
    if not items:
        return ""
    lis = "\n".join(paper_li(p, me) for p in items)
    return f"<ol>\n{lis}\n</ol>"


def generate(data):
    about = data.get("about", {})
    me = about.get("name", "")

    parts = []

    # Header
    name = esc(me)
    blurb = esc(about.get("blurb", ""))
    address = esc(about.get("address", ""))
    phone = esc(about.get("phone", ""))
    email = esc(about.get("email", ""))

    parts.append(f"<h1>{name}</h1>")
    if blurb:
        parts.append(f"<p>{blurb}</p>")
    contact_parts = []
    if address:
        contact_parts.append(address)
    if phone:
        contact_parts.append(f"&#9990;{phone}")
    if email:
        contact_parts.append(f"&#9993; {email}")
    if contact_parts:
        parts.append("<p>" + "&nbsp; ".join(contact_parts) + "</p>")

    # Academic Appointments
    work_highlighted = highlight(about.get("work", []), filter_highlighted=True)
    if work_highlighted:
        parts.append("<h2>Academic Appointments</h2>")
        rows = ""
        for v in work_highlighted:
            t = tenure([v.get("startdate"), v.get("enddate")])
            rows += f"<tr><td>{esc(t)}</td><td>{esc(v.get('title',''))}, {esc(v.get('venue',''))}</td></tr>\n"
        parts.append(f"<table>\n{rows}</table>")

    # Education
    education = about.get("education", [])
    if education:
        parts.append("<h2>Education</h2>")
        rows = ""
        for v in education:
            t = tenure([v.get("startdate"), v.get("enddate")])
            rows += f"<tr><td>{esc(t)}</td><td>{esc(v.get('title',''))}, {esc(v.get('venue',''))}</td></tr>\n"
        parts.append(f"<table>\n{rows}</table>")

    # Research and Teaching Interests
    interests = about.get("interests", {})
    interest_entries = keys(interests)
    if interest_entries:
        parts.append("<h2>Research and Teaching Interests</h2>")
        headers = "".join(f"<th>{esc(e['key'])}</th>" for e in interest_entries)
        max_len = max(len(e["value"]) for e in interest_entries) if interest_entries else 0
        rows = f"<tr>{headers}</tr>\n"
        for i in range(max_len):
            cells = ""
            for e in interest_entries:
                val = e["value"][i] if i < len(e["value"]) else ""
                cells += f"<td>{esc(val)}</td>"
            rows += f"<tr>{cells}</tr>\n"
        parts.append(f"<table>\n{rows}</table>")

    # Research sections
    research = data.get("research", {})

    def research_section(heading, key):
        items = research.get(key, [])
        if items:
            parts.append(f"<h2>{esc(heading)}</h2>")
            parts.append(section_ol(items, me))

    research_section("Journal Articles", "journal articles")
    research_section("Preprint", "Preprint")
    research_section("Conference Proceedings", "conference proceedings")
    research_section("Conference Presentations", "conference presentations")
    research_section("Conference Posters", "posters")
    research_section("Books", "books")
    research_section("Book Chapters", "book chapters")

    # Grants
    grants = research.get("grants", [])
    if grants:
        parts.append("<h2>Grants</h2>")
        lis = ""
        for g in grants:
            title = esc(g.get("title", ""))
            venue = esc(g.get("venue", ""))
            year = esc(g.get("year", ""))
            amt = esc(money(g.get("amount")))
            lis += f"<li>{title}, {venue}, {year} {amt}</li>\n"
        parts.append(f"<ol>\n{lis}</ol>")

    # Teaching
    courses = data.get("teaching", {}).get("courses", [])
    if courses:
        parts.append("<h2>Teaching</h2>")
        course_list = ", ".join(
            f"{esc(c.get('id',''))}: {esc(c.get('title',''))}" for c in courses
        )
        parts.append(f"<p>{course_list}</p>")

    # Professional Service
    service = data.get("service", {})
    service_entries = keys(service)
    if service_entries:
        parts.append("<h2>Professional Service</h2>")
        rows = ""
        for cat in service_entries:
            for s in cat["value"]:
                t = tenure([s.get("startdate"), s.get("enddate")])
                role = esc(s.get("role", ""))
                venue = esc(s.get("venue", ""))
                short = esc(s.get("venueshort", ""))
                rows += f"<tr><td>{esc(t)}</td><td>{role} at {venue} ({short})</td></tr>\n"
        parts.append(f"<table>\n{rows}</table>")

    # Awards
    awards = data.get("recognition", {}).get("awards", [])
    if awards:
        parts.append("<h2>Awards</h2>")
        lis = "".join(
            f"<li>{esc(v.get('title',''))}, {esc(v.get('venue',''))}, {esc(v.get('year',''))}</li>\n"
            for v in awards
        )
        parts.append(f"<ol>\n{lis}</ol>")

    # Invited Presentations
    talks = data.get("invitations", {}).get("talks", [])
    if talks:
        parts.append("<h2>Invited Presentations</h2>")
        lis = ""
        for v in talks:
            title = esc(v.get("title", ""))
            venue = esc(v.get("venue", ""))
            year = esc(v.get("year", ""))
            url = v.get("url", "")
            title_html = f'<a href="{esc(url)}">{title}</a>' if url else title
            lis += f"<li>{title_html}, {venue}, {year}</li>\n"
        parts.append(f"<ol>\n{lis}</ol>")

    # Invited Panels
    panels = data.get("invitations", {}).get("panels", [])
    if panels:
        parts.append("<h2>Invited Panels</h2>")
        lis = "".join(
            f"<li>{esc(v.get('title',''))}, {esc(v.get('venue',''))}, {esc(v.get('year',''))}</li>\n"
            for v in panels
        )
        parts.append(f"<ol>\n{lis}</ol>")

    # Press Coverage
    press = data.get("recognition", {}).get("press", [])
    if press:
        parts.append("<h2>Press Coverage</h2>")
        lis = ""
        for v in press:
            title = esc(v.get("title", ""))
            venue = esc(v.get("venue", ""))
            year = esc(v.get("year", ""))
            url = v.get("url", "")
            title_html = f'<a href="{esc(url)}">{title}</a>' if url else title
            lis += f"<li>{title_html}, {venue}, {year}</li>\n"
        parts.append(f"<ol>\n{lis}</ol>")

    # Work Experience (non-highlighted)
    work_other = highlight(about.get("work", []), filter_highlighted=False)
    if work_other:
        parts.append("<h2>Work Experience</h2>")
        rows = ""
        for v in work_other:
            t = tenure([v.get("startdate"), v.get("enddate")])
            rows += f"<tr><td>{esc(t)}</td><td>{esc(v.get('title',''))}, {esc(v.get('venue',''))}</td></tr>\n"
        parts.append(f"<table>\n{rows}</table>")

    return "\n".join(parts)


def main():
    with open(DATA_FILE, encoding="utf-8") as f:
        data = json.load(f)

    body = generate(data)
    name = html_module.escape(data.get("about", {}).get("name", "Resume"))

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Resume of {name}</title>
  <style>
    body {{
      font-family: "Times New Roman", Times, serif;
      max-width: 900px;
      margin: 0 auto;
      padding: 1em 2em;
      line-height: 1.5;
    }}
    h1 {{ margin-bottom: 0.2em; }}
    h2 {{ margin-top: 1.4em; border-bottom: 1px solid #ccc; padding-bottom: 0.2em; }}
    table {{ border-collapse: collapse; width: 100%; margin-bottom: 0.5em; }}
    td {{ vertical-align: top; padding: 0.15em 0.5em 0.15em 0; }}
    td:first-child {{ white-space: nowrap; padding-right: 1em; }}
    ol {{ list-style-position: outside; padding-left: 1.5em; margin: 0.3em 0; }}
    li {{ margin-bottom: 0.3em; }}
    a {{ color: #1a0dab; }}
  </style>
</head>
<body>
{body}
</body>
</html>
"""

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(html)

    print(f"Generated: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
