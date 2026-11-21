# State — Proprietario pessoa fisica ou juridica

## Snapshot

- status: `T-01` a `T-07` implementadas em 2026-11-11/12; colunas na `main` (deploy request `#47` aplicado em 2026-11-12 12:56, `complete_pending_revert`; `SHOW COLUMNS` confere; 3 proprietarios, todos `PF`)
- ultima task concluida: `T-07`
- task em andamento: nenhuma
- proxima task exata: browser do painel e PDF; depois `fw:review`; publicar API e depois o painel
- prova mais recente: vitest back 60 arquivos / 517 testes, front 48 / 288; `prisma validate` ok; build do painel ok; lint limpo nos arquivos tocados; `GET /venue/getById` sem token no localhost (dados reais) devolve `ownerVenue` so com `ownerId` e `venueId`

## Delta da ultima task

- mudou:
  - banco: enums e quatro colunas em `Owner`, migration `20261111190000_add_owner_person_type`, branch `add-owner-person-type`, deploy request `#47` (`ready`, diff so com as quatro colunas);
  - API: `getSelectedVenue` sem o objeto `owner`; `OwnerAuthorizer` nas seis rotas de `/owner`; `functions/owner-document.ts` (`resolveOwnerData`); schemas Zod com PF/PJ e sem `organizationId` na edicao; `findDuplicate` no lugar de `vefiryIfOwnerExists`; `update` so mexe em vinculos com `venueIds`;
  - painel: `lib/owner-document.ts`, `OwnerForm` com PF/PJ, CNPJ alfanumerico (`formatChars`), porte e rotulos Representante/Titular; edicao nao envia mais `venueIds`; lista, busca e quatro seletores com o nome exibido;
  - PDF: `lib/owner-template-values.ts`; `RAZAO_SOCIAL_PROPRIETARIO`, `CNPJ_PROPRIETARIO` e `PORTE_PROPRIETARIO`; campo `owner.*` vazio sai em branco.
- testes novos: `use-case-get-by-id-venue.spec.ts` (2), `owner-document.spec.ts` (13), `owner.spec.ts` (19), `owner-document.test.ts` (8), `owner-template-values.test.ts` (7)
- ficou pendente: browser do painel (PJ MEI, troca para PF, porte limpo, seletores) e PDF de PF legado e PJ
- lacunas de prova: browser e PDF ainda nao exercitados; formulario publico nao aberto no browser (so a chamada HTTP)

## Decisoes recentes

- duplicidade de PF compara so com proprietarios PF da organizacao (nome de representante de PJ nao bloqueia PF)
- `companySize`, `companyName` e `cnpj` aceitam `null` tambem na criacao; `resolveOwnerData` decide
- listar sem ser membro responde 403 mesmo se a organizacao nao existe (antes 404 "Organizacao")
- `T-03` sem consulta na `main`: `UserVenuePermission` exige `userOrganizationId` (FK), entao quem tem permissao de espaco ja e membro
- rotulos de `NOME_PROPRIETARIO`, `CPF_PROPRIETARIO` e `RG_PROPRIETARIO` no editor indicam "representante, se PJ"; o `display` nao mudou

## Riscos ou bloqueios

- rollback das colunas: revert do `#47` so na janela e so depois de reverter a API
- `T-02` muda rota publica (owner ciente antes do deploy da API)
- typecheck do backend tem erros antigos fora do escopo (in-memory repos, spec de proposta); nenhum nos arquivos desta spec

## Memoria promovida

- topics atualizados: `auth-and-security.md` (isolamento de `/owner`, fim do vazamento em `/venue/getById`, lacunas de `/organization/*` e `/venue/update`)
- project atualizados: `api-endpoints.md` (auth e corpo de `/owner`, formato de `ownerVenue`), `planetscale.md` (`#47`), `product/08-data-model.md`
- project-decisions e ADRs: nenhum
