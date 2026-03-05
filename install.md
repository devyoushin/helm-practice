# 바이너리 파일을 직접 다운로드하여 설치

### 1. 최신 버전 압축 파일 다운로드
```bash
wget https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz
```

### 2. 압축 해제
```bash
tar -zxvf helm-v3.14.0-linux-amd64.tar.gz
```

### 3. 바이너리 파일을 시스템 실행 경로로 이동
```bash
sudo mv linux-amd64/helm /usr/local/bin/helm
```

### 4. 설치 확인
```bash
helm version
```
