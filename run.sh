#!/usr/bin/env bash

## set -eu -o pipefail

# region variables
FORMAT_BOLD="1"

FG_RED="91" # originally 31 but 91 is brighter and better with black background
FG_GREEN="32"
FG_YELLOW="33"

stderr_tmp=$(mktemp)
stdout_tmp=$(mktemp)

step_by_step=0
step=0
step_target=0
step_limit=0
step_limit_index=0

# endregion

# region functions
function color_inline() {
  local bg="${1:-}"
  local format="${2:-}"
  local fg="${3:-}"
  local msg="$4"

  echo -n -e "\e[${bg};${format};${fg}m${msg}\e[0m"
}

function color() {
  color_inline "$@"
  echo
}

function info() {
  color "" "$FORMAT_BOLD" "$FG_YELLOW" "$@"
}

function step_info() {
  color "" "$FORMAT_BOLD" "$FG_GREEN" "$@"
}

function run() {
  local command="$1"

  ((++step))

  if (( step_target > step )); then
    return 0
  fi

  (( ++step_limit_index ))

  [[ -n "${2:-}" ]] && command="$1 $2"

  step_info "[Step $step] command:"

  info "$command" | awk '{ gsub("\t", "\\t"); print $0 }'

  if [[ "$step_by_step" == "1" ]]; then
    echo
    step_info "[Step $step] Press ENTER to run the above command"
    read -r
  fi

  eval "$command"
  err=$?

  if [[ "$step_by_step" == "1" ]]; then
    echo
    step_info "[Step $step] Press ENTER to continue"
    read -r
    echo
  fi

  echo

  if (( step_limit != 0 )) && (( step_limit_index >= step_limit )); then
    exit 0
  fi
  return "$err"
}

function run_i() {
  local indent_input="$1"
  local version="$2"
  local executable_file="$3"

  command="$(awk \
      -v "indent_input=$indent_input" \
      -v "version=$version" \
      '{ gsub("^ {" indent_input "}" ,""); gsub("\{v\}", "v" version); print $0 }' \
      "$executable_file"
  )"
  run "$command"
}

function reset_examples() {
  run_i 2 "$1" <(cat <<EOF
  docker container ls --all --quiet --filter label=fixcontainers | xargs -I '{}' -- docker container rm -f {}
  docker image ls --quiet --filter label=fixcontainers | xargs -I '{}' -- docker image rm -f {}
  rm -r ./var 2>/dev/null || true
EOF
)
}

function usage() {
  echo "Usage $0 [options]"
  echo
  echo "Options:"
  echo
  echo "-a            Run all tests. Every container and image created by the examples will be deleted in the end."
  echo "-s            Run examples step by step. You need to press ENTER to continue every time."
  echo "-S <number>   The step that you want to start with"
  echo "-l <number>   How many steps you want to run"
  echo "-h            Show this help"
}
# endregion

# region argument parser
if [[ "$#" == 0 ]]; then
  usage
  exit 0
fi

while getopts ":asl:S:" opt; do
  case $opt in
    a)
      echo "Running all examples..."
      ;;
    s)
      step_by_step=1
      ;;
    S)
      step_target="$OPTARG"
      ;;
    l)
      step_limit="$OPTARG"
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      >&2 echo Invalid argument: "$OPTARG"
      >&2 usage
      exit 1
  esac
done
shift $((OPTIND-1))
# endregion

# region reset
reset_examples 0
# endregion

# region example: v0
run_i 2 0 <(cat <<EOF
  docker run --label fixcontainers -d --name {v} httpd:2.4
EOF
)

run_i 2 0 <(cat <<EOF
  docker container ls --all --filter label=fixcontainers
EOF
)

run_i 2 0 <(cat <<EOF
  docker container logs --tail 30 {v}
EOF
)
# endregion

# region example: v1
run_i 2 1 <(cat <<EOF
  docker run --label fixcontainers -d --name {v} httpd:2.4 httpd-foregroun
EOF
)

run_i 2 1 <(cat <<EOF
  docker container ls --all --filter label=fixcontainers
EOF
)
# endregion

