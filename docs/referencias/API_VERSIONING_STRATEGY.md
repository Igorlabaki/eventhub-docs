# Estratégia de versionamento de API — EventHub

**Objetivo:** Como introduzir `/v1` ou `X-Api-Version`; como manter rotas antigas; política de depreciação. Baseado no estado atual (sem versionamento no repositório).

**Fontes no repositório:** `art56_server_v3/src/server.ts`, `art56_server_v3/src/router/`, [MIGRATION_STRATEGY.md](./MIGRATION_STRATEGY.md), [API_CONTRACTS.md](./API_CONTRACTS.md).

---

## 1. Estado atual

- Não há prefixo de versão (ex.: `/v1/`) nas rotas.
- Não há header `X-Api-Version` ou equivalente.
- Contratos implícitos (Zod no BE, tipos no FE); envelope de resposta inconsistente.

---

## 2. Opções de versionamento

### Opção A — Prefixo de path (`/v1/`)

- **Prós:** Claro na URL; cache e proxies tratam por path.
- **Contras:** Duplicar todas as rotas ou montar router sob `/v1`; cliente precisa trocar base URL ou path.

**Implementação sugerida:** Em `server.ts`, montar `app.use('/v1', routesV1)` onde `routesV1` agrupa os mesmos routers atuais. Manter `app.use('/auth', authRoutes)` etc. como legado; novo cliente usa `baseURL + '/v1'`. Depreciação: anunciar fim do suporte ao path sem prefixo em data X.

### Opção B — Header `X-Api-Version`

- **Prós:** Mesma URL; opt-in por cliente; fácil A/B.
- **Contras:** Middleware em toda request para ler header; documentação deve deixar claro que sem header = v1.

**Implementação sugerida:** Middleware que lê `req.headers['x-api-version']` e seta `req.apiVersion = 2` (ou 1). Controllers ou use cases que precisem de comportamento diferente checam `req.apiVersion`. Resposta pode mudar (ex.: envelope `{ data }` quando version === 2).

### Opção C — Query `?api_version=2`

- Similar ao header; menos limpo para cache e para logs. Não recomendado como principal.

---

## 3. Recomendação para EventHub

- **Curto prazo:** Não introduzir versionamento até padronizar auth e contratos (estabilização). Documentar em [API_CONTRACTS.md](./API_CONTRACTS.md) o formato atual.
- **Quando introduzir:** Preferir **header `X-Api-Version`** para não duplicar paths e permitir evolução por recurso. Valor `1` (ou ausência) = comportamento atual; `2` = novo envelope ou novos campos quando aplicável.
- **Manter rotas antigas:** Sempre que o contrato mudar de forma incompatível (ex.: remover campo, mudar tipo), manter resposta antiga para `X-Api-Version: 1` ou sem header; nova resposta para `X-Api-Version: 2`.

---

## 4. Política de depreciação

- **Anúncio:** Documentar em README ou neste doc; header `Deprecation: true` ou `X-Deprecated: 2025-12-01` em respostas de rotas depreciadas.
- **Prazo:** Mínimo 6 meses entre anúncio e remoção (ajustar conforme contrato com clientes).
- **Logs:** Registrar uso de versão depreciada (path ou header) para métrica e comunicação com clientes.
- **Remoção:** Após prazo, remover código da v1 ou redirecionar para v2 com resposta de erro explicativa por um período curto.

---

## 5. Exemplo de uso do header (futuro)

- FE: `api.defaults.headers.common['X-Api-Version'] = '2'` quando toda a base estiver migrada para v2.
- BE: middleware opcional que seta `req.apiVersion = parseInt(req.headers['x-api-version'] || '1', 10)`; em controller de sucesso, se `req.apiVersion >= 2` retornar `res.json({ data: result })`, senão `res.json(result)` (comportamento atual).

---

## Decisões e recomendações

- Não fazer big bang de versionamento; introduzir quando houver primeira mudança breaking de contrato.
- Manter esta estratégia alinhada a [MIGRATION_STRATEGY.md](./MIGRATION_STRATEGY.md) e atualizar [API_CONTRACTS.md](./API_CONTRACTS.md) quando houver versões.
