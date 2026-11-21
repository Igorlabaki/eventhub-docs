# Solicitacao da Tarefa

## Nome sugerido da tarefa

Mostrar a cortesia dos servicos no link do cliente

## Resumo da solicitacao

No card "Seu investimento" do link publico do orcamento, cada servico com cortesia mostra o desconto embaixo do nome, como ja acontece no detalhe do painel: "Cortesia: 3h (-R$ 750,00)" no servico por hora, "Cortesia (-R$ 300,00)" no fixo. O cliente precisa ver quanto ganhou de cortesia, e nao so a linha com R$ 0,00.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao
- risco principal: o cliente ver um valor de cortesia que nao bate com o total, ou continuar vendo a versao antiga porque o link aponta para a Vercel
- repos tocados: `frontend` (`eventhub-vista-dashboard/`); `backend` (`art56_server_v3/`) so para publicar o que a spec de cortesia ja fez
- fora de escopo operacional: regra de calculo da cortesia, campo de cortesia no painel, modal "Alterar servicos", "Sua experiencia inclui", schema e o dominio fixo do link
- prova minima desta execucao: em `http://localhost:<porta>/proposal/<id>/view` de um orcamento com Painel de Led (R$ 250,00 x 5 h, 3h de cortesia), Seguranca e Limpeza (cortesia fixa), "Seu investimento" mostra "Cortesia: 3h (-R$ 750,00)" embaixo do Painel de Led e "Cortesia (-R$ 300,00)" embaixo de Seguranca e de Limpeza; Recepcionista sem cortesia fica sem linha extra; o total continua R$ 5.800,00
- criterio de escalada: publicar API ou frontend e deploy, exige aprovacao nomeada; se no localhost a cortesia ja aparece, o que sobra e so publicacao e a task volta para a spec de cortesia
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/specs/2026-11-10-cortesia-servicos-orcamento/05-state.md#Snapshot`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/specs/2026-11-10-cortesia-servicos-orcamento/01-spec.md#R-11`
  - `.cursor/framework_core/topics/pricing-and-proposal-calculation.md#Servicos`
  - `.cursor/framework_core/topics/public-pages-and-branding.md`
  - `.cursor/framework_global/framework-libs/react/index.md`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` (card "Seu investimento"), `src/lib/service-courtesy.ts` (`courtesyDetail`), `src/components/proposal/ProposalServicesSummary.tsx` (modelo do painel)
- palavras-chave ou simbolos de busca: `courtesyDetail`, `courtesyQuantity`, `unitPrice`, `quotedServiceDetail`, `Seu investimento`, `event-hub-dashboard.vercel.app`
- testes provaveis: `src/lib/service-courtesy.test.ts`; abrir o link no localhost com o orcamento dos prints
- nao ler por padrao: `security`, `database`, schema, rotas de cotacao e formularios de criar

## Contexto informado na entrada

Pedido em chat, com dois prints do mesmo orcamento (50 pessoas, 02/10/2027, 12:00-18:00, total R$ 5.800,00). O detalhe do painel mostra a cortesia embaixo de Painel de Led, Seguranca e Limpeza. O link do cliente mostra os mesmos valores finais, mas sem nenhuma linha de cortesia. Pedido: "pro cliente tambem tem que aparecer os valores de desconto".

## Problema atual

O cliente ve Seguranca e Limpeza a R$ 0,00 e Painel de Led a R$ 500,00, sem saber que houve cortesia nem de quanto. Na leitura do codigo, "Seu investimento" ja chama `courtesyDetail` (spec de cortesia, `T-07`), mas essa mudanca esta so no working tree, sem commit. O link aberto pelo painel usa o dominio fixo `https://event-hub-dashboard.vercel.app/proposal/<id>/view`, que ainda serve a versao antiga.

## Objetivo da mudanca

No link do cliente, todo servico com cortesia mostra "Cortesia ... (-R$ X)" embaixo do nome, com o mesmo texto e valor do detalhe do painel, e o total nao muda.

## Escopo inicial percebido

