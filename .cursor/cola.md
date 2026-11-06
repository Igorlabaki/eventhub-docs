### Antes de qualquer task

ler `.cursor/framework_core/project/agent-entrypoint.md` — o core ja tem o contexto do EventHub (`product/`, `project/`, `topics/` e o mapa dos repositorios `backend` e `frontend`)

consultar `.cursor/framework_core/BOARD.md` para verificar se ja existe task-request, spec ou plano relacionado

### Criar task-request

use `C:\Users\Igorino Locochino\Desktop\code\eventhub\.cursor\framework_global\framework-base\prompts\tasking\task-request-synthesizer.md` para gerar uma task-request

para varias demandas independentes, use `C:\Users\Igorino Locochino\Desktop\code\eventhub\.cursor\framework_global\framework-base\prompts\tasking\batch-task-request-synthesizer.md`

### Executar task-request

use `C:\Users\Igorino Locochino\Desktop\code\eventhub\.cursor\framework_global\framework-base\prompts\tasking\task-workflow-prompt.md` para executar a task

### Promover task-request para spec

use `C:\Users\Igorino Locochino\Desktop\code\eventhub\.cursor\framework_global\framework-base\prompts\spec-driven\spec-feature-bootstrap-prompt.md` para promover a task para spec

### Executar spec

use `C:\Users\Igorino Locochino\Desktop\code\eventhub\.cursor\framework_global\framework-base\prompts\spec-driven\spec-task-execution-prompt.md` para executar todas as tasks da spec

para executar apenas a proxima task, use o gatilho `fw:run` com o caminho da spec

### Dividir trabalho por repositorio

use `C:\Users\Igorino Locochino\Desktop\code\eventhub\.cursor\framework_global\framework-base\prompts\tasking\task-request-repo-split-prompt.md` para dividir task-request entre `backend` e `frontend`

use `C:\Users\Igorino Locochino\Desktop\code\eventhub\.cursor\framework_global\framework-base\prompts\spec-driven\spec-repo-split-prompt.md` para dividir uma spec

### Revisar task-request

use `C:\Users\Igorino Locochino\Desktop\code\eventhub\.cursor\framework_global\framework-base\prompts\review\task-request-review-prompt.md` para revisar antes da execucao

### Revisar spec

use `C:\Users\Igorino Locochino\Desktop\code\eventhub\.cursor\framework_global\framework-base\prompts\review\spec-review-prompt.md` para revisar antes da implementacao

### Revisar entrega ou erros

use `C:\Users\Igorino Locochino\Desktop\code\eventhub\.cursor\framework_global\framework-base\prompts\review\task-delivery-review-prompt.md` para revisar a entrega

### Validar o framework

use `fw:doctor` ou execute:

```powershell
py -3 framework_global/framework-base/tools/validate-framework.py --core .cursor/framework_core --global-root framework_global --strict
```
