# Google Calendar — Current

## Passos

1. usuario com VIEW solicita status ou connect URL;
2. backend cria state OAuth e redireciona ao Google;
3. callback troca code por tokens, criptografa e persiste;
4. usuario com EDIT escolhe calendario ou usa `primary`;
5. create/update/delete de DateEvent tenta sincronizar;
6. desconexao remove a integracao.

## Comportamento de falha

Falha externa e registrada, mas nao reverte evento local. Token expirado tenta refresh; revogacao exige reconexao. Validar callback URI, scopes, permissao e ausencia de tokens em logs.
