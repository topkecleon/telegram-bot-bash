#!/usr/bin/env bash
#### $$VERSION$$ 0.70-dev-15-g074a103

# magic to ensure that we're always inside the root of our application,
# no matter from which directory we'll run script
GIT_DIR=$(git rev-parse --git-dir)
cd "$GIT_DIR/.." || exit 1

dev/hooks/pre-commit.sh

