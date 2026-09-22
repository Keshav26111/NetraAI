# NetraAI: minimal project tasks (Phase 0).
# Requires only GNU make, git and a POSIX shell. No target installs anything.

.DEFAULT_GOAL := help
.PHONY: help check check-structure check-ignore

# Files and folders that must exist.
REQUIRED_PATHS := \
  README.md .gitignore .env.example Makefile \
  docs/architecture.md docs/api.md docs/model-card.md docs/data-card.md \
  docs/threat-model.md docs/demo-script.md \
  apps/api apps/web ml/src/netra_ml models/README.md infra tests/e2e .github/workflows

# Sample paths that must be git-ignored (secrets, datasets, model artifacts, local env).
MUST_IGNORE := \
  .env .env.local data/images/sample.jpg models/sample.pt ml/runs/sample .venv/sample node_modules/sample

# Paths that must NOT be git-ignored.
MUST_TRACK := \
  .env.example models/README.md ml/src/netra_ml/models ml/src/netra_ml/data

help:
	@echo "NetraAI make targets:"
	@echo "  make check            run all foundation checks"
	@echo "  make check-structure  verify required folders and docs exist"
	@echo "  make check-ignore     verify secrets, data and model artifacts are git-ignored"
	@echo "Application, ML and test targets arrive in later phases."

check: check-structure check-ignore

check-structure:
	@fail=0; \
	for p in $(REQUIRED_PATHS); do \
	  if [ ! -e "$$p" ]; then echo "MISSING: $$p"; fail=1; fi; \
	done; \
	if [ $$fail -ne 0 ]; then exit 1; fi; \
	echo "OK: required structure present"

check-ignore:
	@fail=0; \
	for p in $(MUST_IGNORE); do \
	  if ! git check-ignore -q "$$p"; then echo "NOT IGNORED (should be): $$p"; fail=1; fi; \
	done; \
	for p in $(MUST_TRACK); do \
	  if git check-ignore -q "$$p"; then echo "IGNORED (should be tracked): $$p"; fail=1; fi; \
	done; \
	if [ $$fail -ne 0 ]; then exit 1; fi; \
	echo "OK: ignore rules behave as expected"
