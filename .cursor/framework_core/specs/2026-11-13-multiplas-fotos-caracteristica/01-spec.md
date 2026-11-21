# Spec — Ate tres fotos na caracteristica

## Problema

A caracteristica guarda uma foto em `VenueAmenity.imageUrl`. O formulario tem um campo de arquivo e o botao "Remover foto". As rotas de criar e editar recebem um arquivo. O modal publico do "?" mostra uma imagem. Quem cadastra "2 saloes cobertos" nao consegue mostrar os dois saloes.

## Objetivos

- gravar ate 3 fotos por caracteristica, todas opcionais, em ordem escolhida
- no criar e no editar, adicionar, remover e reordenar as fotos
- no modal publico, mostrar as fotos em grid na ordem salva
- manter a foto que cada caracteristica ja tem como a primeira

## Fora de escopo

- video, descricao, nome, posicao da caracteristica e permissoes
- legenda por foto e ampliar a foto ao clicar
- arrastar e soltar
- miniatura na tabela do painel
- apagar a coluna `venue_amenity.imageUrl` (fica para uma limpeza futura)
- galeria da casa e foto do servico

## User stories ou cenarios principais

- Quem edita o espaco abre Nova caracteristica, escolhe 3 fotos, troca a ordem com as setas e salva.
- Quem edita "2 saloes cobertos" ve a foto atual como primeira, adiciona mais duas, remove uma e move a nova para o comeco.
- Quem abre a proposta clica no "?" e ve as fotos em grid; as setas do modal continuam levando a proxima caracteristica.

## Criterios de aceite

- `R-01`: criar aceita de 0 a 3 fotos; a ordem gravada e a ordem dos arquivos enviados
- `R-02`: cada foto aceita `image/*` de ate 5 MB; o que fica gravado e a URL devolvida pelo upload, nunca uma URL do cliente
- `R-03`: mais de 3 fotos, no envio ou no resultado final da edicao, responde 400 com `{ title, message }` e a mensagem "A caracteristica aceita no maximo 3 fotos"; nada e gravado nem enviado ao storage
- `R-04`: editar com a lista `images` grava exatamente aquela lista, na ordem dela, misturando fotos ja salvas (`{ id }`) e arquivos novos (`{ newIndex }`)
- `R-05`: id de foto que nao e desta caracteristica, id repetido, `newIndex` fora dos arquivos, `newIndex` repetido ou arquivo enviado e nao referenciado responde 400; nada e gravado nem enviado ao storage
- `R-06`: editar sem `images` mantem as fotos como estao; enviar arquivo sem `images` responde 400
- `R-07`: foto que sai da lista na edicao, e todas as fotos ao excluir a caracteristica, sao removidas do storage depois que o banco grava
- `R-08`: se um upload falhar, nenhuma linha muda, nenhuma foto antiga sai do storage e as fotos novas ja enviadas nesse pedido sao removidas
- `R-09`: usuario sem `EDIT_VENUE_AMENITIES` naquele venue nao grava e nao envia arquivo ao storage
- `R-10`: a foto que existe hoje em `imageUrl` aparece como a primeira foto da caracteristica; caracteristica sem foto continua valida
- `R-11`: a apresentacao publica devolve `images: string[]` em ordem e `imageUrl` igual a primeira foto ou `null`; nao passa a devolver id de foto nem dado interno do venue
- `R-12`: no painel, criar e editar mostram as fotos em miniaturas com mover para a esquerda, mover para a direita e remover; o campo de arquivo aceita varios e some com 3 fotos; arquivos alem do limite sao descartados com aviso
- `R-13`: no modal publico, 1 foto ocupa a largura, 2 ficam lado a lado e 3 ficam uma em cima e duas embaixo; o "?" aparece com pelo menos uma foto; as setas, o teclado e o deslizar entre caracteristicas continuam funcionando

## Requisitos implicitos esperados

