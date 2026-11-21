# Spec

## Problema

A aba Redes, em Configuracoes do espaco, mostra cada rede num cartao com Subir, Descer, Remover e o texto "No link tree". A pagina publica `/espaco/:id/links` mostra pilulas com icone e texto centralizados juntos, entao cada titulo comeca num ponto diferente.

## Objetivos

- A aba Redes fica com faixa, KPIs, contador e tabela no desenho de Contatos. Escolher uma rede continua adicionando a linha. A unica acao a mais e o icone de arrastar.
- A pagina publica usa o card de "Gerencie seu evento": icone no canto superior esquerdo, seta no canto superior direito, titulo embaixo, todos no mesmo alinhamento.

## Fora de escopo

- schema, endpoint, campo ou payload novo
- botao de copiar link na faixa
- linha de descricao no card publico
- grid de duas colunas na pagina publica
- recolocar Subir e Descer
- reabrir o request da pilula clara (`visual-pagina-links-espaco-request.md`)
- mudar logo, slogan, titulo da aba ou a marca EventHub sem logo

## User stories ou cenarios principais

- O dono abre Redes, escolhe Instagram e a linha entra na tabela. Arrasta essa linha para cima de WhatsApp. A ordem gravada muda.
- O dono busca "insta" e ve so Instagram. Os KPIs continuam contando todas as redes.
- O visitante abre `/espaco/AR756/links` e ve cards no estilo do evento, com Apresentacao, Fazer orcamento e Regras comecando no mesmo ponto.

## Criterios de aceite

- `R-01`: a faixa da aba Redes tem busca por nome, o select Escolher rede e o filtro Todas / No link tree / Ocultas
- `R-02`: escolher uma rede no select acrescenta a linha na hora, no fim, sem duplicar um `kind` que ja esta na lista
- `R-03`: os KPIs Total, No link tree e Com link contam a lista inteira, nao o recorte da busca ou do filtro
- `R-04`: o contador mostra quantas redes a tabela esta exibindo
- `R-05`: a tabela tem alca de arrastar, nome, link e acoes so com icone; nao ha Subir nem Descer
- `R-06`: arrastar uma linha, com busca vazia e filtro Todas, troca a ordem e regrava `position` em todas as linhas
- `R-07`: o olho alterna `visible`; a lixeira so aparece em rede colada (`isPastedVenueLink`); rede fixa nao some
- `R-08`: rede colada mostra o campo de URL e o aviso de `checkVenueLinkUrl`; rede sem URL mostra um traco
- `R-09`: busca e filtro so escondem linhas; nao apagam rede nem mudam `position`
- `R-10`: com busca ou filtro diferente de Todas, a alca nao reordena
- `R-11`: `/espaco/:id/links` e `/venue/:id/links` mostram um card por link visivel, numa coluna, embaixo da logo e do slogan, na largura `max-w-md`
- `R-12`: cada card tem icone no canto superior esquerdo, seta no canto superior direito e titulo embaixo, sem linha de descricao; os titulos comecam no mesmo ponto
- `R-13`: o card usa fundo `proposalSecondaryColor` e texto `proposalTextColor`; a pagina continua com fundo `proposalPrimaryColor`; link `mailto` nao abre em aba nova; os demais abrem

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: a aba Redes segue o acesso que Configuracoes ja tem; a pagina publica continua sem token em `GET /venue/links/:venueId`
- erros e mensagens esperadas: URL invalida continua com a mensagem ja devolvida por `checkVenueLinkUrl`; filtro sem resultado mostra a tabela vazia
- observabilidade minima: nenhuma; a prova e o teste de UI e o build do front
- concorrencia, idempotencia ou retry: nao ha gravacao nova; a ordem segue no estado que o formulario de Configuracoes ja salva
- rollout, fallback ou degradacao: sem flag; o visual novo substitui o atual no mesmo deploy do front

## Casos de erro e borda obrigatorios

- caso: filtro ou busca sem linha
  impacto: a tabela nao pode parecer quebrada nem zerar os KPIs
  cobertura esperada: `T-01`
- caso: arraste com a lista filtrada
  impacto: a ordem gravada nao pode mudar
  cobertura esperada: `T-01`
- caso: rede fixa (Apresentacao, orcamento, regras)
  impacto: nao ganha lixeira
  cobertura esperada: `T-01`
- caso: lista publica vazia, sem logo ou slogan so com espaco
  impacto: continua sem lista, com a marca EventHub e sem o slogan vazio
  cobertura esperada: `T-02`
- caso: cores da casa ausentes
  impacto: card cai no fallback branco `#ffffff` e texto `#181818`; a pagina cai no fundo `#111315` e texto `#f7f7f5` que `VenueLinks` ja usa
  cobertura esperada: `T-02`

## Impacto esperado

So o dashboard. Quem configura as redes ve a lista de Contatos. Quem abre o link publico ve o card do evento. O contrato do `GET` nao muda.

## Areas impactadas

- `eventhub-vista-dashboard`: `VenueLinkEditor`, aba `redes` de `VenueSettings`, `VenueLinksView`
- `topics/public-pages-and-branding.md`: a frase que ainda descreve a pilula, atualizada em `T-02`

## Restricoes e cuidados

- preservar `addKind`, `moveVenueLink`, `onDrop`, `isPastedVenueLink`, `canShowVenueLink` e `checkVenueLinkUrl`
- nao copiar o dominio de contato para dentro do editor
- o teste atual de `VenueLinks.test.tsx` exige a cor invertida da pilula; `T-02` troca essa expectativa

## Dependencias

- nenhuma spec aberta
- o request da pilula clara segue a revisao dele e nao bloqueia esta spec

## Mapeamento leve requisito -> task -> prova

- `R-01` a `R-10` -> `T-01` -> unitario
- `R-11` a `R-13` -> `T-02` -> unitario

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `nao se aplica`
- review pre-implementacao: `pendente`
- proxima acao: `executar task`
- entrada publica recomendada: `fw:run`
