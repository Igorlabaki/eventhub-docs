# Functional Flows — EventHub

## Fluxos principais

- autenticacao: registrar por email/Google, login, sessao, access token, refresh e reset de senha;
- estrutura: Organization -> Venue -> capacidades operacionais;
- comercial: formulario publico -> Proposal -> contato/edicao -> contrato -> pagamento;
- operacao: Proposal -> Person, Schedule, DateEvent, Document, Payment, History e Notification;
- site: textos, imagens, FAQ e venues publicados por Organization/Venue;
- acesso: User -> UserOrganization -> permissoes de organization e venue;
- calendario: DateEvent local -> sincronizacao opcional Google Calendar;
- comunicacao: envio de proposta, contrato, confirmacao, mensagens e notificacoes.

## Contratos transversais

- frontend chama a URL definida por `VITE_API_URL` com JWT Bearer;
- respostas nao possuem envelope unico;
- erros usam principalmente `{ title, message }`;
- datas de agenda devem preservar wall-clock;
- uploads usam S3 e processamento de imagem no ciclo da request.

## Mapas detalhados

- `flows/proposal-lifecycle-current.md`: ciclo comercial e estados implicitos;
- `flows/public-budget-request-current.md`: do formulario publico ao orcamento apresentado;
- `flows/event-operation-current.md`: contato, contrato, agenda, pagamento e operacao do dia;
- `flows/auth-and-access-current.md`: login, sessao, refresh e permissoes;
- `flows/google-calendar-current.md`: OAuth e sync de agenda.

Telas e endpoints de cada passo: `project/frontend-map.md` e `project/api-endpoints.md`.
