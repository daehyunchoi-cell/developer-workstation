# 개발자용 작업실 꾸미기

## 📌프로젝트 개요

Docker, Git, Linux CLI를 활용하여 재현 가능한 개발 워크스테이션 환경을 구축하는 프로젝트입니다.

## 실행 환경

- OS: macOS (Apple Silicon M2)
- Terminal: zsh
- Container Runtime: OrbStack
- Editor: Visual Studio Code

## 📂프로젝트 디렉토리 구조

### 디렉토리 설계 개요
developer-workstation/
├── site/ # 웹 서비스 파일
│ ├── index.html # 메인 HTML 페이지
│ ├── css/ # 스타일시트
│ └── js/ # JavaScript 파일
├── docker/ # Docker 관련 파일
│ ├── Dockerfile # 컨테이너 이미지 정의
│ └── docker-compose.yml # 다중 컨테이너 구성
├── scripts/ # 자동화 스크립트
│ ├── setup.sh # 초기 설정 스크립트
│ └── deploy.sh # 배포 스크립트
└── README.md # 프로젝트 문서

### 각 디렉토리의 목적

| 디렉토리 | 목적 | 주요 파일 |
|---------|------|---------|
| **site/** | 웹 애플리케이션 소스 코드 | HTML, CSS, JS |
| **docker/** | 컨테이너 환경 설정 | Dockerfile, docker-compose.yml |
| **scripts/** | 자동화 및 배포 도구 | Shell 스크립트 |
| **root** | 프로젝트 메타데이터 | README.md, .gitignore |

### 디렉토리 설계 원칙

1. **관심사의 분리**: 각 디렉토리는 단일 책임을 가짐
2. **확장성**: 새로운 기능 추가 시 디렉토리 구조 유지
3. **재현성**: Docker를 통해 동일한 환경 재현 가능
4. **문서화**: 각 디렉토리의 목적을 명확히 함

## 파일 시스템 관리 증거

### 파일 이동 (mv)
- file1.txt → file1_moved.txt 성공
- 원본 파일은 제거되고 새 이름으로 이동됨

### 파일 삭제 (rm)
- file2.txt 제거 성공
- 파일이 완전히 삭제됨

### 디렉토리 삭제 (rm -rf)
- test_files/ 디렉토리 및 내부 파일 3개 모두 제거
- 재귀적 삭제로 디렉토리 구조 완전 제거

## ✅수행 체크리스트

- [x] 터미널 기본 조작 및 폴더 구성
- [x] 파일/디렉토리 권한 변경 실습
- [x] Docker 설치/점검 (version, info)
- [x] hello-world 실행
- [x] ubuntu 컨테이너 진입 및 종료/유지(exec) 관찰
- [x] Dockerfile 기반 커스텀 이미지 빌드
- [x] 포트 매핑 접속 (8080, 8081 — 2회)
- [x] 볼륨(데이터 영속성) 검증
- [x] Git 설정 및 GitHub 연동

---

## 0. 터미널 기초 & 파일 권한 실습

### 파일/디렉토리 생성

실습용 파일과 디렉토리를 만들고 권한을 확인했다.

```bash
$ mkdir perm-test && cd perm-test
$ touch sample.txt
$ mkdir sample-dir
$ ls -l
drwxr-xr-x  2 daehyunchoi  staff  64 ... sample-dir
-rw-r--r--  1 daehyunchoi  staff   0 ... sample.txt
```

### 권한 변경 실습 (chmod)

권한 표기: `rwx`(읽기/쓰기/실행)를 소유자/그룹/그외 3묶음으로 나눠 표시.
숫자 표기는 `r=4, w=2, x=1`의 합. 예) `644 = rw-r--r--`, `755 = rwxr-xr-x`.

파일과 디렉토리 각각의 권한을 바꿨다가 원래대로 복원하며 변경 전/후를 비교했다.

```bash
# 변경 전: sample.txt = rw-r--r--(644), sample-dir = rwxr-xr-x(755)
```

```bash
# 파일 권한 변경 (644 → 600: 그룹/그외 읽기 제거)
$ chmod 600 sample.txt
$ ls -l sample.txt
-rw-------  1 daehyunchoi  staff  0 ... sample.txt
```

```bash
# 디렉토리 권한 변경 (755 → 700: 그룹/그외 접근 제거)
$ chmod 700 sample-dir
$ ls -l
drwx------  2 daehyunchoi  staff  64 ... sample-dir
-rw-------  1 daehyunchoi  staff   0 ... sample.txt
```

```bash
# 원래 권한으로 복원
$ chmod 644 sample.txt
$ chmod 755 sample-dir
$ ls -l
drwxr-xr-x  2 daehyunchoi  staff  64 ... sample-dir
-rw-r--r--  1 daehyunchoi  staff   0 ... sample.txt
```

**관찰:** `600`, `700`으로 바꾸자 그룹/그외 권한(`r--`, `r-x`)이 `---`로 사라졌고, 복원 시 되돌아왔다. 폴더의 `x`는 "실행"이 아니라 "폴더 진입 가능"을 의미하므로 디렉토리는 보통 755를 사용한다.

---

## 1. Docker 설치 및 점검

Docker(OrbStack) 버전과 데몬 동작 여부를 확인했다.

```bash
$ docker --version
Docker version 29.4.0, build 9d7ad9f
```   

```bash
$ docker info
Client:
 Version:    29.4.0
 Context:    orbstack
Server:
 Containers: 4
  Running: 2
  Stopped: 2
 Images: 3
 Server Version: 29.4.0
 Operating System: OrbStack
 OSType: linux
 Architecture: aarch64
 Name: orbstack
```

---

## 2. 컨테이너 실행 실습

### hello-world

```bash
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### ubuntu 컨테이너 진입

ubuntu 컨테이너에 진입해 내부에서 명령을 실행하고, `exit`으로 나왔다.

```bash
$ docker run -it ubuntu bash

root@b904cab54f77:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

root@b904cab54f77:/# echo "hello from ubuntu container"
hello from ubuntu container

root@b904cab54f77:/# cat /etc/os-release
PRETTY_NAME="Ubuntu 26.04 LTS"
NAME="Ubuntu"
VERSION="26.04 LTS (Resolute Raccoon)"
ID=ubuntu

root@b904cab54f77:/# exit
exit
```

### 종료(run) vs 유지(exec) 관찰

- `docker run ... bash` + `exit` → 메인 프로세스(bash) 종료 → **컨테이너도 종료(Exited)**
- `docker exec ... bash` + `exit` → 메인 프로세스(sleep infinity) 유지 → **컨테이너는 유지(Up)**

```bash
$ docker run -d --name keep-alive ubuntu sleep infinity
6d3d781aba2c...

$ docker ps
CONTAINER ID   IMAGE    COMMAND            STATUS         NAMES
6d3d781aba2c   ubuntu   "sleep infinity"   Up 3 seconds   keep-alive

# 컨테이너 안으로 들어가 명령 실행 후 exit
$ docker exec -it keep-alive bash
root@6d3d781aba2c:/# echo "still running"
still running
root@6d3d781aba2c:/# exit

# exit 후에도 컨테이너는 여전히 Up → exec은 컨테이너 생사에 영향 없음
$ docker ps
CONTAINER ID   IMAGE    COMMAND            STATUS          NAMES
6d3d781aba2c   ubuntu   "sleep infinity"   Up 38 seconds   keep-alive

# 실습 정리
$ docker rm -f keep-alive
keep-alive
```

---

## 3. 커스텀 이미지 빌드 (Dockerfile)

### 선택한 방식

기존 `nginx:alpine` 이미지를 베이스로, 정적 HTML을 얹어 커스텀 이미지를 만들었다.

**Dockerfile:**

```dockerfile
FROM nginx:alpine
LABEL org.opencontainers.image.title="my-custom-nginx"
COPY site/ /usr/share/nginx/html/
```

**커스텀 포인트:**
- `FROM nginx:alpine` — nginx 웹서버가 포함된 경량 베이스 이미지 사용
- `COPY site/ ...` — 내 정적 페이지(index.html)를 nginx 웹 루트에 복사하여 기본 페이지 대체

### 빌드

```bash
$ docker build -t my-web:1.0 .
[+] Building 4.7s (7/7) FINISHED
 => [internal] load build definition from Dockerfile
 => [internal] load metadata for docker.io/library/nginx:alpine
 => [1/2] FROM docker.io/library/nginx:alpine
 => [2/2] COPY site/ /usr/share/nginx/html/
 => exporting to image
 => => naming to docker.io/library/my-web:1.0
```

```bash
$ docker images
IMAGE                ID
hello-world:latest   c3cbe1cc1aa5
my-web:1.0           c9b2c07666a4
ubuntu:latest        3131b4cc82a7
```

### Docker 이미지의 불변성 (Immutability)

Docker 이미지는 **빌드된 후 변경될 수 없는 불변 객체**입니다.

#### 이미지 불변성의 의미
Dockerfile 작성
↓
docker build 실행
↓
이미지 생성 (고정됨) ← 이 시점부터 변경 불가
↓
컨테이너 실행 (이미지 기반)
↓
컨테이너 내부 파일 수정 (컨테이너만 변경, 이미지는 영향 없음)

#### 실제 예시

```bash
# 1. 이미지 빌드
$ docker build -t my-custom-nginx .
Successfully built abc123def456

# 2. 컨테이너 실행
$ docker run -d --name web1 my-custom-nginx

# 3. 컨테이너 내부 파일 수정
$ docker exec web1 sh -c "echo 'modified' > /usr/share/nginx/html/test.txt"

# 4. 같은 이미지로 새 컨테이너 실행
$ docker run -d --name web2 my-custom-nginx

# 5. 확인: web2에는 수정 사항이 없음!
$ docker exec web2 ls /usr/share/nginx/html/
# test.txt 파일이 없음 (web1에만 있음)
```

#### 이미지 불변성의 장점
| 장점 | 설명 |
|------|------|
| 재현성 | 같은 이미지로 만든 컨테이너는 항상 동일한 환경 |
| 신뢰성 | 이미지가 변경되지 않으므로 예측 가능한 동작 |
| 버전 관리 | 이미지 태그로 버전 관리 가능 (v1.0, v2.0) |
| 배포 안정성 | 프로덕션에서 동일한 이미지 사용 보장 |

#### 변경이 필요하면?
- 이미지를 수정하려면 새로운 이미지를 빌드해야 한다.

# Dockerfile 수정
```bash
$ nano Dockerfile
# (내용 변경)

# 새 이미지 빌드
$ docker build -t my-custom-nginx:v2 .

# 새 이미지로 컨테이너 실행
$ docker run -d my-custom-nginx:v2
```

---

## 4. 포트 매핑 및 접속 증거

동일 이미지로 컨테이너 2개를 서로 다른 포트(8080, 8081)에 매핑해 실행했다.
`-p 호스트포트:컨테이너포트` 로 외부(Mac)에서 컨테이너 내부 nginx(80)에 접속할 수 있다.

```bash
$ docker run -d -p 8080:80 --name web1 my-web:1.0
c59474359b9bb16eebd932fd2a939a908b9d782aef80a7f6079dcf891873ab92

$ docker run -d -p 8081:80 --name web2 my-web:1.0
38b830efaf24...

$ docker ps
CONTAINER ID   IMAGE        COMMAND                  STATUS   PORTS                  NAMES
38b830efaf24   my-web:1.0   "/docker-entrypoint.…"   Up       0.0.0.0:8081->80/tcp   web2
c59474359b9b   my-web:1.0   "/docker-entrypoint.…"   Up       0.0.0.0:8080->80/tcp   web1
```

**브라우저 접속 화면:**

<img width="1466" height="850" alt="스크린샷 2026-07-30 오후 1 14 49" src="https://github.com/user-attachments/assets/0002a34c-5267-4a37-9826-70f43945074c" />


<img width="1466" height="853" alt="스크린샷 2026-07-30 오후 1 17 01" src="https://github.com/user-attachments/assets/04a9c0eb-2b01-4f59-9c01-4d6613cf9bf5" />

---

### 포트 충돌 진단 및 해결

Docker 컨테이너는 **네트워크 네임스페이스**라는 독립된 네트워크 환경에서 실행된다.
호스트(Mac)의 포트와 컨테이너 포트를 매핑할 때, 호스트 포트가 이미 사용 중이면 충돌이 발생한다.

#### 네트워크 네임스페이스란?
호스트 (macOS)
├── 포트 8080 (web1 컨테이너에 매핑)
├── 포트 8081 (web2 컨테이너에 매핑)
└── 포트 3000 (다른 애플리케이션 사용 중)

컨테이너 1 (네임스페이스 격리)
└── 포트 80 (nginx 실행)

컨테이너 2 (네임스페이스 격리)
└── 포트 80 (nginx 실행)

**각 컨테이너는 독립된 네트워크 환경을 가지므로, 같은 포트(80)를 사용해도 충돌하지 않는다.**
하지만 **호스트 포트는 공유되므로**, 같은 포트에 여러 컨테이너를 매핑할 수 없다.


#### 포트 충돌 진단 단계

##### 1단계: 호스트의 포트 사용 현황 확인

**macOS에서 특정 포트를 사용 중인 프로세스 찾기:**

```bash
# 포트 8080을 사용 중인 프로세스 확인
$ lsof -i :8080
COMMAND   PID     USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
node      1234    user   12u  IPv4 0x1234abcd      0t0  TCP *:8080 (LISTEN)
설명:

COMMAND: 프로세스 이름 (node, python, java 등)
PID: 프로세스 ID
USER: 실행 사용자
NODE NAME: 포트 상태 (LISTEN = 대기 중)
```

#### 2단계: 포트를 사용 중인 프로세스 종료 또는 변경
- 옵션 A: 기존 프로세스 종료
```bash
# PID 1234인 프로세스 종료
$ kill 1234

# 강제 종료가 필요한 경우
$ kill -9 1234
```

- 옵션 B: 컨테이너 포트 매핑 변경
```bash
# 기존 컨테이너 중지
$ docker stop web1

# 다른 포트로 재실행
$ docker run -d -p 9000:80 --name web1 my-web:1.0
```

#### 3단계: 포트 충돌 해결 확인
```bash
# 포트 8080이 이제 사용 가능한지 확인
$ lsof -i :8080
# (출력 없음 = 포트 사용 가능)

# 컨테이너 정상 실행 확인
$ docker ps
CONTAINER ID   IMAGE        PORTS                  NAMES
abc123def456   my-web:1.0   0.0.0.0:8080->80/tcp   web1
```

#### 실제 포트 충돌 시나리오 및 해결
- 시나리오: 포트 8080에서 충돌 발생
```bash
# 1. 현재 상태 확인
$ docker ps
CONTAINER ID   IMAGE        PORTS                  NAMES
abc123def456   my-web:1.0   0.0.0.0:8080->80/tcp   web1

# 2. 포트 8080 사용 현황 확인
$ lsof -i :8080
COMMAND   PID     USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
node      5678    user   12u  IPv4 0x5678efgh      0t0  TCP *:8080 (LISTEN)

# 3. Node.js 프로세스가 포트 8080을 사용 중 → 종료
$ kill 5678

# 4. 다시 확인
$ lsof -i :8080
# (출력 없음 = 포트 해제됨)

# 5. 컨테이너 재시작
$ docker restart web1

# 6. 브라우저에서 http://localhost:8080 접속 성공
```

#### 보안 고려사항

| 주의사항	 | 설명 |
|------|----------|
| 포트 범위	| 1-1023: 시스템 포트 (root 권한 필요), 1024-65535: 사용자 포트 |
| 방화벽	| -p 0.0.0.0:8080:80 사용 시 모든 인터페이스에 노출 (보안 위험) |
| 로컬만 노출	| -p 127.0.0.1:8080:80 사용 시 localhost에서만 접속 가능 |
| 프로세스 강제 종료	| kill -9는 정상 종료 기회를 주지 않으므로 마지막 수단 |


### Dockerfile에서의 경로: 절대 경로 vs 상대 경로

Dockerfile 작성 시 `COPY`, `WORKDIR`, `RUN` 등에서 경로를 지정할 때, **절대 경로**와 **상대 경로** 중 어느 것을 선택할지 결정해야 한다.

#### 경로 선택 기준표

| 상황 | 권장 경로 | 이유 | 예시 |
|------|---------|------|------|
| **컨테이너 내 고정 위치** | 절대 경로 | 명확하고 이식성 높음 | `COPY site/ /usr/share/nginx/html/` |
| **Dockerfile과 같은 디렉토리** | 상대 경로 | 간결하고 유지보수 용이 | `COPY . /app/` |
| **중첩된 디렉토리 구조** | 절대 경로 | 경로 추적이 명확함 | `WORKDIR /app/src/config` |
| **빌드 컨텍스트 내 파일** | 상대 경로 | 빌드 컨텍스트 기준으로 동작 | `COPY ./docker/config.json /etc/app/` |


#### 절대 경로 사용 (권장)

**정의:** 컨테이너 루트(`/`)부터 시작하는 전체 경로

```dockerfile
FROM nginx:alpine
COPY site/ /usr/share/nginx/html/
WORKDIR /usr/share/nginx/html/
RUN ls -la
```

- 장점
✅ 경로가 명확하고 예측 가능
✅ 다른 사람이 읽기 쉬움
✅ 컨테이너 내 정확한 위치 보장

- 단점
❌ 타이핑이 길어짐


#### 상대 경로 사용
정의: 현재 작업 디렉토리(WORKDIR)를 기준으로 한 경로

```bash
FROM nginx:alpine
WORKDIR /usr/share/nginx/html/
COPY site/ .
RUN ls -la
```

- 장점
✅ 코드가 간결함
✅ WORKDIR을 명시하면 구조가 명확


- 단점
❌ WORKDIR이 설정되지 않으면 혼동 가능
❌ 여러 WORKDIR 변경 시 추적 어려움

#### 실제 프로젝트에서의 경로 선택
현재 프로젝트의 Dockerfile:
FROM nginx:alpine
LABEL org.opencontainers.image.title="my-custom-nginx"
COPY site/ /usr/share/nginx/html/

선택 이유: 절대 경로 사용 (/usr/share/nginx/html/)

nginx의 표준 웹 루트 위치로, 모든 nginx 사용자가 인식하는 경로
명확하고 이식성이 높음


상대 경로 사용 (site/)

빌드 컨텍스트(프로젝트 루트) 기준으로 site/ 디렉토리 지정
프로젝트 구조에 따라 유연하게 대응

#### 경로 오류 진단
문제: 잘못된 상대 경로

FROM nginx:alpine
COPY ./site/ ./html/  # ❌ 상대 경로만 사용 → 위치 불명확

해결: 절대 경로로 명시

FROM nginx:alpine
COPY ./site/ /usr/share/nginx/html/  # ✅ 명확한 위치 지정

#### 베스트 프랙티스

##### 1. WORKDIR로 기본 작업 디렉토리 설정 (절대 경로)
WORKDIR /app

##### 2. 상대 경로로 파일 복사 (WORKDIR 기준)
COPY . .

##### 3. 필요시 절대 경로로 명시적 지정
RUN mkdir -p /var/log/app

---

## 5. 볼륨 (데이터 영속성)

볼륨은 컨테이너와 **분리된 저장 공간**이다. 컨테이너를 삭제해도 볼륨에 저장된 데이터는 유지된다.
이를 증명하기 위해 볼륨을 만들고 파일을 쓴 뒤, 컨테이너를 삭제하고 새 컨테이너에서 같은 파일을 확인했다.

```bash
# 1) 볼륨 생성
$ docker volume create mydata
mydata

# 2) 볼륨을 연결한 컨테이너에서 파일 작성
$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
$ docker exec -it vol-test bash
root@e166337e8609:/# echo "hello volume" > /data/hello.txt
root@e166337e8609:/# cat /data/hello.txt
hello volume
root@e166337e8609:/# exit

# 3) 컨테이너 삭제 (데이터가 사라지는지 확인하려고)
$ docker rm -f vol-test
vol-test

# 4) 새 컨테이너에 같은 볼륨(mydata)을 연결
$ docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity

# 5) 이전에 쓴 파일이 그대로 남아있음 → 데이터 영속성 증명
$ docker exec vol-test2 cat /data/hello.txt
hello volume
```

**결론:** 파일을 만든 컨테이너(vol-test)를 삭제했음에도, 새 컨테이너(vol-test2)에서 동일한 데이터를 읽을 수 있었다.
데이터가 컨테이너가 아닌 볼륨(mydata)에 저장되기 때문이다.

## 5-1. 바인드마운트 (Bind Mount): 호스트 디렉토리 직접 연결

볼륨(Named Volume)은 Docker가 관리하는 저장 공간이지만, **바인드마운트**는 호스트의 특정 디렉토리를 컨테이너에 직접 연결하는 것이다.

### 바인드마운트 vs 볼륨 비교

| 구분 | 바인드마운트 | 볼륨 (Named Volume) |
|------|------------|-------------------|
| **관리** | 호스트 파일시스템 직접 관리 | Docker가 관리 |
| **위치** | 호스트의 임의 경로 | `/var/lib/docker/volumes/` |
| **사용 사례** | 소스코드 공유, 설정 파일 | 데이터베이스, 영속 데이터 |
| **성능** | 호스트 파일시스템 의존 | Docker 최적화 |
| **삭제 시** | 호스트 파일 유지 | Docker가 함께 삭제 |

### 바인드마운트 실습

#### 1단계: 호스트에 공유 디렉토리 생성

```bash
# 호스트(Mac)에서 공유할 디렉토리 생성
$ mkdir -p ~/docker-share/data
$ echo "This is shared data from host" > ~/docker-share/data/host-file.txt

# 확인
$ cat ~/docker-share/data/host-file.txt
This is shared data from host
```

#### 2단계: 바인드마운트로 컨테이너 실행
```bash
# -v 호스트경로:컨테이너경로 로 바인드마운트
$ docker run -d --name bind-test -v ~/docker-share/data:/container-data ubuntu sleep infinity

# 컨테이너에서 호스트 파일 확인
$ docker exec bind-test cat /container-data/host-file.txt
This is shared data from host
```

#### 3단계: 컨테이너에서 파일 생성 및 호스트에서 확인
```bash
# 컨테이너에서 새 파일 생성
$ docker exec bind-test sh -c "echo 'Created in container' > /container-data/container-file.txt"

# 호스트(Mac)에서 확인
$ cat ~/docker-share/data/container-file.txt
Created in container

# 호스트 파일 목록
$ ls -la ~/docker-share/data/
total 16
drwxr-xr-x   4 user  staff   128 Jul 30 14:25 .
drwxr-xr-x   3 user  staff    96 Jul 30 14:20 ..
-rw-r--r--   1 user  staff    30 Jul 30 14:20 host-file.txt
-rw-r--r--   1 user  staff    24 Jul 30 14:25 container-file.txt
결론: 호스트와 컨테이너가 동일한 파일을 실시간으로 공유합니다.
```

####4단계: 컨테이너 삭제 후 호스트 파일 확인
```bash
# 컨테이너 삭제
$ docker rm -f bind-test

# 호스트 파일은 여전히 존재
$ cat ~/docker-share/data/container-file.txt
Created in container
```

중요: 바인드마운트는 호스트 파일시스템을 사용하므로, 컨테이너 삭제 후에도 호스트 파일은 유지됩니다.


#### 바인드마운트 사용 사례
- 사례 1: 소스코드 개발 환경 공유
```bash
# 호스트의 프로젝트 디렉토리를 컨테이너의 /app에 연결

$ docker run -d --name dev-app \
  -v ~/my-project:/app \
  node:16 \
  npm start

# 호스트에서 코드 수정 → 컨테이너에서 즉시 반영
```

- 사례 2: 설정 파일 공유
```bash 
# 호스트의 설정 파일을 컨테이너에 제공
$ docker run -d --name nginx-custom \
  -v ~/nginx-config/nginx.conf:/etc/nginx/nginx.conf \
  nginx:alpine
```

#### 백업 및 복구 절차

#### 백업 절차
```bash
1단계: 백업 디렉토리 생성
# 백업 저장소 생성
$ mkdir -p ~/backups
```

```bash
2단계: 데이터 백업 (tar 압축)
# 바인드마운트 디렉토리를 tar로 압축
$ tar -czf ~/backups/data-backup-$(date +%Y%m%d-%H%M%S).tar.gz ~/docker-share/data/

# 백업 파일 확인
$ ls -lh ~/backups/
total 8
-rw-r--r--  1 user  staff  512B Jul 30 14:30 data-backup-20260730-143000.tar.gz
```

설명: tar -czf: tar 파일 생성 (-c), gzip 압축 (-z), 파일명 지정 (-f)
$(date +%Y%m%d-%H%M%S): 백업 시간을 파일명에 포함 (예: 20260730-143000)

```bash
3단계: 정기 백업 자동화 (선택사항)
# cron 작업으로 매일 자정에 백업
$ crontab -e

# 다음 라인 추가:
0 0 * * * tar -czf ~/backups/data-backup-$(date +\%Y\%m\%d-\%H\%M\%S).tar.gz ~/docker-share/data/
```

#### 복구 절차
```bash
1단계: 현재 데이터 확인
$ ls -la ~/docker-share/data/
total 16
-rw-r--r--  1 user  staff  30 Jul 30 14:20 host-file.txt
-rw-r--r--  1 user  staff  24 Jul 30 14:25 container-file.txt
```

```bash
2단계: 데이터 삭제 (복구 테스트)
# 실수로 파일 삭제
$ rm ~/docker-share/data/container-file.txt

# 확인
$ ls -la ~/docker-share/data/
total 8
-rw-r--r--  1 user  staff  30 Jul 30 14:20 host-file.txt
```

```bash
3단계: 백업에서 복구
# 백업 파일 확인
$ ls ~/backups/
data-backup-20260730-143000.tar.gz

# 복구 (기존 디렉토리 덮어쓰기)
$ tar -xzf ~/backups/data-backup-20260730-143000.tar.gz -C /

# 또는 특정 디렉토리에만 복구
$ mkdir -p ~/docker-share-restored
$ tar -xzf ~/backups/data-backup-20260730-143000.tar.gz -C ~/docker-share-restored

# 복구 확인
$ ls -la ~/docker-share/data/
total 16
-rw-r--r--  1 user  staff  30 Jul 30 14:20 host-file.txt
-rw-r--r--  1 user  staff  24 Jul 30 14:25 container-file.txt  # 복구됨!
```

- 설명

tar -xzf: tar 파일 추출 (-x), gzip 해제 (-z), 파일명 지정 (-f)
-C 경로: 추출 대상 디렉토리 지정


#### 백업/복구 체크리스트
| 단계 | 명령 | 확인 사항 |
|------|------|-----------|
| 백업 | `tar -czf ~/backups/backup.tar.gz 경로/` | 파일 생성 여부, 파일 크기 |
| 백업 검증 | `tar -tzf ~/backups/backup.tar.gz` | 백업 내용 확인 |
| 복구 | `tar -xzf ~/backups/backup.tar.gz -C /` | 파일 복구 여부 |
| 복구 검증 | `ls -la 복구경로/` | 파일 개수, 타임스탬프 |

#### 바인드마운트 주의사항
| 주의사항 | 설명 | 해결 방법 |
|----------|------|-----------|
| 권한 문제 | 컨테이너 사용자와 호스트 사용자의 UID 불일치 | `--user` 옵션으로 사용자 지정 |
| 성능 저하 | macOS에서 바인드마운트 성능 낮음 | 볼륨 사용 권장 |
| 파일 동기화 지연 | 호스트-컨테이너 간 파일 동기화 지연 | 명시적으로 sync 실행 |
| 삭제 위험 | 호스트 파일 실수 삭제 시 복구 어려움 | 정기 백업 필수 |


## 트러블슈팅

Docker 사용 중 발생하는 일반적인 문제와 해결 방법을 정리했다.

### 트러블슈팅 명령어 및 실행 시간 표

| 문제 | 진단 명령 | 예상 실행시간 | 출력 예시 | 해결 방법 |
|------|---------|------------|---------|---------|
| **컨테이너 실행 안 됨** | `docker ps -a` | ~1초 | `STATUS: Exited (1)` | `docker logs 컨테이너명` 으로 에러 확인 |
| **이미지 빌드 실패** | `docker build -t my-app .` | 30초~5분 | `ERROR: failed to build` | Dockerfile 문법 확인, 베이스 이미지 존재 확인 |
| **포트 충돌** | `lsof -i :8080` | ~1초 | `COMMAND PID ... TCP *:8080 (LISTEN)` | `kill PID` 또는 다른 포트로 변경 |
| **디스크 공간 부족** | `docker system df` | ~1초 | `RECLAIMABLE: 2.5GB` | `docker system prune -a` 로 미사용 이미지 삭제 |
| **네트워크 연결 안 됨** | `docker network ls` | ~1초 | 네트워크 목록 출력 | `docker network inspect 네트워크명` 으로 상세 확인 |
| **볼륨 마운트 실패** | `docker inspect 컨테이너명` | ~1초 | `"Mounts": [...]` | 호스트 경로 존재 확인, 권한 확인 |
| **컨테이너 느림** | `docker stats 컨테이너명` | 실시간 | `CPU %, MEM USAGE` | 리소스 제한 조정 또는 컨테이너 재시작 |
| **이미지 레이어 확인** | `docker history 이미지명` | ~1초 | 각 레이어 크기 출력 | 불필요한 레이어 제거로 이미지 최적화 |

### 주요 진단 명령어 상세 설명

#### 1. 컨테이너 상태 확인

```bash
# 실행 중인 컨테이너만 표시
$ docker ps
CONTAINER ID   IMAGE        STATUS        PORTS                  NAMES
abc123def456   my-web:1.0   Up 2 minutes  0.0.0.0:8080->80/tcp   web1

# 모든 컨테이너 표시 (중지된 것 포함)
$ docker ps -a
CONTAINER ID   IMAGE        STATUS                     PORTS     NAMES
abc123def456   my-web:1.0   Up 2 minutes              8080/tcp   web1
def456ghi789   my-web:1.0   Exited (1) 5 minutes ago            web2

# 실행 시간: ~1초


진단 포인트:

STATUS: 컨테이너 상태 (Up = 실행 중, Exited = 중지됨)
Exited (1): 에러 코드 1로 종료됨 → docker logs 확인 필요

# 컨테이너 로그 출력
$ docker logs web1
[nginx] 2026-07-30 14:25:30 Starting nginx...
[nginx] 2026-07-30 14:25:31 nginx started successfully

# 실시간 로그 모니터링
$ docker logs -f web1
[nginx] 2026-07-30 14:25:30 Starting nginx...
[nginx] 2026-07-30 14:25:31 nginx started successfully
# (Ctrl+C로 종료)

# 최근 50줄만 출력
$ docker logs --tail 50 web1

# 실행 시간: ~1초 (실시간 모니터링은 지속)

진단 포인트:

STATUS: 컨테이너 상태 (Up = 실행 중, Exited = 중지됨)
Exited (1): 에러 코드 1로 종료됨 → docker logs 확인 필요
```


#### 2. 컨테이너 로그 확인
```bash
# 컨테이너 로그 출력
$ docker logs web1
[nginx] 2026-07-30 14:25:30 Starting nginx...
[nginx] 2026-07-30 14:25:31 nginx started successfully

# 실시간 로그 모니터링
$ docker logs -f web1
[nginx] 2026-07-30 14:25:30 Starting nginx...
[nginx] 2026-07-30 14:25:31 nginx started successfully
# (Ctrl+C로 종료)

# 최근 50줄만 출력
$ docker logs --tail 50 web1

# 실행 시간: ~1초 (실시간 모니터링은 지속)
```

#### 3. 포트 충돌 진단
```bash
# macOS에서 포트 8080 사용 현황 확인
$ lsof -i :8080
COMMAND   PID     USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
node      1234    user   12u  IPv4 0x1234abcd      0t0  TCP *:8080 (LISTEN)

# 실행 시간: ~1초

# 해결: 프로세스 종료
$ kill 1234
$ lsof -i :8080
# (출력 없음 = 포트 해제됨)
```

#### 4. 디스크 사용량 확인
```bash 
# Docker 시스템 전체 디스크 사용량
$ docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          5         2         2.5GB     1.8GB (72%)
Containers      3         1         512MB     512MB (100%)
Local Volumes   2         1         256MB     0B (0%)

# 실행 시간: ~1초

# 미사용 이미지·컨테이너·볼륨 정리
$ docker system prune -a
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all build cache

Total reclaimed space: 1.8GB

# 실행 시간: 10초~1분 (삭제 대상 크기에 따라)
```

#### 5. 컨테이너 리소스 사용량 모니터링
```bash
# 실시간 리소스 모니터링
$ docker stats web1
CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT     MEM %     NET I/O
abc123def456   web1      0.05%     12.3MiB / 1GiB        1.2%      1.2MB / 500KB

# 실행 시간: 실시간 (Ctrl+C로 종료)

# 특정 컨테이너만 모니터링
$ docker stats --no-stream web1
# (한 번만 출력)
```

#### 6. 이미지 레이어 확인
```bash 
# 이미지의 각 레이어 크기 확인
$ docker history my-web:1.0
IMAGE          CREATED        CREATED BY                                      SIZE      COMMENT
abc123def456   2 days ago     /bin/sh -c #(nop) COPY site/ /usr/share/ng...  512B
def456ghi789   2 days ago     /bin/sh -c #(nop) LABEL org.opencontainers...  0B
ghi789jkl012   2 weeks ago    /bin/sh -c apk add --no-cache curl             5.2MB
jkl012mno345   2 weeks ago    FROM nginx:alpine                               42.3MB

# 실행 시간: ~1초

# 이미지 최적화 팁:
# - 큰 레이어는 불필요한 파일 포함 여부 확인
# - 여러 RUN 명령을 && 로 연결하여 레이어 수 감소
```

#### 7. 네트워크 진단
```bash
# Docker 네트워크 목록
$ docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
abc123def456   bridge    bridge    local
def456ghi789   host      host      local
ghi789jkl012   none      null      local

# 실행 시간: ~1초

# 특정 네트워크 상세 정보
$ docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "abc123def456...",
        "Containers": {
            "web1": {
                "IPv4Address": "172.17.0.2/16"
            }
        }
    }
]

# 실행 시간: ~1초
```

#### 8. 트러블슈팅 체크리스트
- 컨테이너 문제 발생 시 진단 순서
1️⃣ 컨테이너 상태 확인
   └─ docker ps -a
   └─ STATUS 확인: Up / Exited?

2️⃣ 컨테이너 로그 확인
   └─ docker logs 컨테이너명
   └─ 에러 메시지 분석

3️⃣ 포트 확인 (네트워크 관련)
   └─ docker port 컨테이너명
   └─ lsof -i :포트번호

4️⃣ 리소스 확인 (성능 관련)
   └─ docker stats 컨테이너명
   └─ CPU, 메모리 사용량 확인

5️⃣ 볼륨 확인 (데이터 관련)
   └─ docker inspect 컨테이너명
   └─ Mounts 섹션 확인

6️⃣ 네트워크 확인 (통신 관련)
   └─ docker network inspect 네트워크명
   └─ 컨테이너 IP 주소 확인

- 일반적인 에러 메시지 및 해결
| 에러 메시지 | 원인 | 해결 방법 |
|-------------|------|-----------|
| `Error response from daemon: driver failed programming external connectivity` | 포트 충돌 | `lsof -i :포트` 로 충돌 확인, 프로세스 종료 또는 포트 변경 |
| `no such file or directory` | 마운트 경로 없음 | 호스트 경로 존재 확인: `ls -la 경로` |
| `permission denied` | 권한 부족 | `sudo` 사용 또는 사용자 그룹 추가: `sudo usermod -aG docker $USER` |
| `image not found` | 이미지 없음 | `docker pull 이미지명` 으로 다운로드 |
| `container already exists` | 같은 이름의 컨테이너 존재 | `docker rm 컨테이너명` 으로 삭제 후 재실행 |


## 6. Git 설정 및 GitHub 연동

Git으로 로컬 버전 관리를 설정하고, GitHub 원격 저장소에 연결해 소스코드를 업로드했다.

**Git과 GitHub의 역할 차이:**
- **Git**: 내 컴퓨터에서 동작하는 버전 관리 도구. 파일의 변경 이력을 커밋 단위로 기록한다. (로컬)
- **GitHub**: 그 커밋들을 인터넷에 올려 공유·협업하는 웹 플랫폼. (원격)

### Git 사용자 정보 및 기본 브랜치 설정

```bash
$ git config --global user.name "daehyunchoi-cell"
$ git config --global user.email "***@***"   # 민감정보 마스킹
$ git config --list
credential.helper=osxkeychain
init.defaultbranch=main
user.name=daehyunchoi-cell
user.email=***@***
```

### 로컬 저장소 초기화 및 첫 커밋

```bash
$ git init
Initialized empty Git repository in .../developer-workstation/.git/

$ git add .
$ git commit -m "첫 커밋: Docker 실습 및 README 작성"
[main (root-commit) 668d745] 첫 커밋: Docker 실습 및 README 작성
 3 files changed, 240 insertions(+)
```

### GitHub 원격 저장소 연결 및 push

```bash
$ git remote add origin https://github.com/daehyunchoi-cell/developer-workstation.git
$ git branch -M main
$ git push -u origin main
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

**인증:** GitHub는 HTTPS 비밀번호 인증을 지원하지 않으므로, Personal Access Token(PAT, `repo` 권한)을 발급해 push 인증에 사용했다. (토큰은 문서에 노출하지 않음)
