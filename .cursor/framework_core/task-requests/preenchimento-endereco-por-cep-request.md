# Solicitacao da Tarefa

## Nome sugerido da tarefa

Preenchimento de endereco por CEP

## Resumo da solicitacao

Quem preenche um endereco obrigatorio digita o CEP e logradouro, bairro, cidade e UF aparecem. Numero e complemento continuam manuais. O mesmo gesto vale no cadastro e na edicao do espaco e nos dados de endereco do contrato, no painel e na pagina publica. O endereco gravado deixa de sair com grafias diferentes no relatorio de origem.

## Context Pack

- frente principal: frontend (formularios de endereco)
- superficie sensivel: sim — endereco de cliente e proprietario ja e dado pessoal; a busca envia o CEP do navegador para ViaCEP e, se precisar, para a BrasilAPI
- risco principal: a busca preencher errado e a pessoa salvar por cima, ou o padrao "Sao Paulo" / "SP" dos contratos mascarar um campo que a busca nao trouxe
- repos tocados: `frontend` (`eventhub-vista-dashboard/`). O backend nao ganha endpoint nem coluna
- fora de escopo operacional: limpar enderecos ja gravados; mudar a query do relatorio de origem; catalogo de ruas; select de todas as cidades no lugar do CEP; endpoint novo; coluna nova
- prova minima desta execucao: um teste do bloco de endereco com busca simulada para `01001000` preenche logradouro, bairro, cidade e UF e deixa numero e complemento vazios; CEP invalido ou busca falha mostra o erro no campo e mantem o que ja estava digitado; o mesmo bloco aparece em criar espaco, Configuracoes aba Endereco, contrato PF/PJ do painel e contrato publico PF/PJ
- criterio de escalada: promover para spec (ja e o proximo passo). Escalar de novo se a execucao precisar de proxy no backend ou de coluna nova
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`, `patterns`, `security`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Provas`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_core/topics/frontend-application.md`
  - `.cursor/framework_core/topics/auth-and-security.md`
- caminhos candidatos: `CreateVenueForm.tsx`; `VenueSettings.tsx` aba Endereco; `pf-contract-form.tsx`; `pj-contract-form.tsx`; `PFContractPersonalInfoForm.tsx`; `PJContractPersonalInfoForm.tsx`; `ContractPublicField.tsx`; `OwnerForm.tsx`; `EditVenueForm.tsx`
- palavras-chave ou simbolos de busca: `cep`, `street`, `neighborhood`, `city`, `state`, `adressComplement`
- testes provaveis: vitest do bloco com busca simulada (CEP completo, CEP sem rua, CEP invalido, busca fora do ar)
- nao ler por padrao: `database`, `observability`, schema alem de confirmar que nao ha coluna nova, use case do relatorio de origem, PlanetScale

## Contexto informado na entrada

Pedido em chat. Nao existe busca de CEP no frontend e o `package.json` do dashboard nao tem ViaCEP, BrasilAPI nem biblioteca de CEP. Os formularios gravam endereco em texto livre, cada um com mascara diferente. O relatorio de origem agrupa cidade, estado e bairro da proposta; grafias diferentes da mesma cidade ficam separadas, e linha sem um dos tres campos fica de fora.

## Problema atual

Criar espaco, editar espaco, contrato do painel e contrato publico pedem o endereco digitado. Cidade e estado do contrato ja nascem "Sao Paulo" e "SP". O criar espaco grava o CEP so com digitos; Configuracoes e os contratos nao. O relatorio le `Proposal.city`, `Proposal.state` e `Proposal.neighborhood`, nao o endereco do espaco.

## Objetivo da mudanca

Nos formularios de endereco do espaco e do contrato, digitar o CEP completo preenche logradouro, bairro, cidade e UF, e numero e complemento continuam em branco para a pessoa informar.

## Escopo inicial percebido

Um bloco de endereco reutilizado nas telas que ja pedem endereco, com busca no navegador. Nao ha mudanca de schema nem de API. Toca varios formularios e por isso cabe em spec, nao em uma task isolada.

## Itens incluidos neste request

- CEP como primeiro passo: com 8 digitos, a busca preenche logradouro, bairro, cidade e UF
- numero e complemento continuam manuais
- criar espaco (`CreateVenueForm.tsx`) e editar espaco, aba Endereco (`VenueSettings.tsx`)
- contrato PF e PJ do painel (`pf-contract-form.tsx`, `pj-contract-form.tsx`)
- contrato publico PF e PJ (`PFContractPersonalInfoForm.tsx`, `PJContractPersonalInfoForm.tsx`)
- formularios que a premissa default inclui: proprietario (`OwnerForm.tsx`) e cidade/estado do site da organizacao (`EditVenueForm.tsx`)
- CEP invalido ou busca falha: erro no proprio campo, sem apagar o que ja estava digitado
- CEP que devolve so cidade e UF: rua e bairro ficam para a pessoa digitar

## Requisitos implicitos ja visiveis

- a busca roda no navegador; ViaCEP primeiro, BrasilAPI se a primeira nao responder
- campos preenchidos pela busca ficam editaveis
- quando a busca falha, a UF vira select das 27 siglas; a cidade vira select da lista do IBGE filtrada pela UF so quando o CEP nao trouxer rua nem bairro
- um unico bloco de endereco serve aos formularios
- ao salvar, a UF sai em duas letras maiusculas e o CEP sai so com digitos, no valor que o formulario ja envia
- endereco ja gravado permanece; o relatorio antigo so muda se alguem reabrir e salvar

## Casos de erro e borda ja percebidos

- CEP de cidade sem logradouro nem bairro na base
- CEP invalido
- ViaCEP e BrasilAPI fora do ar: mesmo tratamento do CEP invalido
- contrato que ja abre com cidade "Sao Paulo" e estado "SP": esses valores nao podem fingir que a busca preencheu
- criar espaco ja corta o CEP; Configuracoes e os contratos ainda podem gravar a mascara

## Dependencias

- os formularios e os campos de endereco ja existem e ja salvam
- `Proposal`, `Venue` e `Owner` ja tem os campos de endereco; nada disso muda de schema

## Restricoes e cuidados

- nao reabrir: o CEP preenche logradouro, bairro, cidade e UF; numero e complemento sao manuais; o select de todas as cidades nao substitui o CEP; catalogo de ruas fica de fora
- nao criar endpoint nem coluna
- nao corrigir em massa o que ja esta gravado
- nao mudar a query de `eventOriginRows` nem `buildEventOrigin`
- o CEP enviado para fora e dado de endereco; nao enviar o restante do formulario
- nao ler nem versionar valores de `.env`

## Insumo para o bootstrap

- ViaCEP: `https://viacep.com.br/ws/{cep}/json/`. Reserva: `https://brasilapi.com.br/api/cep/v2/{cep}`
- criar espaco ja grava o CEP so com digitos; Configuracoes do espaco e os contratos nao
- contratos nascem com cidade "Sao Paulo" e estado "SP"
- relatorio de origem usa cidade, estado e bairro da `Proposal` (`eventOriginRows` e `buildEventOrigin`). Endereco errado do espaco segue na apresentacao e nos tokens `venue.cep`, `owner.cep` e `client.cep`, e nao e a fonte desse relatorio
- nao ha schema novo. A mudanca e o preenchimento e o formato do valor que os formularios ja salvam

