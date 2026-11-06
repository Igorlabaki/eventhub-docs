# Frontend Application

## Mapa

- repo: `frontend`;
- React 18 + Vite 5 + TypeScript;
- 55 paginas, 31 services, 54 hooks, 27 stores e mais de 200 componentes;
- rotas centralizadas em `src/App.tsx`;
- HTTP em `src/lib/axios.ts` e `src/services/`;
- UI em `src/components/ui/` e componentes por dominio;
- estado em TanStack React Query e Zustand.

## Areas

- auth/profile;
- organization: venues, owners, contratos, website, settings e permissoes;
- venue: dashboard, eventos, propostas, agenda, despesas, metas, servicos, contatos, site e relatorios;
- proposal: detalhes, edicao, datas, historico, pagamento, contrato, documentos, escala, listas e envios;
- formularios publicos: proposta, parceiro, equipe e contratos.

## Cuidados

- `ProtectedRoute` nao substitui autorizacao no servidor;
- token/sessao em localStorage elevam impacto de XSS;
- refresh e rotas publicas divergem entre arquivos e backend;
- App e grande, sem lazy loading;
- nao duplicar store/hook/componente sem verificar o canonico;
- somente `lib/wall-clock-datetime.test.ts` foi mapeado como teste.

## Leitura minima

`project/frontend-map.md`, pagina/rota, componente de dominio, service, hook/store e tipos. Para API, ler router/Zod backend correspondente.
