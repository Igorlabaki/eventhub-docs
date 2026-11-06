# Spec — Adicionar ou tirar servico no link publico

## Problema

Quem abre `/proposal/:id/view` ve os servicos ja ligados em "Sua experiencia inclui" e o valor no card "Seu investimento", e so a equipe consegue mudar essa lista no painel.

## Objetivos

O cliente abre um modal nesse card, marca ou desmarca servicos do espaco e confirma. Servico obrigatorio para os convidados atuais permanece marcado. A pagina passa a mostrar a lista e o total gravados. Cada falha aparece no modal e a lista anterior permanece.

## Fora de escopo

- mudar a regra de quando um servico e obrigatorio
- dia, convidados, horas, check-in, check-out e minimo de noites
- incluir sozinho um servico que passou a ser obrigatorio porque "Alterar orcamento" mudou os convidados
- descontos, adicionais e o total digitado a mao da locacao
- cadastro, foto e descricao do servico
- regravar a linha de um servico que ja estava no orcamento so porque o preco do cadastro mudou
- nova tabela, migration e rate limit proprio

## User stories ou cenarios principais

- O cliente abre o modal, ve os servicos do espaco, tira um opcional, confirma e ve a experiencia e o total sem essa linha.
- O cliente tenta tirar um obrigatorio, nao consegue, e ao confirmar esse servico continua no total.
- O cliente erra a rede ou o orcamento ja foi confirmado, le o motivo e a pagina nao troca a lista.

## Criterios de aceite

- `R-01`: No card "Sua experiencia inclui" ha o botao "Adicionar servico", visivel em qualquer largura, que abre um modal. O card aparece quando o espaco tem servico, mesmo que o orcamento ainda nao tenha nenhum.
- `R-02`: O modal lista os servicos daquele espaco. Os ja ligados vem marcados. Cada linha mostra o nome e o valor da linha. Obrigatorio para os convidados atuais vem marcado, desabilitado, com o texto "Obrigatorio a partir de N pessoas."
- `R-03`: Confirmar envia somente os ids escolhidos. Nao envia preco nem total.
- `R-04`: Uma selecao diferente grava as linhas e o total. A experiencia e o investimento passam a mostrar a lista nova. Servico novo entra pela conta da casa: fixo, vezes as horas ou vezes os convidados. Servico que ja estava permanece com a linha gravada.
- `R-05`: Id obrigatorio omitido pelo cliente volta para a lista e entra no total. Servico cujo minimo de pessoas ainda nao foi atingido pode sair.
- `R-06`: Orcamento com `approved` ou `paid` verdadeiro nao e gravado; o modal diz "Este orçamento já foi confirmado e não pode ser alterado."
- `R-07`: Falha de rede ou erro inesperado mostra "Não foi possível atualizar os serviços. Tente de novo.", mantem o que foi marcado no modal e nao troca a lista nem o total da pagina.
- `R-08`: Id de outro espaco ou desconhecido nao grava; o modal diz "Um dos serviços não pertence a este espaço."
- `R-09`: A mesma selecao nao regrava linha, total nem historico.
- `R-10`: A lista do modal e a resposta da gravacao nao incluem preco unitario, tipo de preco, dono, contrato, pagamento nem documento. O valor exibido e o da linha neste orcamento.
- `R-11`: Enquanto a gravacao nao volta, Confirmar nao dispara de novo.
- `R-12`: O historico da proposta ganha "Cliente atualizou os serviços pelo link", sem usuario, so quando a selecao muda.
- `R-13`: Dia, convidados, horas, locacao e horas extras permanecem. O total muda so pela diferenca da soma das linhas de servico.

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: as rotas novas sao publicas de proposito, no orcamento da URL; nao usam `ensureAuthenticate`. Nao gravam se `approved` ou `paid` for verdadeiro. D-05: a trava e a regra do orcamento e o corpo estreito, nao a permissao de tela.
- erros e mensagens esperadas: texto de pessoa, no modal, em `role="alert"`; falha nao limpa a selecao nem a pagina.
- observabilidade minima: sem metrica nova. O sinal e o historico na proposta e a mensagem HTTP que o modal mostra.
- concorrencia, idempotencia ou retry: a mesma selecao nao grava de novo. Duas gravacoes diferentes ficam com a ultima. O botao trava no envio. Nao ha fila nem lock alem do `update` que ja troca as linhas e o total juntos.
- rollout, fallback ou degradacao: sem flag. Se a lista do espaco nao carregar e o orcamento nao tiver servico, o card nao aparece. Se o orcamento ja tiver servico, o card permanece e o modal mostra o erro sem gravar.

