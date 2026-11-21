# Spec — Cadastro das redes e consumo por venue_link

## Problema

A lista nova de redes nao mostrou o que a AR756 ja tinha nas colunas. Configuracoes mistura cadastro e visibilidade. O item Link tree da sidebar abre a pagina publica. Salvar o WhatsApp ou o video do tour nao cria link. Apresentacao, orcamento, rodape, e-mail, lista de espacos e o site da Guaeca ainda montam o clique pela coluna.

## Objetivos

- Cadastrar uma rede em Configuracoes cria o link. Na URL colada, o formulario pergunta se nasce visivel.
- A sidebar abre uma tela interna, no molde de Indicar parceiros, so com o que ja foi cadastrado. O clique liga ou esconde e salva.
- Salvar o numero cria o link de WhatsApp. Salvar o video cria o link do tour.
- O que ainda estiver nas quatro colunas volta como linha, sem inventar URL vazia.
- Quem mostra rede do espaco le `venue_link`.

## Fora de escopo

- Coluna nova, enum novo e apagar `url`, `instagramUrl`, `facebookUrl` ou `tiktokUrl`.
- Redesenho da aba Redes e dos cards da pagina publica.
- Redes de `Organization` e de `Contact`.
- Mudar Apresentacao, Fazer orcamento, Regras, E-mail, Google Maps e Site da organizacao.
- Reordenar na tela da sidebar.

## Cenarios

- O dono cadastra o Instagram em Configuracoes, responde que fica visivel, e o link entra na pagina publica.
- O dono abre Link tree na sidebar, clica o TikTok e ele passa a aparecer. Clica de novo e ele sai. Os dois cliques salvam sozinhos.
- O dono salva `+55 (11) 983953239` em Geral. A sidebar passa a listar WhatsApp, desligado. Ligado, o clique abre `wa.me` com esse numero.
- O dono salva o video em Apresentacao. A sidebar lista o tour, desligado. Ligado, o clique abre essa URL.
- A AR756 ainda tem site, Instagram, Facebook ou TikTok na coluna e nenhuma linha daquele tipo. A pagina publica mostra esse link sem ninguem colar de novo.

## Criterios de aceite

- R-01: Cadastrar uma URL colada cria uma linha `venue_link` daquele tipo e grava o visivel escolhido no formulario.
- R-02: O item Link tree da sidebar abre tela interna do painel e nao abre `/espaco/{nome}/links`.
- R-03: A tela interna lista so link ja cadastrado. O clique envia o visivel desejado e salva. O outro clique esconde.
- R-04: `/espaco/{nome}/links` sem login mostra so link cadastrado e visivel, com o card atual, sem cadastrar, arrastar nem remover.
- R-05: Salvar `whatsappNumber` nao vazio cria `WHATSAPP` desligado se a linha nao existe. Numero vazio remove a linha. O clique usa o numero atual em `wa.me`.
- R-06: Salvar `tourVideoUrl` nao vazio cria `TOUR_VIDEO` desligado se a linha nao existe. URL vazia remove a linha. O clique abre essa URL.
- R-07: Coluna nao vazia de site, Instagram, Facebook ou TikTok, sem linha daquele tipo, vira linha visivel com a URL reconhecida. Coluna vazia nao cria linha. Linha que ja existe nao e sobrescrita.
- R-08: Salvar links ou outro formulario do espaco nao grava vazio em `url`, `instagramUrl`, `facebookUrl` nem `tiktokUrl`.
- R-09: Apresentacao, orcamento, formulario, casca publica, rodape, e-mail, lista de espacos e o rodape da Guaeca usam o href de `venue_link`.
- R-10: Formularios de organizacao e de contato continuam iguais.
- R-11: Nao ha coluna nova nem valor novo no enum.
- R-12: Apresentacao, Fazer orcamento, Regras, E-mail, Google Maps e Site da organizacao conservam o comportamento atual.
- R-13: Continua um link por tipo no mesmo espaco.
- R-14: Quem ve Site abre a tela interna. So quem edita o site grava o clique.

## Requisitos implicitos

- O destino de WhatsApp e do tour nao e uma segunda URL guardada na linha. A linha marca que o link existe e se esta visivel.
- A ordem publica continua a `position` gravada no cadastro. A sidebar nao reordena.
- A rota publica de leitura continua na allowlist e nao devolve dono, contrato, pagamento nem dado interno.
- Nao surge permissao nova.

## Casos de erro e borda

- Coluna legada vazia ou URL que nao passa na checagem verde nao vira linha.
- Duas leituras ao mesmo tempo nao criam duas linhas do mesmo tipo.
- Repetir o mesmo visivel nao duplica linha nem alterna de novo.
- Espaco inexistente nao devolve link de outra casa.
- Casa sem link visivel abre a pagina publica sem lista.
- Trocar o numero ou o video nao muda o visivel da linha que ja existe.
- `MinimumPricesTab` e qualquer update que reenvie as quatro URLs nao apaga a coluna nem a linha.

## Impacto esperado

O dono cadastra em Configuracoes, escolhe o que aparece na sidebar e o visitante ve so isso. As URLs antigas que ainda estao nas colunas voltam. As colunas deixam de ser a fonte das telas.

## Areas impactadas

- `art56_server_v3`: links, update do espaco, pacotes de apresentacao, orcamento, hub e web
- `eventhub-vista-dashboard`: aba Redes, sidebar, pagina publica e leitores do espaco
- `guaeca-house-escapade`: rodape

## Restricoes e dependencias

- `venue_link` e o enum ja existem. A migration nao copiou as colunas.
- O banco de producao nao foi lido. So entra o que ainda estiver gravado.
- Escrita de DDL nao entra. A copia e feita pela aplicacao.
- Execucao multi-repo. As tasks ja separam backend, painel e site da Guaeca. O split por repo e opcional.

## Mapeamento requisito para task

| Requisito | Task | Prova |
|---|---|---|
| R-05, R-06, R-07, R-08, R-11, R-13 | T-01 | testes do use case de links e do update do espaco |
| R-09, R-10, R-12 | T-02 | pacote publico sem as quatro URLs como fonte do clique |
| R-01 | T-03 | formulario de cadastro grava o visivel escolhido |
| R-02, R-03, R-14 | T-04 | sidebar interna liga e esconde |
| R-09 | T-05 | telas e rodape da Guaeca usam o href da lista |
| R-04 | T-06 | pagina publica sem controles de dono |

## Base documental

- `task-requests/cadastro-redes-e-consumo-venue-link-request.md`
- `topics/public-pages-and-branding.md` (a pagina publica hoje ainda deixa o dono cadastrar, arrastar e remover)
- `project/agent-entrypoint.md#Leitura por frente`
- `project/active-libs.md#Leituras por frente`
- `framework-libs/patterns/rules/06_senior_engineering_concepts.md` (idempotencia e unique)
- `framework-libs/security/index.md#Revisar mudanca que toca superficie sensivel`
- `framework-libs/database/index.md` (sem schema novo; a leitura de migration nao se aplica)

## Operacao

- tipo: `spec`
- proxima task: `T-01`
- execucao recomendada: `normal`
- repo-local: `opcional` (`spec-repo-split-prompt.md` antes de executar em paralelo)
- review pre-implementacao: `nao` (decisoes fechadas no request; lacunas em `02-clarify.md` com premissa)
- proxima acao: `executar T-01`
- entrada publica recomendada: `fw:spec`
