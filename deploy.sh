#!/usr/bin/env bash

shopt -s extglob
set -o errtrace
#set -o errexit
set +o noclobber

# Defaults {{{
ASSUMEYES=0
NOOP=
FORCE=0
VERBOSE=1
UGLIFY=1

BT_ORG=genesys
BT_REPO=widgets
BT_PACKAGE=
BT_VERSION=
BT_USER=
BT_KEY=
BT_LICENSES=MIT
# Defaults }}}

# Read the local env file if any
[[ -r .env ]] && source .env

# tools {{{

function verbose() { # {{{2
  [[ $VERBOSE > 0 ]] && echo -e "$@"
} # 2}}}

function warn() { # {{{2
  echo -e "Warning: $@"
} # 2}}}

function error() { # {{{2
  echo -e "\e[0;31mError: $@\e[0m" >&2
} # 2}}}

function die() { # {{{2
  local message=$1
  local errorlevel=$2

  [[ -z $message    ]] && message='Died'
  [[ -z $errorlevel ]] && errorlevel=1
  echo -e "\e[0;31m$message\e[0m" >&2
  exit $errorlevel
} # 2}}}

function die_on_error() { # {{{2
  local status=$?
  local message=$1

  if [[ $status != 0 ]]; then
    die "${message}, Error: $status" $status
  fi
} # 2}}}

# }}}

function uglify() {
  local file=$1
  local target=$2
  local status

  verbose "Uglifying $1 into $2"
  mkdir -p tmp
  npx terser $file --compress --mangle --output $target
  status=$?
  return $status
}

function bt_config_set() {
  local user=$1
  local key=$2
  local licenses=$3

  npx jfrog bt config --user $user --key $key --licenses $licenses
}

function bt_package_exists() {
  local org=$1
  local repo=$2
  local package=$3
  local results
  local status

  results=$(npx jfrog bt package-show ${org}/${repo}/${package} 2>&1 >/dev/null)
  return $?
}

function bt_package_info() {
  local org=$1
  local repo=$2
  local package=$3
  local results
  local status

  results=$(npx jfrog bt package-show ${org}/${repo}/${package} 2>&1)
  status=$?
  echo $results
  return $status
}

function bt_package_create() {
  local org=$1
  local repo=$2
  local package=$3
  local results
  local status

  results=$(npx jfrog bt package-create ${org}/${repo}/${package} 2>&1)
  status=$?
  echo $results
  return $status
}

function bt_version_exists() {
  local org=$1
  local repo=$2
  local package=$3
  local version=$4
  local results
  local status

  results=$(npx jfrog bt version-show ${org}/${repo}/${package}/${version} 2>&1 >/dev/null)
  return $?
}

function bt_version_create() {
  local org=$1
  local repo=$2
  local package=$3
  local version=$4
  local results
  local status

  verbose "Creating version: ${org}/${repo}/${package}/${version}"
  results=$(npx jfrog bt version-create ${org}/${repo}/${package}/${version} 2>&1 >/dev/null)
  status=$?
  echo $results
  return $status
#docker run docker.bintray.io/jfrog/jfrog-cli-go \
#  jfrog bt version-create \
#  --user $BT_USER --key $BT_KEY \
#  genesys/widgets/genesys-webchat-uploader/1.2.3

}

function bt_upload() {
  local org=$1
  local repo=$2
  local package=$3
  local version=$4
  local file=$5
  local results
  local status

  verbose "Uploading $file to ${org}/${repo}/${package}/${version}"
  npx jfrog bt upload $file ${org}/${repo}/${package}/${version} ${version}/
  status=$?
  return $status
#docker run docker.bintray.io/jfrog/jfrog-cli-go \
#  -v "${PWD}/tmp:/" \
#  jfrog bt upload \
#  /genesys-webchat-richmessage.min.js \
#  --user $BT_USER --key $BT_KEY \
#  genesys/widgets/genesys-webchat-uploader/1.2.3
}

function bt_version_publish() {
  local org=$1
  local repo=$2
  local package=$3
  local version=$4
  local results
  local status

  verbose "Publishing ${org}/${repo}/${package}/${version}"
  npx jfrog bt version-publish ${org}/${repo}/${package}/${version}
  status=$?
  return $status
#docker run docker.bintray.io/jfrog/jfrog-cli-go \
#  jfrog bt version-publish \
#  --user $BT_USER --key $BT_KEY \
#  genesys/widgets/genesys-webchat-uploader/1.2.3
}

function usage() { # {{{2
  echo "$(basename $0) [options] [archive-filename]"
  echo "  Packages and deploy the app"
  echo "  Options are:"
  echo " --org=name"
  echo " --organization=name"
  echo "   Use [name] for the organization instead of ${BT_ORG}"
  echo " --package=name"
  echo "   Use [name] for the package instead of ${BT_PACKAGE}"
  echo " --no-uglify"
  echo "   Do not uglify the package before deploying it to bintray.com"
  echo " --key=value"
  echo "   Use [value] for the Bintray API Key instead of the default stored in your configuration"
  echo " --user=name"
  echo "   Use [name] for the Bintray user instead of the default stored in your configuration"
  echo " --help, -h, -?  "
  echo "   Prints some help on the output."
  echo " --noop, --dry-run  "
  echo "   Do not execute instructions that would make changes to the system (write files, install software, etc)."
  echo " --quiet  "
  echo "   Runs the script as silently as possible."
  echo " --verbose  "
  echo "   Runs the script verbosely, that's by default."
  echo " --yes, --assumeyes, -y  "
  echo "   Answers yes to any questions automatiquely."
} # 2}}}