## Casos de erro e borda obrigatorios

- caso: `rpaRequired` sem `rpaMinPeople`
  impacto: o formulario publico nao trata esse servico como obrigatorio
  cobertura esperada: a gravacao tambem nao trava; ele pode sair
- caso: linha antiga sem `amount`
  impacto: a diferenca do total usaria zero e deixaria o valor do servico dentro do total
  cobertura esperada: a soma antiga dessa linha usa a conta atual do cadastro; se ela continuar na selecao, a linha nova passa a guardar o snapshot
- caso: `PER_HOUR` em orcamento de mais de um dia
  impacto: a hora do servico novo mudaria se a conta usasse so um dia
  cobertura esperada: a quantidade usa o intervalo ja gravado entre inicio e fim, sem alterar as datas
- caso: `BARTER` ou modelo `TIERED`
  impacto: recalcular a locacao pela tabela nao tem conta segura
  cobertura esperada: este fluxo nao recalcula a locacao; so move a soma dos servicos
- caso: preco do cadastro mudou depois da proposta
  impacto: confirmar sem mexer na selecao trocaria o valor ja enviado
  cobertura esperada: selecao igual nao grava; servico mantido conserva `amount`
- caso: dois ids iguais no corpo
  impacto: a linha entraria duas vezes
  cobertura esperada: a selecao e um conjunto

## Impacto esperado

O link publico passa a alterar os servicos e o total daquele orcamento. Locacao, dia e horas ficam como estavam. O painel ve o historico e as mesmas linhas que ja mostra.

## Areas impactadas

- `frontend`: `ProposalView` e o servico de proposta
- `backend`: duas rotas publicas no orcamento, use case, Zod e historico
- produto: uma frase em `product/02-business-rules.md#Proposal` e em `product/03-user-profiles.md#Cliente proponente`

## Restricoes e cuidados

- D-02: router, controller, use case, repositorio
- D-05: permissao de tela nao protege esta gravacao
- D-07: dinheiro continua em Float; esta feature nao migra o tipo
- nao ler nem versionar `.env`
- nao criar estado novo no frontend; a lista do modal fica em estado local, e o retorno entra no `currentProposal` que a pagina ja usa
- nao chamar `GET /service/list/:venueId` na pagina publica

## Dependencias

- card "Sua experiencia inclui" e card "Seu investimento" em `ProposalView`
- `quoteServiceLines` e `sumServiceQuote`
- `ServiceRepository.getByVenueId`
- `proposalRepository.update` com `serviceLines`
- `Dialog` de `components/ui/dialog.tsx`
- `History.userId` opcional
- colunas `ProposalService.amount`, `unitPrice`, `quantity` e `pricingType` ja existentes

## Mapeamento leve requisito -> task -> prova

- `R-04`, `R-05`, `R-08`, `R-09`, `R-12`, `R-13` -> `T-01` -> unitario
- `R-03`, `R-06`, `R-10` -> `T-02` -> unitario
- `R-01`, `R-02`, `R-07`, `R-11` -> `T-03` -> browser

## Perguntas em aberto

Nenhuma bloqueante. Premissas e o risco de cada uma estao em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
