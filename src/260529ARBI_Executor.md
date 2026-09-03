# 260529ARBI_Executor.md — L2→L1 인출 헬퍼 페이지

L2 의 `withdrawEth` 트랜잭션 해시 한 줄만 입력하면 L1 `Outbox.executeTransaction` 의 인자 8개를 자동 생성하고, 지갑이 있으면 1-클릭으로 인출까지 마치는 **단일 정적 HTML 페이지**입니다.

파일: **`/root/ArbiEver/executor.html`** (이 서버 10.8.0.10) — 17 KB, 의존성은 CDN 의 ethers.js v5 하나뿐.

---

## 지금 즉시 미리보기 (이 서버에서 임시 호스팅 중)

```
http://10.8.0.10:8765/executor.html
```
VPN 에 붙은 채로 위 URL 접속. (외부 인터넷에선 안 보입니다 — 의도된 것.) 동작 확인 절차:

1. ArbiEver Blockscout 등에서 본인의 `withdrawEth` 트랜잭션 해시 복사
2. 페이지 입력란에 붙여넣고 "조회"
3. 15분 이내(확정 전)면 → ⏳ "아직 확정되지 않았습니다" + 본인 정보 노출
4. 15분 이후(확정됨)면 → ✅ 8개 인자 표시 + "지갑으로 인출" 버튼 활성화

임시 서버 중지:
```bash
pkill -f "http.server 8765"
```

---

## 페이지가 하는 일 (한 줄 흐름)

```
[L2 tx hash]
   ↓ getTransactionReceipt        (ArbiEver L2 RPC)
   ↓ logs 에서 L2ToL1Tx 추출      (ArbSys 이벤트, topic0 매칭)
   ↓ Interface.parseLog           (caller / destination / position / arbBlockNum / ethBlockNum / timestamp / callvalue / data)
   ↓ ArbSys.sendMerkleTreeState() (현재 size)
   ↓ NodeInterface.constructOutboxProof(size, position)  ← 확정 전이면 revert
                                  └─ revert면 친절한 "기다리세요" 메시지
   ↓
[8개 인자 + 1-클릭 실행 버튼]
   ↓
EtherEver L1 RPC 로 Outbox.executeTransaction 호출 (지갑 서명)
```

상호작용하는 RPC 는 두 개:
- **L2**: `https://rpc-arbi.ever-chain.xyz` (조회 전용)
- **L1**: 지갑이 자동 라우팅 (사용자가 EtherEver L1 에 연결돼 있어야)

둘 다 CORS `*` 허용이라 어떤 도메인에서 열어도 동작합니다.

---

## 영구 호스팅 옵션 4가지

### 옵션 A — 로컬 파일 그대로 (가장 단순)
사용자가 파일을 다운로드해 더블클릭하면 끝. CORS 무관.
- 단점: 일반 사용자에게 URL 공유 불가

### 옵션 B — 10.8.0.6 의 nginx 정적 마운트 (권장)
EtherEver Blockscout 의 proxy 컨테이너에 정적 파일 한 줄 추가.

```bash
# 10.8.0.6 에서
scp /root/ArbiEver/executor.html root@10.8.0.6:/root/blockscout/docker-compose/
# proxy 컨테이너 안의 nginx 가 /executor.html 을 서빙하도록 docker-compose.yml 의 proxy 서비스 volumes 에 한 줄 추가
#   - ./executor.html:/etc/nginx/html/executor.html
# 그리고 nginx 설정에 location /executor.html { ... } 또는 root 변경.
# 또는 더 간단히: 별도 컨테이너 (nginx:alpine) 를 4007 같은 포트로 띄워서 라우팅
```

가장 빠른 길은 **별도 nginx 컨테이너**:
```yaml
  executor:
    image: nginx:alpine
    container_name: arbiever-executor
    ports:
      - "4007:80"
    volumes:
      - ./executor.html:/usr/share/nginx/html/index.html:ro
    restart: unless-stopped
```
그 후 Cloudflare 에서 `withdraw.ever-chain.xyz` 같은 서브도메인을 4007 로 포워딩.

### 옵션 C — GitHub Pages (외부 정적 호스팅, 무료)
1. 새 repo: `makewalletfirst/ArbiEver-Executor` (public)
2. `executor.html` 을 `index.html` 로 push
3. Settings → Pages → main branch / root 선택
4. `https://makewalletfirst.github.io/ArbiEver-Executor/` 가 곧 열림

장점: 운영 부담 0. RPC 만 CORS 열려있으면 됨 (이미 열림 ✓).

### 옵션 D — IPFS / 분산 호스팅
탈중앙적이지만 운영 학습용 chain 엔 과한 듯. 생략.

---

## 코드 구조 (한 파일 안)

| 섹션 | 줄 (대략) | 역할 |
|---|---|---|
| `<style>` | 1~95 | 다크 친화 디자인. system font + 단색 팔레트 |
| `<body>` HTML | 96~155 | 입력란, 진행 상태, 결과 카드, 실행 섹션 |
| 상수 정의 | 200~225 | RPC URL, precompile/Outbox 주소, ABI |
| `lookup()` | 250~310 | L2 영수증 → 이벤트 → 머클 증명 |
| `renderOutput()` | 330~380 | 8 개 인자 카드 + 복사 버튼 |
| `execute()` 핸들러 | 400~450 | window.ethereum 으로 L1 트랜잭션 전송 |

수정 포인트:
- 다른 체인용으로 재활용: 상단 상수 5줄 (`L2_RPC`, `L1_RPC`, `ETHEREVER_CHAIN_ID`, `OUTBOX`, `L2_TO_L1_TX_TOPIC`) 만 바꾸면 됨
- 디자인 변경: `<style>` 섹션 색상 변수 (`#0f1115`, `#3b82f6`, `#10b981`) 만 수정

---

## 운영자에게 — 다음 작업 후보

이번 페이지로 L2→L1 출금 사이클이 **완전 셀프 서비스** 가 됐습니다:

| 단계 | 사용자 인터페이스 |
|---|---|
| L1→L2 입금 | DepositHelper proxy (이미 verify됨) — Write Contract |
| L2 출금 시작 | WithdrawHelper (이미 verify됨) — Write Contract |
| L2→L1 인출 | **이 헬퍼 페이지** ← **NEW** |

남은 운영 개선 후보:
- 로고/스타일을 ArbiEver 브랜드에 맞춤
- `position` 외 다른 head/tail 도 보여주기 (디버깅용)
- 다국어 (영어 토글)
- 출금 status checker — 본인 출금 모두 목록 (실행 가능/대기 중 분류)