- auth, autorizacao ou ownership: rota autenticada; `VenueAmenityAuthorizer` amarra o venue da caracteristica antes de qualquer upload; a tela nao substitui a API
- erros e mensagens esperadas: 400 com `{ title, message }`, inclusive para erro do multer; nome duplicado segue 409; o painel mostra o toast que a secao ja usa
- observabilidade minima: sem metrica nova; prova por teste e erro HTTP
- concorrencia, idempotencia ou retry: duas edicoes ao mesmo tempo, vale a ultima; a copia da foto atual e idempotente
- rollout, fallback ou degradacao: tabela nova por deploy request; copia da foto atual com aprovacao nomeada; a API sai antes do front e a pagina publica antiga continua lendo `imageUrl`

## Casos de erro e borda obrigatorios

- caso: quarta foto no envio
  impacto: 400, nada gravado
  cobertura esperada: `T-01` (multer) e `T-02` (use case)
- caso: lista final da edicao com 4 itens (2 salvas e 2 novas, por exemplo)
  impacto: 400, nada gravado
  cobertura esperada: `T-02`
- caso: id de foto de outra caracteristica
  impacto: 400, nada gravado
  cobertura esperada: `T-02`
- caso: segunda foto nova falha no upload
  impacto: a primeira nova sai do storage; banco e fotos antigas intactos
  cobertura esperada: `T-02`
- caso: remover todas as fotos
  impacto: a caracteristica fica sem foto; o "?" depende de descricao ou video
  cobertura esperada: `T-02` e `T-05`
- caso: arquivo que nao e imagem ou passa de 5 MB
  impacto: 400 antes de qualquer upload
  cobertura esperada: `T-01` e `T-02`
- caso: escolher 4 arquivos com 1 foto ja na lista
  impacto: entram 2, aviso de limite
  cobertura esperada: `T-04`
- caso: grid com 1, 2 e 3 fotos no celular
  impacto: imagem sem distorcer
  cobertura esperada: `T-05`

## Impacto esperado

A caracteristica passa a ter uma lista de fotos. O contrato de criar e editar troca `file` e `removeImage` por `files` e `images`. A apresentacao publica ganha `images`. O formulario ganha a lista de miniaturas e o modal ganha o grid.

## Areas impactadas

- `backend`: schema, rotas de criar e editar, use cases de criar, editar, listar e excluir, apresentacao da proposta
- `frontend`: formulario da caracteristica, service, tipos, modal de detalhe e bloco "Conheça nosso espaço"

## Restricoes e cuidados

- migration so com DDL aditiva; a copia da foto atual e SQL de escrita e exige aprovacao nomeada (`project/planetscale.md#Permissoes do agente`)
- nunca `migrate dev` contra o PlanetScale
- nao adicionar dependencia de arrastar e soltar
- nao mudar o modal dos servicos
- nao ler nem versionar `.env`

## Dependencias

- spec `2026-11-05-foto-video-descricao-caracteristica`: backend commitado; frontend com a navegacao do modal ainda nao commitada (`02-clarify.md`)
- upload `uploadServiceImage` e `deleteServiceImage` via `amenityImageStorage`

## Mapeamento leve requisito -> task -> prova

- `R-01`, `R-02`, `R-03`, `R-07` (excluir), `R-09`, `R-10` (leitura) -> `T-01` -> unitario
- `R-03`, `R-04`, `R-05`, `R-06`, `R-07` (editar), `R-08`, `R-09` -> `T-02` -> unitario
- `R-11` -> `T-03` -> unitario
- `R-12` -> `T-04` -> unitario da funcao pura e browser
- `R-13` -> `T-05` -> unitario do modal e browser
- `R-10` (dado real) -> `T-06` -> leitura na `main`

## Perguntas em aberto

Nenhuma bloqueante. Premissas em `02-clarify.md`.

## Operacao

- tipo: `spec`
- proxima task: nenhuma
- execucao recomendada: `normal`
- repo-local: `ainda nao`
- review pre-implementacao: `pendente`
- proxima acao: `revisar entrega`
- entrada publica recomendada: `fw:review`