# region example: v2
run_i 2 2 <(cat <<EOF
  docker run --label fixcontainers --rm -it --name {v} httpd:2.4 bash
  # Run in the container:
  #
  # httpd-foregroun
  # exit
EOF
)
# endregion

# region example: v3 (help)
run_i 2 3 <(cat <<EOF
  docker run --label fixcontainers --rm --name {v} httpd:2.4 httpd-foreground -h
EOF
)
# endregion

# region example: v4
run_i 2 4 <(cat <<EOF
  docker run --label fixcontainers -d --name {v} httpd:2.4 httpd-foreground -e trace8
EOF
)

run_i 2 4 <(cat <<EOF
  docker container ls --all --filter label=fixcontainers
EOF
)

run_i 2 4 <(cat <<EOF
  docker logs --tail 30 {v}
EOF
)
# endregion

# region example: v5
run_i 2 5 <(cat <<EOF
  docker run --label fixcontainers -d --name {v} httpd:2.4 httpd-foreground -e race8
EOF
)

run_i 2 5 <(cat <<EOF
  docker container ls --all --filter label=fixcontainers
EOF
)

run_i 2 5  <(cat <<EOF
  docker logs --tail 30 {v}
EOF
)

run_i 2 5 <(cat <<EOF
  docker container ls --all --filter label=fixcontainers --format '{{ json . }}'
EOF
)

run_i 2 5 <(cat <<'EOF'
  docker container ls --all --filter label=fixcontainers --format '{{ json . }}' | jq -C
EOF
)

run_i 2 5 <(cat <<'EOF'
  docker container ls --all --filter label=fixcontainers --format '{{ json . }}' | python3 -m json.tool --json-lines
EOF
)

run_i 2 5 <(cat <<'EOF'
  docker container ls --all --filter label=fixcontainers --format 'table {{ .Names }}\t{{ .Status }}\t{{ .Command }}'
EOF
)

run_i 2 5 <(cat <<'EOF'
  docker container ls --all --filter label=fixcontainers --format 'table {{ .Names }}\t{{ .Status }}\t{{ .Command }}' --no-trunc
EOF
)
# endregion

# region example: v6
run_i 2 6 <(cat <<'EOF'
  chmod 664 $PWD/examples/v6/entrypoint.sh
  docker run --label fixcontainers -d -v $PWD/examples/{v}/entrypoint.sh:/entrypoint.sh --entrypoint /entrypoint.sh --name {v} httpd:2.4
EOF
)

run_i 2 6 <(cat <<'EOF'
  ls -l $PWD/examples/{v}/entrypoint.sh
EOF
)
# endregion

# region example: v7
run_i 2 7 <(cat <<'EOF'
  chmod 774 $PWD/examples/{v}/entrypoint.sh
  docker run --label fixcontainers -d -v $PWD/examples/{v}/entrypoint.sh:/entrypoint.sh --entrypoint /entrypoint.sh --name {v}-exiting httpd:2.4
EOF
)

run_i 2 7 <(cat <<'EOF'
  docker container ls --all --filter label=fixcontainers --format 'table {{ .Names }}\t{{ .Status }}\t{{ .Command }}' --no-trunc
EOF
)

run_i 2 7 <(cat <<'EOF'
  cat $PWD/examples/{v}/entrypoint.sh
EOF
)

run_i 2 7 <(cat <<'EOF'
 docker logs --tail 10 {v}-exiting
EOF
)

run_i 2 7 <(cat <<'EOF'
  docker container inspect {v}-exiting
EOF
)

run_i 2 7 <(cat <<'EOF'
  docker image inspect httpd:2.4 --format "{{ json .Config.Cmd }}" | python3 -m json.tool
EOF
)

run_i 2 7 <(cat <<'EOF'
  docker container inspect {v}-exiting --format "{{ json .Config.Cmd }}" | python3 -m json.tool
EOF
)

run_i 2 7 <(cat <<'EOF'
  chmod 774 $PWD/examples/{v}/entrypoint.sh
  docker run --label fixcontainers -d -v $PWD/examples/{v}/entrypoint.sh:/entrypoint.sh --entrypoint /entrypoint.sh --name {v}-running httpd:2.4 httpd-foreground
EOF
)

