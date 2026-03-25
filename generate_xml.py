#!/usr/bin/env python3
"""
Generate resume.xml from src/assets/data.json.

Usage:
    python3 generate_xml.py
Output:
    src/assets/resume.xml  (references resume.xsl for browser rendering)
"""

import json
import xml.etree.ElementTree as ET
from pathlib import Path
from xml.dom import minidom

SCRIPT_DIR = Path(__file__).parent
ASSETS_DIR = SCRIPT_DIR / "src/assets"
DATA_FILE = ASSETS_DIR / "data.json"
OUTPUT_FILE = ASSETS_DIR / "resume.xml"
XSL_FILE = "resume.xsl"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def sub(parent, tag, text=None, **attrs):
    """Create a subelement with optional text and attributes."""
    el = ET.SubElement(parent, tag)
    if text is not None:
        el.text = str(text)
    for k, v in attrs.items():
        if v is not None:
            el.set(k, str(v))
    return el


def text_el(parent, tag, value):
    """Add a simple text child element only when value is non-empty."""
    if value:
        el = ET.SubElement(parent, tag)
        el.text = str(value)
        return el
    return None


def section_attrs(raw_name):
    """Return (clean_name, hidden) for a possibly '-' prefixed key."""
    hidden = raw_name.startswith("-") and not raw_name.startswith("--")
    return raw_name.lstrip("-"), hidden


# ---------------------------------------------------------------------------
# XML builders
# ---------------------------------------------------------------------------

def build_about(root, about):
    el = ET.SubElement(root, "about")
    for field in ("name", "blurb", "picture", "address", "email", "phone", "fax"):
        text_el(el, field, about.get(field))

    # Websites
    websites = about.get("websites", [])
    if websites:
        ws_el = ET.SubElement(el, "websites")
        for w in websites:
            sub(ws_el, "website", title=w.get("title"), url=w.get("url"))

    # Education
    education = about.get("education", [])
    if education:
        edu_el = ET.SubElement(el, "education")
        for e in education:
            sub(edu_el, "entry",
                title=e.get("title"), venue=e.get("venue"),
                startdate=e.get("startdate"), enddate=e.get("enddate"),
                abstract=e.get("abstract"))

    # Expertise / certifications
    expertise = about.get("expertise", [])
    if expertise:
        exp_el = ET.SubElement(el, "expertise")
        for e in expertise:
            sub(exp_el, "entry",
                title=e.get("title"), venue=e.get("venue"),
                startdate=e.get("startdate"), enddate=e.get("enddate"),
                url=e.get("url"), abstract=e.get("abstract"))

    # Work
    work = about.get("work", [])
    if work:
        work_el = ET.SubElement(el, "work")
        for w in work:
            sub(work_el, "entry",
                title=w.get("title"), venue=w.get("venue"),
                startdate=w.get("startdate"), enddate=w.get("enddate"),
                highlight=w.get("highlight"), abstract=w.get("abstract"))

    # Interests
    interests = about.get("interests", {})
    if interests:
        int_el = ET.SubElement(el, "interests")
        for cat_name, items in interests.items():
            cat_el = sub(int_el, "category", name=cat_name)
            for item in items:
                text_el(cat_el, "item", item)


def build_research(root, research):
    if not research:
        return
    res_el = ET.SubElement(root, "research")
    for raw_name, papers in research.items():
        clean, hidden = section_attrs(raw_name)
        sec = sub(res_el, "section", name=clean)
        if hidden:
            sec.set("hidden", "true")
        for p in papers:
            paper_el = sub(sec, "paper",
                           id=p.get("id") or None,
                           title=p.get("title"),
                           year=p.get("year"),
                           accepted=p.get("accepted"),
                           venue=p.get("venue"),
                           url=p.get("url") or None,
                           abstract=p.get("abstract") or None)
            authors = p.get("authors", [])
            if authors:
                authors_el = ET.SubElement(paper_el, "authors")
                for a in authors:
                    text_el(authors_el, "author", a)


def build_teaching(root, teaching):
    if not teaching:
        return
    teach_el = ET.SubElement(root, "teaching")
    courses = teaching.get("courses", [])
    if courses:
        courses_el = ET.SubElement(teach_el, "courses")
        for c in courses:
            sub(courses_el, "course",
                id=c.get("id"), title=c.get("title"),
                url=c.get("url") or None, abstract=c.get("abstract") or None)


def build_keyed_section(root, tag, data):
    if not data:
        return
    parent = ET.SubElement(root, tag)
    for raw_name, entries in data.items():
        clean, hidden = section_attrs(raw_name)
        sec = sub(parent, "section", name=clean)
        if hidden:
            sec.set("hidden", "true")
        for e in entries:
            entry = ET.SubElement(sec, "entry")
            for f in ("title", "role", "venue", "venueshort",
                      "startdate", "enddate", "year", "url", "abstract"):
                v = e.get(f)
                if v is not None:
                    entry.set(f, str(v))


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def build_xml(data):
    root = ET.Element("resume")
    build_about(root, data.get("about", {}))
    build_research(root, data.get("research", {}))
    build_teaching(root, data.get("teaching", {}))
    build_keyed_section(root, "service", data.get("service", {}))
    build_keyed_section(root, "invitations", data.get("invitations", {}))
    build_keyed_section(root, "recognition", data.get("recognition", {}))
    return root


def prettify(element):
    """Return indented XML string (no extra blank lines)."""
    rough = ET.tostring(element, encoding="unicode")
    dom = minidom.parseString(rough)
    pretty = dom.toprettyxml(indent="  ", encoding=None)
    # Remove the blank lines minidom adds
    lines = [line for line in pretty.splitlines() if line.strip()]
    return "\n".join(lines)


def main():
    with open(DATA_FILE, encoding="utf-8") as f:
        data = json.load(f)

    root = build_xml(data)
    xml_str = prettify(root)

    # Insert the XSL stylesheet PI right after the XML declaration
    lines = xml_str.split("\n")
    output_lines = []
    for line in lines:
        output_lines.append(line)
        # if line.startswith("<?xml "):
        #     output_lines.append(f'<?xml-stylesheet type="text/xsl" href="{XSL_FILE}"?>')

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines) + "\n")

    print(f"Generated: {OUTPUT_FILE}")
    print("Tip: serve with 'python3 -m http.server' then open http://localhost:8000/src/assets/resume.xml")


if __name__ == "__main__":
    main()
