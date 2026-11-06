# Design System Direction — EventHub

## Base atual

- React 18, Tailwind CSS, shadcn/Radix, Lucide e CSS global;
- tokens/tema em `eventhub-vista-dashboard/src/index.css` e `tailwind.config.ts`;
- componentes base em `src/components/ui/`;
- componentes de dominio em `src/components/<dominio>/`.

## Direcao operacional

- reutilizar componente de `ui/` ou dominio antes de criar outro;
- manter acessibilidade dos primitives Radix;
- usar feedback consistente por toast/dialog/skeleton;
- telas novas devem seguir navegacao e shells existentes;
- mudanca visual ampla deve nascer em ux-ui request ou spec, nao em ajuste isolado.

## Lacunas

Nao ha Storybook, inventario aprovado de tokens, politica documentada de responsividade/dark mode, guidelines de marca ou matriz de componentes canonicos completa. `project/frontend-map.md` e a fonte pratica ate isso ser formalizado.
