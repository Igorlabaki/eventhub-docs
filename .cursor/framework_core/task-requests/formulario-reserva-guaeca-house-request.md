# Solicitacao da Tarefa

## Nome sugerido da tarefa

Corrigir o preenchimento do formulario de reserva do site da Guaeca House

## Resumo da solicitacao

O formulario "Solicite uma Reserva" do site da Guaeca House (`guaeca-house-escapade/`) da erro no preenchimento. O diagnostico em chat mostrou que a API aceita o payload do site, entao o problema esta no cliente: o campo de datas fica invalido sem mostrar mensagem, e o erro do envio esconde o motivo devolvido pela API. A tarefa confirma o erro que o usuario ve e corrige a validacao e a mensagem.

## Context Pack

- frente principal: frontend (site publico da Guaeca House)
- superficie sensivel: sim — formulario publico que envia PII (nome, WhatsApp, e-mail) para endpoint publico; a execucao nao muda auth nem o endpoint
- camadas transversais: `design`
- risco principal: o site chama a API de producao (`https://art56-server-v3.vercel.app`, fixo em `src/lib/axios.ts`) com `venueId` real fixo; enviar o formulario no localhost cria orcamento real e notificacao no painel da Guaeca House
- repos tocados: `guaeca-house-escapade/` (repo proprio, fora dos maps do core)
- fora de escopo operacional: backend `art56_server_v3/` e `POST /proposal/createPerDay`; trocar a URL da API por variavel de ambiente; layout e textos do formulario; pagina `/orcamento/byId/:id`; o formulario publico do painel (`eventhub-vista-dashboard`)
- prova minima desta execucao: `npm run build` verde em `guaeca-house-escapade/`; no localhost, (1) escolher so a data de entrada e enviar mostra "Selecione a data de saída." abaixo do calendario; (2) clicar de novo na data de entrada com o periodo completo nao mostra "Required" em ingles; (3) entrada e saida no mesmo dia mostra erro; (4) com tudo valido, o envio so acontece com aprovacao nomeada (cria orcamento real) ou com a chamada interceptada; erro da API aparece no toast com a mensagem do servidor
- criterio de escalada: sobe para `normal` com backend se o erro que o usuario ve vier da API (status 4xx/5xx com mensagem que nao seja de data); sobe para `spec` se for preciso tirar a URL e o `venueId` fixos do codigo
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `guaeca-house-escapade/src/components/sections/BookingSection.tsx` em `formSchema`, `onSubmit` e no `FormField` `dateRange`
- libs obrigatorias: `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Regras de ouro`
  - `.cursor/framework_core/project/api-endpoints.md` na linha de `POST /proposal/createPerDay`
- caminhos candidatos: `guaeca-house-escapade/src/lib/axios.ts`; `guaeca-house-escapade/src/context/VenueContext.tsx` (`venueId` fixo); `guaeca-house-escapade/src/components/ui/form.tsx` (`FormMessage`); `guaeca-house-escapade/src/components/ui/calendar.tsx`
- palavras-chave ou simbolos de busca: `dateRange`, `FormMessage`, `onSelect`, `toast`, `createPerDay`, `maxGuest`
- testes provaveis: o site nao tem script de teste; prova por build e browser
- nao ler por padrao: `security`, `database`, backend, `topics/`

## Contexto informado na entrada

Pedido em chat: "preciso consertar o formulario desse site, o preenchimento esta dando erro, veja o que esta errado". Sem print nem texto do erro.

Ja verificado no chat (2026-11-14), so com leitura ou chamada que nao grava:

- `POST /proposal/createPerDay` com o payload do site e `venueId` falso passou na validacao e parou em 404 "Locacao nao encontrado"
- `GET /proposal/byId/<uuid falso>` responde 404 normal, sem erro de coluna no banco
- CORS da API e `origin: "*"`
- o espaco `42b9e0f2-3d50-4aff-a0a4-f7a4d9553708` tem so o servico "Limpeza", `FIXED`, entao a exigencia de horas de servico `PER_HOUR` nao se aplica
- React 18.3 com `react-input-mask` 2.0.4 e `react-day-picker` 8.10; `node_modules` nao instalado no site

## Problema atual

- o erro de data fica em `dateRange.from` ou `dateRange.to`, e o `<FormMessage />` do campo `dateRange` so le `errors.dateRange.message`; com so a entrada escolhida o formulario treme e nada explica o motivo
- no modo `range` do `react-day-picker` 8, clicar de novo na data de entrada com o periodo completo devolve `undefined`; o campo vira `undefined` e aparece "Required" do Zod, em ingles
- entrada e saida no mesmo dia passam, gerando reserva de zero diarias
- o `catch` do `onSubmit` mostra sempre "Por favor, tente novamente mais tarde." e descarta `error.response.data.message`

## Objetivo da mudanca

Todo erro de preenchimento do formulario de reserva aparece em portugues abaixo do campo certo, e falha da API mostra no toast a mensagem que o servidor devolveu.

## Escopo inicial percebido

Ajuste no schema Zod e no calendario de `BookingSection.tsx`, mais a mensagem do toast. Sem mudar a API, o payload ou o layout.

## Itens incluidos neste request

- confirmar com o usuario (ou reproduzindo no localhost) qual erro ele ve, antes de mexer
- `dateRange` validado no nivel do objeto (`refine`), com mensagens de entrada, saida e saida depois da entrada
- `onSelect` do calendario nunca grava `undefined` no campo
- toast de erro usa a mensagem da API quando existir (`isAxiosError`)

## Requisitos implicitos ja visiveis

- mensagens em portugues, no mesmo tom das que ja existem no schema
- o envio continua com `startDay`/`endDay` em `yyyy-MM-dd`, `startHour` `14:00`, `endHour` `12:00` e "Limpeza" sempre incluida
- o limite de `maxGuest` (12) continua funcionando

## Casos de erro e borda ja percebidos

- so a data de entrada escolhida
- clique de novo na data de entrada com o periodo completo
- entrada e saida no mesmo dia
- hoje aparece desabilitado (`date < new Date()` compara com a hora atual); confirmar se e intencional
- API fora do ar ou 5xx: toast com texto padrao
- API 400 com mensagem: toast com a mensagem

## Dependencias

- `npm install` (ou `yarn`) em `guaeca-house-escapade/` para rodar build e localhost

## Restricoes e cuidados

- nao enviar o formulario valido no localhost sem aprovacao nomeada: grava orcamento real na producao da Guaeca House
- se precisar provar o envio, usar `venueId` falso so em teste manual, sem commitar, ou interceptar a chamada no browser
- o repo do site nao esta nos maps do core; nao criar map novo nesta task

## Perguntas em aberto

- Qual erro o usuario ve? Premissa: o formulario treme sem mensagem ao escolher as datas, ou aparece "Required"; se for toast de "Erro ao enviar solicitacao", escalar para `normal` com leitura da API.
- Bloquear entrada e saida no mesmo dia? Premissa: sim, minimo de uma diaria.
- Liberar o dia de hoje no calendario? Premissa: nao mexer nesta task; so registrar.

## Prioridade sugerida

Alta. Formulario de captacao do site publico; erro aqui perde reserva.

## Faixa sugerida para task workflow

- `B` — um repo e um componente, mas a causa exata ainda precisa ser confirmada com o usuario e o envio toca producao
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: correcao localizada de validacao e mensagem em um componente

## Sugestao de slug da spec

- `framework_core/specs/formulario-reserva-guaeca-house/`, apenas se a escalada para spec acontecer

## Sugestao de nome do arquivo

- `formulario-reserva-guaeca-house-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `executar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica` (um repo)
