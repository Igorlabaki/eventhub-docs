# Design System Direction — EventHub

## Base atual

- React 18, Tailwind 3, shadcn/Radix (estilo `default`, base `slate`, CSS variables), lucide-react no painel e react-icons nas redes/listas publicas;
- tokens em `eventhub-vista-dashboard/src/index.css` (HSL shadcn) e `tailwind.config.ts`;
- primaria indigo (`244 75% 67%`, ~`#6366f1`), secundaria lavanda, destrutiva vermelha, `--radius 0.5rem`;
- paleta `eventhub.*`: primary `#6366f1`, secondary `#818cf8`, tertiary `#c7d2fe`, background `#f5f7ff`, text `#111827`;
- classes `.eventhub-card`, `.eventhub-heading`, `.eventhub-subheading`, `.eventhub-btn-primary|secondary`, `.eventhub-stat`, `.scrollbar-eventhub`, `.scrollbar-house`, `.proposal-photo-zoom`;
- animacoes `fade-in`, `slide-in(-right/out)`, `slow-pulse`, `accordion-*` e as publicas `logo-in`, `cover-in`, `rise-in`;
- tipografia: Inter no painel, Manrope nas paginas publicas;
- componentes base em `src/components/ui/` (49 shadcn + 16 proprios) e de dominio em `src/components/<dominio>/`.

## Duas linguagens visuais

- painel: shell `DashboardLayout` (sidebar por secoes + header), fundo `#f5f7ff`, cards brancos, KPIs com `YearlyChange` e sparkline, graficos recharts, skeletons por area;
- paginas publicas: marca do espaco (cores primaria/secundaria/texto, logo, video), Manrope, animacoes de entrada, skeleton com as cores da casa; regras em `topics/public-pages-and-branding.md`.

## Direcao operacional

- reutilizar componente de `ui/` ou do dominio antes de criar outro; `form-layout` para formularios, `data-table` para tabelas, `confirm-delete-dialog` para exclusao;
- manter acessibilidade dos primitives Radix e respeitar `prefers-reduced-motion` nas animacoes;
- feedback por toast (`showSuccessToast`, sonner), dialog e skeleton so na area que carrega;
- telas novas de lista seguem o modelo de Orcamentos (`MonthYearNavigator`, filtros, cards de resumo, tabela, pager);
- pagina publica nova usa `PublicVenueListShell` e `public-list-pattern.ts`;
- mudanca visual ampla nasce em ux-ui request ou spec.

## Lacunas

Nao ha Storybook, inventario aprovado de tokens, dark mode funcional (variaveis `.dark` sem provider), guideline de marca do EventHub, politica de responsividade documentada nem matriz de componentes canonicos. `bg-eventhub-primary-dark` e usado sem definicao. Duplicados (`EmptyState`, `PageHeader`, `SubmitButton`) precisam de dono canonico.
