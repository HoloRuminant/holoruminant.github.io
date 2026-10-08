# HoloRuminant tools

Source for <https://holoruminant.github.io>, a list of the open-access bioinformatic tools and workflows developed by the HoloRuminant team. The content comes from Deliverable D1.4, "HoloR-tools" (H2020 grant agreement N° 101000213).

## Add a tool

1. Open `_data/tools.yml`.
2. Copy an existing entry and paste it at the end of the file.
3. Edit the values. Keep the indentation exactly as it is (two spaces for fields, four for paper items).
4. Leave optional fields blank if you do not have a value. Do not delete them.
5. Commit the change. If you are not a member of the Holoruminant organisation, fork this repository and open a pull request instead.

A check runs on every push and pull request. It fails if `tools.yml` is not valid YAML or a required field is missing or invalid.

## Field guide

| Field | Required | Meaning |
|---|---|---|
| `name` | yes | Display name |
| `description` | yes | One or two sentences |
| `type` | yes | `Tool`, `Workflow`, `Pipeline`, `R package` or `Web app` |
| `status` | yes | `available` or `restricted` |
| `maintainer` | no | Contact person. Blank if unknown. |
| `repo` | no | Source repository URL (GitHub or GitLab) |
| `app_url` | no | Link to a hosted app |
| `papers` | no | List of papers, preprints, software records or notes |

Each item in `papers`:

| Field | Required | Meaning |
|---|---|---|
| `label` | yes | Short citation, for example `Kobel et al. 2025` |
| `kind` | yes | `publication`, `preprint`, `software` or `in-preparation` |
| `doi` | no | DOI without the `https://doi.org/` prefix |
| `url` | no | Used when no DOI exists |

How entries are displayed:

- Buttons and links appear only when their value is present.
- A paper links to `https://doi.org/<doi>` when `doi` is set, otherwise to `url`. An `in-preparation` item is shown as plain text.
- A tool with `status: restricted` shows a "Coming soon" label and no repository or app link. Do not add a repository URL for a restricted tool until the team confirms its release.

## Verification

Before a release, run:

```bash
ruby scripts/validate_tools.rb      # schema check
bundle exec jekyll build            # build; fix any warnings
```

Then check that every URL in `tools.yml` responds (`curl -sI <url>`) and that each DOI resolves at `https://doi.org/<doi>` to the work named in its `label`.

## Build locally

The site uses the `github-pages` gem, which matches the GitHub Pages build. It needs Ruby 3.x.

```bash
bundle install
bundle exec jekyll serve
```

Ruby and gem versions are recorded in `Gemfile` and `Gemfile.lock`.

## Contact

Chris Creevey, Queen's University Belfast (chris.creevey@qub.ac.uk).

## Licence and acknowledgements

The site code is released under the MIT licence (see `LICENSE`). The logo is the property of the HoloRuminant project and is not covered by that licence.

The structure of this site follows the Food Co-Centre tools site (<https://github.com/foodcocentre/foodcocentre.github.io>), reused with the permission of its author, James Gillespie (Queen's University Belfast).

This project has received funding from the European Union's Horizon 2020 research and innovation programme under grant agreement N° 101000213.
