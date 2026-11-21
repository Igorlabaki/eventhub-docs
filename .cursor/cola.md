### Antes de qualquer task

ler `.cursor/framework_core/project/agent-entrypoint.md` — o core ja tem o contexto do EventHub (`product/`, `project/`, `topics/` e o mapa dos repositorios `backend` e `frontend`)

consultar `.cursor/framework_core/BOARD.md` para verificar se ja existe task-request, spec ou plano relacionado

### Criar task-request

use `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\tasking\task-request-synthesizer.md` para gerar uma task-request

para varias demandas independentes, use `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\tasking\batch-task-request-synthesizer.md`

### Transformar conversa do chat em task-request

cole no fim de uma conversa em que a ideia ja foi discutida:

```markdown
com base em tudo que discutimos neste chat, monte um prompt para `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\tasking\task-request-synthesizer.md` gerar uma task-request

o prompt deve comecar mandando ler `.cursor/framework_core/project/agent-entrypoint.md` e conferir `.cursor/framework_core/BOARD.md`, e conter as secoes:

- `Demanda`: o pedido em linguagem de usuario, com exemplo concreto
- `Contexto ja verificado`: so o que foi confirmado no codigo durante o chat, com caminhos de arquivo
- `Decisoes fechadas (preservar no request, nao reabrir como pergunta)`: tudo que eu escolhi ou confirmei
- `Limitacoes aceitas na v1`
- `Perguntas ainda abertas`: so se sobrou alguma, cada uma com premissa default
- `Notas tecnicas para a spec (nao descartar; registrar no request como insumo para o bootstrap)`: schema, endpoints, formulas, componentes levantados
- `Saida esperada`: task-request em `framework_core/task-requests/`, faixa sugerida, flags transversais (`security`, `database`, `design`, `observability`, `patterns`), indicacao de spec com slug sugerido, linha no `BOARD.md` e o comando de promocao com `spec-feature-bootstrap-prompt.md` se for candidata a spec

regras:
- nao inventar nada que nao apareceu no chat; lacuna vira pergunta aberta com default
- nao incluir ideias descartadas na conversa
- me entregue o prompt num bloco markdown pronto para copiar; nao execute ainda
```

para gerar e ja executar no mesmo passo, troque a ultima regra por: `depois de montar o prompt, execute o synthesizer com ele`

### Executar task-request

use `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\tasking\task-workflow-prompt.md` para executar a task

### Promover task-request para spec

use `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\spec-driven\spec-feature-bootstrap-prompt.md` para promover a task para spec

### Executar spec

use `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\spec-driven\spec-task-execution-prompt.md` para executar todas as tasks da spec

para executar apenas a proxima task, use o gatilho `fw:run` com o caminho da spec

### Dividir trabalho por repositorio

use `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\tasking\task-request-repo-split-prompt.md` para dividir task-request entre `backend` e `frontend`

use `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\spec-driven\spec-repo-split-prompt.md` para dividir uma spec

### Revisar task-request

use `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\review\task-request-review-prompt.md` para revisar antes da execucao

### Revisar spec

use `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\review\spec-review-prompt.md` para revisar antes da implementacao

### Revisar entrega ou erros

use `C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs\framework_global\framework-base\prompts\review\task-delivery-review-prompt.md` para revisar a entrega

### Validar o framework

use `fw:doctor` ou execute (requer Python 3 instalado; nesta maquina `py`/`python` ainda nao existem):

```powershell
cd C:\Users\AR756\Desktop\igor\eventhub\eventhub-docs
py -3 framework_global/framework-base/tools/validate-framework.py --core .cursor/framework_core --global-root framework_global --strict
```
