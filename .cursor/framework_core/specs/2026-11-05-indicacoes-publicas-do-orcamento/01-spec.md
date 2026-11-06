# Spec — Indicacoes publicas do orcamento

## Problema

Em Enviar Parceiros, a equipe marca fornecedores e a tela abre o WhatsApp do cliente com nome, funcao e redes. A selecao nao fica no orcamento. O e-mail do cadastro nem entra no texto. A pessoa nao tem uma pagina para consultar as indicacoes.

## Objetivos

Gravar no orcamento os parceiros indicados, sem enviar mensagem, e mostra-los numa pagina publica com a marca do espaco e com os dados que o cadastro do parceiro ja tem.

## Fora de escopo

- envio do orcamento ou da indicacao por WhatsApp ou e-mail
- cadastro de parceiro e de equipe
- foto ou descricao nova no parceiro
- listas de convidados, colaboradores, programacao e contratos
- fechar a rota de listagem de contatos, que hoje ja e publica
- painel, site da organizacao e as paginas publicas que ja existem

## User stories ou cenarios principais

- A equipe marca parceiros num orcamento, salva, e ao reabrir a tela a mesma selecao continua marcada.
- A pessoa abre o link sem login e ve so esses parceiros, com os dados atuais do cadastro.
- Um fornecedor que nao foi marcado, e um contato de equipe, nao aparecem nessa pagina.

## Criterios de aceite

- `R-01`: salvar a selecao grava o conjunto daquele orcamento e nao abre WhatsApp
- `R-02`: salvar de novo substitui o conjunto; lista vazia apaga as indicacoes daquele orcamento
- `R-03`: recarregar Enviar Parceiros mostra marcados os parceiros gravados
- `R-04`: a tela mostra o link `/proposal/:id/indications` para copiar e nao envia mensagem
- `R-05`: contato inexistente, de outro espaco ou que nao seja fornecedor rejeita a gravacao inteira
- `R-06`: gravar sem token responde 401; sem `SEND_PROPOSAL_INFO` no espaco daquele orcamento responde 403 e nao altera a selecao
- `R-07`: a leitura publica, sem login, devolve so os parceiros indicados, na ordem em que foram salvos, com nome, funcao, WhatsApp, e-mail, Instagram, Facebook, TikTok e site
- `R-08`: a leitura publica nao devolve fornecedor nao indicado, contato de equipe nem dado de outro orcamento
- `R-09`: `/proposal/:id/indications` usa a casca das listas publicas: primaria no fundo, secundaria nos cards e no rodape, cor do texto na fonte, Manrope, logo, descricao, aba, skeleton, entrada e rodape
- `R-10`: campo vazio nao aparece; WhatsApp, e-mail e redes presentes abrem o destino correspondente
- `R-11`: orcamento sem indicacao abre a pagina na marca do espaco, com a lista vazia
- `R-12`: mudar ou apagar o parceiro no cadastro muda ou tira o card, sem copia do dia da indicacao
- `R-13`: log de gravacao ou de leitura nao registra WhatsApp nem e-mail do parceiro

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a gravacao exige JWT e `SEND_PROPOSAL_INFO` no espaco do orcamento; a leitura pelo id do orcamento e publica, no mesmo modelo de `/proposal/:id/guest-list`
- erros e mensagens esperadas: falha de gravacao permanece na tela, com a selecao anterior; orcamento inexistente na leitura publica responde 404
- observabilidade minima: falha registra o id do orcamento e a quantidade de contatos, nunca o payload do parceiro
- concorrencia, idempotencia ou retry: duas gravacoes seguidas com o mesmo conjunto deixam o mesmo resultado; gravacoes simultaneas ficam com a ultima que concluir
- rollout, fallback ou degradacao: a tabela nova e aditiva; sem indicacao, a pagina existe e aparece vazia

## Casos de erro e borda obrigatorios

- caso: ids repetidos no mesmo salvamento
  impacto: a ordem nao pode duplicar o card
  cobertura esperada: `T-02`
- caso: contato de equipe ou de outro espaco no meio de uma lista valida
  impacto: nada daquele pedido e gravado
  cobertura esperada: `T-02`
- caso: usuario com a permissao em outro espaco
  impacto: 403 neste orcamento
  cobertura esperada: `T-02`
- caso: pagina aberta enquanto a marca ainda carrega
  impacto: nao mostrar a marca EventHub nem cor de outro espaco
  cobertura esperada: `T-05`
- caso: espaco sem logo, descricao ou alguma cor
  impacto: o mesmo fallback das listas publicas
  cobertura esperada: `T-05`

## Impacto esperado

A indicacao passa a ser um dado do orcamento. O cliente deixa de depender do texto colado no WhatsApp.

## Areas impactadas

- `backend`: schema, gravacao autenticada e leitura publica em `art56_server_v3/`
- `frontend`: Enviar Parceiros e a pagina publica em `eventhub-vista-dashboard/`

## Restricoes e cuidados

- `D-01`: contrato nos dois repositorios
- `D-02`: router, controller, use case e repository no monolito Express
- `D-03`: integridade no Prisma, sem contar com FK fisica
- `D-05`: a permissao da tela nao substitui a da API; testes negativos obrigatorios
- nao ler nem versionar `.env`
- migration de producao, quando houver, usa `prisma migrate deploy` e e aditiva

## Dependencias

- Enviar Parceiros ja lista fornecedores do espaco e ja exige `SEND_PROPOSAL_INFO` na UI
- o contato ja guarda nome, funcao, WhatsApp, e-mail, Instagram, Facebook, TikTok e site
- `PublicVenueListShell` ja aplica a marca nas listas publicas
- o contato pertence ao espaco; o orcamento ainda nao aponta indicacoes

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-02`, `R-05`, `R-06` -> `T-02` -> unitario
- `R-03`, `R-04` -> `T-04` -> tela
- `R-07`, `R-08`, `R-12`, `R-13` -> `T-03` -> unitario
- `R-09`, `R-10`, `R-11` -> `T-05` -> tela
- persistencia de `R-02` e `R-12` -> `T-01` -> `prisma validate`

## Perguntas em aberto

As premissas que a execucao segue estao em `02-clarify.md`. Nenhuma bloqueia `T-01`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
