# learn

Minimal repo sink for `learn` skill outputs.

## Usage

Run from this repo:

```bash
bash scripts/learn_to_repo.sh "<url-or-file>"
```

What it does:

1. Calls local `learn` skill with `--save-file`.
2. Writes one markdown report into `reports/`.
3. Commits and pushes to this repo.
4. Prints the report URL.
