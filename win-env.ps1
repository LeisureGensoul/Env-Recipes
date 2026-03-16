param(
    [Parameter(Position = 0)]
    [string]$Project = '',

    [Parameter(Position = 1)]
    [string]$Action = 'up',

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rootDir = Split-Path -Parent $PSCommandPath
$projectsRoot = Join-Path $rootDir 'projects'
$initRoot = Join-Path $rootDir 'init'
$projects = Get-ChildItem -Path $projectsRoot -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'compose.yaml') } |
    Select-Object -ExpandProperty Name |
    Sort-Object

function Show-Help {
    param(
        [string]$Message = ''
    )

    if ($Message) {
        Write-Host $Message -ForegroundColor Yellow
        Write-Host ''
    }

    Write-Host 'Usage:'
    Write-Host '  .\win-env.ps1 <project> [action] [extra args...]'
    Write-Host '  .\win-env.ps1 help'
    Write-Host ''
    Write-Host "Projects: $($(if ($projects) { $projects -join ', ' } else { '<none>' }))"
    Write-Host ''
    Write-Host 'Actions:'
    Write-Host '  init    clone/update repositories in the source volumes'
    Write-Host '  up      build and start the environment in background'
    Write-Host '  down    stop and remove containers and network'
    Write-Host '  build   build image only'
    Write-Host '  shell   open a bash shell in the running dev container'
    Write-Host '  config  show the final compose config without starting'
    Write-Host '  logs    follow container logs'
    Write-Host '  ps      show container status'
    Write-Host '  restart restart services'
    Write-Host '  stop    stop services without removing them'
    Write-Host ''
    Write-Host 'Tip: edit the project compose.yaml directly if you want to change mounted volumes.'
}

if ($Project -in @('', 'help', '-h', '--help') -or $Action -in @('help', '-h', '--help')) {
    Show-Help
    exit 0
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'docker is not available in PATH.'
}

$projectDir = Join-Path $projectsRoot $Project
if (-not (Test-Path $projectDir -PathType Container)) {
    Show-Help "Unknown project '$Project'."
    exit 1
}

$composeBaseRel = if ($Action -eq 'init') { Join-Path 'init' $Project } else { Join-Path 'projects' $Project }
$composeBaseDir = if ($Action -eq 'init') { Join-Path $initRoot $Project } else { $projectDir }

if (-not (Test-Path $composeBaseDir -PathType Container) -or -not (Test-Path (Join-Path $composeBaseDir 'compose.yaml') -PathType Leaf)) {
    if ($Action -eq 'init') {
        Show-Help "Project '$Project' does not define an init recipe."
        exit 1
    }

    throw "Missing compose.yaml in '$composeBaseDir'."
}

$dockerArgs = @('compose')
$composeFileRel = Join-Path $composeBaseRel 'compose.yaml'

$dockerArgs += @('-f', $composeFileRel)

switch ($Action) {
    'init' { $dockerArgs += @('run', '--rm', 'bootstrap') }
    'up' { $dockerArgs += @('up', '--build', '-d') }
    'down' { $dockerArgs += 'down' }
    'build' { $dockerArgs += 'build' }
    'shell' { $dockerArgs += @('exec', 'dev', 'bash') }
    'config' { $dockerArgs += 'config' }
    'logs' { $dockerArgs += @('logs', '-f') }
    'ps' { $dockerArgs += 'ps' }
    'restart' { $dockerArgs += 'restart' }
    'stop' { $dockerArgs += 'stop' }
    default {
        Show-Help "Unsupported action '$Action'."
        exit 1
    }
}

if ($ExtraArgs) {
    $dockerArgs += $ExtraArgs
}

Push-Location $rootDir
try {
    Write-Host "Project     : $Project"
    Write-Host "Action      : $Action"
    Write-Host "Compose     : $composeFileRel"
    Write-Host "Docker call : docker $($dockerArgs -join ' ')"

    & docker @dockerArgs
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

exit $exitCode
