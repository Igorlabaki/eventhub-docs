# Spec — Apresentacao publica do orcamento

## Problema

Quem abre `/proposal/:id/view` ve logo, data, convidados e a lista de valores. Fotos marcadas para o site, caracteristicas, descricao de venda e os servicos deste orcamento nao formam uma apresentacao. O espaco tambem nao escolhe as cores dessa pagina.

A pagina publica hoje busca o venue por `GET /venue/getById`, cujo retorno inclui dono, contrato e anexo. A lista de caracteristicas exige `VIEW_VENUE_AMENITIES` e nao pode ser chamada por esse link.

## Objetivos

Na pagina publica de um orcamento, a pessoa ve a casa e o que esta incluso antes do valor. Quem edita Configuracoes do espaco grava cor primaria, secundaria e cor do texto, e essa pagina usa essas cores.

## Fora de escopo

- regras do espaco
- textos com `area: "amenities"`
- rua, numero, CEP, proprietarios, e-mail do espaco e tabela de preco do cadastro
- repintar o painel ou o site da organizacao
- mudar o calculo do total
- enxugar o `GET /proposal/byId/:proposalId`, que ja devolve pagamento e lista de pessoas
- criar permissao nova ou corrigir a autorizacao de todo o `PUT /venue/update`

## User stories ou cenarios principais

- cliente abre o link do orcamento e ve a casa antes do total
- operador grava as tres cores em Configuracoes e as ve de novo na pagina publica
- casa sem foto, sem caracteristica, sem servico ou sem cor ainda mostra o valor

## Criterios de aceite

- `R-01`: com `logoUrl`, a capa usa o logo do espaco; sem logo, permanece o fallback EventHub que a pagina ja usa
- `R-02`: a capa usa a primeira imagem com `isShowOnOrganization`; a galeria usa as demais, por `position`; imagem desmarcada nao aparece
- `R-03`: as caracteristicas daquele espaco aparecem na ordem do cadastro; textos antigos de amenities nao aparecem
- `R-04`: a pagina mostra descricao, cidade, bairro e capacidade maxima; nao mostra rua, numero, CEP nem proprietario
- `R-05`: espaco com pernoite mostra check-in, check-out e minimo de noites; sem pernoite mostra abertura e fechamento
- `R-06`: os servicos ligados a este orcamento aparecem pelo nome antes do total; base, horas extras, preco de cada servico e total ficam no card final
- `R-07`: site, Instagram, Facebook e TikTok aparecem como icone so quando a URL existe; o WhatsApp continua no fim
- `R-08`: quem edita Configuracoes do espaco grava cor primaria, secundaria e cor do texto, e os tres valores continuam ao reabrir a tela
- `R-09`: a pagina publica aplica cada cor gravada; cor ausente mantem a cor atual da pagina; cor invalida nao e gravada
- `R-10`: as tres cores nao mudam o painel nem o site da organizacao
- `R-11`: o pacote publico deste orcamento devolve so o recorte de apresentacao da casa daquele orcamento, sem dono, contrato, pagamento, preco de tabela ou regra
- `R-12`: gravar cor sem autenticacao nao persiste; a tela de Configuracoes continua exigindo a permissao de edicao que ja tem
- `R-13`: secao sem dado some e o total continua; data e hora do evento permanecem em wall-clock
- `R-14`: orcamento inexistente nao devolve dado de casa

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a leitura da apresentacao e publica de proposito e amarrada ao id do orcamento; a gravacao das cores segue o `PUT /venue/update` ja autenticado; a tela nao substitui essa autenticacao
- erros e mensagens esperadas: cor invalida nao grava e a tela mostra o erro; orcamento inexistente responde nao encontrado
- observabilidade minima: falha da leitura publica nao registra o corpo da casa nem dado de cliente; sem dashboard novo
- concorrencia, idempotencia ou retry: duas gravacoes de cor seguem a ultima escrita, como o resto de Configuracoes; sem chave de idempotencia
- rollout, fallback ou degradacao: coluna nula e casa sem dado opcional degradam para a pagina atual; migration aditiva, sem backfill

## Casos de erro e borda obrigatorios

- caso: nenhuma foto marcada
  impacto: capa com logo e descricao, sem galeria
  cobertura esperada: `T-05`
- caso: casa sem logo
  impacto: fallback EventHub
  cobertura esperada: `T-05`
- caso: cor ausente ou invalida
  impacto: ausente usa a cor atual; invalida nao grava
  cobertura esperada: `T-02` e `T-05`
- caso: sem caracteristica ou sem servico
  impacto: a secao some; o total fica
  cobertura esperada: `T-05`
- caso: leitura publica sem token
  impacto: so o recorte de apresentacao; sem dono, contrato ou pagamento
  cobertura esperada: `T-03`
- caso: gravacao de cor sem token
  impacto: nao persiste
  cobertura esperada: `T-02`
- caso: id de orcamento de outra casa
  impacto: a pagina nao mistura foto ou caracteristica de outro venue
  cobertura esperada: `T-03`

## Impacto esperado

O link que o cliente ja recebe passa a vender a casa antes do valor. Configuracoes ganha tres cores. A pagina publica deixa de carregar o venue completo.

## Areas impactadas

- `backend`: schema do venue, update do venue, leitura publica por id de orcamento
- `frontend`: Configuracoes do espaco e `ProposalView`
- produto: jornada do cliente que recebe o orcamento

## Restricoes e cuidados

- D-01: backend e frontend sao repositorios distintos
- D-02: a leitura nova segue router, controller, use case e repository
- D-03: migration aditiva; nao assumir FK fisica
- D-05: a permissao da tela nao substitui a autenticacao da gravacao
- D-06: horario do evento permanece wall-clock
- nao ler nem versionar valores de `.env`

## Dependencias

- caracteristicas, fotos com `isShowOnOrganization`, logo, links e servicos da proposta ja existem
- as tres cores ainda nao existem
- a tela `/venue/:id/settings` ja existe

## Mapeamento leve requisito -> task -> prova

- `R-08`, `R-09`, `R-12` -> `T-01` -> integracao do schema
- `R-08`, `R-09`, `R-10`, `R-12` -> `T-02` -> integracao da gravacao
- `R-02`, `R-03`, `R-04`, `R-05`, `R-11`, `R-14` -> `T-03` -> integracao da leitura publica
- `R-08`, `R-09`, `R-10`, `R-12` -> `T-04` -> tela de Configuracoes
- `R-01` a `R-07`, `R-09`, `R-10`, `R-13` -> `T-05` -> pagina publica no browser

## Perguntas em aberto

As premissas que a execucao deve seguir estao em `02-clarify.md`. Nenhuma bloqueia `T-01`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `nao feita; o lote foi executado a pedido`
- proxima acao: `revisar spec`
- entrada publica recomendada: `fw:review`