function parse_args() { # {{{2
  while (( "$#" )); do
    # Replace --parm=arg with --parm arg
    [[ $1 == --*=* ]] && set -- "${1%%=*}" "${1#*=}" "${@:2}"
    case $1 in
      # GENERAL Stuff
      --key)
        [[ -z $2 || ${2:0:1} == '-' ]] && die "Argument for option $1 is missing"
        BT_KEY=$2
        shift 2
        continue
      ;;
      --org|--organization)
        [[ -z $2 || ${2:0:1} == '-' ]] && die "Argument for option $1 is missing"
        BT_ORG=$2
        shift 2
        continue
      ;;
      --package|--repo|--repository)
        [[ -z $2 || ${2:0:1} == '-' ]] && die "Argument for option $1 is missing"
        # Extract the name of the repository, ex: 'user/repo' (github provides only that)
        BT_PACKAGE=${2##*/}
        shift 2
        continue
      ;;
      --no-uglify)
        UGLIFY=0
      ;;
      --user)
        [[ -z $2 || ${2:0:1} == '-' ]] && die "Argument for option $1 is missing"
        BT_USER=$2
        shift 2
        continue
      ;;

      # Standard options
      --force)
        warn "This program will overwrite the current configuration"
        FORCE=1
        ;;
      -h|-\?|--help)
       usage
       exit 0
       ;;
      --noop|--dry_run|--dry-run)
        warn "This program will execute in dry mode, your system will not be modified"
        NOOP=:
        ;;
     --quiet)
       VERBOSE=0
       ;;
     -v|--verbose)
       VERBOSE=$((VERBOSE + 1))
       ;;
     -y|--yes|--assumeyes|--assume_yes|--assume-yes) # All questions will get a "yes"  answer automatically
       ASSUMEYES=1
       ;;
     -?*) # Invalid options
       warn "Unknown option $1 will be ignored"
       ;;
     --) # Force end of options
       shift
       break
       ;;
     *)  # End of options
       ARGS+=( "$1" )
       break
       ;;
    esac
    shift
  done

  # Set all positional arguments back in the proper order
  eval set -- "${ARGS[@]}"

# if [[ -n $1 ]]; then
#   if [[ $1 =~ ".*/.*" ]]; then
#     DEST="${1%/*}"
#     FILENAME="${1##*/}"
#   else
#     FILENAME=$1
#   fi
# fi

  # Validation
  [[ -z $BT_PACKAGE ]] && BT_PACKAGE=${BT_PACKAGE:-$(basename $PWD)}
  [[ -z $BT_VERSION ]] && BT_VERSION=${BT_VERSION:-$(awk '/var version =/{print $4}' ${BT_PACKAGE}.js | tr -d "'")}

  return 0
} # 2}}}


function main() {
  parse_args "$@"

  verbose "Processing Package: ${BT_ORG}/${BT_REPO}/${BT_PACKAGE} version ${BT_VERSION}"

  if ! bt_package_exists $BT_ORG $BT_REPO $BT_PACKAGE ; then
    warn "Package $BT_PACKAGE does not exist"
    bt_package_create $BT_ORG $BT_REPO $BT_PACKAGE || die_on_error "Failed to create package ${BT_PACKAGE} on bintray.com"
  fi

  if ! bt_version_exists $BT_ORG $BT_REPO $BT_PACKAGE $BT_VERSION ; then
    bt_version_create $BT_ORG $BT_REPO $BT_PACKAGE $BT_VERSION || die_on_error "Failed to create version ${BT_VERSION} for package ${BT_PACKAGE} on bintray.com"
  else
    verbose "Package $BT_PACKAGE already contains version $BT_VERSION"
  fi

  # 3/ uglyfying
  UPLOADS=()
  if [[ $UGLIFY == 1 ]]; then
    if [[ -r ${BT_PACKAGE}.js ]]; then
      uglify ${BT_PACKAGE}.js tmp/${BT_PACKAGE}.min.js
      UPLOADS+=( tmp/${BT_PACKAGE}.min.js )
    fi
    if [[ -r ${BT_PACKAGE}.css ]]; then
      # TODO: Find a CSS uglifier
      cp ${BT_PACKAGE}.css tmp/${BT_PACKAGE}.min.css
      UPLOADS+=( tmp/${BT_PACKAGE}.css )
    fi
  else
    if [[ -r ${BT_PACKAGE}.js ]]; then
      UPLOADS+=( ${BT_PACKAGE}.js )
    fi
    if [[ -r ${BT_PACKAGE}.css ]]; then
      UPLOADS+=( ${BT_PACKAGE}.css )
    fi
  fi
  # 4/ upload uglified stuff
  for file in ${UPLOADS[*]}; do
    bt_upload $BT_ORG $BT_REPO $BT_PACKAGE $BT_VERSION $file
    die_on_error "Failed to upload $file"
  done
  # 5/ publish version
  bt_version_publish $BT_ORG $BT_REPO $BT_PACKAGE $BT_VERSION
  die_on_error "Failed to publish version $BT_VERSION for package $BT_PACKAGE"

  return 0
}

main "$@"