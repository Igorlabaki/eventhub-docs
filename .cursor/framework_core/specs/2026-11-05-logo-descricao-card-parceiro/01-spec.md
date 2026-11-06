# Spec — Logo, descricao e card vertical do parceiro

## Problema

O cadastro publico de parceiro grava nome, categoria, funcao, WhatsApp, e-mail e redes. Nao ha logo nem descricao do servico. A pagina `/proposal/:id/indications` mostra um card horizontal com nome, funcao e icones. Quem se cadastra nao ve como o card vai aparecer.

## Objetivos

- o parceiro envia uma logo e uma descricao opcionais no cadastro publico
- no fim do formulario, um preview vertical mostra avatar, nome, descricao e redes
- o card publico das indicacoes usa o mesmo formato
- o painel corrige logo e descricao no contato do tipo fornecedor

## Fora de escopo

- autenticar as rotas de contato que hoje ja sao abertas
- mudar categoria, quem entra na indicacao, ou o contato de equipe
- foto e descricao dos servicos cobrados do espaco
- envio de indicacao por WhatsApp
- storage privado ou URL assinada para a logo
- redesenho do restante do formulario publico

## User stories ou cenarios principais

- o parceiro preenche o cadastro, escolhe uma logo, escreve o servico e ve o card antes de cadastrar
- a pessoa abre as indicacoes do orcamento e ve esse card, com a marca do espaco em volta
- o espaco troca ou remove a logo e edita a descricao no painel

## Criterios de aceite

- `R-01`: descricao e opcional, tem no maximo 400 caracteres depois do trim, vazio vira `null`, e so permanece em contato `SUPPLIER`
- `R-02`: `logoUrl` nao e aceito no corpo enviado pelo cliente; a URL so existe depois que o servidor grava o arquivo
- `R-03`: a logo aceita jpeg, png, webp e gif ate 5 MB, e recusa o resto, inclusive SVG; o arquivo gravado e WebP em chave `contact-logo/`
- `R-04`: trocar ou remover a logo apaga o objeto anterior quando a chave e desse prefixo no bucket do projeto
- `R-05`: o cadastro publico tem campo de logo, campo de descricao e, acima de Cadastrar, um preview ao vivo na ordem avatar, nome, descricao, redes
- `R-06`: no preview, sem logo aparece a inicial do nome; nome vazio mostra "Seu nome"; descricao vazia mostra "Descrição do serviço"; so entram redes preenchidas
- `R-07`: o card de `/proposal/:id/indications` repete essa ordem, esconde descricao vazia, usa a inicial sem logo, e nao mostra a funcao
- `R-08`: o formulario de fornecedor no painel edita logo e descricao; membro da equipe nao guarda esses campos, e mudar o tipo para equipe limpa os dois
- `R-09`: a pagina de indicacoes continua devolvendo so os parceiros ligados a aquele orcamento
- `R-10`: a migration so adiciona colunas nullable; cliente antigo que nao envia logo nem descricao continua cadastrando

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: o cadastro publico segue sem login, de proposito. O `PUT` de contato do painel continua como esta hoje, sem esta spec inventar autorizacao nova. A pagina de indicacoes nao passa a listar fornecedor nao indicado
- erros e mensagens esperadas: arquivo invalido ou grande demais responde erro claro no padrao `{ title, message }`; o formulario mostra o toast destrutivo que ja existe
- observabilidade minima: sem servico novo, sem metrica nova; a falha aparece na resposta HTTP e no toast
- concorrencia, idempotencia ou retry: um contato guarda uma logo; upload e sincrono, como a foto de servico; falha ao apagar o objeto antigo nao desfaz a gravacao
- rollout, fallback ou degradacao: colunas nullable; card sem logo, sem descricao ou sem rede continua inteiro

## Casos de erro e borda obrigatorios

- caso: arquivo que nao e imagem, SVG, ou imagem acima de 5 MB
  impacto: nada e gravado no bucket nem no contato
  cobertura esperada: unitario do validador e da rota de criar
- caso: corpo JSON com `logoUrl` apontando para um endereco qualquer
  impacto: o valor e ignorado
  cobertura esperada: unitario do schema
- caso: descricao com mais de 400 caracteres, ou so espacos
  impacto: a longa falha a validacao; a vazia grava `null`
  cobertura esperada: unitario do schema
- caso: contato vira membro da equipe tendo logo
  impacto: logo e descricao saem do registro e o objeto do prefixo e apagado
  cobertura esperada: unitario do update
- caso: parceiro indicado sem logo e sem descricao
  impacto: card com inicial e sem bloco de descricao
  cobertura esperada: teste do componente
- caso: fornecedor do espaco que nao esta na indicacao daquele orcamento
  impacto: a pagina publica nao o mostra
  cobertura esperada: teste ja existente da listagem, sem regressao

## Impacto esperado

O contato do fornecedor passa a ter cara de card. O cadastro publico e a pagina de indicacoes mostram a mesma peca. O contrato de criar e atualizar contato ganha descricao e arquivo opcional.

## Areas impactadas

- `backend`: modelo `Contact`, schemas de criar e atualizar, rotas de contato, select publico das indicacoes
- `frontend`: `PartnerForm`, formulario de contato do painel, card das indicacoes, tipos de contato e de indicacao

## Restricoes e cuidados

- seguir `project-decisions.md#D-01` e `#D-03`: dois repositorios, migration aditiva com `prisma migrate deploy`
- a logo e asset publico de pagina, no mesmo tipo da foto de servico; nao introduzir URL assinada
- nao ler nem versionar `.env`
- nao colocar a funcao no card

## Dependencias

- pagina publica de indicacoes e cadastro de parceiro ja existem
- upload de foto de servico ja limita tipo, tamanho, Sharp e S3

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-02`, `R-09`, `R-10` -> `T-01` -> unitario
- `R-03`, `R-04`, `R-08` (limpeza da logo) -> `T-02` -> unitario
- `R-05`, `R-06` -> `T-03` -> unitario e tela
- `R-07`, `R-09` -> `T-04` -> unitario e tela
- `R-08` -> `T-05` -> unitario e tela

## Perguntas em aberto

Registradas em `02-clarify.md`. Nenhuma bloqueia `T-01`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `executar task`
- entrada publica recomendada: `fw:run`