run_i 2 7 <(cat <<'EOF'
  docker container ls --all --filter label=fixcontainers --format 'table {{ .Names }}\t{{ .Status }}\t{{ .Command }}' --no-trunc
EOF
)

run_i 2 7 <(cat <<'EOF'
 docker logs --tail 10 {v}-running
EOF
)
# endregion

# region example: v8
run_i 2 8 <(cat <<'EOF'
  chmod 774 $PWD/examples/{v}/entrypoint.sh
  docker run \
    --label fixcontainers \
    -d \
    -v $PWD/examples/{v}/entrypoint.sh:/entrypoint.sh \
    --entrypoint /entrypoint.sh \
    --name {v} \
    httpd:2.4 \
    httpd-foreground
EOF
)

run_i 2 8 <(cat <<'EOF'
  docker container ls --all --filter label=fixcontainers --format 'table {{ .Names }}\t{{ .Status }}\t{{ .Command }}' --no-trunc
EOF
)

run_i 2 8 <(cat <<'EOF'
  docker logs --tail 10 {v}
EOF
)

run_i 2 8 <(cat <<'EOF'
  docker top {v}
EOF
)

run_i 2 8 <(cat <<'EOF'
  docker kill {v}
EOF
)

run_i 2 8 <(cat <<'EOF'
  docker container ls --all --filter label=fixcontainers --format 'table {{ .Names }}\t{{ .Size }}'
EOF
)

run_i 2 8 <(cat <<'EOF'
  mkdir -p ./var/
  docker cp --archive {v}:/ ./var/{v}
  ls -la ./var/{v}
EOF
)

run_i 2 8 <(cat <<'EOF'
  docker container diff {v}
EOF
)

run_i 2 8 <(cat <<'EOF'
  docker cp {v}:/usr/local/apache2/bin/httpd ./var/{v}-httpd
  hexdump -C -n 100 ./var/{v}-httpd
EOF
)

run_i 2 8 <(cat <<'EOF'
     cd "$(docker container inspect {v} --format '{{ .GraphDriver.Data.UpperDir }}')" \
  && find .
EOF
)

run_i 2 8 <(cat <<'EOF'
  # https://github.com/justincormack/nsenter1
  # https://gist.github.com/BretFisher/5e1a0c7bcca4c735e716abf62afad389
  docker run --rm --privileged --pid=host alpine:3.16.2 nsenter -t 1 -m -u -i -n -p -- sh -c "
       cd \"$(docker container inspect {v} --format '{{ .GraphDriver.Data.UpperDir }}')\" \\
    && find .
  "
EOF
)

run_i 2 8 <(cat <<'EOF'
  docker run --rm --privileged --pid=host alpine:3.16.2 nsenter -t 1 -m -u -i -n -p -- sh -c "
      cd \"$(docker container inspect {v} --format '{{ .GraphDriver.Data.UpperDir }}')\"
      hexdump -C -n 100 ./usr/local/apache2/bin/httpd
  "
EOF
)

run_i 2 8 <(cat <<'EOF'
  cat $PWD/examples/{v}/entrypoint.sh
EOF
)

run_i 2 9 <(cat <<'EOF'
  docker build $PWD/examples/{v} --label fixcontainers --tag "localhost/{v}" --progress plain
EOF
)

run_i 2 9 <(cat <<'EOF'
  cat $PWD/examples/{v}/Dockerfile
EOF
)

run_i 2 10 <(cat <<'EOF'
  cat $PWD/examples/{v}/Dockerfile
EOF
)

run_i 2 10 <(cat <<'EOF'
  docker build $PWD/examples/{v} --label fixcontainers --tag "localhost/{v}" --progress plain --no-cache
EOF
)

run_i 2 11 <(cat <<'EOF'
  cat $PWD/examples/{v}/Dockerfile
EOF
)

run_i 2 11 <(cat <<'EOF'
  docker build $PWD/examples/{v} --label fixcontainers --tag "localhost/{v}" --progress plain
EOF
)

run_i 2 11 <(cat <<'EOF'
  docker run --rm -it --name {v} "localhost/{v}" sh
  # Run in the container
  #
  # ls -la /usr/local/bin/
EOF
)

