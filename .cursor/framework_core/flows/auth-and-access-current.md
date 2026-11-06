# Auth and Access — Current

## Passos

1. usuario registra por email ou Google e autentica;
2. backend emite JWT, RefreshToken e Session;
3. frontend guarda token/sessao em localStorage e envia Bearer;
4. `ProtectedRoute` consulta permissoes de organization/venue;
5. backend usa `ensureAuthenticate` em parte das rotas;
6. 401 aciona tentativa de refresh do Axios;
7. falha limpa storage e redireciona para login fora de rotas publicas.

## Lacunas

Refresh FE/BE divergente, allowlist publica duplicada, protecao backend parcial e autorizacao por ownership/permissao incompleta.
