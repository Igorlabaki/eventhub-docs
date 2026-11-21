# State

## Snapshot

- status: `T-01`, `T-02` e `T-03` no codigo; coluna ainda fora da `main`
- ultima task concluida: `T-03`
- task em andamento: nenhuma
- proxima task exata: revisar entrega (`fw:review`)
- prova mais recente: vitest back 8 (`proposal-public-key.spec.ts`); vitest front 39 nos arquivos de URL; `prisma validate` ok; browser sem API

## Delta da ultima task

- mudou: casa em `/espaco/{nome}/apresentacao|formulario|regras|parceiro|colaborador`; copias de regras, parceiro e colaborador usam o nome
- ficou pendente: deploy da coluna na `main`, com aprovacao nomeada
- lacunas de prova: API local estava parada; as paginas novas nao redirecionam ao login, mas o conteudo da casa nao carregou

## Decisoes recentes

- casa: `/espaco/{nome}/apresentacao`, `/formulario`, `/regras`, `/parceiro`, `/colaborador`
- orcamento: `/espaco/{casa}/orcamento/{rotulo}-{codigo}` mais `/evento`, `/convidados`, `/colaboradores`, `/programacao`, `/indicacoes`, `/contrato`
- codigo de 8 caracteres, aleatorio, nao sequencial
- `/contrato` escolhe PF ou PJ pelo CNPJ gravado
- painel e API ficam em `proposal`; links velhos continuam
- id antigo continua abrindo; sem redirect
- sem `publicCode`, a copia cai no endereco antigo

## Riscos ou bloqueios

- coluna nova nao entra na `main` sem aprovacao nomeada

## Memoria promovida

- topics atualizados: `topics/public-pages-and-branding.md`
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: pronto para review de entrega
- bloqueantes: 0
- achados: nenhum aberto nesta execucao
