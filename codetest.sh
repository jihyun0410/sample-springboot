#!/bin/bash

# 가상환경이 생성될 숨김 폴더 이름
VENV_DIR=".ai_env"

echo "========================================="
echo "로컬 AI Agent 환경 구성을 시작합니다..."
echo "========================================="

# 1. 파이썬 명령어 확인 (python3 또는 python)
if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
    PYTHON_CMD="python"
else
    echo "Error: 시스템에서 파이썬(Python)을 찾을 수 없습니다."
    echo "Python이 설치되어 있고 환경변수(PATH)에 등록되어 있는지 확인해주세요."
    exit 1
fi

# 2. 가상환경(.ai_env)이 없으면 최초 1회 생성
if [ ! -d "$VENV_DIR" ]; then
    echo "최초 1회: AI Agent용 독립 파이썬 환경을 생성 중입니다..."
    $PYTHON_CMD -m venv $VENV_DIR
fi

# 3. 운영체제(OS)에 따른 실행 경로 자동 설정 (Windows vs Mac/Linux)
if [ -d "$VENV_DIR/Scripts" ]; then
    BIN_DIR="$VENV_DIR/Scripts"   # Windows (Git Bash 환경 포함)
else
    BIN_DIR="$VENV_DIR/bin"       # Mac / Linux
fi

# 4. GitHub에서 Agent 라이브러리 설치 및 최신화 (조용하게 진행: --quiet)
echo "GitHub에서 최신 AI Agent 라이브러리를 동기화합니다..."
"$BIN_DIR/pip" install --quiet --upgrade git+https://github.com/jihyun0410/codereview_gitver.git

# 5. 환경 구성 완료 — 실행은 사용자가 CLI에서 직접 입력한다.
echo "========================================="
echo "환경 구성 완료. 아래 명령을 직접 입력하세요."
echo
echo "  source $BIN_DIR/activate"
echo "  codetest project register --token <GitHub_API_Token>   # 최초 1회"
echo "  codetest run --stage"
echo
echo "활성화 없이 바로 쓰려면: $BIN_DIR/codetest run --stage"
echo "========================================="