# Clarify

## Perguntas criticas

- O tamanho do codigo fica o do exemplo `k7m2`?
- As paginas publicas irmas (`/links`, listas, contratos) tambem trocam `proposal` por `orcamento`?
- O painel `/proposal/:id` troca de palavra?
- A API `/proposal/...` troca de palavra?

## Respostas confirmadas

- Formato fechado no chat: nome da pessoa como rotulo, codigo como chave, homonimos com codigos diferentes, nome errado na URL ainda abre o codigo certo. Sufixo numerado foi recusado.
- Chat seguinte: a palavra `proposal` na URL vira `orcamento`.
- Chat seguinte: a palavra `venue` nessa URL vira `espaco`. O endereco fica `/espaco/AR756/orcamento/maria-silva-k7m2`.
- Chat seguinte, depois da review: todo link publico enviado ao cliente entra no mesmo padrao. Casa pelo nome em `/espaco/{nome}/apresentacao`, `/formulario`, `/regras`, `/parceiro` e `/colaborador`. Orcamento em `/espaco/{nome}/orcamento/{rotulo}-{codigo}` com `/evento`, `/convidados`, `/colaboradores`, `/programacao`, `/indicacoes` e `/contrato`.

## Requisitos implicitos confirmados

- O nome do espaco na URL e o `Venue.name` ja usado no formulario e na apresentacao.
- Link ja enviado com o id continua valendo.
- Cliente sem nome nao ganha um nome inventado.

## Premissas assumidas

- O exemplo `k7m2` mostra a forma, nao o tamanho. O codigo tem 8 caracteres do alfabeto sem `0`, `o`, `1`, `l` e `i`. Risco se estiver errado: 4 caracteres da para enumerar; 8 fica mais longo do que o exemplo.
- `/contrato` e um so caminho. Pessoa fisica ou juridica sai do tipo ja gravado, o mesmo que hoje escolhe `person-contract` ou `b2b-contract`. Risco se estiver errado: o cliente abre o formulario do outro tipo.
- Links velhos de `/venue/` e `/proposal/` continuam registrados. O que se copia e o endereco novo.
- O painel autenticado permanece em `/proposal/:id` e subcaminhos. Risco se estiver errado: o operador ainda ve a palavra `proposal` no painel.
- A API permanece em `/proposal/...`. O codigo viaja no parametro que hoje recebe o id. Risco se estiver errado: o cliente veria `proposal` so na aba de rede, nao no endereco.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Orcamento antigo sem codigo abre pelo id. A copia do link novo para esse orcamento espera o codigo preenchido; ate la a copia pode continuar no id.

## Itens bloqueantes

- Nenhum para escrever e revisar a spec. Aplicar a coluna na `main` continua fora desta spec e exige aprovacao nomeada.

## O que pode seguir mesmo com lacunas

- `T-01` e `T-02` podem ser executadas depois do review. A migration fica no repositorio, sem deploy request.
