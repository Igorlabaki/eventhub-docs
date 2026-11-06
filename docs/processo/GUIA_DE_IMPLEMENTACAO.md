# Guia Oficial de Implementação - EventHub

Protocolo operacional obrigatório para qualquer tarefa no projeto. Funciona em conjunto com [INDEX.md](../INDEX.md).

------------------------------------------------------------
1. Princípio Fundamental
------------------------------------------------------------

- **Nenhuma tarefa pode ser executada sem consultar o INDEX.**
- O **INDEX.md** é a constituição do projeto: define quais documentos existem, quando usá-los e a prioridade entre fontes.
- Este **GUIA_DE_IMPLEMENTACAO.md** é o protocolo operacional: define a ordem de execução e as regras de conclusão.

------------------------------------------------------------
2. Etapa Obrigatória Antes de Codar
------------------------------------------------------------

Antes de qualquer implementação:

1. **Consultar** `/docs/INDEX.md`
2. **Identificar** quais documentos serão impactados pela tarefa (ver seção 3)
3. **Consultar** as "Regras de Ouro" do INDEX (seção 3 do INDEX)
4. **Seguir** a prioridade de fontes definida no INDEX (em conflito: DOMAIN_MODEL → API_CONTRACTS → database.dbml → documentos de análise)

------------------------------------------------------------
3. Identificação de Impacto Documental
------------------------------------------------------------

Antes de implementar, responder:

| Pergunta | Se sim, documentos a atualizar (ver INDEX §5) |
|----------|-----------------------------------------------|
| A tarefa altera **FRONTEND**? | estado/frontend/FRONTEND_ANALISE_ATUAL.md, estado/frontend/FRONTEND_TODO_PRIORIDADE.md (se backlog), INDEX.md (se arquitetura) |
| A tarefa altera **BACKEND**? | estado/backend/BACKEND_ANALISE_ATUAL.md, referencias/API_CONTRACTS.md (se endpoint/payload), INDEX.md (se arquitetura) |
| A tarefa altera **BANCO**? | referencias/database.dbml, referencias/DATA_MODEL_EXPLAINED.md, referencias/DOMAIN_MODEL.md (se regra), referencias/REGRAS_DE_NEGOCIO.md (se regra de negócio comportamental), referencias/API_CONTRACTS.md (se contrato), processo/MIGRATION_STRATEGY.md (se estratégia), INDEX.md |
| A tarefa altera **regras de negócio** (comportamento/restrições do sistema)? | referencias/REGRAS_DE_NEGOCIO.md, referencias/DOMAIN_MODEL.md (se impactar glossário/invariantes), INDEX.md (se necessário) |
| A tarefa altera **API/Contratos**? | referencias/API_CONTRACTS.md, INDEX.md |
| A tarefa altera **AUTENTICAÇÃO/AUTORIZAÇÃO**? | referencias/AUTHORIZATION_MODEL.md, processo/SECURITY_HARDENING.md, referencias/API_CONTRACTS.md, INDEX.md |
| A tarefa altera **PRODUÇÃO/PERFORMANCE/OBSERVABILIDADE**? | planos/PRODUCTION_SETUP.md, planos/PERFORMANCE_PLAN.md, planos/OBSERVABILITY_PLAN.md, INDEX.md |
| A tarefa é **criar um novo documento** (.md)? | **INDEX.md** (obrigatório: adicionar o novo doc no Mapa por Área com "Use quando:", Keywords, Dependências, Status). Ver Regra de Inclusão de Novos Documentos no INDEX. |

Com base nas respostas, **listar explicitamente** os documentos que precisarão ser atualizados ao finalizar a tarefa.

------------------------------------------------------------
4. Regras Técnicas Obrigatórias
------------------------------------------------------------

**Banco**

- Mudanças devem ser **aditivas** e **retrocompatíveis**.
- Nunca quebrar produção.
- Seguir [MIGRATION_STRATEGY.md](./MIGRATION_STRATEGY.md).

**API**

- Evitar breaking changes.
- Seguir [API_VERSIONING_STRATEGY.md](../referencias/API_VERSIONING_STRATEGY.md).
- Atualizar [API_CONTRACTS.md](../referencias/API_CONTRACTS.md) se alterar contrato.

**Autorização**

- Sempre validar no backend.
- Seguir [AUTHORIZATION_MODEL.md](../referencias/AUTHORIZATION_MODEL.md).

**Frontend**

- Manter coerência arquitetural descrita em [FRONTEND_ANALISE_ATUAL.md](../estado/frontend/FRONTEND_ANALISE_ATUAL.md).

------------------------------------------------------------
5. Regra de Finalização
------------------------------------------------------------

**Nenhuma tarefa é considerada concluída se:**

- O código foi alterado **e**
- A documentação impactada não foi atualizada

**Ao finalizar qualquer tarefa:**

- Atualizar todos os documentos listados na identificação de impacto (seção 3).
- Atualizar o INDEX.md se houver mudança estrutural (novo doc, nova área, status).
- **Se a tarefa foi criar um novo documento (.md):** o agente **deve** adicionar esse documento ao INDEX.md (seção Mapa por Área, na área correspondente), com Nome do arquivo, "Use quando:", Keywords, Dependências e Status. Tarefa de criação de doc sem atualização do INDEX é **incompleta** (ver Regra de Inclusão de Novos Documentos no INDEX).
- Garantir consistência entre:
  - Código
  - referencias/database.dbml
  - referencias/API_CONTRACTS.md
  - referencias/DOMAIN_MODEL.md
  - referencias/REGRAS_DE_NEGOCIO.md (quando a tarefa impactar regras de negócio)

------------------------------------------------------------
6. Protocolo de Execução no Chat (IA)
------------------------------------------------------------

Ao usar IA para executar tarefas no projeto:

**Sempre que for iniciar uma tarefa**, fornecer:

1. O conteúdo de **INDEX.md**
2. O conteúdo deste **GUIA_DE_IMPLEMENTACAO.md**
3. A descrição da tarefa

Isso ativa o modo de execução disciplinado: consulta ao INDEX, identificação de impacto, cumprimento das regras técnicas e atualização da documentação ao finalizar.
