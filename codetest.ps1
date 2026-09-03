<#
.SYNOPSIS
    IntelliJ PowerShell 터미널에서 codetest CLI 환경을 바로 구성한다.

.DESCRIPTION
    codetest.sh (Git Bash / macOS / Linux) 의 PowerShell 판이다.
    프로젝트 안에 독립 파이썬 환경(.ai_env)을 만들고 codetest CLI 를 설치한다.

      1. 파이썬 확인 (py -3 → python → python3)
      2. .ai_env 가상환경 생성 (최초 1회)
      3. GitHub 에서 codetest CLI 설치/최신화
      4. (선택) MCP 주소·API Key 를 .codetest/config.json 에 저장

    실행은 하지 않는다 — 환경만 만들고 사용자가 CLI 에서 직접 명령을 입력한다.

.PARAMETER ServerUrl
    MCP 엔드포인트 주소. 주면 .codetest/config.json 에 저장한다.

.PARAMETER ApiKey
    MCP 인증 키(X-API-Key). 주면 .codetest/config.json 에 저장한다.
    (.codetest/ 는 .gitignore 에 있어 커밋되지 않는다)

.PARAMETER Recreate
    기존 .ai_env 를 지우고 새로 만든다.

.EXAMPLE
    .\codetest.ps1

.EXAMPLE
    .\codetest.ps1 -ServerUrl "http://<host>:80/mcp/<id>" -ApiKey "..."

.NOTES
    실행이 막히면 (스크립트 실행 정책):
        powershell -ExecutionPolicy Bypass -File .\codetest.ps1
    또는 현재 세션에만 허용:
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#>

[CmdletBinding()]
param(
    [string]$ServerUrl,
    [string]$ApiKey,
    [switch]$Recreate
)

$ErrorActionPreference = "Stop"

# 가상환경이 생성될 숨김 폴더 이름
$VenvDir = ".ai_env"
$PackageUrl = "git+https://github.com/jihyun0410/codereview_gitver.git"

# 어느 위치에서 실행하든 프로젝트 루트(이 스크립트가 있는 폴더)를 기준으로 한다
Set-Location -LiteralPath $PSScriptRoot

Write-Host "========================================="
Write-Host "로컬 AI Agent 환경 구성을 시작합니다..."
Write-Host "========================================="

# --- 0. 실행 환경 판별 (PowerShell 5.1 에는 $IsWindows 가 없다) ---------------
if ($null -eq $IsWindows) { $onWindows = $true } else { $onWindows = $IsWindows }

# --- 1. 파이썬 명령어 확인 ------------------------------------------------------
function Find-Python {
    # Windows 런처(py -3)를 먼저 본다. PATH 에 python.exe 가 없어도 잡히는 경우가 많다.
    if ($onWindows -and (Get-Command "py" -ErrorAction SilentlyContinue)) {
        try {
            & py -3 --version 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { return @("py", @("-3")) }
        } catch { }
    }
    foreach ($name in @("python", "python3")) {
        $found = Get-Command $name -ErrorAction SilentlyContinue
        if (-not $found) { continue }
        # Windows 앱 실행 별칭(Microsoft Store 안내판)은 실제 파이썬이 아니다
        if ($found.Source -and $found.Source -like "*WindowsApps*") { continue }
        return @($name, @())
    }
    return $null
}

$python = Find-Python
if ($null -eq $python) {
    Write-Host "Error: 시스템에서 파이썬(Python)을 찾을 수 없습니다." -ForegroundColor Red
    Write-Host "Python이 설치되어 있고 환경변수(PATH)에 등록되어 있는지 확인해주세요."
    exit 1
}
$PythonCmd, $PythonArgs = $python
Write-Host ("사용할 파이썬: {0} {1}" -f $PythonCmd, ($PythonArgs -join " "))

# pip install git+... 는 git 실행 파일을 쓴다
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host "Error: git 을 찾을 수 없습니다. CLI 설치에 git 이 필요합니다." -ForegroundColor Red
    exit 1
}

# --- 2. 가상환경(.ai_env) 생성 --------------------------------------------------
if ($Recreate -and (Test-Path -LiteralPath $VenvDir)) {
    Write-Host "기존 가상환경을 제거합니다: $VenvDir"
    Remove-Item -LiteralPath $VenvDir -Recurse -Force
}

if (-not (Test-Path -LiteralPath $VenvDir)) {
    Write-Host "최초 1회: AI Agent용 독립 파이썬 환경을 생성 중입니다..."
    & $PythonCmd @PythonArgs -m venv $VenvDir
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: 가상환경 생성에 실패했습니다." -ForegroundColor Red
        exit 1
    }
}

# --- 3. 실행 경로 자동 설정 (Windows vs macOS/Linux PowerShell) -----------------
$BinDir = Join-Path $VenvDir "Scripts"      # Windows
if (-not (Test-Path -LiteralPath $BinDir)) {
    $BinDir = Join-Path $VenvDir "bin"      # macOS / Linux (PowerShell Core)
}

$PipExe = Join-Path $BinDir "pip"
$ActivateScript = Join-Path $BinDir "Activate.ps1"
$CodetestExe = Join-Path $BinDir "codetest"

# --- 4. GitHub에서 Agent 라이브러리 설치 및 최신화 -------------------------------
Write-Host "GitHub에서 최신 AI Agent 라이브러리를 동기화합니다..."
& $PipExe install --quiet --upgrade $PackageUrl
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: codetest CLI 설치에 실패했습니다." -ForegroundColor Red
    Write-Host "  사내망/프록시 환경이라면 HTTPS_PROXY 설정을 확인하세요."
    exit 1
}

# --- 5. (선택) 접속 정보를 저장소별 설정에 남긴다 --------------------------------
if ($ServerUrl -or $ApiKey) {
    $ConfigPath = Join-Path ".codetest" "config.json"
    New-Item -ItemType Directory -Path ".codetest" -Force | Out-Null

    $config = @{}
    if (Test-Path -LiteralPath $ConfigPath) {
        # project_id 등 기존 값은 지우지 않는다
        $existing = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($property in $existing.PSObject.Properties) {
            $config[$property.Name] = $property.Value
        }
    }
    if ($ServerUrl) { $config["server_url"] = $ServerUrl }
    if ($ApiKey) { $config["api_key"] = $ApiKey }

    $config | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ConfigPath -Encoding UTF8
    Write-Host "접속 정보를 저장했습니다: $ConfigPath"
}

# --- 6. 환경 구성 완료 — 실행은 사용자가 CLI에서 직접 입력한다 -------------------
Write-Host "========================================="
Write-Host "환경 구성 완료. 아래 명령을 직접 입력하세요."
Write-Host ""
Write-Host "  . $ActivateScript"
Write-Host "  codetest project register       # 최초 1회"
Write-Host "  codetest generate               # Test Code 생성만"
Write-Host "  codetest run --stage            # 생성 + 실행 + report"
Write-Host ""
Write-Host "활성화 없이 바로 쓰려면: $CodetestExe run --stage"
Write-Host ""
Write-Host "활성화가 실행 정책에 막히면 현재 세션에만 허용하세요:"
Write-Host "  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
Write-Host "========================================="
