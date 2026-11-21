# Preenchimento de endereco por CEP

## Problema

Quem cadastra o espaco ou os dados do contrato digita rua, bairro, cidade e UF a mao. A mesma cidade sai como "Sao Paulo", "São Paulo" ou "S.Paulo". O relatorio de origem agrupa cidade, estado e bairro da proposta pela grafia e deixa de fora a linha incompleta. Endereco errado do espaco ainda aparece na apresentacao e no contrato, mas a fonte desse relatorio e a proposta.

## Objetivos

Digitar um CEP de 8 digitos preenche logradouro, bairro, cidade e UF. Numero e complemento ficam para a pessoa. O valor salvo sai com UF de duas letras e CEP so com digitos. O mesmo bloco serve aos formularios que ja pedem endereco.

## Fora de escopo

- limpar ou reescrever enderecos ja gravados
- mudar `eventOriginRows` ou `buildEventOrigin`
- coluna nova, codigo IBGE gravado, endpoint nosso de CEP
- catalogo de ruas
- select de todas as cidades como caminho principal
- trocar o padrao "Sao Paulo" / "SP" de contrato novo que ainda nao passou por uma busca

## User stories ou cenarios principais

- No contrato, a pessoa digita `01001-000`. Logradouro, bairro, cidade e UF preenchem. Ela informa numero e complemento e salva.
- No cadastro do espaco e em Configuracoes, aba Endereco, o mesmo gesto.
- CEP de cidade, sem rua nem bairro na base, deixa rua e bairro vazios para digitar e oferece a cidade na lista do IBGE daquela UF.
- CEP invalido ou servico fora do ar mostra o erro no campo e mantem o que ja estava digitado. UF vira a lista das 27 siglas e a cidade, a lista do IBGE da UF escolhida.
- O proprietario usa o mesmo bloco. No site da organizacao, o CEP so preenche cidade e UF; o CEP do espaco continua sendo gravado em Configuracoes.

## Criterios de aceite

- `R-01`: com 8 digitos, a busca preenche logradouro, bairro, cidade e UF quando a base devolver esses campos
- `R-02`: numero e complemento nao sao preenchidos pela busca; o `complemento` da ViaCEP nao entra no campo complemento
- `R-03`: logradouro, bairro, cidade e UF preenchidos continuam editaveis
- `R-04`: CEP invalido ou as duas buscas falhando mostra erro no campo do CEP e nao apaga o que ja estava digitado
- `R-05`: CEP que devolve cidade e UF sem rua e sem bairro deixa rua e bairro vazios e troca a cidade pelo select do IBGE daquela UF
- `R-06`: quando a busca falha, a UF vira select das 27 siglas e a cidade vira select do IBGE filtrado pela UF escolhida
- `R-07`: o valor enviado no salvamento ja existente tem UF em duas letras maiusculas, quando o valor for uma sigla, e CEP so com digitos
- `R-08`: o bloco esta em criar espaco, Configuracoes aba Endereco, contrato PF/PJ do painel e contrato publico PF/PJ
- `R-09`: o formulario do proprietario usa o mesmo bloco
- `R-10`: no `EditVenueForm`, o CEP preenche cidade e UF e nao e enviado no salvamento dessa tela
- `R-11`: para fora do navegador segue so o CEP com 8 digitos, para ViaCEP ou BrasilAPI, e a sigla da UF, para a lista de municipios do IBGE
- `R-12`: nao ha migration nem mudanca na query do relatorio de origem
- `R-13`: cidade "Sao Paulo" e estado "SP" iniciais do contrato nao contam como resultado de busca
- `R-14`: uma resposta antiga de CEP nao sobrescreve o CEP que a pessoa digitou depois

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: os formularios continuam nas rotas que ja tem; a busca nao passa pela API do EventHub
- erros e mensagens esperadas: erro ao lado do CEP, em portugues, dizendo para conferir o numero ou preencher cidade e estado
- observabilidade minima: o erro fica no campo; o CEP nao vai para log, toast nem console
- concorrencia, idempotencia ou retry: a busca e GET; repetir o mesmo CEP reescreve os mesmos campos; timeout de 4s; uma reserva (BrasilAPI) no lugar de varias tentativas
- rollout, fallback ou degradacao: com os servicos fora, a pessoa ainda digita o endereco; a lista do IBGE, se falhar, volta a ser campo de texto

## Casos de erro e borda obrigatorios

- caso: ViaCEP responde `erro: true` ou estoura o tempo
  impacto: tenta a BrasilAPI uma vez; se essa tambem falhar, vale `R-04` e `R-06`
  cobertura esperada: unitario
- caso: CEP generico, rua e bairro vazios
  impacto: rua e bairro do formulario ficam vazios, mesmo que houvesse texto antes; cidade e UF vem da base
  cobertura esperada: unitario
- caso: a pessoa troca o CEP enquanto a primeira busca ainda responde
  impacto: so a resposta do CEP atual altera o formulario
  cobertura esperada: unitario
- caso: estado ja gravado por extenso, como "Sao Paulo"
  impacto: nao e cortado para duas letras; a sigla entra quando a busca ou o select grava
  cobertura esperada: unitario
- caso: nome de cidade da base nao esta na lista do IBGE
  impacto: a cidade permanece texto com o nome devolvido pela base
  cobertura esperada: unitario

## Impacto esperado

Enderecos novos e os que forem salvos de novo tendem a repetir a grafia da base postal. O relatorio de origem so muda nesses registros. Apresentacao e tokens `venue.cep`, `owner.cep` e `client.cep` seguem lendo os campos que ja existem.

## Areas impactadas

- frontend: formularios de espaco, contrato, proprietario e site da organizacao
- integracao de leitura: ViaCEP, BrasilAPI e API de localidades do IBGE, chamadas pelo navegador

## Restricoes e cuidados

- endereco de cliente e de proprietario e dado pessoal; o corpo dos outros campos nao sai na busca
- nao criar store nova; o valor fica no react-hook-form e o estado da busca fica no bloco
- nao aplicar mascara de novo na hora de salvar por cima do valor ja normalizado

## Dependencias

- os formularios ja salvam `street`, `streetNumber`, `neighborhood`, `city`, `state` e `cep`
- proposta usa `adressComplement`; espaco e proprietario usam `complement`
- criar espaco aninha os campos em `data.`

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-02`, `R-11`, `R-14` -> `T-01` -> unitario
- `R-03`, `R-04`, `R-05`, `R-06`, `R-07`, `R-13` -> `T-02` -> unitario
- `R-08`, `R-12` -> `T-03` e `T-04` -> unitario
- `R-09`, `R-10`, `R-12` -> `T-05` -> unitario

## Perguntas em aberto

Nenhuma bloqueante. As premissas do request estao em `02-clarify.md` e a execucao segue por elas.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `smart`
- repo-local: `nao se aplica`
- review pre-implementacao: `pendente`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
