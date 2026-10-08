# HoloRuminant tools

[![Check site](https://github.com/HoloRuminant/holoruminant.github.io/actions/workflows/check.yml/badge.svg)](https://github.com/HoloRuminant/holoruminant.github.io/actions/workflows/check.yml)
[![Check links](https://github.com/HoloRuminant/holoruminant.github.io/actions/workflows/links.yml/badge.svg)](https://github.com/HoloRuminant/holoruminant.github.io/actions/workflows/links.yml)

Source for **<https://holoruminant.github.io>**, the catalogue of open-access bioinformatic tools and workflows developed during the [HoloRuminant project](https://holoruminant.eu) (EU Horizon 2020, grant agreement N° 101000213).

The site is generated from two plain-text data files. **You do not need to touch any HTML to add a tool or a contributor.**

- [Add or update a tool](#add-or-update-a-tool)
- [Add yourself as a contributor](#add-yourself-as-a-contributor)
- [Field guide: tools](#field-guide-tools)
- [Field guide: contributors](#field-guide-contributors)
- [Checks](#checks)
- [Build the site locally](#build-the-site-locally)
- [Repository layout](#repository-layout)
- [Contact, licence and acknowledgements](#contact-licence-and-acknowledgements)

## How to contribute

Members of the HoloRuminant GitHub organisation can edit files directly on GitHub (open the file, click the pencil icon, then commit). Everyone else should fork the repository, make the change and open a pull request. The pull request template lists what to check.

Every push and pull request runs an automatic check. If it fails, the error message names the entry and field to fix.

### Add or update a tool

1. Open [`_data/tools.yml`](_data/tools.yml).
2. Copy an existing entry and paste it at the end of the file.
3. Edit the values. Keep the indentation exactly as it is: two spaces before each field, four before each paper item and six before paper fields.
4. Leave optional fields blank if you have no value. Do not delete them.
5. Commit, or open a pull request.

A minimal entry:

```yaml
- name: MyTool
  description: One or two sentences on what it does and who it is for.
  type: Tool
  status: available
  maintainer:
  repo: https://github.com/your-account/mytool
  app_url:
  updated: 2026-10-01
  papers:
    - label: Smith et al. 2026
      kind: publication
      doi: 10.1234/example.5678
      citation: "Smith, A., & Jones, B. (2026). Title of the paper. Journal, 1(2). https://doi.org/10.1234/example.5678"
```

**Getting a citation.** You can get a formatted citation for any DOI from the DOI registry:

```bash
curl -sL -H "Accept: text/x-bibliography; style=apa; locale=en-GB" https://doi.org/10.1234/example.5678
```

Paste the result into `citation`, inside double quotes. Remove any HTML tags (such as `<i>`) from the output.

### Add yourself as a contributor

1. Open [`_data/contributors.yml`](_data/contributors.yml).
2. Copy the existing entry and fill in your details.
3. Under `tools`, list the tools you worked on, spelled exactly as their `name` in `tools.yml`. Your name then appears as "Developed by" on those tool cards.
4. Optional photo: add a square image (at least 144 × 144 pixels, JPEG or PNG) to `assets/img/contributors/` and put its file name in `photo`. Without a photo, your initials are shown.

```yaml
- name: Ada Lovelace
  institute: Norwegian University of Life Sciences
  role: Postdoctoral researcher
  github: adalovelace
  orcid: 0000-0002-1825-0097
  website: https://example.org
  photo: ada-lovelace.jpg
  tools:
    - CompareM2
```

## Field guide: tools

| Field | Required | Meaning |
|---|---|---|
| `name` | yes | Display name. Must be unique. |
| `description` | yes | One or two sentences |
| `type` | yes | `Tool`, `Workflow`, `Pipeline`, `R package` or `Web app` |
| `status` | yes | `available` or `restricted` |
| `maintainer` | no | Contact person, shown as "Contact" |
| `repo` | no | Source repository URL (GitHub or GitLab) |
| `app_url` | no | Link to a hosted web app |
| `updated` | no | Date of the latest release or code change, as `YYYY-MM-DD`. Used for "Recently updated" sorting. |
| `papers` | no | List of papers, preprints, software records or notes (see below) |

Each item in `papers`:

| Field | Required | Meaning |
|---|---|---|
| `label` | yes | Short citation, for example `Kobel et al. 2025` |
| `kind` | yes | `publication`, `preprint`, `software` or `in-preparation` |
| `doi` | no | DOI without the `https://doi.org/` prefix, for example `10.1093/bioinformatics/btaf517` |
| `url` | no | Link used only when there is no DOI |
| `citation` | no | Full formatted citation, shown under "How to cite" with a copy button |

How entries are displayed:

- Buttons and links appear only when their value is present.
- A paper links to `https://doi.org/<doi>` when `doi` is set, otherwise to `url`. An `in-preparation` item is shown as plain text.
- A tool with `status: restricted` shows a "Coming soon" label and no repository or app link. Do not add a repository URL for a restricted tool until the team confirms its release.

## Field guide: contributors

| Field | Required | Meaning |
|---|---|---|
| `name` | yes | Full name. Must be unique. |
| `institute` | yes | Institution |
| `role` | no | Job title or role in the project |
| `github` | no | GitHub username only, not the full URL |
| `orcid` | no | ORCID iD only, for example `0000-0002-1825-0097` |
| `website` | no | Personal or group web page |
| `photo` | no | File name of an image in `assets/img/contributors/` |
| `tools` | no | List of tool names from `tools.yml` |

## Checks

| Check | When it runs | What it does |
|---|---|---|
| **Check site** (`.github/workflows/check.yml`) | Every push and pull request | Validates both data files, builds the site, and confirms there are no empty links and that every page carries the funding statement |
| **Check links** (`.github/workflows/links.yml`) | Every Monday, or on demand from the Actions tab | Requests every URL and DOI in the data files and fails if any is broken. GitHub emails the repository admins when it fails. |

Run them yourself:

```bash
ruby scripts/validate_data.rb   # schema check, no network needed
ruby scripts/check_links.rb     # link and DOI check, needs network
```

Some publishers (for example Oxford University Press) block automated requests. The link check reports these as `warn` rather than failing. Check them by hand in a browser.

## Build the site locally

The site uses the [`github-pages`](https://github.com/github/pages-gem) gem, so a local build matches what GitHub Pages publishes. You need Ruby 3.x and Bundler.

```bash
bundle install
bundle exec jekyll serve
```

Then open <http://localhost:4000>. Ruby gem versions are pinned in `Gemfile.lock`.

GitHub Pages rebuilds and publishes the site automatically a minute or two after each push to `main`.

## Repository layout

```text
_data/tools.yml           Tool entries (edit this)
_data/contributors.yml    Contributor entries (edit this)
_layouts/default.html     Page layout: header, navigation, footer
index.html                Tools page
contributors.html         Contributors page
about.html                About page
assets/css/               Styles
assets/js/site.js         Search, filter, sort and copy-citation (no external requests)
assets/img/               Logo, icons, social preview image, contributor photos
scripts/                  Data validation and link checking
.github/                  Workflows and pull request template
```

Design rules:

- British English in all visible text and documentation.
- No analytics, cookies, external fonts or third-party scripts.
- Tool and contributor information lives only in the data files, never hard-coded in HTML.
- Do not invent DOIs, URLs, authors or maintainers. Leave fields blank if you are unsure.
- The footer on every page carries the Horizon 2020 funding statement.

## Contact, licence and acknowledgements

**Contact:** Chris Creevey, Queen's University Belfast (<chris.creevey@qub.ac.uk>).

**Licence:** the site code is released under the [MIT licence](LICENSE). The HoloRuminant logo and icon belong to the HoloRuminant project and are not covered by that licence. Tools listed on the site have their own licences; see each tool's repository.

**Acknowledgements:** the structure of this site follows the Food Co-Centre tools site ([foodcocentre/foodcocentre.github.io](https://github.com/foodcocentre/foodcocentre.github.io)), reused with the permission of its author, James Gillespie (Queen's University Belfast). The list of tools was first compiled for HoloRuminant Deliverable D1.4, "HoloR-tools".

This project has received funding from the European Union's Horizon 2020 research and innovation programme under grant agreement N° 101000213.