Confirmar no localhost que a exibicao do `T-07` funciona no link. Se funcionar, o trabalho restante e publicar a API e depois o frontend da spec de cortesia. Se nao funcionar, corrigir o card "Seu investimento" para usar os mesmos campos do painel.

## Itens incluidos neste request

- provar o card "Seu investimento" no localhost com o orcamento dos prints
- corrigir o card se a linha de cortesia nao aparecer ou trouxer valor diferente do painel
- separar num commit proprio os arquivos da cortesia, sem levar as mudancas de relatorios que estao no mesmo working tree
- deixar a publicacao (API antes do frontend) pronta para aprovacao

## Requisitos implicitos ja visiveis

- mesmo texto do painel: "Cortesia: Nh", "Cortesia: N pessoas" ou "Cortesia", seguido de "(-R$ X)"
- a coluna da direita continua com o valor final da linha
- linha sem cortesia fica como hoje
- o detalhe "R$ 250,00 x 5 h" continua acima da linha de cortesia
- a ordem dos servicos (fixo, por hora, por pessoa) nao muda

## Casos de erro e borda ja percebidos

- cortesia que cobre o servico inteiro: linha a R$ 0,00 com a cortesia embaixo
- servico por hora sem `unitPrice` gravado (orcamento antigo): sem linha de cortesia em vez de valor errado
- depois de "Alterar servicos" ou "Alterar orcamento" no link, a cortesia continua visivel e com o valor recalculado
- orcamento com total manual ou `BARTER`: a cortesia so muda a linha, nunca o total

## Dependencias

- spec [Cortesia de servicos no orcamento](../specs/2026-11-10-cortesia-servicos-orcamento/00-overview.md): `T-05` (API devolve `courtesyQuantity`) e `T-07` (exibicao)
- coluna `courtesyQuantity` ja na `main` (deploy request `#45`)
- API publicada antes do frontend

## Restricoes e cuidados

- nao mudar calculo, contrato da API nem schema
- nao trocar o dominio fixo do link nesta task
- publicar ou fazer deploy so com aprovacao nomeada
- nao misturar no commit os arquivos de relatorios (`src/components/reports/*`, `venue.service.ts`, `venueReportsStore.ts`)

## Perguntas em aberto

- O print do cliente veio da Vercel ou do localhost? Premissa: da Vercel, pelo dominio fixo dos botoes do painel. Provar no localhost antes de mexer no codigo.
- A cortesia tambem aparece em "Sua experiencia inclui"? Premissa: nao. So em "Seu investimento", como diz `R-11`.
- O link mostra o valor cheio do servico alem do detalhe? Premissa: nao. Mesmo formato do painel: detalhe, cortesia e valor final.

## Prioridade sugerida

Alta. A cortesia ja esta no banco de producao, e o cliente ve servicos a R$ 0,00 sem explicacao.

## Faixa sugerida para task workflow

- `A` — uma tela, codigo provavelmente pronto; o que pesa e a prova e a publicacao
- `A` = executar com `tasking/task-workflow-prompt-smart.md`
- `B` = executar com `tasking/task-workflow-prompt-normal.md`
- `C` = promover para `spec-driven/spec-feature-bootstrap-prompt.md`

## Candidato a spec

- `nao`
- motivo: e o fechamento do `R-11` da spec de cortesia, que ja existe

## Sugestao de slug da spec

- nao se aplica; se a correcao crescer, registrar como continuacao de `specs/2026-11-10-cortesia-servicos-orcamento/`

## Sugestao de nome do arquivo

- `cortesia-no-link-do-cliente-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
- status: executado em 2026-11-10 sem mudanca de codigo. Em `http://localhost:8080/proposal/26a79102-1981-49b5-a700-a070cf9172b2/view` (API local no banco `main`), "Seu investimento" mostra "Cortesia (-R$ 300,00)" em Seguranca e Limpeza, "R$ 250,00 × 5 h" e "Cortesia: 3h (-R$ 750,00)" no Painel de Led, Recepcionista sem linha extra e total R$ 5.800,00. `service-courtesy.test.ts` com 10 testes verdes. O print do cliente veio da Vercel, que ainda serve a versao antiga. Falta commit separado dos relatorios e publicacao (API antes do frontend), com aprovacao nomeada
