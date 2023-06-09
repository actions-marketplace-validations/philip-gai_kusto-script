#!/bin/bash

function get_auth_string() {
  uri=$1
  tenant=$2

  if [ -z "$uri" ]; then
    echo "Usage: get_auth_string <uri> <tenant>" >&2
    return 1
  fi

  # Remove anything after the last '/' in the uri
  num_forward_slashes=$(grep -o '/' <<<"$uri" | grep -c .)
  if [ $num_forward_slashes -gt 2 ]; then
    uri="${uri%/*}"
  fi

  # Get user token from az cli
  echo "Getting Access token to $uri" >&2
  token=$(az account get-access-token --resource=$uri --query accessToken --output tsv)

  if [ -z "$token" ]; then
    echo "Failed to get access token" >&2
    return 1
  fi

  if [ ! -z "$CI" ]; then
    echo "::add-mask::$token" >&2
  fi
  auth="Fed=true;AppToken=$token;"

  if [ ! -z "$tenant" ]; then
    echo "Using Authority Id $tenant" >&2
    auth+="Authority Id=$tenant;"
  fi

  echo "$auth"
}
