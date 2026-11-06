# Tasks — Logo, descricao e card vertical do parceiro

## Ordem macro

`T-01` grava a descricao e deixa `logoUrl` so para o servidor. `T-02` sobe o arquivo. `T-03` monta o formulario publico e o componente do card. `T-04` e `T-05` usam esse componente e podem correr juntas depois de `T-03`.

## Tasks

### T-01 - Gravar descricao e reservar logoUrl

- objetivo: o contato persiste descricao de ate 400 caracteres e a coluna `logoUrl`, sem aceitar URL vinda do cliente, e a indicacao publica devolve os dois campos
- cobre requisitos: `R-01`, `R-02`, `R-09`, `R-10`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: `applyPartnerCategory` e o select publico de indicacoes
- prompt recomendado: smart
- estrategia de teste: unitario do schema e da listagem publica
- cenarios obrigatorios: descricao vazia vira `null`; descricao acima de 400 falha; `logoUrl` no JSON e descartado; `SUPPLIER` grava a descricao; criar `TEAM_MEMBER` com descricao falha; a listagem de indicacoes inclui os campos novos e continua limitada ao orcamento; `npx prisma validate` passa
- definition of done: migration aditiva criada; schemas, repositorio e select publico atualizados; testes verdes; nenhuma tela alterada

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — a resposta publica de indicacoes ganha dois campos
- risco principal: aceitar `logoUrl` do cliente ou devolver parceiro que nao foi indicado
- repos tocados: `backend`
- fora de escopo desta task: upload, formulario, card visual, auth das rotas de contato
- prova minima desta task: os cenarios obrigatorios verdes e `npx prisma validate`
- criterio de escalada: parar se a mudanca exigir apagar coluna ou autenticar o modulo de contato
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `node`, `database`, `patterns`, `security`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `topics/data-and-migrations.md#Regras`
  - `framework-libs/database/skills/writing-zero-downtime-migrations.md`
  - `topics/auth-and-security.md#Estado atual`
- caminhos candidatos: `prisma/schema.prisma` modelo `Contact`; `src/zod/contact/`; `src/repositories/in-prisma/proposal-indication-in-prisma-repository.ts`
- palavras-chave ou simbolos de busca: `createContactSchema`, `publicContactSelect`, `description`, `logoUrl`
- testes provaveis: `src/zod/contact/partner-category.spec.ts`; spec da listagem de indicacoes
- nao ler por padrao: `01-spec.md`, `04-tasks.md` inteiro, formulario e pagina de indicacoes no frontend

### T-02 - Subir, trocar e remover a logo

- objetivo: criar e atualizar contato aceitam uma imagem opcional, gravam WebP em `contact-logo/` e apagam a logo anterior desse prefixo
- cobre requisitos: `R-03`, `R-04`, limpeza de logo de `R-08`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: `service-image.ts`, `service-image-storage.ts`, leitura de `payload` do controller de servico
- prompt recomendado: normal
- estrategia de teste: unitario do validador e dos controllers, com upload e delete isolados
- cenarios obrigatorios: jpeg dentro do limite gera URL `contact-logo/` e WebP; png, webp e gif passam; SVG e arquivo acima de 5 MB nao gravam; JSON sem arquivo continua valendo; `removeLogo` zera `logoUrl` e apaga a chave antiga; arquivo novo vence `removeLogo`; chave fora do prefixo nao e apagada; virar `TEAM_MEMBER` apaga a logo; criar equipe com arquivo falha
- definition of done: rotas com multer de 5 MB; controllers ligados; testes verdes; formulario ainda sem campo de arquivo

#### Context Pack

- frente principal: backend
- superficie sensivel: sim — upload em `POST /contact/create`, rota publica
- risco principal: gravar arquivo que nao e imagem ou apagar objeto que nao e logo de contato
- repos tocados: `backend`
- fora de escopo desta task: tela, storage privado, auth nova nas rotas de contato
- prova minima desta task: os cenarios obrigatorios verdes
- criterio de escalada: parar se a solucao passar a exigir URL assinada ou mudanca de bucket
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Decisoes arquiteturais importantes`
- libs obrigatorias: `node`, `aws`, `security`, `patterns`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `topics/integrations.md#S3 e arquivos`
  - `framework-libs/security/skills/securing-private-file-upload-and-storage.md#Quando nao usar`
- caminhos candidatos: `src/router/contact.ts`; `src/functions/service-image-storage.ts`; `src/use-cases/service/create-service/controller-create-service.ts`
- palavras-chave ou simbolos de busca: `uploadServiceImage`, `readServiceBody`, `contact-logo`
- testes provaveis: spec novo ao lado dos specs de contato
- nao ler por padrao: `01-spec.md`, frontend, pagamento

### T-03 - Formulario publico e componente do card

