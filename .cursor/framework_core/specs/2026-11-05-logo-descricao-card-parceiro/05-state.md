# State — Logo, descricao e card vertical do parceiro

## Snapshot

- status: codigo de `T-01` a `T-05` no working tree; schema no `main`
- ultima task concluida: migration `20261105180000_add_contact_logo_and_description` no `main`
- task em andamento: nenhuma
- proxima task exata: prova no browser de gravar logo e descricao
- prova mais recente: deploy request 42; `contact.logoUrl` varchar(191) NULL e `contact.description` varchar(400) NULL no `main`

## Delta da ultima task

- mudou: colunas aplicadas no `main` pelo deploy request 42 (`complete_pending_revert`)
- ficou pendente: gravar um parceiro com logo e descricao e ver o card publico
- lacunas de prova: submit real e pagina de indicacoes com logo ainda nao exercitados depois do schema

## Decisoes recentes

- descricao ate 400 caracteres; vazio vira `null`
- logo so por upload, WebP publico em `contact-logo/`, largura 512
- um componente para o preview e para as indicacoes
- o preview navega nas redes preenchidas, como o card publico; pedido em `task-requests/icones-clicaveis-preview-parceiro-request.md`
- auth das rotas de contato fica de fora

## Riscos ou bloqueios

- `POST /contact/create` e publico e vai aceitar arquivo em `T-02`
- a janela de revert do deploy request 42 ainda esta aberta; rollback e `DROP` das duas colunas

## Memoria promovida

- topics atualizados: nenhum
- project-decisions atualizados: nenhum
- ADRs criados ou alterados: nenhum

## Veredito

- veredito: schema no `main`; falta a prova de gravacao no browser
- bloqueantes: nenhum
- achados: a logo e asset publico; storage privado foi descartado
