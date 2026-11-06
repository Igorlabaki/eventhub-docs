# Solicitacao da Tarefa

## Nome sugerido da tarefa

Agendar visita no card do espaco da proposta publica

## Resumo da solicitacao

O card "Conheça nosso espaço" ganha, abaixo das caracteristicas, um convite para visitar o espaco e um botao discreto que abre o WhatsApp oficial com a mensagem de agendamento e o link desta proposta.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — a pagina `/proposal/:id/view` ja e publica e o WhatsApp do espaco ja aparece nela; o botao reutiliza esse numero e o link que o cliente ja abriu
- risco principal: o botao sumir quando nao ha caracteristicas, ou a mensagem ir para um numero que nao e o WhatsApp do espaco
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: botao verde "Conversar com nossa equipe", painel, schema, API, calculo e as demais secoes da proposta
- prova minima desta execucao: abrir `/proposal/:id/view` de um orcamento com caracteristicas e WhatsApp e ver, no fim do card do espaco, o texto "Quer conhecer pessoalmente?" e o botao "Agendar uma visita"; o link do botao abre `wa.me` desse espaco com o nome do espaco e a URL desta pagina na mensagem; sem WhatsApp, o botao nao aparece; o botao verde do investimento continua
- criterio de escalada: promover para `normal` se a visita precisar de agenda, formulario ou coluna nova; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx` no card "Conheça nosso espaço" e no link `wa.me` ja existente
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: pagina publica da proposta
- palavras-chave ou simbolos de busca: `ProposalView`, `Conheça nosso espaço`, `wa.me`, `whatsappNumber`
- testes provaveis: abrir a pagina publica com e sem WhatsApp e conferir o botao e a mensagem
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com um mock do card "Conheça nosso espaço". Abaixo da lista de caracteristicas entra um bloco com borda superior: a esquerda, "Quer conhecer pessoalmente?" e "Agende uma visita e descubra tudo o que a {nome do espaço} oferece."; a direita, um botao com borda, icone de calendario, o texto "Agendar uma visita" e uma seta. O fundo do botao e branco e o texto e preto, para nao competir com o botao verde do final. A implementacao usa o WhatsApp oficial do espaco e o link dinamico do orcamento.

Mensagem automatica:

```
Olá! Recebi o orçamento da {nome do espaço} e gostaria de agendar uma visita para conhecer o espaço.

Segue o link da minha proposta:
{url desta página}
```

## Problema atual

Quem abre a proposta ve as caracteristicas do espaco e so encontra contato no botao verde do card de investimento. Nao ha um convite para agendar visita logo depois de conhecer o espaco.

## Objetivo da mudanca

No card "Conheça nosso espaço" de qualquer orcamento publico com caracteristicas e WhatsApp, a pessoa ve o convite de visita e o botao "Agendar uma visita" abre o WhatsApp do espaco com a mensagem e o link desta proposta.

## Escopo inicial percebido

Ajuste de um card que ja existe. Nenhuma gravacao nova.

## Itens incluidos neste request

- traco separando a lista do convite
- titulo "Quer conhecer pessoalmente?"
- subtitulo com o nome do espaco
- botao "Agendar uma visita", com borda, icone de calendario e seta, fundo branco e texto preto
- abertura do WhatsApp ja cadastrado no espaco
- mensagem com o nome do espaco e a URL da pagina publica deste orcamento

## Requisitos implicitos ja visiveis

- o nome do espaco e o numero de WhatsApp continuam os do cadastro; o mock da AR756 e so exemplo
- o link da mensagem e a URL atual da proposta, nao um texto fixo
- o botao verde do investimento permanece com o texto e o destino atuais
- em tela estreita, o texto e o botao empilham; em tela larga, ficam na mesma linha, como no mock
- sem numero de WhatsApp, o convite e o botao nao aparecem

## Casos de erro e borda ja percebidos

- orcamento sem caracteristicas: o card "Conheça nosso espaço" continua oculto e o convite nao cria um card sozinho
- apresentacao da casa sem nome: o subtitulo e a mensagem nao inventam um nome de espaco

## Dependencias

- o card de caracteristicas e o numero de WhatsApp ja chegam na pagina publica

## Restricoes e cuidados

- nao substituir o botao verde
- nao gravar agenda, formulario nem coluna nova
- nao fixar no codigo o nome AR756 nem um numero de telefone

## Perguntas em aberto

- o botao fica so dentro do card de caracteristicas, mesmo que um espaco sem caracteristicas tenha WhatsApp — premissa: sim, o convite nao cria card proprio
- a cor do botao e branca com texto preto, independente da cor do card — premissa: sim, como no mock

## Prioridade sugerida

- alta para o link que o cliente ja recebe

## Faixa sugerida para task workflow

- `A`

## Candidato a spec

- `nao`
- motivo: um bloco e um link em um card que ja existe

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `agendar-visita-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar entrega`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
