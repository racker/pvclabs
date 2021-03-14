#!/usr/bin/env bash
set +x
# This script assumes its run in a directory with ./app and ./tests local to it

DEFAULT_DIR="/opt/pysetup"
LOCAL_DIR=${1:-$DEFAULT_DIR}


commands=( \
    "cd ${LOCAL_DIR} && \
        poetry check && \
        cd -" \
    "flake8 \
        --max-line-length=88 \
        --count \
        --statistics \
        ./app ./tests" \
    "black \
        --config ${LOCAL_DIR}/pyproject.toml \
        --check \
        ./app ./tests" \
    "isort \
        --settings-path ${LOCAL_DIR}/pyproject.toml \
        --check-only \
        ./app ./tests" \
    "bandit \
        -r ./app ./tests \
    safety check \
        --cache \
        --full-report" \
    "coverage run \
        -m \
        --branch \
        --omit='*/tests/*' \
        --source ./app \
            pytest -vv \
                ./tests && \
                coverage report \
                    -m \
                    --skip-covered \
                    --skip-empty \
                    --fail-under=75 " \
)

for c in ${commands[@]}; do
    eval $c
    [[ $? != 0 ]] && exit 1
done