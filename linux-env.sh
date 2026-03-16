#!/usr/bin/env bash

set -euo pipefail

project="${1:-}"
action="${2:-up}"
extra_args=()
if [[ $# -gt 2 ]]; then
  extra_args=("${@:3}")
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
projects_root="$script_dir/projects"
init_root="$script_dir/init"
projects="$(
  find "$projects_root" -mindepth 1 -maxdepth 1 -type d \
    | while read -r dir; do
        [[ -f "$dir/compose.yaml" ]] && basename "$dir"
      done \
    | sort \
    | paste -sd ', ' -
)"

show_help() {
  local message="${1:-}"

  if [[ -n "$message" ]]; then
    echo "$message" >&2
    echo >&2
  fi

  cat <<EOF
Usage:
  bash ./linux-env.sh <project> [action] [extra args...]
  bash ./linux-env.sh help

Projects: ${projects:-<none>}

Actions:
  init    clone/update repositories in the source volumes
  up      build and start the environment in background
  down    stop and remove containers and network
  build   build image only
  shell   open a bash shell in the running dev container
  config  show the final compose config without starting
  logs    follow container logs
  ps      show container status
  restart restart services
  stop    stop services without removing them

Tip: edit the project compose.yaml directly if you want to change mounted volumes.
EOF
}

if [[ -z "$project" || "$project" == "help" || "$project" == "-h" || "$project" == "--help" || "$action" == "help" || "$action" == "-h" || "$action" == "--help" ]]; then
  show_help
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not available in PATH." >&2
  exit 1
fi

project_dir="$projects_root/$project"
if [[ ! -d "$project_dir" ]]; then
  show_help "Unknown project '$project'."
  exit 1
fi

if [[ "$action" == "init" ]]; then
  compose_base_dir="$init_root/$project"
  compose_base_rel="init/$project"
else
  compose_base_dir="$project_dir"
  compose_base_rel="projects/$project"
fi

if [[ ! -f "$compose_base_dir/compose.yaml" ]]; then
  if [[ "$action" == "init" ]]; then
    show_help "Project '$project' does not define an init recipe."
    exit 1
  fi

  echo "Missing compose.yaml in '$compose_base_dir'." >&2
  exit 1
fi

docker_args=(compose)
compose_file_rel="$compose_base_rel/compose.yaml"

docker_args+=(-f "$compose_file_rel")

case "$action" in
  init) docker_args+=(run --rm bootstrap) ;;
  up) docker_args+=(up --build -d) ;;
  down) docker_args+=(down) ;;
  build) docker_args+=(build) ;;
  shell) docker_args+=(exec dev bash) ;;
  config) docker_args+=(config) ;;
  logs) docker_args+=(logs -f) ;;
  ps) docker_args+=(ps) ;;
  restart) docker_args+=(restart) ;;
  stop) docker_args+=(stop) ;;
  *)
    show_help "Unsupported action '$action'."
    exit 1
    ;;
esac

if [[ ${#extra_args[@]} -gt 0 ]]; then
  docker_args+=("${extra_args[@]}")
fi

cd "$script_dir"

echo "Project     : $project"
echo "Action      : $action"
echo "Compose     : $compose_file_rel"
echo "Docker call : docker ${docker_args[*]}"

docker "${docker_args[@]}"
