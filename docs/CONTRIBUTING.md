# Contributing

This is a personal project. This document is primarily for my own reference and to demonstrate a professional workflow.

---

## Commit conventions

Commits follow [Conventional Commits](https://www.conventionalcommits.org/) and are enforced automatically via **Commitlint** + **Husky**.

### Using Commitizen (recommended)

Instead of `git commit`, use the interactive assistant:

```bash
pnpm commit
```

It will guide you through:

1. **Type** — what kind of change is this?
2. **Scope** — which part of the project does it affect?
3. **Description** — short summary in lowercase

Available scopes: `api` · `mobile` · `shared` · `db` · `auth` · `realtime` · `docs` · `ci`

### Manual commits

If you write commits manually, they must follow this format or Husky will reject them:

```
<type>(<scope>): <short description in lowercase>
```

**Types:**

| Type | Use for |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change with no behaviour change |
| `chore` | Tooling, dependencies, config |
| `test` | Adding or updating tests |

Examples:
```
feat(api): add post /characters endpoint
fix(mobile): correct hp display on character sheet
docs(db): document session_members table
refactor(api): extract character service from controller
chore: update pnpm lockfile
```

---

## Setup

After cloning, install dependencies to activate the git hooks:

```bash
pnpm install
```

Husky activates automatically via the `prepare` script. From that point on, every commit is validated before it's saved.

---

## Branch strategy

| Branch | Purpose |
|---|---|
| `main` | Stable, deployable state |
| `dev` | Active development |
| `feat/<name>` | Feature branches, merged into `dev` |
