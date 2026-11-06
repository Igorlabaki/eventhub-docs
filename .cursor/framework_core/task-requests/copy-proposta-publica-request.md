# Solicitacao da Tarefa

## Nome sugerido da tarefa

Aplicar o copy comercial na proposta publica

## Resumo da solicitacao

A pagina publica do orcamento troca os titulos internos por copy de proposta: o espaco, a experiencia e o investimento, com icones nas listas e a locacao exclusiva no lugar do valor base.

## Context Pack

- frente principal: frontend
- superficie sensivel: nao — a pagina `/proposal/:id/view` ja e publica; esta entrega so troca texto e icones ja renderizados
- risco principal: o copy novo apagar o nome do espaco, os itens cadastrados ou o calculo do total
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: painel, contrato, schema, API, calculo de preco, cores, fotos, mapa e rodape
- prova minima desta execucao: abrir `/proposal/:id/view` e ver os titulos, subtitulos, o check nas caracteristicas, o circulo nos servicos, "Locação exclusiva do espaço", "Investimento total" e o botao "Conversar com nossa equipe"; orcamento sem caracteristica ou sem servico continua omitindo essa secao
- criterio de escalada: promover para `normal` se o texto passar a ser editavel por espaco ou exigir coluna nova; `spec` nao se aplica
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `eventhub-vista-dashboard/src/pages/ProposalView.tsx`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/active-libs.md#Leituras por frente`
  - `.cursor/framework_global/framework-libs/react/index.md`
  - `.cursor/framework_global/framework-libs/design/index.md`
- caminhos candidatos: pagina publica da proposta
- palavras-chave ou simbolos de busca: `ProposalView`, `Valor base`, `O que a casa tem`, `Incluso neste orçamento`
- testes provaveis: abrir a pagina publica com caracteristicas e servicos e conferir o copy
- nao ler por padrao: `security`, `database`, `topics/`, backend e schema

## Contexto informado na entrada

Pedido em chat, com um mock do link de orcamento. Os titulos e subtitulos do mock entram na pagina. A palavra investimento substitui o rotulo de preco. A linha do valor base passa a ser "Locação exclusiva do espaço". Caracteristicas ganham check e servicos ganham circulo. Os nomes dos itens continuam os do cadastro.

## Problema atual

Quem abre o link ve "O que a casa tem", "Incluso neste orçamento", "Valor" e "Valor base". A lista nao tem marcador e o fechamento pede "Falar no WhatsApp".

## Objetivo da mudanca

Na pagina publica de qualquer orcamento, os blocos usam o copy comercial do mock, com os itens do espaco e deste orcamento no lugar dos exemplos.

## Escopo inicial percebido

Troca de texto e icone em uma pagina que ja existe. Nenhuma gravacao nova.

## Itens incluidos neste request

- titulo "Conheça nosso espaço" e o subtitulo do ambiente versatil
- check ao lado de cada caracteristica cadastrada
- titulo "Sua experiência inclui" e o subtitulo dos servicos
- circulo ao lado de cada servico deste orcamento
- titulo "Seu investimento" e o subtitulo com o nome do espaco
- linha "Locação exclusiva do espaço" no lugar de "Valor base"
- rotulo "Investimento total"
- nota de valores sujeitos a alteracao ate a confirmacao da reserva
- "Referência por convidado" e "Hora adicional de evento"
- fechamento "Vamos tornar seu evento especial?" e o botao "Conversar com nossa equipe"
- bloco inicial "Proposta personalizada" com "Seu evento na {nome}", data por extenso, horario reservado, convidados previstos, capacidade e horario de funcionamento

## Requisitos implicitos ja visiveis

- nomes de caracteristica e de servico continuam dinamicos
- sem caracteristica ou sem servico, a secao correspondente continua oculta
- o total, a referencia por convidado e a hora adicional usam os mesmos numeros de hoje
- o botao continua abrindo o WhatsApp do espaco
- a linha de horas extras cobradas permanece quando o orcamento tem hora extra
- sem nome de espaco na apresentacao, o subtitulo do investimento nao inventa um nome

## Casos de erro e borda ja percebidos

- apresentacao da casa indisponivel: o card de investimento ainda aparece, sem citar um nome de espaco
- orcamento sem convidado ou sem valor base: a referencia por convidado continua "-"

## Dependencias

- pagina publica ja renderiza caracteristicas, servicos e o card de valor

## Restricoes e cuidados

- nao alterar calculo, contrato nem o rotulo "Preço Base" do gerador de contrato
- nao fixar no codigo os exemplos do mock (piscina, limpeza, AR756)

## Perguntas em aberto

- nenhuma

## Prioridade sugerida

- alta para o link que o cliente ja recebe

## Faixa sugerida para task workflow

- `A`

## Candidato a spec

- `nao`
- motivo: troca de copy e icone em um unico componente

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `copy-proposta-publica-request.md`

## Operacao

- tipo: `task-request`
- faixa: `A`
- candidato a spec: `nao`
- execucao recomendada: `smart`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:review`
- derivacao repo-local: `nao se aplica`
