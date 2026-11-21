# Tasks

## Ordem macro

1. `T-01` entrega a busca e a normalizacao, sem tela.
2. `T-02` entrega o bloco. Depende de `T-01`.
3. `T-03`, `T-04` e `T-05` ligam o bloco nas telas e podem correr juntas.

## Tasks

### T-01 - Busca de CEP

- objetivo: dado 8 digitos, devolver logradouro, bairro, cidade e UF, ou a falha, sem mexer em numero e complemento
- cobre requisitos: `R-01`, `R-02`, `R-11`, `R-14`
- depende de: nenhuma
- pode rodar em paralelo com: nenhuma
- reusa: nada de tela; `fetch` injetado no teste
- prompt recomendado: smart
- estrategia de teste: unitario com fetch falso
- cenarios obrigatorios: ViaCEP completa preenche os quatro campos e ignora `complemento`; CEP sem rua e sem bairro devolve cidade e UF com rua e bairro vazios; ViaCEP com `erro: true` cai na BrasilAPI; as duas falhas devolvem falha; resposta do CEP anterior nao aplica no CEP novo; a URL leva so os 8 digitos; timeout aborta em 4 segundos
- definition of done: os cenarios verdes; nenhuma chamada ao backend do EventHub; `topics/` nao muda

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o CEP sai do navegador
- risco principal: a URL levar outro campo alem do CEP, ou uma resposta velha ganhar da nova
- repos tocados: `eventhub-vista-dashboard`
- fora de escopo desta task: componente visual, formularios, IBGE, selects
- prova minima desta task: os cenarios obrigatorios verdes, com fetch falso e sem rede
- criterio de escalada: parar se a resposta real exigir proxy no backend
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `security`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `03-design.md#Falhas, casos de borda e invariantes`, `framework_global/framework-libs/patterns/rules/06_senior_engineering_concepts.md#Conceitos e roteamento`, `framework_global/framework-libs/security/index.md#Quando esta lib e obrigatoria`
- caminhos candidatos: pasta nova `src/lib/` ao lado dos outros modulos puros do dashboard
- palavras-chave ou simbolos de busca: `viacep`, `brasilapi`, `logradouro`, `erro`
- testes provaveis: `src/lib/cep-lookup.test.ts`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `database`, formularios

### T-02 - Bloco de endereco

- objetivo: um bloco com CEP primeiro, campos editaveis, erro no CEP e select so na reserva
- cobre requisitos: `R-03`, `R-04`, `R-05`, `R-06`, `R-07`, `R-13`
- depende de: `T-01`
- pode rodar em paralelo com: nenhuma
- reusa: a funcao de `T-01`; `Input`, `Select`, `FormField`, `InputMask`, `publicLabelClass`
- prompt recomendado: normal
- estrategia de teste: unitario do bloco com a busca falsa
- cenarios obrigatorios: ordem CEP, logradouro, numero, complemento, bairro, cidade, UF; "Buscando CEP..." durante a espera; erro no CEP sem apagar os campos; sucesso com rua deixa inputs; sucesso sem rua nem bairro zera os dois e abre o select de cidade; falha abre select de UF e, com sigla, select de cidade; valor inicial Sao Paulo / SP nao dispara busca; CEP do formulario fica so com digitos e sigla nova fica maiuscula; estado "Sao Paulo" por extenso nao e cortado; IBGE falho devolve o input de cidade
- definition of done: cenarios verdes; variante `panel` e `public`; modo com CEP local para a tela que nao grava CEP; sem store nova

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o bloco dispara a busca de `T-01`
- risco principal: o bloco apagar numero, complemento ou um endereco ja digitado quando a busca falha
- repos tocados: `eventhub-vista-dashboard`
- fora de escopo desta task: ligar as telas existentes
- prova minima desta task: os cenarios obrigatorios verdes nas duas variantes
- criterio de escalada: parar se o bloco precisar de Zustand ou React Query
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Falhas, casos de borda e invariantes`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Componentes e modulos impactados`, `03-design.md#Falhas, casos de borda e invariantes`, `framework_global/framework-libs/design/rules/06_forms_and_input_ux.md#Entrada`, `framework_global/framework-libs/design/rules/05_component_states_and_variants.md#Estados de componente interativo`
- caminhos candidatos: `src/components/ui/select.tsx`; `src/components/proposal/forms/ContractPublicField.tsx`; `src/components/proposal/public-list-pattern`
- palavras-chave ou simbolos de busca: `FormField`, `InputMask`, `publicLabelClass`, `Select`
- testes provaveis: `src/components/address/AddressFields.test.tsx`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security` alem do que `T-01` ja garante, `database`

### T-03 - Espaco cria e edita com o bloco

- objetivo: criar espaco e Configuracoes, aba Endereco, usam o bloco e salvam CEP so com digitos
- cobre requisitos: `R-08`, `R-12`
- depende de: `T-02`
- pode rodar em paralelo com: `T-04`, `T-05`
- reusa: o bloco de `T-02`; o `onSubmit` que ja existe
- prompt recomendado: normal
- estrategia de teste: unitario do payload nesses dois formularios, com a busca falsa
- cenarios obrigatorios: criar espaco mostra o bloco no lugar dos inputs soltos de endereco; Configuracoes aba Endereco tambem; o payload de criar espaco segue com `cep` em digitos dentro de `data`; Configuracoes envia `cep` em digitos; numero e complemento nao mudam com a busca; nenhuma edicao em `schema.prisma` nem em `eventOriginRows`
- definition of done: os dois formularios salvam pelo caminho atual; vitest desses payloads verde

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — o formulario grava o endereco do espaco
- risco principal: o salvamento de Configuracoes deixar de enviar rua, numero ou preco junto com o endereco
- repos tocados: `eventhub-vista-dashboard`
- fora de escopo desta task: contratos, proprietario, `EditVenueForm`, backend
- prova minima desta task: os cenarios obrigatorios verdes
- criterio de escalada: parar se o salvamento exigir campo novo na API
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Componentes e modulos impactados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Componentes e modulos impactados`, `03-design.md#Contratos e dados`
- caminhos candidatos: `src/components/venue/CreateVenueForm.tsx`; `src/pages/VenueSettings.tsx`
- palavras-chave ou simbolos de busca: `data.cep`, `name="cep"`, `endereco`
- testes provaveis: teste de payload ao lado dos testes ja existentes de `VenueSettings`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, `database`, relatorio de origem

