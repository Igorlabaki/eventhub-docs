# EventHub Documentation Index

------------------------------------------------------------
0) Estrutura de pastas (docs/)
------------------------------------------------------------

A documentação está organizada por **tipo**:

| Pasta | Conteúdo |
|-------|----------|
| **planos/** | Roadmaps, planos de feature/infra (ROADMAP_TECHNICAL, PLANO_INTEGRACAO_DOCUSIGN, contrato-clausulas, horario-wall-clock, OBSERVABILITY_PLAN, PERFORMANCE_PLAN, PRODUCTION_SETUP). |
| **referencias/** | Consulta: API, domínio, modelo de dados, regras, auth, arquitetura (API_CONTRACTS, DOMAIN_MODEL, REGRAS_DE_NEGOCIO, DATA_MODEL_EXPLAINED, database.dbml, AUTHORIZATION_MODEL, ARCHITECTURE_OVERVIEW, API_VERSIONING_STRATEGY). |
| **estado/backend/** | Análise atual do backend (BACKEND_ANALISE_ATUAL). |
| **estado/frontend/** | Análise e backlog do frontend (FRONTEND_ANALISE_ATUAL, FRONTEND_TODO_PRIORIDADE). |
| **estado/integracao/** | Integração FE↔BE, limitações, backlog consolidado (INTEGRACAO_FRONT_BACK_ANALISE_ATUAL, KNOWN_LIMITATIONS, TODO_MASTER). |
| **processo/** | Como trabalhamos: guia de implementação, migração, segurança (GUIA_DE_IMPLEMENTACAO, MIGRATION_STRATEGY, SECURITY_HARDENING). |

Na **raiz** de `docs/` ficam apenas **INDEX.md** (este arquivo) e **README.md**.

------------------------------------------------------------
1) Como usar este índice
------------------------------------------------------------

Use este índice para decidir **qual documento consultar** conforme a tarefa:

| Precisa de… | Documento(s) principal(is) |
|-------------|----------------------------|
| **Domínio / regras de negócio** | referencias/DOMAIN_MODEL.md, referencias/REGRAS_DE_NEGOCIO.md |
| **Banco de dados** (estrutura, entidades, ER) | referencias/database.dbml, referencias/DATA_MODEL_EXPLAINED.md |
| **Migrations** (como evoluir o banco sem quebrar) | processo/MIGRATION_STRATEGY.md |
| **API / contratos** (endpoints, payloads, status) | referencias/API_CONTRACTS.md |
| **Autenticação / autorização** (JWT, refresh, permissões) | referencias/AUTHORIZATION_MODEL.md |
| **Segurança** (ameaças, riscos, mitigações) | processo/SECURITY_HARDENING.md |
| **Frontend** (estrutura, stack, estado atual) | estado/frontend/FRONTEND_ANALISE_ATUAL.md, estado/frontend/FRONTEND_TODO_PRIORIDADE.md |
| **Backend** (estrutura, use cases, rotas) | estado/backend/BACKEND_ANALISE_ATUAL.md |
| **Integração FE ↔ BE** (chamadas, base URL, auth) | estado/integracao/INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md |
| **Produção / deploy** (rodar local, envs, Vercel) | planos/PRODUCTION_SETUP.md |
| **Observabilidade** (logs, métricas, health) | planos/OBSERVABILITY_PLAN.md |
| **Performance** (paginação, índices, uploads) | planos/PERFORMANCE_PLAN.md |
| **Limitações conhecidas** (dívidas, bugs, workarounds) | estado/integracao/KNOWN_LIMITATIONS.md |

Ordem de prioridade em conflito entre documentos: ver seção **Regras de Ouro**.

------------------------------------------------------------
2) Mapa por Área
------------------------------------------------------------

### 1) Visão Geral & Arquitetura

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| README.md | Primeiro contato com a documentação; índice resumido e “por onde começar”. | índice, onboarding, mapa pastas | — | ✅ Atual |
| referencias/ARCHITECTURE_OVERVIEW.md | Entender o que é o sistema, componentes, fluxos e diagramas de alto nível. | arquitetura, componentes, diagrama, FE, BE | FRONTEND_ANALISE_ATUAL, BACKEND_ANALISE_ATUAL, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | ✅ Atual |
| planos/ROADMAP_TECHNICAL.md | Planejar entregas 30/60/90 dias; prioridades e riscos. | roadmap, sprints, prioridades | KNOWN_LIMITATIONS, SECURITY_HARDENING, INTEGRACAO, FRONTEND_TODO_PRIORIDADE | ✅ Atual |

### 2) Domínio

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| referencias/DOMAIN_MODEL.md | Consultar glossário, ciclo de vida da Proposal, invariantes e regras de negócio. | domínio, glossário, proposal, organização, venue | database.dbml, BACKEND_ANALISE_ATUAL | ✅ Atual |
| referencias/REGRAS_DE_NEGOCIO.md | Consultar a fonte da verdade sobre comportamento e restrições do sistema (sem estrutura de banco nem implementação). | regras de negócio, comportamento, restrições, autorização, organização, venue, proposta, pagamento | DOMAIN_MODEL, DATA_MODEL_EXPLAINED, API_CONTRACTS, AUTHORIZATION_MODEL, KNOWN_LIMITATIONS, INTEGRACAO_FRONT_BACK_ANALISE_ATUAL | ✅ Atual |

### 3) Banco de Dados & Migrations

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| referencias/database.dbml | Ver esquema lógico completo (tabelas, enums, relações); gerado a partir do Prisma. | DBML, schema, tabelas, enums | Prisma schema (fonte da verdade) | ✅ Atual |
| referencias/DATA_MODEL_EXPLAINED.md | Entender o banco em termos de domínio, ER, campos sensíveis e integridade. | modelo de dados, ER, integridade | database.dbml, DOMAIN_MODEL, BACKEND_ANALISE_ATUAL | ✅ Atual |
| processo/MIGRATION_STRATEGY.md | Definir como fazer mudanças no banco e na API sem quebrar produção; rollback. | migrations, retrocompatibilidade, versionamento | DATA_MODEL_EXPLAINED, BACKEND_ANALISE_ATUAL, INTEGRACAO | ✅ Atual |

### 4) API & Contratos

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| referencias/API_CONTRACTS.md | Consultar endpoints, métodos, auth, payloads e respostas por recurso. | API, contratos, endpoints, Zod | Código em art56_server_v3/src | ✅ Atual |
| referencias/API_VERSIONING_STRATEGY.md | Introduzir /v1 ou X-Api-Version; política de depreciação. | versionamento, depreciação | MIGRATION_STRATEGY, API_CONTRACTS | ✅ Atual |

### 5) Autenticação & Autorização

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| referencias/AUTHORIZATION_MODEL.md | Entender auth (JWT/refresh/session), permissões org/venue e lacunas atuais. | auth, JWT, refresh, permissões, ensureAuthenticate | BACKEND_ANALISE_ATUAL, INTEGRACAO | ✅ Atual |

### 6) Segurança

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| processo/SECURITY_HARDENING.md | Ver threat model, riscos no código e plano de mitigações (2 sprints). | segurança, threat model, CORS, rotas sem auth | AUTHORIZATION_MODEL, BACKEND_ANALISE_ATUAL, INTEGRACAO | ✅ Atual |

### 7) Backend

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| estado/backend/BACKEND_ANALISE_ATUAL.md | Conhecer estrutura do backend, use cases, routers e estado atual. | backend, Express, Prisma, use cases | — | ✅ Atual |

### 8) Frontend

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| estado/frontend/FRONTEND_ANALISE_ATUAL.md | Entender estrutura do FE, stack, pastas e padrões atuais. | frontend, React, Vite, Zustand, React Query | — | ✅ Atual |
| estado/frontend/FRONTEND_TODO_PRIORIDADE.md | Ver backlog de correções e melhorias do FE por prioridade. | TODO, prioridade, bugs, melhorias | FRONTEND_ANALISE_ATUAL | ✅ Atual |

### 9) Integração FE ↔ BE

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| estado/integracao/INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md | Mapear chamadas FE→BE, base URL, auth e inconsistências. | integração, Axios, VITE_API_URL, mapeamento | — | ✅ Atual |

### 10) Produção

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| planos/PRODUCTION_SETUP.md | Rodar local (FE/BE), envs, deploy Vercel, migrations e smoke test. | deploy, env, Vercel, migrations | INTEGRACAO | ✅ Atual |

### 11) Observabilidade

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| planos/OBSERVABILITY_PLAN.md | Definir logs, métricas, alertas e health check; onde instrumentar. | logs, métricas, alertas, health | BACKEND_ANALISE_ATUAL | ✅ Atual |

### 12) Performance

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| planos/PERFORMANCE_PLAN.md | Ver onde falta paginação, índices, transações e recomendações de upload. | paginação, índices, transações, Sharp, S3 | BACKEND_ANALISE_ATUAL, DATA_MODEL_EXPLAINED | ✅ Atual |

### 13) Limitações

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| estado/integracao/KNOWN_LIMITATIONS.md | Consultar dívidas, bugs prováveis e workarounds por camada (FE, BE, integração, DB). | limitações, dívidas, bugs | estado/frontend/, estado/backend/, estado/integracao/ | ✅ Atual |

### 14) Planos de feature / integração

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| planos/PLANO_INTEGRACAO_DOCUSIGN.md | Implementar integração DocuSign end-to-end (contratos, assinatura, webhooks). | DocuSign, assinatura, envelope, webhook | referencias/API_CONTRACTS, referencias/DOMAIN_MODEL, processo/MIGRATION_STRATEGY, planos/OBSERVABILITY_PLAN | ✅ Atual |
| planos/contrato-clausulas/ | Corrigir ordenação de cláusulas no contrato (PDF aleatório); plano faseado: API, UX, modelo de dados. **Fase 1 concluída.** | contrato, cláusula, position, PDF, ordenação | referencias/API_CONTRACTS, referencias/DOMAIN_MODEL, referencias/database.dbml, processo/GUIA_DE_IMPLEMENTACAO | ✅ Fase 1 concluída |
| planos/horario-wall-clock/ | Padronizar horários de evento (wall-clock): escolheu 13:00 → salva e exibe 13:00; plano faseado FE/BE/integrações. | horário, UTC, wall-clock, timezone, proposta, dateEvent | referencias/DATA_MODEL_EXPLAINED, referencias/REGRAS_DE_NEGOCIO, referencias/API_CONTRACTS, processo/GUIA_DE_IMPLEMENTACAO | 📋 Documentado |
| INTEGRATIONS_GOOGLE_CALENDAR.md | Configurar e operar integração 1-way EventHub → Google Calendar; setup OAuth, scopes, fluxo, troubleshooting e exemplos curl. | Google Calendar, OAuth, integração, sync, VIEW_VENUE_CALENDAR, EDIT_VENUE_CALENDAR | referencias/API_CONTRACTS, referencias/AUTHORIZATION_MODEL, processo/MIGRATION_STRATEGY | ✅ Atual |

### 15) Processo

| Arquivo | Use quando: | Keywords | Dependências | Status |
|---------|-------------|----------|--------------|--------|
| processo/GUIA_DE_IMPLEMENTACAO.md | Seguir o protocolo obrigatório antes e depois de codar; impacto documental. | guia, implementação, INDEX, impacto | INDEX.md | ✅ Atual |

------------------------------------------------------------
3) Regras de Ouro
------------------------------------------------------------

## Regras de Ouro

- Mudanças no banco devem ser **retrocompatíveis** (seguir **processo/MIGRATION_STRATEGY.md**).
- Evitar **breaking changes** na API (seguir **referencias/API_VERSIONING_STRATEGY.md**).
- Autorização deve ser **validada no backend** (seguir **referencias/AUTHORIZATION_MODEL.md**).
- Em caso de **conflito entre documentos**, ordem de prioridade:
  1. **referencias/DOMAIN_MODEL.md**
  2. **referencias/API_CONTRACTS.md**
  3. **referencias/database.dbml**
  4. Documentos de análise (estado/frontend/, estado/backend/, estado/integracao/).

------------------------------------------------------------
4) Onde fica o quê (por feature)
------------------------------------------------------------

## Onde fica o quê (por feature)

| Feature | Documentos |
|---------|------------|
| **Auth / Refresh Token** | referencias/AUTHORIZATION_MODEL.md, estado/integracao/INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md, referencias/API_CONTRACTS.md |
| **Proposal / Orçamento** | referencias/DOMAIN_MODEL.md, referencias/REGRAS_DE_NEGOCIO.md, referencias/DATA_MODEL_EXPLAINED.md, referencias/database.dbml, referencias/API_CONTRACTS.md |
| **Uploads / Imagens** | processo/SECURITY_HARDENING.md, planos/PRODUCTION_SETUP.md, referencias/API_CONTRACTS.md, planos/PERFORMANCE_PLAN.md |
| **Permissões por organização / venue** | referencias/AUTHORIZATION_MODEL.md, referencias/DOMAIN_MODEL.md, referencias/REGRAS_DE_NEGOCIO.md |
| **Venue / Organização** | referencias/DOMAIN_MODEL.md, referencias/REGRAS_DE_NEGOCIO.md, referencias/DATA_MODEL_EXPLAINED.md, referencias/database.dbml, referencias/API_CONTRACTS.md |
| **Contratos / Cláusulas** | planos/contrato-clausulas/README.md, referencias/DOMAIN_MODEL.md, referencias/database.dbml, referencias/API_CONTRACTS.md |
| **Horários / datas de evento** | planos/horario-wall-clock/README.md, referencias/REGRAS_DE_NEGOCIO.md, referencias/DATA_MODEL_EXPLAINED.md, referencias/API_CONTRACTS.md |
| **Pagamentos / Documentos** | referencias/REGRAS_DE_NEGOCIO.md, referencias/DOMAIN_MODEL.md, referencias/API_CONTRACTS.md, referencias/DATA_MODEL_EXPLAINED.md |
| **Deploy / ambiente** | planos/PRODUCTION_SETUP.md, estado/integracao/INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md |
| **Mudanças no banco sem quebrar** | processo/MIGRATION_STRATEGY.md, referencias/DATA_MODEL_EXPLAINED.md, referencias/database.dbml |
| **Integração Google Calendar** | INTEGRATIONS_GOOGLE_CALENDAR.md, referencias/API_CONTRACTS.md, referencias/AUTHORIZATION_MODEL.md |

------------------------------------------------------------
5) Política de Atualização Obrigatória da Documentação
------------------------------------------------------------

# Política de Atualização Obrigatória da Documentação

**Se alterar FRONTEND:**
- Atualizar **estado/frontend/FRONTEND_ANALISE_ATUAL.md**
- Atualizar **estado/frontend/FRONTEND_TODO_PRIORIDADE.md** (se impactar backlog)
- Atualizar **INDEX.md** se mudar arquitetura ou responsabilidades

**Se alterar BACKEND:**
- Atualizar **estado/backend/BACKEND_ANALISE_ATUAL.md**
- Atualizar **referencias/API_CONTRACTS.md** se alterar endpoint, payload ou status
- Atualizar **INDEX.md** se mudar arquitetura

**Se alterar BANCO DE DADOS:**  
Atualizar obrigatoriamente:
- **referencias/database.dbml**
- **referencias/DATA_MODEL_EXPLAINED.md**
- **referencias/DOMAIN_MODEL.md** (se alterar regra de negócio)
- **referencias/API_CONTRACTS.md** (se alterar contrato)
- **processo/MIGRATION_STRATEGY.md** (se alterar estratégia)
- **INDEX.md**

Regras: mudanças devem ser **aditivas**, **retrocompatíveis** e **nunca quebrar produção**.

**Se alterar AUTENTICAÇÃO ou AUTORIZAÇÃO:**
- Atualizar **referencias/AUTHORIZATION_MODEL.md**
- Atualizar **processo/SECURITY_HARDENING.md**
- Atualizar **referencias/API_CONTRACTS.md**
- Atualizar **INDEX.md**

**Se alterar PRODUÇÃO / PERFORMANCE / OBSERVABILIDADE:**
- Atualizar **planos/PRODUCTION_SETUP.md**
- Atualizar **planos/PERFORMANCE_PLAN.md**
- Atualizar **planos/OBSERVABILITY_PLAN.md**
- Atualizar **INDEX.md**

------------------------------------------------------------
6) Regra de Inclusão de Novos Documentos
------------------------------------------------------------

## Regra de Inclusão de Novos Documentos

- Sempre que um novo documento for criado no projeto, ele deve **obrigatoriamente** ser adicionado ao `/docs/INDEX.md`.
- Nenhum novo .md é considerado oficial se não estiver listado no INDEX.
- A criação de documentação sem atualização do INDEX é considerada **tarefa incompleta**.
- Ao adicionar no INDEX: incluir na seção "Mapa por Área" (área correspondente), com Nome do arquivo, "Use quando:", Keywords, Dependências e Status.

------------------------------------------------------------
7) Regra de Conclusão de Tarefa
------------------------------------------------------------

**Nenhuma tarefa é considerada concluída se:**
- O código foi alterado  
- E a documentação impactada não foi atualizada  

**Toda tarefa deve terminar com:**
- Verificação de impacto documental  
- Atualização dos arquivos correspondentes (conforme seção 5)  
- Atualização do **INDEX.md** se necessário (novo doc, nova área ou mudança de status). Para **novo doc**, seguir a **Regra de Inclusão de Novos Documentos** (seção 6).

------------------------------------------------------------
8) Gaps & Ações Recomendadas
------------------------------------------------------------

## Gaps & Ações Recomendadas

| Ação | Descrição |
|------|-----------|
| Criar `.env.example` (FE e BE) | Documentação de variáveis hoje só em PRODUCTION_SETUP.md; ausência no repo dificulta onboarding. |
| Revisar status dos docs periodicamente | Manter coluna "Status" do Mapa por Área atualizada (✅ Atual / ⚠️ Revisar / ❌ Desatualizado) no INDEX.md. |
| Alinhar README.md com INDEX.md | README é índice resumido; INDEX.md é o mapa oficial. Garantir que README aponte para INDEX.md como referência completa. |
| Evitar redundância longa | FRONTEND_TODO_PRIORIDADE e KNOWN_LIMITATIONS têm sobreposição (limitações FE); manter FRONTEND_TODO focado em tarefas e KNOWN_LIMITATIONS em dívidas/riscos. |
