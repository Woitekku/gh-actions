#!/bin/bash

RUNNER_NAME=$(hostname)
RUNNER_WORKDIR=${RUNNER_WORKDIR:-_work}

if [[ -z "${GITHUB_ACCESS_TOKEN}" || -z "${GITHUB_ACTIONS_RUNNER_CONTEXT}" ]]; then
  echo 'One of the mandatory parameters is missing. Quit!'
  exit 1
else
  AUTH_HEADER="Authorization: Bearer ${GITHUB_ACCESS_TOKEN}"
  USERNAME=$(cut -d/ -f4 <<< ${GITHUB_ACTIONS_RUNNER_CONTEXT})
  REPOSITORY=$(cut -d/ -f5 <<< ${GITHUB_ACTIONS_RUNNER_CONTEXT})

  if [[ -z "${REPOSITORY}" ]]; then
    TOKEN_REGISTRATION_URL="https://api.github.com/orgs/${USERNAME}/actions/runners/registration-token"
  else
    TOKEN_REGISTRATION_URL="https://api.github.com/repos/${USERNAME}/${REPOSITORY}/actions/runners/registration-token"
  fi

  RUNNER_TOKEN="$(curl -XPOST -fsSL \
    -H "Accept: application/vnd.github+json" \
    -H "${AUTH_HEADER}" \
    "${TOKEN_REGISTRATION_URL}" \
    | jq -r '.token')"
fi

./config.sh --url "${GITHUB_ACTIONS_RUNNER_CONTEXT}" --token "${RUNNER_TOKEN}" --name "${RUNNER_NAME}" --work "${RUNNER_WORKDIR}"
./run.sh