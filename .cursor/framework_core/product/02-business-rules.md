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

## Pagamentos e contratos

- Payment pertence a Proposal e Venue, com valor positivo;
- soma dos pagamentos e `amountPaid` devem ser coerentes e nao exceder o total aplicavel;
- Clause e reutilizavel e sua `position` determina ordem no contrato e PDF;
- Service tem nome unico dentro do Venue.

## Acesso

- interface aplica permissoes `VIEW_*`, `EDIT_*` e `SEND_*`;
- regra desejada: somente usuario com acesso ao recurso altera dado restrito;
- estado atual nao garante essa regra em todas as rotas do backend; nao tratar comportamento inseguro como regra de produto.

## Fonte detalhada

`docs/referencias/REGRAS_DE_NEGOCIO.md` e `docs/referencias/AUTHORIZATION_MODEL.md`.
