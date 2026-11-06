# Integração Google Calendar — EventHub

Integração 1-way (EventHub → Google Calendar): eventos criados, atualizados ou excluídos no EventHub são sincronizados automaticamente com o Google Calendar do usuário, desde que a integração esteja conectada e o usuário tenha permissão **EDIT_VENUE_CALENDAR**.

---

## 1. Setup no Google Cloud Console

1. Acesse [Google Cloud Console](https://console.cloud.google.com/).
2. Crie um projeto ou selecione um existente.
3. Ative a **Google Calendar API**: APIs & Services → Library → procure "Google Calendar API" → Enable.
4. Crie credenciais OAuth 2.0:
   - APIs & Services → Credentials → Create Credentials → OAuth client ID.
   - Tipo: **Web application**.
   - Em **Authorized redirect URIs** adicione a URL do callback do backend, por exemplo:
     - Produção: `https://sua-api.com/integrations/google-calendar/callback`
     - Desenvolvimento: `http://localhost:3000/integrations/google-calendar/callback` (ou a porta do seu backend).
5. Copie o **Client ID** e o **Client Secret** e configure no backend (variáveis de ambiente).

---

## 2. Variáveis de ambiente (backend)

| Variável | Descrição |
|----------|-----------|
| `GOOGLE_CLIENT_ID` | OAuth 2.0 Client ID do Google Cloud. |
| `GOOGLE_CLIENT_SECRET` | OAuth 2.0 Client Secret. |
| `GOOGLE_REDIRECT_URI` | URL do callback (deve coincidir exatamente com a configurada no Console), ex.: `https://sua-api.com/integrations/google-calendar/callback`. |
| `ENCRYPTION_KEY` | Chave base64 (32 bytes) para criptografar tokens no banco. Gerar com: `node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"`. |
| `FRONTEND_URL` | (Opcional) URL base do frontend para redirecionamento após o callback, ex.: `https://app.eventhub.com`. |
| `JWT_SECRET_KEY` | Usado para assinar o `state` do OAuth (já existente no projeto). |

---

## 3. Scopes usados

- `https://www.googleapis.com/auth/calendar`
- `https://www.googleapis.com/auth/calendar.events`

São solicitados no fluxo de autorização (connect). O backend usa `access_type=offline` e `prompt=consent` para obter refresh token.

---

## 4. Fluxo do usuário

1. **Login:** usuário faz login no EventHub (Google ou email/senha).
2. **Permissão interna:** apenas usuários com **VIEW_VENUE_CALENDAR** no contexto do venue veem a seção de integração na página de Agenda. Quem tem **EDIT_VENUE_CALENDAR** pode conectar, desconectar e ter eventos sincronizados.
3. **Conectar:** na página Agenda do venue, o usuário clica em "Conectar Google Calendar". O frontend chama `GET /integrations/google-calendar/connect-url?organizationId=...` (com Bearer) e redireciona o navegador para a URL retornada (Google). O usuário autoriza o acesso ao Calendar.
4. **Callback:** o Google redireciona para `GET /integrations/google-calendar/callback?code=...&state=...`. O backend troca o `code` por tokens, criptografa e persiste em `GoogleCalendarIntegration`, depois redireciona o usuário para o frontend com `?google_calendar=connected`.
5. **Seleção de calendário:** (opcional) o usuário pode chamar `GET /integrations/google-calendar/calendars` e `POST /integrations/google-calendar/select-calendar` para escolher em qual calendário os eventos serão criados. Se não escolher, usa-se o calendário "primary".
6. **Sync automático:** ao criar, editar ou excluir um DateEvent no EventHub, o backend verifica se o usuário tem EDIT_VENUE_CALENDAR e se existe integração ativa; em caso positivo, cria/atualiza/exclui o evento no Google Calendar. Falhas no Google não revertem a operação no banco.

---

## 5. Permissões internas (EventHub)

| Permissão | Uso |
|-----------|-----|
| **VIEW_VENUE_CALENDAR** | Ver status da integração, listar calendários, obter URL de conexão. |
| **EDIT_VENUE_CALENDAR** | Selecionar calendário, desconectar, e permitir sync (criar/atualizar/excluir eventos no Google). |

Todas as checagens são feitas no backend. Respostas **403** devem exibir: "Você não tem permissão para acessar o calendário. Solicite ao administrador."

---

## 6. Troubleshooting

| Problema | Possível causa | Ação |
|----------|----------------|------|
| 401 ao chamar auto-status ou connect | Token ausente ou inválido. | Verificar header `Authorization: Bearer <token>` e renovar token (refresh). |
| 403 ao chamar integração | Usuário sem VIEW_VENUE_CALENDAR ou EDIT_VENUE_CALENDAR no contexto da organização. | Conceder a permissão no cadastro de permissões do venue/org. |
| "invalid_grant" no callback | Código de autorização expirado (cerca de 10 min) ou já utilizado; redirect_uri diferente do configurado. | Verificar GOOGLE_REDIRECT_URI e tentar conectar novamente. |
| Token expirado / 401 da API Google | Access token expirado e refresh falhou (ex.: refresh revogado). | Usuário deve "Reconectar Google Calendar" (novo fluxo OAuth). |
| Eventos não aparecem no Google | Sync só ocorre se usuário tiver EDIT_VENUE_CALENDAR e integração ativa; falhas são apenas logadas. | Verificar logs do backend; confirmar permissão e integração. |

---

## 7. Exemplos curl

Base URL assumida: `https://sua-api.com`. Substituir pelo seu backend e incluir `Authorization: Bearer <seu_token>` onde indicado.

### Auto-status

```bash
curl -s -H "Authorization: Bearer SEU_TOKEN" \
  "https://sua-api.com/integrations/google-calendar/auto-status?organizationId=ORGANIZATION_ID"
```

Resposta esperada (exemplo): `{"connected":true,"calendarId":"primary"}` ou `{"connected":false,"needsGooglePermission":false}`.

### Connect URL (retorna JSON com URL para o frontend redirecionar)

```bash
curl -s -H "Authorization: Bearer SEU_TOKEN" \
  "https://sua-api.com/integrations/google-calendar/connect-url?organizationId=ORGANIZATION_ID"
```

Resposta: `{"redirectUrl":"https://accounts.google.com/o/oauth2/v2/auth?..."}`.

### Listar calendários

```bash
curl -s -H "Authorization: Bearer SEU_TOKEN" \
  "https://sua-api.com/integrations/google-calendar/calendars?organizationId=ORGANIZATION_ID"
```

### Selecionar calendário

```bash
curl -s -X POST -H "Authorization: Bearer SEU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"organizationId":"ORGANIZATION_ID","calendarId":"primary"}' \
  "https://sua-api.com/integrations/google-calendar/select-calendar"
```

### Desconectar

```bash
curl -s -X POST -H "Authorization: Bearer SEU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"organizationId":"ORGANIZATION_ID"}' \
  "https://sua-api.com/integrations/google-calendar/disconnect"
```

---

## 8. Semântica de horário

O EventHub grava a hora do evento como relógio de parede nos componentes UTC (`2026-07-05T11:00:00.000Z` significa 11:00). O sync envia esses dígitos **sem** sufixo `Z`, com `timeZone: America/Sao_Paulo`, para o Google Calendar mostrar 11:00. Um `dateTime` com `Z` junto desse fuso faria o evento aparecer 3 horas mais cedo.

## 9. Referências

- [Google Calendar API — Overview](https://developers.google.com/workspace/calendar/api/guides/overview)
- [Google Calendar API — Auth](https://developers.google.com/workspace/calendar/api/auth)
- [OAuth 2.0 Web Server Flow](https://developers.google.com/identity/protocols/oauth2/web-server)