## Perguntas em aberto

- O formulario do proprietario entra na mesma entrega? Default: sim.
- O `EditVenueForm` entra, so no que a tela ja pede (cidade e estado)? Default: sim.
- Logradouro, bairro, cidade e UF preenchidos pela busca ficam editaveis? Default: sim.
- Quando a busca falha, a UF vira select das 27 siglas e a cidade vira select do IBGE filtrado pela UF? Default: sim, so como reserva. Cidade em select apenas quando o CEP nao trouxer rua nem bairro.
- Os formularios usam um unico bloco de endereco? Default: sim.
- Ao salvar, a UF fica em duas letras maiusculas e o CEP fica so com digitos? Default: sim.

## Prioridade sugerida

Media. Melhora o endereco que o relatorio de origem agrupa. Nao desbloqueia um fluxo quebrado.

## Faixa sugerida para task workflow

- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `sim`
- motivo: o mesmo preenchimento entra em varios formularios, com busca externa, reserva de select e um bloco compartilhado. Isso se quebra em mais de uma task.

## Sugestao de slug da spec

- `framework_core/specs/preenchimento-endereco-por-cep/`

## Sugestao de nome do arquivo

- `preenchimento-endereco-por-cep-request.md`

## Operacao

- tipo: `task-request`
- faixa: `C`
- candidato a spec: `sim`
- execucao recomendada: `normal`
- proximo passo: `ver spec`
- promovida para: `specs/2026-11-20-preenchimento-endereco-por-cep/`
- entrada publica recomendada: `fw:spec`
- derivacao repo-local: `nao se aplica`
- promocao: usar `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\spec-driven\spec-feature-bootstrap-prompt.md` a partir deste request
