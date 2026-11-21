# Business Rules — EventHub

## Escopo e unicidade

- Organization tem nome unico e agrega venues, owners, contratos e conteudo.
- Venue pertence a uma Organization e tem nome unico.
- User pode pertencer a varias organizations, sem duplicar o par user/organization.
- permissao de organization e unica por UserOrganization; permissao de venue e unica por UserOrganization/Venue.

## Proposal

- sempre pertence a um Venue;
- datas devem formar intervalo coerente e respeitar capacidade/preco do venue;
- pode ser criada e visualizada por fluxos publicos;
- no link publico, o cliente pode marcar ou desmarcar servicos; o obrigatorio para os convidados atuais permanece, e o total muda so pela soma desses servicos;
- servico por hora pede a quantidade de horas, no maximo a duracao do evento; acima disso a tela avisa na hora e a API nao grava; a quantidade fica na linha, e mudar o horario do evento no link nao a substitui;
- no painel, criar e editar orcamento perguntam a mesma quantidade e gravam essa linha; a duracao do evento nao substitui o que foi digitado;
- nao possui maquina de estados oficial: `approved`, `termsAccepted`, `paid`, `amountPaid` e `contact` formam estados implicitos;
- pessoas, pagamentos, documentos, datas, escala e historico pertencem ao seu contexto.

## Precificacao

- o modelo de preco do Venue define a base: por pessoa, por dia, por pessoa/dia, por pessoa/hora; `TIERED` existe no schema sem calculo;
- adicionais e descontos sazonais somam percentuais por intervalo de datas `dd/MM` ou dia da semana;
- metas aumentam o preco unitario em `increasePercent` quando a receita aprovada do mes cai na faixa da meta e o mes esta na lista;
- piso: vale o maior preco minimo por periodo que contem a data, senao o minimo padrao do Venue; abaixo do piso, o total vira piso + servicos e as horas extras zeram;
- hora extra no modelo por pessoa custa `base / 6` arredondado;
- servico fixo conta 1, por pessoa conta convidados, por hora conta horas escolhidas; servico com `rpaRequired` e obrigatorio a partir de `rpaMinPeople`;
- cortesia: no painel, quem ve ou edita orcamentos do Venue pode dar parte do servico de cortesia (horas, pessoas ou o fixo inteiro); a parte cortesia sai do valor da linha, aparece como "Cortesia" no detalhe e no link, e o cliente nao altera a cortesia pelo link;
- desconto: no painel, quem ve ou edita orcamentos do Venue pode dar um desconto de 0 a 100% (ate 2 casas) sobre o total estimado de um orcamento por pessoa; o orcamento grava a % e o valor; detalhe e link mostram subtotal, desconto e total; se o cliente alterar servicos, data, convidados ou horas pelo link, o desconto cai (recalcular sem mudar nada mantem); por dia, permuta e total manual nao tem desconto;
- permuta (`BARTER`) grava valores zerados;
- detalhe e onde roda: `topics/pricing-and-proposal-calculation.md`.

## Estado da Proposal

- Aberto/Fechado vem de `approved`; agendar DateEvent de evento, producao ou permuta aprova; apagar esse DateEvent desaprova;
- `paid` nao e gravado por nenhum fluxo hoje; o saldo real e `totalAmount - amountPaid`;
- o cliente so recalcula no link publico enquanto a proposta esta aberta, nao paga e de um dia so;
- categoria do evento e obrigatoria para tipo evento e alimenta relatorios.

## Links publicos

- o cliente acessa por links com o ID da proposta ou do Venue, sem login: orcamento, link do evento, convidados, colaboradores, programacao, indicacoes, regras e contrato PF/PJ;
- convidados ficam limitados ao numero de convidados da proposta; colaboradores nao;
- as paginas publicas usam a marca do espaco (cores, logo, fonte); detalhes em `topics/public-pages-and-branding.md`.

## Pagamentos e contratos

- Payment pertence a Proposal e Venue, com valor positivo;
- soma dos pagamentos e `amountPaid` devem ser coerentes e nao exceder o total aplicavel;
- Clause e reutilizavel e sua `position` determina ordem no contrato e PDF;
- Service tem nome unico dentro do Venue.

## Acesso

- interface aplica permissoes `VIEW_*`, `EDIT_*`, `SEND_*` e `CONFIRM_*` (catalogo em `topics/permissions-catalog.md`);
- regra desejada: somente usuario com acesso ao recurso altera dado restrito;
- estado atual nao garante essa regra em todas as rotas do backend; nao tratar comportamento inseguro como regra de produto.

## Fonte detalhada

`docs/referencias/REGRAS_DE_NEGOCIO.md` e `docs/referencias/AUTHORIZATION_MODEL.md`.
