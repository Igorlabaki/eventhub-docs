# Clarify — Cortesia de servicos no orcamento

## Perguntas criticas

- Onde a cortesia e decidida? Em cada orcamento, pelo dono. Confirmado pelo usuario.
- O que o cliente ve? Valor cheio, cortesia descontada e valor final. Confirmado pelo usuario.
- O cliente remove pelo link um servico com cortesia e adiciona de novo: a cortesia volta? Nao; so o dono pode dar de novo. Confirmado pelo usuario.

## Respostas confirmadas

- `POST /proposal/createPerPerson` e `/createPerDay` nao usam `ensureAuthenticate` e atendem o formulario publico e o painel.
- O painel manda `Authorization: Bearer` em toda chamada (`src/lib/axios.ts`).
- `readOptionalUserId(req)` ja existe em `middleware/ensureAuthenticate.ts`.
- O controller de `createPerPerson` chama `safeParse` e descarta o resultado. O de `createPerDay` usa `parse`, que remove chaves desconhecidas.
- `ProposalQuoteAuthorizer.assert(userId, venueId)` confere `VIEW_VENUE_PROPOSALS` ou `EDIT_VENUE_INFO` em `UserVenuePermission` e lanca 401 ou 403.
- `updatePerPerson` e `updatePerDay` exigem token, mas nao conferem permissao no espaco.
- O repositorio regrava as linhas com `deleteMany` mais `create` (`serviceLineRows`). Todo campo novo precisa estar na linha montada.
- `GET /proposal/byId/:id` devolve as linhas com todos os campos de `ProposalService`, entao `courtesyQuantity` chega ao link e ao painel sem rota nova.
- Em `ProposalView`, `applyPublicServices` deduz `unitPrice = amount / hours` depois do PUT publico. Com cortesia, essa conta fica errada.
- Sem `_prisma_migrations` na `main`. A pasta `prisma/migrations/` e a fonte versionada da DDL, e a aplicacao e por deploy request (`project/planetscale.md`).

## Requisitos implicitos confirmados

- A cortesia e inteira e na mesma unidade da quantidade da linha.
- O valor da cortesia e derivado (`unitPrice x courtesyQuantity`), nao gravado.
- `totalAmount` passa a ser liquido. A receita dos relatorios ja sai certa.
- A permissao vem do token, nunca do `userId` do corpo.

## Premissas assumidas

- Cortesia acima de 0 sem permissao responde 401 ou 403, em vez de ser ignorada.
  - Risco se estiver errado: um painel com token vencido falha ao criar com cortesia, em vez de criar sem ela. E melhor falhar do que gravar um valor diferente do que o dono viu.
- `serviceCourtesy` com quantidade 0 nao exige permissao.
  - Risco se estiver errado: nenhum valor muda com 0.
- Item de `serviceCourtesy` para servico nao selecionado e ignorado, como em `serviceHours`.
  - Risco se estiver errado: um erro de tela passa sem aviso.
- Na edicao, `serviceCourtesy` ausente zera a cortesia.
  - Risco se estiver errado: um frontend antigo apaga a cortesia ao salvar. Isso so ocorre se o backend sair muito antes do frontend; a ordem de deploy fecha a janela.
- Com total manual (`totalAmountInput`), o total digitado vence e a base absorve a diferenca, como ja acontece com os servicos.
  - Risco se estiver errado: o dono espera o total cair sozinho. O total estimado da tela mostra o valor com cortesia para ele ajustar.
- Desmarcar o servico no painel apaga a cortesia digitada.
  - Risco se estiver errado: o dono redigita.
- Servico obrigatorio por `rpaMinPeople` pode receber cortesia.
  - Risco se estiver errado: nenhum valor sai errado; vira so uma regra comercial a mais.
- Na permuta, a cortesia e gravada, mas o total continua 0.
  - Risco se estiver errado: nenhum.
- Sem acao nova de historico. A edicao continua "atualizou este orcamento".
  - Risco se estiver errado: perde-se o rastro de quem deu a cortesia; o historico atual ja registra o usuario da edicao.
- O contrato em PDF continua so com o total.
  - Risco se estiver errado: o cliente nao ve a cortesia no contrato.
- Teto do Zod para `quantity`: inteiro de 0 a 100000. O limite real e a quantidade da linha.
  - Risco se estiver errado: nenhum.

## Perguntas de erro e borda ainda abertas

- Nenhuma. A execucao segue pelas premissas acima.

## Itens bloqueantes

- Aplicar o deploy request na `main` (`T-01`) exige aprovacao nomeada (org `igorlabakig`, banco `ar756`, numero do deploy request). O codigo das outras tasks pode ser escrito antes, mas o backend nao pode ir ao ar antes da coluna.

## O que pode seguir mesmo com lacunas

- `T-02` nao depende do banco e pode comecar ja.
- O review pode trocar a premissa do 401/403 por "ignorar" sem redesenhar: muda so o ramo do use case de criacao.
