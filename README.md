# 개발자용 작업실 꾸미기

## 프로젝트 개요

Docker, Git, Linux CLI를 활용하여 재현 가능한 개발 워크스테이션 환경을 구축하는 프로젝트입니다.

## 실행 환경

- OS: macOS (Apple Silicon M2)
- Terminal: zsh
- Container Runtime: OrbStack
- Editor: Visual Studio Code

## 수행 체크리스트

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

# 파일 권한 변경 (644 → 600: 그룹/그외 읽기 제거)
$ chmod 600 sample.txt
$ ls -l sample.txt
-rw-------  1 daehyunchoi  staff  0 ... sample.txt

# 디렉토리 권한 변경 (755 → 700: 그룹/그외 접근 제거)
$ chmod 700 sample-dir
$ ls -l
drwx------  2 daehyunchoi  staff  64 ... sample-dir
-rw-------  1 daehyunchoi  staff   0 ... sample.txt

# 원래 권한으로 복원
$ chmod 644 sample.txt
$ chmod 755 sample-dir
$ ls -l
drwxr-xr-x  2 daehyunchoi  staff  64 ... sample-dir
-rw-r--r--  1 daehyunchoi  staff   0 ... sample.txt
```

**관찰:** `600`, `700`으로 바꾸자 그룹/그외 권한(`r--`, `r-x`)이 `---`로 사라졌고, 복원 시 되돌아왔다. 폴더의 `x`는 "실행"이 아니라 "폴더 진입 가능"을 의미하므로 디렉토리는 보통 755를 사용한다.

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

## 트러블슈팅

### 1. Dockerfile 이름 오타로 빌드 실패 위험

- **문제:** VS Code에서 설계도 파일을 만들 때 이름을 `Dockfile`로 잘못 지정했다. 이대로 `docker build`를 하면 Docker가 기본 파일명인 `Dockerfile`을 찾지 못해 실패한다.
- **원인:** 파일명 오타(`Dockerfile` → `Dockfile`). `docker build`는 기본적으로 `Dockerfile`이라는 정확한 이름을 찾는다.
- **해결:** 파일을 우클릭 → Rename으로 `Dockerfile`로 수정한 뒤 빌드했고, 정상적으로 이미지가 생성됐다.

### 2. 따옴표 짝이 안 맞아 터미널이 입력 대기 상태에 갇힘

- **문제:** 볼륨 실습 중 `docker exec ... bash -c "..."` 명령을 붙여넣는 과정에서 명령이 줄바꿈으로 쪼개지며 따옴표(`"`) 짝이 깨졌다. 터미널이 `dquote>` 상태로 바뀌어 다음 명령을 받지 않았다.
- **원인:** 큰따옴표가 닫히지 않아, 셸이 "명령이 아직 끝나지 않았다"고 판단하고 나머지 입력을 기다렸다.
- **해결:** `Control + C`로 입력을 취소해 프롬프트를 복구했다. 이후 `docker exec -it`로 컨테이너에 직접 진입한 뒤, 파일 작성 명령을 짧게 한 줄씩 실행해 따옴표 문제를 피했다.

### 3. git push 시 비밀번호가 아닌 토큰 필요

- **문제:** `git push` 실행 시 Username/Password를 물었고, GitHub 로그인 비밀번호로는 인증되지 않는다.
- **원인:** GitHub는 2021년부터 HTTPS 방식에서 계정 비밀번호 인증을 폐지하고, Personal Access Token(PAT)을 요구한다.
- **해결:** GitHub Settings → Developer settings에서 `repo` 권한의 classic 토큰을 발급받아 Password 자리에 입력해 push에 성공했다. (토큰은 비밀번호에 준하는 정보이므로 문서·스크린샷에 노출하지 않도록 마스킹함.)

## 6. Git 설정 및 GitHub 연동

_(다음 단계에서 작성)_
