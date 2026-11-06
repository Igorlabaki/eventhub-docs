# Spec — Categoria do parceiro

## Problema

O parceiro e um `Contact` com `type = SUPPLIER`. O cadastro, no painel e em `/venue/:id/partner-form`, guarda a funcao em texto livre e nao pede categoria. A pagina `/proposal/:id/indications` lista os indicados daquele orcamento numa fila so.

## Objetivos

- gravar uma categoria da lista fechada em todo parceiro novo
- deixar em `OUTROS` os fornecedores que ja existem
- pedir a categoria no cadastro do painel e no formulario publico
- separar, na pagina publica, os indicados pela categoria atual do cadastro

## Fora de escopo

- filtro, busca ou rota nova na pagina publica
- apagar ou substituir a funcao livre (`role`)
- foto, descricao ou preco do parceiro
- categoria para membro de equipe
- redesenhar a casca `PublicVenueListShell`
- aplicar `prisma migrate deploy` em producao nesta spec

## User stories ou cenarios principais

- A equipe cadastra um parceiro no painel e escolhe a categoria antes de salvar.
- Uma pessoa se cadastra em `/venue/:id/partner-form` e escolhe a mesma lista.
- Um fornecedor antigo abre como Outros e pode ser trocado para outra categoria.
- A pessoa abre o link das indicacoes e ve cada parceiro no grupo da categoria, na ordem Buffet ate Outros.

## Criterios de aceite

- `R-01`: `Contact.category` e o enum `PartnerCategory`, opcional, sem default, com exatamente `BUFFET`, `CHURRASCO`, `BAR`, `DJ`, `MUSICA_AO_VIVO`, `FOTOGRAFIA`, `FILMAGEM`, `DECORACAO`, `CENOGRAFIA`, `BOLOS_DOCES`, `RECREACAO`, `ENTRETENIMENTO`, `CERIMONIAL`, `AUDIOVISUAL`, `MOBILIARIO`, `BRINDES` e `OUTROS`.
- `R-02`: a migration adiciona a coluna opcional e grava `OUTROS` somente onde `type = SUPPLIER` e a categoria ainda e nula. `TEAM_MEMBER` permanece nulo.
- `R-03`: criar contato `SUPPLIER` sem categoria, ou com valor fora da lista, responde erro de validacao e nao grava.
- `R-04`: criar contato `TEAM_MEMBER` grava `category` nula. Payload de equipe com categoria nao grava.
- `R-05`: atualizar para `SUPPLIER` sem categoria valida nao grava. Atualizar para `TEAM_MEMBER` zera a categoria.
- `R-06`: o formulario do painel, quando o tipo e Fornecedor, e o formulario publico de parceiro exigem a categoria, com os rotulos em portugues da tabela do design. A funcao livre continua nos dois.
- `R-07`: a lista de contatos do painel mostra o rotulo da categoria no fornecedor e continua mostrando a funcao quando ela existe.
- `R-08`: `GET /proposal/indications/:proposalId` segue sem autenticacao, devolve so fornecedor daquele espaco, na ordem de `position`, e inclui `category` sem incluir `venueId` nem `type`.
- `R-09`: a pagina publica agrupa pela ordem do enum, omite grupo vazio e, dentro do grupo, mantem a ordem recebida. Nome, funcao e links do card nao mudam.
- `R-10`: `category` nula na leitura publica entra no grupo Outros e nao dispara gravacao.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: o `POST /contact/create` continua publico, como o formulario de parceiro ja e. A validacao da categoria acontece no schema. A permissao da tela do painel nao muda e nao substitui o schema.
- erros e mensagens esperadas: campo vazio mostra "Selecione a categoria". Valor desconhecido volta erro de validacao, sem gravar.
- observabilidade minima: o toast de erro que o formulario ja usa. Sem metrica nem log novo. Log de erro nao imprime WhatsApp, e-mail nem nome.
- concorrencia, idempotencia ou retry: a ultima gravacao do contato vale. Nao ha fila nem retry novo.
- rollout, fallback ou degradacao: a coluna nasce opcional. API antiga ignora o campo. API nova e os formularios sobem juntos; senao o cadastro de parceiro passa a recusar envio sem categoria.

## Casos de erro e borda obrigatorios

- caso: fornecedor antigo
  impacto: precisa abrir como Outros sem escolha manual
  cobertura esperada: `T-01` pelo SQL; `T-04` ao exibir o rotulo
- caso: membro de equipe antigo ou novo
  impacto: nao pode ficar em Outros
  cobertura esperada: `T-01` e `T-02`
- caso: formulario enviado sem categoria
  impacto: o parceiro incompleto nao grava e o que foi digitado permanece
  cobertura esperada: `T-02` e `T-04`
- caso: orcamento sem indicacao
  impacto: a pagina continua vazia, sem titulo de grupo
  cobertura esperada: `T-05`
- caso: todos os indicados em Outros, ou categoria alterada depois da indicacao
  impacto: um unico grupo Outros, ou o grupo da categoria atual, porque a pagina le o cadastro
  cobertura esperada: `T-03` e `T-05`
- caso: troca de tipo
  impacto: equipe perde a categoria; fornecedor sem categoria nao grava
  cobertura esperada: `T-02`

## Impacto esperado

O cadastro de parceiro passa a classificar o servico. A pagina publica deixa de ser uma lista unica. Colaborador e a funcao livre ficam como estao.

## Areas impactadas

- `backend`: `Contact` no Prisma, schemas de contato, leitura publica das indicacoes
- `frontend`: formulario de contato, formulario publico de parceiro, lista de contatos, `ProposalIndications`

## Restricoes e cuidados

- migration aditiva; producao usa `prisma migrate deploy`, fora desta spec
- `relationMode = "prisma"`: a categoria nao depende de FK
- nao criar indice
- nao ler nem versionar `.env`

## Dependencias

- `Contact.type` ja separa `SUPPLIER` e `TEAM_MEMBER`
- `GET /proposal/indications/:proposalId` ja lista o cadastro atual, na ordem de `position`, so de fornecedor do espaco
- a casca publica e os links do card ja existem

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-02` -> `T-01` -> `integracao` (`prisma validate` e o SQL)
- `R-03`, `R-04`, `R-05` -> `T-02` -> `unitario`
- `R-08`, `R-10` -> `T-03` -> `unitario`
- `R-06`, `R-07` -> `T-04` -> `unitario`
- `R-09`, `R-10` -> `T-05` -> `unitario`

## Perguntas em aberto

Nenhuma bloqueante. Premissas fechadas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
