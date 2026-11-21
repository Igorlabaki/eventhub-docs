# Public Pages and Branding — EventHub

Paginas que o cliente final abre sem login e como a marca do espaco e aplicada, observado em 2026-11-10. Lista de rotas em `project/frontend-map.md`; endpoints em `project/api-endpoints.md`.

## Marca do espaco

Configurada em `VenueSettings` (bloco Cores da proposta) e gravada no Venue:

| Campo | Papel | Padrao |
|---|---|---|
| `proposalPrimaryColor` | fundo da pagina, fundo dos botoes e dos campos | `#111315` |
| `proposalSecondaryColor` | fundo dos cards e do rodape | cards `#ffffff`, rodape `#4f46e5` |
| `proposalTextColor` | texto da pagina, dos cards, dos botoes e do rodape | `#f7f7f5` / `#181818` |
| `logoUrl` | topo (`animate-logo-in`) e rodape; sem logo entra a marca EventHub | — |
| `faviconUrl` | icone da aba em `ProposalView`, `VenuePresentation`, `PublicVenueListShell`, `VenueDashboard` e `ProposalForm`; sem arquivo fica `/favicon.ico` | — |
| `tourVideoUrl` | destaque da proposta (YouTube ou mp4/webm/ogg/mov) | — |
| `slogan` | abaixo do logo e no titulo da aba das paginas publicas e do painel do espaco | — |
| `description` | card A casa da apresentacao; fora do topo do orcamento, do formulario e das cascas | — |

- botao "Usar cores padrao" limpa as tres cores;
- fonte Manrope nas paginas publicas (carregada antes de exibir); painel usa Inter;
- skeletons usam as cores da casa assim que o venue chega; cinza ajustado pela luminancia (`surfaceIsDark`);
- a pagina espera ate 8 s por fonte, logo, fotos e video antes de animar;
- titulo da aba: `venueTabTitle(nome, slogan)`; slogan vazio ou so com espaco some o paragrafo e a aba fica so com o nome;
- classes compartilhadas em `components/proposal/public-list-pattern.ts`; moldura em `PublicVenueListShell`;
- `.scrollbar-house` usa `--house-scroll` no modal de detalhe do servico.

Aplicam a marca: `/espaco/{casa}/orcamento/{rotulo}-{codigo}` e os sufixos `evento`, `convidados`, `colaboradores`, `programacao`, `indicacoes` e `contrato`; os caminhos antigos `/proposal/:id/view`, listas, `/links`, `/indications` e contratos PF/PJ continuam abrindo. Casa: `/venue/:id/form`, `/venue/:id/apresentacao`, `/venue/:id/rules/view`. Nao aplicam: `/venue/:id/partner-form` e `/crew-form` (fundo EventHub e `ProposalFooter` roxo fixo).

## Orcamento publico (`/espaco/{casa}/orcamento/{rotulo}-{codigo}`)

O link copiado para o cliente usa o nome da casa, o rotulo do cliente e um codigo de 8 caracteres. Sem nome, o rotulo sai. `/contrato` escolhe pessoa fisica ou juridica pelo CNPJ ja gravado. O id antigo em `/proposal/:id/view` continua abrindo. O painel segue `/proposal/:id`. Quem ja pode abrir o painel daquele espaco ve Gerir orcamento no canto superior direito da capa e das listas; o clique abre `/proposal/{id}`. Sem essa permissao, o botao nao aparece.

Ordem: logo e slogan; video do tour ou foto de capa; card Proposta personalizada (data, horario/duracao ou check-in/out, convidados, capacidade, minimo de noites ou funcionamento); galeria; Conheca nosso espaco (caracteristicas, `?` quando ha descricao, foto ou video do YouTube, + WhatsApp Agendar uma visita); Sua experiencia inclui (servicos, `?` de detalhe, obrigatorio a partir de N pessoas); Seu investimento (locacao, horas extras, servicos, total, por convidado, hora adicional); mapa (link + iframe); rodape com redes.

- video: autoplay mudo em loop com botao de som;
- fotos: carrossel em tela cheia (embla); quem tem `EDIT_VENUE_SITE` nesse espaco reordena e troca a foto pelo catalogo, na URL antiga e na nova; visitante e quem nao tem Site nao ve alca, nao ve Trocar foto e nao recebe o catalogo; so imagens com `isShowOnProposal`;
- modal Alterar orcamento: dia, convidados (ate `maxGuest`) e horas (1 a 24); bloqueado se aprovado, pago ou mais de um dia;
- modal Alterar servicos: obrigatorios pre-marcados, horas para servico por hora;
- revelacao por `IntersectionObserver` respeitando `prefers-reduced-motion`.

