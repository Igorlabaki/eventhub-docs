# Integrations

## S3 e arquivos

Uploads de imagens/documentos usam AWS SDK, Multer, Sharp e S3. Parte do processamento ocorre em controller/request. Validar tipo, tamanho, ownership, nome de objeto, acesso privado/publico e remocao.

## E-mail e notificacoes

Nodemailer cobre proposta, contrato, confirmacao e reset. A notificacao do painel fica gravada no banco. Push Firebase foi removido; a coluna `User.fcmToken` permanece sem uso e sem migration. Web Push/VAPID continua no codigo. Nao ha fila/retry/idempotencia padronizada; falha externa pode falhar a request.

## Google Calendar

OAuth por user/organization com tokens criptografados. Sync e unidirecional EventHub -> Google em DateEvent. VIEW permite status/listagem/conexao; EDIT permite selecao, desconexao e sync. Falha Google nao reverte escrita local.

## Contratos e prova

Mudanca de scope/callback/payload e sensivel. Provar sucesso, falha, expiracao, retry/reconexao e permissao. Nunca registrar tokens. Fonte: `docs/INTEGRATIONS_GOOGLE_CALENDAR.md`.
