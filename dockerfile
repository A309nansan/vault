# hashicorp/vault 와 vault 둘 다 존재하는데, 후자는 더 이상 update하지 않는다.
FROM hashicorp/vault:latest

# 시간 동기화 설정: Asia/Seoul 타임존으로 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# vault.json 파일을 /vault/config/로 복사
COPY vault.json /vault/config/vault.json

# Vault가 서비스를 제공하는 기본 포트
EXPOSE 8200

# ps -ef | grep vault
# vault server -config=/vault/config -dev-root-token-id= -dev-listen-address=0.0.0.0:8200 -config=/vault/config/vault.json
# 공식 이미지는 기본적으로 dev 옵션(빨강)을 강제 주입하기 때문에 옵션을 초기화 해야한다.

ENTRYPOINT []

CMD ["vault", "server", "-config=/vault/config/vault.json"]
