# User Journeys — EventHub

## Captar e fechar um evento

1. cliente acessa formulario publico do venue;
2. informa dados, datas, convidados e tipo de evento;
3. sistema calcula e cria Proposal;
4. equipe revisa, contata e edita;
5. envia proposta/contrato e registra aceite/pagamentos;
6. opera documentos, pessoas, agenda e comunicacoes;
7. o cliente abre `/venue/:id/rules/view` e le as regras daquele espaco sem login.

## Administrar um venue

1. usuario entra e seleciona organization/venue permitido;
2. acompanha dashboard, propostas e calendario;
3. configura precos, inclusive piso padrao e piso por periodo, servicos, regras do espaco, caracteristicas, taxas, contatos, site, despesas e metas;
4. consulta relatorios e notificacoes.

## Integrar Google Calendar

1. usuario autorizado solicita conexao;
2. Google OAuth retorna ao backend;
3. tokens criptografados sao persistidos;
4. usuario escolhe calendario;
5. DateEvents criados, alterados ou removidos tentam sincronizar em uma via EventHub -> Google.

## Gerenciar acesso

Administrador vincula User a Organization e atribui permissoes de organization e venue. O frontend esconde/protege rotas; a garantia deve existir tambem no backend.
