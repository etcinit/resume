# resume

A slightly-overkill way to generate a resume in multiple formats.

### Features

- Supports multiple formats via Pandoc: Markdown, HTML, Asciidoc, JSON.
- HTML version can be styled using CSS and a template.
- Each Pandoc writer is executed concurrently.
- Uses INotify to watch for changes and rebuild.

### Getting started

#### Stack + Shake

- Install `stack`.
- Run `./build.hs generate`.
- Built files will be available on `/build`.

#### Manual

- Clone the repository and `cd` into it.
- Obtain a recent copy of `stack`.
- Run `stack setup` and `stack build --copy-bins`.
- Run `~/.local/bin/resume` from the project root.
- Built files will be available on `/build`.

### No PDF?

A PDF version can be generated by opening the HTML in a browser and printing
it into a PDF, which most modern browsers support.

### Public version

The public version of this repository is assembled using the
`./build.hs publish`. A bare git repository is initialized with a single
commit and pushed to GitHub. This ensures that only the most recent version is
available.

### PGP

Commits on this repository are signed with the following PGP key:

```
80A1-5003-7BBF-35DD-371D-6CB3-C82C-CC4C-5CEA-CF85
```

For proofs that this is my actual public PGP key, head to my Keybase profile:
https://keybase.io/etcinit

You may verify the authenticity of each commit using `git verify-commit`.
Example: Verifying the latest commit:

```sh
git verify-commit HEAD
```