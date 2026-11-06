# Design — Adicionar ou tirar servico no link publico

## Visao geral da solucao

Duas rotas publicas no orcamento da URL. A leitura monta o modal. A gravacao troca o conjunto de servicos, recoloca os obrigatorios e move so a parcela de servico do total. Dia, convidados, locacao e horas extras nao sao recalculados.

## Componentes e modulos impactados

- `backend`: `proposal.ts`; use case, controller, factory e Zod novos ao lado de `recalculate-public-proposal`; testes do use case e do controller
- `frontend`: `ProposalView.tsx`, um dialogo novo ao lado de `RecalculateProposalDialog.tsx`, metodos em `proposal.service.ts`
- produto: uma frase em `product/02-business-rules.md#Proposal` e outra em `product/03-user-profiles.md#Cliente proponente`

## Reuso previsto

- `ServiceRepository.getByVenueId` para o catalogo do espaco da proposta
- `quoteServiceLines` e `sumServiceQuote` para servico novo e para linha antiga sem `amount`
- `proposalRepository.update` com `serviceLines`, que ja substitui as linhas e os campos juntos
- `historyRepository.create` sem `userId`, como o recalculo publico
- `Dialog` e o botao pill de "Alterar orcamento"
- a conta de obrigatorio do formulario publico: `rpaRequired` e `rpaMinPeople` com `guestNumber >= rpaMinPeople`

## Contratos e dados

`GET /proposal/presentation/:proposalId/services`

Publica. Nao usa `ensureAuthenticate`. Resposta:

- `services[]`: `id`, `name`, `amount`, `required`, `minPeople`, `selected`
- `amount` de quem ja esta no orcamento e o `ProposalService.amount` quando for numero; senao, a linha calculada agora
- `amount` de quem nao esta e a linha calculada agora, para os convidados e o intervalo ja gravados
- `required` e verdadeiro so quando `rpaRequired` e `rpaMinPeople` existem e os convidados atuais atingem o minimo

`PUT /proposal/presentation/:proposalId/services`

Corpo: `{ serviceIds: string[] }`, cada item uuid, no maximo 100, array vazio permitido. Zod descarta qualquer outro campo.

Passos da gravacao:

1. Proposta inexistente responde nao encontrada.
2. `approved` ou `paid` responde "Este orçamento já foi confirmado e não pode ser alterado." e nao grava.
3. Os ids do corpo viram um conjunto. Entram tambem os ids obrigatorios do espaco.
4. Id que nao pertence ao espaco responde "Um dos serviços não pertence a este espaço." e nao grava.
5. Se o conjunto for igual ao que ja esta gravado, a resposta devolve o total e as linhas atuais, sem `update` e sem historico.
6. Linha mantida com `amount` numerico e copiada. Linha nova, ou antiga sem `amount`, sai de `quoteServiceLines`.
7. `totalAmount` novo = total atual − soma antiga + soma nova. `basePrice`, `extraHoursQty`, `extraHourPrice`, `startDate`, `endDate` e `guestNumber` nao entram no `update`.
8. Historico: "Cliente atualizou os serviços pelo link".

A resposta da gravacao traz `totalAmount` e `proposalServices` com `id`, `serviceId`, `amount` e `service.name`, `service.rpaRequired`, `service.rpaMinPeople`. Nao traz `price`, `unitPrice`, `pricingType`, `description` nem `imageUrl`.

A soma antiga de uma linha sem `amount` usa a conta atual do cadastro, para nao deixar esse valor dentro do total quando a linha sai.

## Falhas, casos de borda e invariantes

- Obrigatorio omitido volta no passo 3 e, se ainda nao estava no orcamento, entra como linha nova.
- `rpaRequired` sem minimo nao entra no passo 3.
- Ids repetidos contam uma vez.
- `PER_HOUR` usa `calcEventDuration` do inicio e do fim ja gravados, inclusive quando cruzam dias.
- `BARTER` e `TIERED` seguem o passo 7. Nao chamam a conta de locacao do recalculo publico.
- Confirmar com a selecao aberta e a gravacao em voo nao dispara o segundo `PUT`.
- Falha HTTP nao altera `currentProposal`.

## Decisoes arquiteturais importantes

- O total muda pela diferenca das linhas. Descartado: rodar de novo a tabela da casa, porque isso substituiria locacao negociada e ja e o trabalho de "Alterar orcamento".
- Servico mantido conserva o snapshot. Descartado: recotar todo o conjunto a cada confirmacao, porque um preco editado no cadastro mudaria o orcamento ja enviado.
- A pagina nao usa `GET /service/list/:venueId`. Descartado: essa lista publica devolve o cadastro inteiro para quem souber o espaco.
- Selecao em `useState` no dialogo. Descartado: React Hook Form, porque nao ha campos de texto; o formulario publico de servico ja usa estado local.
- Sem schema novo. As colunas de linha ja existem em `ProposalService`.

## Passada transversal

- architecture: nao. A rota nova fica no router de proposta que ja atende o link publico.
- database: nao. Sem migration; a gravacao usa as colunas de linha que ja existem.
- design: sim. Modal com caixa desabilitada no obrigatorio, alerta de erro e botao travado enquanto grava.
- observability: nao ha metrica nova. O sinal e o historico da proposta e a mensagem HTTP, como no recalculo publico.
- security: sim. Gravacao publica de valor, sem login, autorizada pelo id da URL e pela recusa de aprovado ou pago.
- patterns/rules/06: idempotencia sim, selecao igual nao grava; concorrencia fica com a ultima gravacao, sem lock novo; sem fila, cache ou retry automatico.

## Riscos e mitigacoes

- Total salvo que nao bate com a soma das linhas: a diferenca desloca esse total. O teste de `T-01` cobre soma antiga nula e soma gravada.
- Catalogo lento: a pagina nao espera essa lista para sair do skeleton. O card entra quando a lista chega, se ainda nao havia servico.

## Rollout, observabilidade e rollback

Sem flag. Rollback e remover as duas rotas e o botao. Orcamentos ja gravados ficam com as linhas novas.

## Estrategia de validacao

- `T-01`: unitario do use case para selecao, obrigatorio, snapshot, total, historico e espaco errado
- `T-02`: unitario do controller para corpo, rota publica e resposta sem preco unitario
- `T-03`: browser em `/proposal/:id/view` para o botao, o obrigatorio travado, a falha e o botao que nao dispara duas vezes

## Fontes que fecharam a solucao

- `product/02-business-rules.md#Proposal`: proposta publica, sem maquina de estados alem de `approved` e `paid`
- `product/03-user-profiles.md#Cliente proponente`: o cliente usa o link publico
- `product/08-data-model.md`: snapshot da linha em `ProposalService`
- `project-decisions.md` D-02, D-05 e D-07
- `security/index.md`: endpoint publico que grava valor entra na lib
- `security/skills/reviewing-security-sensitive-changes.md`: rota nova precisa de auth explicita ou justificativa; aqui a justificativa e a mesma do recalculo
- `patterns/rules/06_senior_engineering_concepts.md`: repetir a mesma selecao nao pode repetir o efeito
- codigo ja lido: `use-case-recalculate-public-proposal.ts`, `quote-service-lines.ts`, `service-repository-interface.ts`, `ProposalView.tsx`, `ClientPerPersonProposalForm.tsx`
