# sample-springboot — CodeTest AI Agent 대상 샘플 프로젝트

`codetest` CLI 가 변경된 코드의 Test Code 를 생성하고 `@SpringBootTest` 로 실행하는
동작을 확인하기 위한 Spring Boot 샘플입니다.

## CLI 환경 구성

프로젝트 안에 독립 파이썬 환경(`.ai_env`)을 만들고 `codetest` CLI 를 설치합니다.
두 스크립트는 하는 일이 같고 셸만 다릅니다.

| 환경 | 스크립트 |
|---|---|
| **IntelliJ PowerShell 터미널** / Windows PowerShell | `codetest.ps1` |
| Git Bash · macOS · Linux | `codetest.sh` |

### IntelliJ 에서 (PowerShell)

IntelliJ 터미널을 PowerShell 로 열고 (Settings → Tools → Terminal → Shell path 를
`powershell.exe` 로), 프로젝트 루트에서 실행합니다.

```powershell
.\codetest.ps1
```

MCP 주소와 인증 키를 함께 넣으면 `.codetest/config.json` 에 저장해 둡니다
(`.codetest/` 는 `.gitignore` 에 있어 커밋되지 않습니다).

```powershell
.\codetest.ps1 -ServerUrl "http://<host>:80/mcp/<id>" -ApiKey "<key>"
```

스크립트 실행이 정책에 막히면 다음 중 하나로 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\codetest.ps1   # 이 실행만 허용
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass # 현재 세션만 허용
```

| 옵션 | 설명 |
|---|---|
| `-ServerUrl` | MCP 엔드포인트 주소. `.codetest/config.json` 에 저장 |
| `-ApiKey` | MCP 인증 키(`X-API-Key`). `.codetest/config.json` 에 저장 |
| `-Recreate` | 기존 `.ai_env` 를 지우고 새로 만든다 |

### Git Bash · macOS · Linux

```bash
bash ./codetest.sh
```

### Gradle 로 (IntelliJ Gradle 창의 `build setup > aiTest`)

```bash
./gradlew aiTest
```

OS 를 보고 Windows 면 `codetest.ps1`, 그 외에는 `codetest.sh` 를 실행합니다.

## 구성한 뒤 쓰는 명령

환경 구성은 **설치까지만** 합니다. 실행은 직접 입력합니다.

```powershell
. .\.ai_env\Scripts\Activate.ps1     # PowerShell
# source .ai_env/bin/activate        # bash

codetest project register            # 최초 1회
codetest generate                    # Test Code 생성만 → src/test/test.txt
codetest run --stage                 # 생성 + 실행 + report
codetest test                        # src/test/test.txt 실행 + report
```

`codetest generate` 결과 화면에서 **`TEST CODE` 의 `보기` 를 클릭하면** 생성된
`src/test/test.txt` 가 열립니다.

## 산출물

| 경로 | 내용 |
|---|---|
| `src/test/test.txt` | 생성된 Test Code (`codetest test` 의 실행 대상) |
| `.codetest/config.json` | MCP 주소·인증 키·`project_id` |
| `.ai_env/` | CLI 전용 파이썬 가상환경 |

`.codetest/` 와 `.ai_env/` 는 `.gitignore` 대상입니다. `src/test/test.txt` 는
`codetest test` 가 읽는 입력이라 저장소에 남습니다.