### T-04 - Contrato do painel e contrato publico

- objetivo: os quatro formularios de contrato usam o bloco, com o visual publico nas duas telas de quem assina
- cobre requisitos: `R-08`, `R-12`
- depende de: `T-02`
- pode rodar em paralelo com: `T-03`, `T-05`
- reusa: o bloco; `adressComplement` da proposta
- prompt recomendado: normal
- estrategia de teste: unitario do payload e da ordem dos campos, com busca falsa
- cenarios obrigatorios: PF e PJ do painel e os dois publicos mostram o CEP antes do logradouro; complemento continua `adressComplement`; CEP salvo so com digitos; valor inicial Sao Paulo / SP permanece se ninguem digitar CEP; a busca nao dispara so por causa desse valor inicial
- definition of done: os quatro formularios salvam pelo `update` que ja existe; vitest verde

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — contrato de cliente, com CPF e endereco
- risco principal: o formulario publico perder o visual da superficie ou salvar com a mascara do CEP
- repos tocados: `eventhub-vista-dashboard`
- fora de escopo desta task: espaco, proprietario, backend, PDF do contrato
- prova minima desta task: os cenarios obrigatorios verdes
- criterio de escalada: parar se o publico precisar de um segundo bloco
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Componentes e modulos impactados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Componentes e modulos impactados`, `03-design.md#Contratos e dados`, `topics/frontend-application.md#Areas`
- caminhos candidatos: `src/components/proposal/forms/pf-contract-form.tsx`; `pj-contract-form.tsx`; `PFContractPersonalInfoForm.tsx`; `PJContractPersonalInfoForm.tsx`
- palavras-chave ou simbolos de busca: `adressComplement`, `São Paulo`, `ContractPublicField`
- testes provaveis: teste novo em `src/components/proposal/forms/`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, `database`

### T-05 - Proprietario e cidade do site da organizacao

- objetivo: o proprietario usa o bloco inteiro; o site da organizacao usa o CEP so para preencher cidade e UF
- cobre requisitos: `R-09`, `R-10`, `R-12`
- depende de: `T-02`
- pode rodar em paralelo com: `T-03`, `T-04`
- reusa: o bloco no modo de CEP local
- prompt recomendado: normal
- estrategia de teste: unitario dos dois payloads; no browser, um CEP valido numa tela do painel se o login estiver disponivel
- cenarios obrigatorios: `OwnerForm` envia rua, numero, complemento, bairro, cidade, UF e CEP em digitos; `EditVenueForm` envia cidade e UF e o corpo nao tem `cep`; busca falha no proprietario nao apaga rua ja digitada
- definition of done: os dois payloads verdes; browser do CEP no painel feito ou a lacuna escrita no `05-state.md`; `topics/` nao muda

#### Context Pack

- frente principal: frontend
- superficie sensivel: sim — proprietario tem CPF, PIX e endereco
- risco principal: o site da organizacao passar a gravar o CEP no lugar do CEP de Configuracoes, ou o payload do proprietario perder o banco
- repos tocados: `eventhub-vista-dashboard`
- fora de escopo desta task: contratos, criar espaco, backend
- prova minima desta task: os cenarios obrigatorios verdes
- criterio de escalada: parar se `EditVenueForm` precisar gravar CEP para a cidade fazer sentido
- nivel de autonomia: `L2`

#### Minimal Read Set

- ler primeiro: `03-design.md#Contratos e dados`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios: `03-design.md#Contratos e dados`, `03-design.md#Componentes e modulos impactados`
- caminhos candidatos: `src/components/owner/OwnerForm.tsx`; `src/components/organization/venue-web/EditVenueForm.tsx`
- palavras-chave ou simbolos de busca: `complement`, `updateVenueInfo`, `city`, `state`
- testes provaveis: teste de payload do `OwnerForm` e do `EditVenueForm`
- nao ler por padrao: `04-tasks.md` inteiro, `01-spec.md`, `security`, `database`
