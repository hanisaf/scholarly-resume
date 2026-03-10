# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Scripts

```bash
python3 generate_resume.py   # Regenerate src/assets/resume.html from data.json
```

`generate_resume.py` reads `src/assets/data.json` and writes a static `src/assets/resume.html` (the Print CV content, for search engine indexing). Re-run it after editing `data.json`.

## Commands

```bash
npm start              # Dev server at http://localhost:4200
npm run build          # Production build
npm run build:prerender # Production build + prerender (for static hosting)
npm test               # Unit tests via Karma/Jasmine
npm run serve:ssr      # Serve with SSR: node dist/scholarly-resume/server/server.mjs
npm run watch          # Dev build with file watching
./publish.sh           # Deploy (gh-pages)
```

## Architecture

**ScholarlyResume** is an Angular 21 SPA with SSR support. The core idea: all resume/CV data lives in a single JSON file (`src/assets/data.json`), which Angular renders into both a web UI and a printable CV from the same source.

**Data flow**: `AppComponent` fetches `data.json` via `HttpClient` → stores in component state → template renders it via `*ngFor`/`*ngIf` + custom pipes.

**Key files**:
- `src/assets/data.json` — master data file; edit this to update resume content without touching code
- `src/app/app.component.ts` — root component; loads data, reads query params, handles print popup
- `src/app/app.component.html` — large template with Material tabs (About, Research, Teaching, Service, Talks, Recognition, Print CV)
- `src/app/pipes.ts` — 8 custom pipes: `APAFormatPipe`, `CoAuthorsPipe`, `KeysPipe`, `LengthPipe`, `TenurePipe`, `HighlightPipe`, `ListFormat`, `MoneyPipe`
- `server.ts` — Express SSR server (port 4000, configurable via `PORT` env var)

**Query parameters** (URL feature toggles):
- `?showall=true` — show hidden items (keys prefixed with `-` in data.json)
- `?accepted=true` — show paper acceptance dates
- `?apaformat=true` — use APA citation format

**data.json structure**:
```json
{
  "about": { "name", "blurb", "contact", "websites", "education", "expertise", "work" },
  "research": { "journal articles", "Preprint", "conference proceedings", ... },
  "teaching": { "courses" },
  "service": { ... },
  "invitations": { "talks", "panels" },
  "recognition": { "awards", "press" }
}
```
Items with keys prefixed by `-` are hidden unless `?showall=true`.

**SSR**: `app.config.ts` (client) and `app.config.server.ts` (server) both bootstrap `AppComponent`; the Express server uses Angular's `CommonEngine`.

**Styling**: Angular Material Indigo-Pink theme + responsive CSS with breakpoints at 768px, 599px, 400px.
