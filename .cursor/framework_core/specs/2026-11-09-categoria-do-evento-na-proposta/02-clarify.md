# Clarify — Categoria do evento na proposta

## Perguntas criticas

- A categoria entra no `type` ou e campo novo? Campo novo. `ProposalType` nao muda.
- Filmagem entra na lista? Nao. Filmagem ja e `PRODUCTION`.
- Lista fechada ou configuravel? Fechada (enum Prisma).
- Obrigatoria? Sim, nas propostas de tipo Evento gravadas a partir desta entrega.

## Respostas confirmadas

- Valores: Empresarial / confraternização, Aniversário, Despedida de solteiro, Casamento, Coffee break, Outro.
- Outro tipo que nao seja Evento grava categoria nula.
- Propostas existentes ficam com categoria nula; sem backfill.

## Requisitos implicitos confirmados

- A regra e validada no backend, nao so na tela.
- Rotulo em portugues na tela; valor gravado e o enum.
- O formulario publico continua publico e passa a enviar a categoria.

## Premissas assumidas

- Nomes `eventCategory` / `EventCategory` e valores em ingles (`CORPORATE`, `BIRTHDAY`, `BACHELOR_PARTY`, `WEDDING`, `COFFEE_BREAK`, `OTHER`), como `ProposalType` e `TrafficSource`. Risco se errado: renomear enum depois exige migration.
- Editar proposta antiga de Evento exige categoria ao salvar. Risco se errado: a equipe precisa escolher uma categoria so para corrigir outro campo.
- No detalhe, a linha "Tipo do evento" entra no card "Informações Pessoais", abaixo de "Por onde nos conheceu", porque e o unico card de dados da proposta. Risco se errado: quem nao tem permissao de dados pessoais nao ve a categoria.
- No formulario publico, o select entra no passo 2 (dados do evento), antes da descricao, e entra na lista de campos do `goNext` desse passo. Risco se errado: so a posicao muda.
- A regra mora no use case (funcao pura compartilhada), nao em `superRefine` do Zod, porque o controller de create por pessoa chama `safeParse` e repassa o body cru. Risco se errado: nenhum funcional; a validacao fica um nivel abaixo do schema.
- API e front sobem no mesmo ciclo, depois da coluna no `main`. Risco se errado: janela em que o painel antigo recebe 400 ao criar Evento, ou o front novo quebra o create numa API sem a coluna.

## Perguntas de erro e borda ainda abertas

Nenhuma. Troca de tipo, proposta antiga, permuta e valor desconhecido ja tem premissa e cobertura em `01-spec.md`.

## Itens bloqueantes

Nenhum para escrever codigo. A prova no browser depende da coluna no `main`, porque o localhost roda contra o banco de producao pelo tunel.

## O que pode seguir mesmo com lacunas

- Owner nao definido. Nao impede `T-01`.
- Divida observada e fora desta spec: `ProposalEdit` e `PerPersonProposalForm` oferecem Pernoite, mas os schemas de update por pessoa e de create por pessoa nao aceitam `OVERNIGHT`; o create por pessoa ignora o resultado do `safeParse`. Registrar no backlog se incomodar.