- objetivo: o cadastro publico envia descricao e logo, e mostra o preview vertical ao vivo
- cobre requisitos: `R-05`, `R-06`
- depende de: `T-02`
- pode rodar em paralelo com: nenhuma
- reusa: `indicationLinks`, `Textarea`, `contactService`, classes publicas ja usadas na pagina
- prompt recomendado: normal
- estrategia de teste: unitario do componente nas duas variantes; o envio do formulario coberto pelo teste do servico ou do componente que monta o `FormData`
- cenarios obrigatorios: preview na ordem avatar, nome, descricao, icones; sem arquivo, a inicial; sem nome, "Seu nome" e circulo vazio; sem descricao, "Descrição do serviço"; rede vazia nao aparece; icone do preview abre a URL digitada, completando o protocolo como o card publico; escolher arquivo mostra a imagem local; enviar com arquivo usa `payload` e `file`; enviar sem arquivo segue JSON; titulo "Seu card" acima do botao Cadastrar
- definition of done: componente reutilizavel exportado; `PartnerForm` integrado; testes verdes; pagina de indicacoes ainda nao trocada

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — a tela publica so exibe o que o usuario acabou de digitar; o upload ja foi limitado em `T-02`
- risco principal: o preview divergir da ordem ou dos textos de espera
- repos tocados: `frontend`
- fora de escopo desta task: card da pagina de indicacoes, formulario do painel, regra de arquivo no servidor
- prova minima desta task: cenarios obrigatorios verdes e, no browser, o preview mudando enquanto o formulario e preenchido
- criterio de escalada: parar se o card publico precisar de outro componente
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Decisoes arquiteturais importantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Visao geral da solucao`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `framework-libs/design/rules/06_forms_and_input_ux.md`
  - `framework-libs/design/rules/05_component_states_and_variants.md`
- caminhos candidatos: `src/pages/PartnerForm.tsx`; `src/lib/indication-links.ts`; `src/services/service.service.ts`; `src/components/ui/textarea.tsx`
- palavras-chave ou simbolos de busca: `PartnerForm`, `indicationLinks`, `serviceFormData`
- testes provaveis: teste novo do componente do card
- nao ler por padrao: `01-spec.md`, backend, `security`

### T-04 - Card vertical nas indicacoes

- objetivo: a pagina publica de indicacoes usa o componente do card no lugar do artigo horizontal
- cobre requisitos: `R-07`, `R-09`
- depende de: `T-01`, `T-03`
- pode rodar em paralelo com: `T-05`
- reusa: o componente criado em `T-03` e `PublicVenueListShell`
- prompt recomendado: smart
- estrategia de teste: unitario da variante `public`; conferir que o tipo `PublicIndication` carrega os campos
- cenarios obrigatorios: ordem avatar, nome, descricao, redes; descricao vazia nao aparece; sem logo, inicial; funcao nao aparece; redes sao links; fornecedor sem os campos novos nao quebra a pagina; a casca da pagina permanece
- definition of done: `ProposalIndications` renderiza o componente; tipos e select do cliente alinhados; testes verdes

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — a pagina publica passa a mostrar logo e descricao
- risco principal: mostrar funcao, texto de espera, ou parceiro que nao foi indicado
- repos tocados: `frontend`
- fora de escopo desta task: quem e indicado, casca da pagina, formulario
- prova minima desta task: cenarios obrigatorios verdes e, no browser, um parceiro indicado com logo e descricao no card vertical
- criterio de escalada: parar se a listagem passar a trazer contato fora do orcamento
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Decisoes arquiteturais importantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Decisoes arquiteturais importantes`
  - `03-design.md#Contratos e dados`
  - `framework-libs/design/rules/05_component_states_and_variants.md`
- caminhos candidatos: `src/pages/ProposalIndications.tsx`; `src/services/proposal.service.ts` tipo `PublicIndication`; componente criado em `T-03`
- palavras-chave ou simbolos de busca: `ProposalIndications`, `PublicIndication`, `publicCardClass`
- testes provaveis: teste do componente na variante `public`
- nao ler por padrao: `01-spec.md`, upload, `security` alem do que `T-01` ja devolve

### T-05 - Editar logo e descricao no painel

- objetivo: o formulario de fornecedor no painel envia e remove logo e edita a descricao
- cobre requisitos: `R-08`
- depende de: `T-02`, `T-03`
- pode rodar em paralelo com: `T-04`
- reusa: `ContactForm`, `contactService` e o envio multipart de `T-03`
- prompt recomendado: smart
- estrategia de teste: unitario do payload do formulario de contato
- cenarios obrigatorios: fornecedor mostra Logo e Descrição do serviço; equipe nao mostra; salvar fornecedor com arquivo manda `file`; remover logo manda `removeLogo`; mudar o tipo para equipe nao envia descricao nem logo; fornecedor sem arquivo novo mantem a logo atual visivel
- definition of done: `ContactForm` e o servico de contato cobrem os casos; testes verdes; membro da equipe inalterado no visual

#### Context Pack

- frente principal: frontend
- superficie sensivel: nao — o painel edita um contato que o operador ja alcanca; o limite do arquivo esta no backend
- risco principal: membro da equipe passar a exibir ou gravar logo
- repos tocados: `frontend`
- fora de escopo desta task: autorizacao nova da API, card publico, cadastro publico
- prova minima desta task: cenarios obrigatorios verdes e, no browser, editar um fornecedor e ver logo e descricao no formulario
- criterio de escalada: parar se a tela do painel exigir permissao que o contato ainda nao tem na API
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `03-design.md#Contratos e dados`
  - `03-design.md#Decisoes arquiteturais importantes`
  - `framework-libs/design/rules/06_forms_and_input_ux.md`
- caminhos candidatos: `src/components/contact/contact-form.tsx`; `src/services/contactService.ts`; `src/types/contact.ts`
- palavras-chave ou simbolos de busca: `ContactForm`, `SUPPLIER`, `removeLogo`
- testes provaveis: teste do formulario de contato
- nao ler por padrao: `01-spec.md`, pagina de indicacoes, `security`
