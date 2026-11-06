# Instrucoes para agentes — EventHub

## Framework da equipe

Antes de qualquer tarefa:

1. leia `.cursor/framework_core/project/agent-entrypoint.md` e siga a ordem de leitura e a leitura dirigida por frente;
2. leia `.cursor/framework_core/project/active-libs.md`, inclusive variantes e camadas transversais declaradas;
3. trate `.cursor/framework_core/project/project-decisions.md` como fonte das excecoes locais;
4. gatilhos `fw:*` seguem `.cursor/framework_global/framework-base/prompts/framework-router-prompt.md`;
5. mantenha `.cursor/framework_core/BOARD.md` atualizado em toda operacao que criar, promover, executar ou concluir artefato;
6. use os `repo-id` de `project/project-catalog-entry.md` ao dividir trabalho entre repositorios;
7. se `.cursor/framework_core/METRICS.md` tiver `status: ligada`, anexe a linha de telemetria ao fim da operacao;
8. `fw:run` manual nao carrega agentes de orquestracao nem dispara subagente automaticamente.

## Limites do workspace

- `art56_server_v3/` e o backend (`repo-id: backend`).
- `eventhub-vista-dashboard/` e o frontend (`repo-id: frontend`).
- `framework_global/` e a camada global atualizavel; nao colocar memoria especifica do EventHub nela.
- `.cursor/framework_core/` e a memoria viva do EventHub.
- `docs/` e a documentacao legada/detalhada; o core a roteia e resume, sem apagar a fonte existente.

## Regra de seguranca

Nunca ler, imprimir ou versionar valores de `.env`. Use apenas os nomes de variaveis presentes em `.env.example`. Valores que parecam segredo em arquivos de exemplo devem ser tratados como incidente de credencial, sem reproduzi-los.
