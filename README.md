# Env-Recipes

Personal Docker recipes for experiments.

## Structure

```text
Env-Recipes/
  init/
    aosp/compose.yaml
    llvm/compose.yaml
    symex-ART/compose.yaml
  projects/
    aosp/
      Dockerfile
      compose.yaml
    graal/
      Dockerfile
      compose.yaml
    llvm/
      Dockerfile
      compose.yaml
    symex-ART/
      Dockerfile
      compose.yaml
```

## Conventions

- `init/` is the lightweight layer for clone/update work. You can think of it as the simplified `volume-create/`.
- `projects/` is the runtime layer. Dockerfiles and long-lived dev containers stay here.
- Volumes are declared directly in each `compose.yaml`.
- Docker volume names are fixed short names such as `symex-art-work`, `llvm-build`, and `graal-art`.
- A project may mount multiple volumes. The source checkout is only one of them; build/cache volumes still stay in `projects/<project>/compose.yaml`.
- `aosp init` uses Tsinghua's AOSP mirror plus mirrored `git-repo`, syncs the `android-16.0.0_r1` manifest, and mounts it at `/workspace/aosp16`.
- `symex-ART init` clones `LeisureGensoul/work_SE` and mounts it at `/workspace/work_SE`.
- `llvm init` clones `LeisureGensoul/llvm-project` into `/workspace/llvm-project`.

## Usage

Windows / PowerShell:

```shell
.\win-env.ps1 symex-ART init
.\win-env.ps1 symex-ART
.\win-env.ps1 llvm init
.\win-env.ps1 llvm
.\win-env.ps1 aosp init
.\win-env.ps1 aosp
.\win-env.ps1 symex-ART shell
.\win-env.ps1 llvm build
.\win-env.ps1 help
```

Linux / macOS / WSL / bash:

```bash
bash ./linux-env.sh symex-ART init
bash ./linux-env.sh symex-ART
bash ./linux-env.sh llvm init
bash ./linux-env.sh llvm
bash ./linux-env.sh aosp init
bash ./linux-env.sh aosp
bash ./linux-env.sh symex-ART shell
bash ./linux-env.sh llvm build
bash ./linux-env.sh help
```

Example:

```powershell
.\win-env.ps1 symex-ART init
.\win-env.ps1 symex-ART config
```

```bash
bash ./linux-env.sh symex-ART init
bash ./linux-env.sh symex-ART config
```

If you need to change mounted volumes, edit the corresponding `compose.yaml` directly.

Both scripts can print a short help page with available projects and action meanings.
