FROM nginx:alpine
LABEL org.opencontainers.image.title="EverChain Bridge Helper"
LABEL org.opencontainers.image.description="EverChain의 EVM L1<->L2 입출금 Helper page (single static HTML)"
LABEL org.opencontainers.image.source="https://github.com/makewalletfirst"

COPY index.html             /usr/share/nginx/html/index.html
COPY contracts.html         /usr/share/nginx/html/contracts.html
COPY arbiicon512.png        /usr/share/nginx/html/arbiicon512.png
COPY etherarbiswap.png      /usr/share/nginx/html/etherarbiswap.png

EXPOSE 80
