# Solicitacao da Tarefa

## Nome sugerido da tarefa

Botao Fazer orçamento antes do WhatsApp na apresentacao do espaco

## Resumo da solicitacao

No card Seu investimento da apresentacao publica do espaco, um botao Fazer orçamento fica acima de Conversar com nossa equipe e abre o formulario publico de orcamento da mesma casa.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — a pagina e o formulario ja sao publicos; esta mudanca so adiciona o atalho
- risco principal: o botao apontar para outra casa, ou sumir quando a apresentacao nao tem WhatsApp
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: criar rota nova; mudar o formulario `/venue/:id/form`; mudar `/proposal/:id/view`; alterar preco, texto do card ou o botao Agendar uma visita
- prova minima desta execucao: em `/venue/AR756/apresentacao`, Fazer orçamento aparece acima de Conversar com nossa equipe e abre `/venue/AR756/form` na mesma aba
- criterio de escalada: promover para `normal` se o link precisar de contrato novo ou de outra pagina; `spec` nao se aplica
- nivel de autonomia: `L2`
- camadas transversais: `design`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/VenuePresentation.tsx` no card "Seu investimento"
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/topics/public-pages-and-branding.md#Pedido de orcamento`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: card "Seu investimento" em `VenuePresentation.tsx`; `publicVenueBudgetFormShareUrl` em `public-venue-presentation.ts`; rota `/venue/:id/form`
- palavras-chave ou simbolos de busca: `Conversar com nossa equipe`, `Seu investimento`, `publicVenueBudgetFormShareUrl`, `/venue/:id/form`
- testes provaveis: a apresentacao renderiza o link de Fazer orçamento acima do WhatsApp e o destino usa o nome da casa
- nao ler por padrao: `security`, `database`, `topics/` alem da secao do formulario, backend e schema

## Contexto informado na entrada

Pedido em chat, com print da apresentacao da AR756. No card Seu investimento, antes do botao verde Conversar com nossa equipe, entra Fazer orçamento. O clique leva a pessoa ao link de fazer orcamento.

O formulario publico ja existe em `/venue/:id/form`. O link copiado usa o nome da casa (`/venue/AR756/form`); um UUID antigo continua abrindo. `publicVenueBudgetFormShareUrl` monta a URL absoluta de producao.

## Problema atual

A apresentacao publica explica o preco e oferece so o WhatsApp. Quem quer orcamento precisa sair da pagina e achar o formulario por outro caminho.

## Objetivo da mudanca

Na apresentacao da casa, Fazer orçamento fica acima de Conversar com nossa equipe e abre o formulario publico de orcamento dessa mesma casa.

## Escopo inicial percebido

Um botao no card Seu investimento de `VenuePresentation`. O destino e o formulario que ja existe. Sem backend.

## Itens incluidos neste request

- botao Fazer orçamento no card Seu investimento, acima de Conversar com nossa equipe
- destino `/venue/{nome}/form` na mesma aba, no host em que a pessoa ja esta
- o botao continua visivel quando a casa nao tem WhatsApp

## Requisitos implicitos ja visiveis

- o texto visivel e Fazer orçamento
- o destino e a casa da apresentacao aberta, nao outra casa
- nome com espaco ou acento continua valendo no caminho, como o link copiado ja faz
- Conversar com nossa equipe permanece o botao verde do WhatsApp e so aparece quando ha numero
- preco, preco minimo e o aviso de valores sujeitos a alteracao continuam como estao
- a pagina do orcamento de um evento nao ganha este botao

## Casos de erro e borda ja percebidos

- casa sem WhatsApp: Fazer orçamento aparece; Conversar com nossa equipe nao
- apresentacao aberta pelo UUID antigo: o formulario abre a mesma casa
- nome com espaco: o caminho vai codificado, no mesmo padrao do link copiado

## Dependencias

- rota publica `/venue/:id/form` e a apresentacao `/venue/:id/apresentacao` ja existem
- o nome da casa ja resolve o formulario

## Restricoes e cuidados

- nao criar rota, endpoint nem permissao
- nao alterar o que o formulario pede nem o que a apresentacao publica devolve
- nao usar o dominio fixo de producao no clique; o caminho relativo vale no localhost e em producao
- nao ler nem versionar valores de `.env`

## Perguntas em aberto

- Nenhuma. Sem WhatsApp, o botao de orcamento continua. O clique abre o formulario na mesma aba, pelo nome da casa.

## Prioridade sugerida

Media. E o atalho que falta na apresentacao publica; o formulario em si ja funciona.

## Faixa sugerida para task workflow

- `A` = executar com `tasking/task-workflow-prompt-smart.md`

## Candidato a spec

- `nao`
- motivo: um botao no frontend, com destino que ja existe. Nao ha contrato, dado nem jornada nova.

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `botao-fazer-orcamento-apresentacao-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