## Pedido de orcamento (`/espaco/{casa}/formulario`)

O link copiado usa o nome do espaco. Apresentacao, regras, parceiro e colaborador seguem `/espaco/{casa}/apresentacao`, `/regras`, `/parceiro` e `/colaborador`. Um link antigo `/venue/AR756/form`, `/venue/AR756/apresentacao`, `/venue/{id}/rules/view`, `partner-form` e `crew-form` continua abrindo. Servicos e a criacao da proposta usam o id real da casa.

Tres passos deslizantes (`PublicBudgetFormSteps`, `ResizeObserver`, passos fora de vista `inert`):

1. pessoais: nome, empresa (por pessoa), e-mail, WhatsApp;
2. evento: por pessoa (data, inicio/fim em passos de 30 min dentro do funcionamento, fim sugerido por `standardEventDuration`, convidados ate `maxGuest`, categoria, descricao) ou por dia (entrada/saida com check-in/out fixos);
3. origem: ja conhece o espaco, servicos (obrigatorios travados, horas para servico por hora, `?` de detalhe sem preco), onde nos achou.

Envio volta ao passo com erro; sucesso abre `/espaco/{casa}/orcamento/{rotulo}-{codigo}`. Formulario por dia quando `hasOvernightStay`.

## Demais paginas publicas

- `/espaco/{casa}/orcamento/{ref}/evento` (antigo `/proposal/:id/links`): resumo do evento, contagem regressiva ao vivo e atalhos para orcamento, parceiros, convidados, colaboradores, programacao e regras;
- `guest-list`: nome e e-mail opcional, planilha csv/xls/xlsx (1 MB, 1000 nomes), limite pelo numero de convidados, envia so os novos;
- `staff-list`: igual, sem limite de convidados;
- `schedule-list`: titulo, colaboradores, inicio/fim dentro do horario do evento, descricao;
- `indications`: parceiros indicados agrupados por categoria (`PartnerPublicCard`);
- `/espaco/{casa}/links` (o alias `/venue/:id/links` continua abrindo): lista vertical com logo e slogan, sem o nome no topo; cada link visivel e um card (`rounded-xl`) com icone no canto superior esquerdo, seta no canto superior direito, titulo e subtitulo fixo do tipo embaixo, fundo `proposalSecondaryColor` e texto `proposalTextColor`. A pagina e so de leitura: visitante e dono veem a mesma lista, sem Cadastrar, sem alca e sem Remover. Lista vazia nao abre a lista nem chama para cadastrar. O cadastro fica na aba Redes. O visivel e a ordem ficam na tela interna `/venue/:id/link-tree`; a aba Redes nao arrasta. Apresentacao e Regras aparecem sempre nessa tela interna, para marcar ou desmarcar, sem URL. A leitura publica e `GET /venue/links/:venueId`;
- `/espaco/{casa}/apresentacao` (o link antigo `/venue/:id/apresentacao` continua abrindo). Casa sem evento. Ordem: logo e slogan, video ou capa, card da casa (descricao, horario, capacidade, noites minimas com pernoite, bairro e cidade), uma foto, Conheça nosso espaço, Serviços disponíveis sem preco, grid, Seu investimento sem total e com Fazer orçamento acima do WhatsApp, mapa com bairro e cidade; a aba usa o slogan. Quem tem `EDIT_VENUE_SITE` reordena e troca as fotos que a pagina ja mostra; os demais so assistem;
- regras: `/espaco/{casa}/regras` e o alias `/venue/:id/rules/view` abrem a mesma pagina em accordion; `GET /venue-rule/public/:venueId` aceita o nome unico ou o id e devolve so id, titulo, texto e posicao;
- `partner-form`: categoria, funcao, contatos, redes, descricao ate 400, logo com preview do card;
- `crew-form`: nome, funcao, WhatsApp, e-mail;
- contratos PF/PJ: CPF/CNPJ, RG, CEP com mascara, endereco, e-mail obrigatorio; mostra obrigado ao salvar.

## Riscos

- endpoints usados por estas paginas sao publicos e baseados em ID (ver `project/api-endpoints.md`);
- `PUBLIC_ROUTES` do Axios nao cobre `links`, `indications`, `partner-form`, `crew-form` e usa `worker-list` em vez de `staff-list`;
- links copiados usam o dominio fixo `event-hub-dashboard.vercel.app`.
