# EverChain Bridge Helper

EverChain 의 EVM L1 ↔ L2 (EtherEver ↔ ArbiEver) 입출금을
**Blockscout 의 Write Contract UI 대신 단일 정적 페이지 한 곳**에서 처리하기 위한 헬퍼입니다.

[Docker Hub: `silverruler/everchain-bridge-helper`](https://hub.docker.com/r/silverruler/everchain-bridge-helper)

---

## 무엇을 하나

세 단계의 L1↔L2 자금 이동을 한 페이지 3개 탭으로 묶었습니다:

| 탭 | 동작 | 컨트랙트 | 체인 |
|---|---|---|---|
| ⬇️ **L1 → L2 입금** | `DepositHelper.depositEthTo` / `depositEthToSelf` | `0x1d69eA04…0eC2` | EtherEver L1 |
| ⬆️ **L2 → L1 출금 시작** | `WithdrawHelper.withdrawEth` / `withdrawEthToSelf` | `0x9c17CAc3…7c33` | ArbiEver L2 |
| ✅ **L1 인출 실행** | `Outbox.executeTransaction` (머클 증명 자동 생성) | `0xDBA33e4e…64Ae` | EtherEver L1 |

추가로:
- 지갑 연결 시 양쪽 체인의 잔액 자동 표시 + 수동 새로고침
- 양쪽 체인 칩 클릭으로 체인 전환 (`wallet_switchEthereumChain`)
- 1-클릭 주소 복사 / 로그아웃
- 다크/라이트 테마 토글 (localStorage 저장 + 시스템 선호 자동 감지)
- 출금 후 추천 인출 실행 시점(15분 + 1분 안전 마진) 표시
- 출금 결과의 tx 해시를 "인출 실행" 탭에 자동 입력

---

## 실행 방법

### Docker Compose (권장 — 운영용)
```bash
git clone https://github.com/makewalletfirst/EverChain-Bridge-Helper.git
cd EverChain-Bridge-Helper
docker compose up -d
```
→ `http://<서버IP>:8765/` 로 접속. 호스트의 8765 포트를 컨테이너의 80 으로 매핑.

종료 / 재기동:
```bash
docker compose down
docker compose up -d
```

### docker run (한 줄로 빠르게)
```bash
docker run -d -p 8765:80 --name everchain-helper --restart unless-stopped \
  silverruler/everchain-bridge-helper:latest
```

### 로컬에서 직접 빌드
```bash
git clone https://github.com/makewalletfirst/EverChain-Bridge-Helper.git
cd EverChain-Bridge-Helper
docker compose up -d --build
```

### Docker 없이 임시 미리보기
```bash
cd EverChain-Bridge-Helper
python3 -m http.server 8765
```

---

## 파일 구성

| 파일 | 역할 |
|---|---|
| `index.html` | 헬퍼 본체 (단일 파일, 의존성은 CDN ethers.js v5 하나) |
| `Dockerfile` | nginx:alpine 기반 정적 호스팅 |
| `arbiicon512.png` | favicon |
| `etherarbiswap.png` | 카카오톡 / 인스타 미리보기용 OG 이미지 |
| `README.md` | 이 문서 |
| `src/executor.html` | 원본 개발용 파일 (도커 빌드 시 index.html 로 들어감) |
| `src/260529ARBI_Executor.md` | 헬퍼의 동작 흐름·호스팅 옵션 4가지·코드 구조 안내 |

---

## OG 메타데이터에 대한 주의

`index.html` 의 `og:image` / `twitter:image` 가 상대 경로 (`etherarbiswap.png`) 로 돼 있어
카카오 / 페이스북 / 인스타 등은 미리보기를 표시 못합니다 (절대 URL 요구).

영구 도메인이 정해지면 다음과 같이 변경 후 재빌드:
```bash
sed -i 's|content="etherarbiswap.png"|content="https://<도메인>/etherarbiswap.png"|g' index.html
docker build -t silverruler/everchain-bridge-helper:latest .
docker push silverruler/everchain-bridge-helper:latest
```

---

## 사용된 컨트랙트 (모두 verified)

| 컨트랙트 | 체인 | 주소 |
|---|---|---|
| DepositHelper | EtherEver L1 | [`0x1d69eA04188Bf5e34AaDdc277a8cDE70076a0eC2`](https://etherever.ever-chain.xyz/address/0x1d69eA04188Bf5e34AaDdc277a8cDE70076a0eC2) |
| WithdrawHelper | ArbiEver L2 | [`0x9c17CAc31EB788b36Aac600cB623854359c67c33`](https://arbiever.ever-chain.xyz/address/0x9c17CAc31EB788b36Aac600cB623854359c67c33) |
| Outbox | EtherEver L1 | [`0xDBA33e4eFbEf4467eD0228C2b43b606B5F2964Ae`](https://etherever.ever-chain.xyz/address/0xDBA33e4eFbEf4467eD0228C2b43b606B5F2964Ae) |
| Inbox | EtherEver L1 | [`0x76b3772769cDD09Fb6A33e5f65fd13256808fc08`](https://etherever.ever-chain.xyz/address/0x76b3772769cDD09Fb6A33e5f65fd13256808fc08) |
| ArbSys (precompile) | ArbiEver L2 | `0x0000000000000000000000000000000000000064` |
| NodeInterface (precompile) | ArbiEver L2 | `0x00000000000000000000000000000000000000C8` |

---

## 라이선스

MIT
