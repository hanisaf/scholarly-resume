# ScholarlyResume

I wrote ScholarlyResume to address the problem of keeping track of my professional activities and produce them in different formats including a printable resume and a website.

I used to maintain my resume in a word document. Over the time, it grew larger and I ended up maintaining a master resume with all details and a shorter one for sharing. I also maintained a website that presented my resume in addition to extra information such as abstracts and links to documents. Maintaining the data in sync in between all of these formats became a hassle that I wanted to address.

ScholarlyResume stores all of this data in a master json file in assets/data.json. I chose the json format because it is human readable, editable, programmable and does not require a storage backend.

This data is formatted into a static website and a printable resume with an Angular app. You can use the app without changing the underlying codebase by referring to the gh-pages branch and editing assets/data.json and portrait.jpg files. That's said, if you want to change the default layout you will need to edit app.component.html and re-build the project. See below the Angular boilerplate documentation.

## Requirements

- Node.js 22.x
- npm (bundled with Node.js)
- Angular CLI (global install recommended)
- Git
- Python 3 (only needed when regenerating static resume files)

## Installation (Step by Step)

1. Clone the repository and move into the project folder.

```bash
git clone https://github.com/hanisaf/scholarly-resume.git
cd scholarly-resume
```

2. Verify Node.js and npm are installed.

```bash
node -v
npm -v
```

Expected: Node version should be 22.x.

3. Install Angular CLI globally.

```bash
npm install -g @angular/cli
```

4. Confirm Angular CLI is available.

```bash
ng version
```

5. Install project dependencies.

```bash
npm install
```

6. Start the development server.

```bash
ng serve
```

Then open http://localhost:4200/.

## Alpine Linux Notes (Optional)

If you are using Alpine Linux and need Node.js 22 specifically, the default Alpine repositories may provide newer major versions. In that case, install Node.js 22 manually from a compatible musl build, then run:

```bash
npm install -g @angular/cli
npm install
```

## Useful Project Commands

```bash
npm start              # Dev server at http://localhost:4200
npm run build          # Production build
npm run build:prerender # Production build + prerender
npm test               # Unit tests (Karma/Jasmine)
npm run serve:ssr      # Serve SSR build
npm run watch          # Dev build with file watching
```

## Data and Static Resume Generation

- Main resume data lives in `src/assets/data.json`.
- After editing data, regenerate the static HTML resume:

```bash
python3 generate_resume.py
```

This updates `src/assets/resume.html`.

## Development server

Run `ng serve` for a dev server. Navigate to `http://localhost:4200/`. The app will automatically reload if you change any of the source files.

## Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive|pipe|service|class|guard|interface|enum|module`.

## Build

Run `ng build` to build the project. The build artifacts will be stored in the `dist/` directory. Use the `-prod` flag for a production build.

## Running unit tests

Run `ng test` to execute the unit tests via [Karma](https://karma-runner.github.io).

## Running end-to-end tests

Run `ng e2e` to execute the end-to-end tests via [Protractor](http://www.protractortest.org/).

## Further help

To get more help on the Angular CLI use `ng help` or go check out the [Angular CLI README](https://github.com/angular/angular-cli/blob/master/README.md).
