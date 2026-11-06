# Product Source and Sync

## Fonte canonica operacional

- codigo: `art56_server_v3/` e `eventhub-vista-dashboard/`;
- documentacao detalhada: `docs/`;
- slug: `eventhub`;
- owner de produto e owner tecnico: nao documentados, exigem confirmacao.

## Papel do snapshot

`product/` oferece contexto curto para tarefas e specs. Nao duplica contratos extensos, backlog historico nem analises de implementacao existentes em `docs/`.

## Triggers de sincronizacao

Atualizar este snapshot quando mudar regra de negocio, perfil/permissao, jornada, fluxo, design system, dominio, schema ou integracao. Atualizar tambem o doc detalhado citado pelo topic afetado.

## Ultima sincronizacao

- nome: bootstrap de projeto existente;
- data: 2026-11-02;
- origem: codigo, manifests, Prisma schema e `docs/`;
- arquivos: `product/`, `project/`, `topics/`, `flows/` e roadmap inicial.

## Pontos em aberto

Confirmar owners, fonte de produto fora do repositorio, prioridades atuais e quais itens do backlog legado ja foram resolvidos.