run_i 2 12 <(cat <<'EOF'
  cat $PWD/examples/{v}/Dockerfile
EOF
)

run_i 2 12 <(cat <<'EOF'
  docker build $PWD/examples/{v} --label fixcontainers --tag "localhost/{v}" --progress plain
EOF
)

run_i 2 12 <(cat <<'EOF'
  docker run -d --name {v} "localhost/{v}"
EOF
)

run_i 2 12 <(cat <<'EOF'
  docker container ls --all --filter label=fixcontainers --format 'table {{ .Names }}\t{{ .Status }}\t{{ .Command }}' --no-trunc
EOF
)

run_i 2 12 <(cat <<'EOF'
  docker logs --tail 30 {v}
EOF
)

run_i 2 13 <(cat <<'EOF'
  docker compose --project-directory $PWD/examples/{v} up -d
EOF
)

run_i 2 13 <(cat <<'EOF'
  docker compose --project-directory $PWD/examples/{v} ps
EOF
)

run_i 2 13 <(cat <<'EOF'
  docker compose --project-directory $PWD/examples/{v} logs
EOF
)

run_i 2 13 <(cat <<'EOF'
  cat $PWD/examples/{v}/docker-compose.yml
EOF
)

run_i 2 13 <(cat <<'EOF'
  docker compose --project-directory $PWD/examples/{v} config
EOF
)

run_i 2 14 <(cat <<'EOF'
  cat $PWD/examples/{v}/docker-compose.yml
EOF
)

run_i 2 14 <(cat <<'EOF'
  docker compose --project-directory $PWD/examples/{v} up -d
EOF
)

run_i 2 14 <(cat <<'EOF'
  docker compose --project-directory $PWD/examples/{v} ps
EOF
)

run_i 2 14 <(cat <<'EOF'
  docker compose --project-directory $PWD/examples/{v} logs
EOF
)

run_i 2 15 <(cat <<'EOF'
  # Run a new HTTPD to test file editing
  # Only for testing NOT FOR changing production configuration
  docker run -d --label fixcontainers --name {v}-server httpd:2.4
EOF
)

run_i 2 15 <(cat <<'EOF'
  docker run \
    --rm \
    -it \
    --network container:{v}-server \
    --label fixcontainers \
    --name {v}-client \
    nicolaka/netshoot:v0.7 \
    curl localhost
EOF
)

run_i 2 15 <(cat <<'EOF'
  docker exec {v}-server sh -c 'apt-get update && apt-get install -y nano'
EOF
)

run_i 2 15 <(cat <<'EOF'
  docker exec {v}-server sh -c 'nano --version'
  # Run interactive terminal to edit files:
  # docker exec -it {v}-server sh
EOF
)

run_i 2 16 <(cat <<'EOF'
  echo "Use Visual Studio Code to edit files in running containers"
  echo "IntellIJ products also has file browser support without editing files."
EOF
)

run_i 2 16 <(cat <<'EOF'
  docker run --rm -it --privileged --pid=host --name {v}-vmlogin alpine:3.16.2 \
    nsenter -t 1 -m -u -i -n -p -- \
      ctr -n services.linuxkit task exec -t --exec-id dockertest docker \
        docker container ls --all --filter label=fixcontainers \
                            --format 'table {{ .Names }}\t{{ .Status }}\t{{ .Command }}' --no-trunc
  
EOF
)

run_i 2 16 <(cat <<'EOF'
  # https://github.com/justincormack/nsenter1
  # https://gist.github.com/BretFisher/5e1a0c7bcca4c735e716abf62afad389
  # https://formulae.brew.sh/formula/socat
  echo 'Run the following commands on macOS to log in to the VM:'
  echo
  echo 'brew install socat'
  echo 'socat $HOME/Library/Containers/com.docker.docker/Data/debug-shell.sock -,rawer'
  echo '# Press ENTER, and use the exit command exit'
  echo 'socat $HOME/Library/Containers/com.docker.docker/Data/vms/0/console.sock -,rawer'
  echo '# Press ENTER, and close the terminal to exit'
  #
  # Troubleshoot: https://docs.docker.com/desktop/troubleshoot/overview/
EOF
)

# region reset
reset_examples 17
# endregion
