#!/usr/bin/env bash
#### $$VERSION$$ 0.70-dev-20-g753f1b3

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

set -e

# source bashbot.sh functionw
cd "${TESTDIR}" || exit 1
# shellcheck source=./bashbot.sh
source "${TESTDIR}/bashbot.sh" source
cd "${DIRME}" || exit 1

echo "${SUCCESS}"
