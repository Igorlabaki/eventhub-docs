# Clarify

## Perguntas criticas

- O proprietario entra na mesma entrega?
- O `EditVenueForm`, que so pede cidade e estado, entra?
- Os campos preenchidos ficam editaveis?
- Quando a busca falha, UF e cidade viram select?
- Os formularios usam um unico bloco?
- UF e CEP sao normalizados ao salvar?

## Respostas confirmadas

- CEP e o primeiro passo e, com 8 digitos, preenche logradouro, bairro, cidade e UF.
- Numero e complemento continuam manuais.
- O bloco vale em criar espaco, Configuracoes aba Endereco, contrato PF/PJ do painel e contrato publico PF/PJ.
- Select de todas as cidades nao substitui o CEP. Catalogo de ruas fica de fora.
- Endereco ja gravado permanece. Sem endpoint novo e sem coluna nova.
- CEP invalido mostra o erro no campo e mantem o digitado.
- CEP que so devolve cidade e UF deixa rua e bairro para digitar.

## Requisitos implicitos confirmados

- A busca roda no navegador: ViaCEP e, em seguida, BrasilAPI.
- O relatorio de origem le `Proposal.city`, `Proposal.state` e `Proposal.neighborhood`. Esta feature nao muda essa leitura.
- Criar espaco ja grava o CEP so com digitos. Os outros formularios ainda podem gravar a mascara.

## Premissas assumidas

- Proprietario entra. Risco se estiver errado: o endereco do proprietario no contrato continua manual.
- `EditVenueForm` entra so para cidade e UF. O CEP digitado ali nao e gravado; o CEP do espaco segue em Configuracoes. Risco se estiver errado: a tela do site da organizacao passa a ter um campo a mais, que nao salva.
- Campos preenchidos ficam editaveis. Risco se estiver errado: a pessoa nao corrige um logradouro abreviado da base.
- Busca falha: UF vira select das 27 siglas e cidade vira select do IBGE da UF. Cidade em select tambem quando o CEP nao trouxer rua nem bairro. Risco se estiver errado: a pessoa esperava select sempre, ou nunca.
- Um unico bloco. Risco se estiver errado: o visual publico e o do painel precisariam de dois componentes.
- Ao salvar, sigla em maiusculas e CEP so com digitos. Estado por extenso ja gravado nao e cortado. Risco se estiver errado: um registro antigo com "Sao Paulo" no estado continua assim ate uma busca ou um select.

## Perguntas de erro e borda ainda abertas

- Nenhuma. Timeout, reserva unica, CEP generico, corrida entre respostas e lista do IBGE indisponivel estao decididos em `03-design.md`.

## Itens bloqueantes

- Nenhum para revisar e executar. Nao ha migration.

## O que pode seguir mesmo com lacunas

- `T-01` pode comecar depois do review. `T-03`, `T-04` e `T-05` esperam o bloco de `T-02` e podem correr juntas.
