# Solicitacao da Tarefa

## Nome sugerido da tarefa

Abas no formulario de configuracoes do espaco

## Resumo da solicitacao

A tela Configuracoes do espaco deixa de ser um formulario unico e longo. Os campos atuais de Informacoes Gerais passam para quatro abas no visual padrao do painel, com um unico salvamento.

## Context Pack

- frente principal: produto (frontend)
- superficie sensivel: nao — so reorganiza a tela que ja edita o espaco; logo, cores e precos continuam no mesmo salvamento
- risco principal: campo obrigatorio ficar numa aba oculta e o Salvar falhar sem mostrar o erro, ou valor digitado (inclusive o arquivo do logo) sumir ao trocar de aba
- repos tocados: `frontend` (`eventhub-vista-dashboard/`)
- fora de escopo operacional: formulario de criar espaco; paginas publicas, orcamento e proposta; API, schema e payload de salvar; quinto grupo so para proprietarios; botao Novo das abas de lista
- prova minima desta execucao: em Configuracoes do espaco, as quatro abas aparecem no visual das abas de Relatorios; cada uma mostra so os seus campos; Salvar numa aba persiste o que foi editado em outra; um campo obrigatorio invalido numa aba oculta leva o operador ate essa aba com a mensagem; Voltar e Deletar continuam no rodape
- criterio de escalada: promover para `spec` se a execucao precisar mudar o contrato de salvar, o formulario de criar espaco ou quebrar o salvamento em varios envios
- nivel de autonomia: `L2`

## Minimal Read Set

- ler primeiro: `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
- libs obrigatorias: `react`, `design`
- documentos obrigatorios:
  - `.cursor/framework_core/project/agent-entrypoint.md#Leitura por frente`
  - `.cursor/framework_core/project/agent-entrypoint.md#Provas`
  - `.cursor/framework_core/project/frontend-map.md#Venue`
- caminhos candidatos: `eventhub-vista-dashboard/src/pages/VenueSettings.tsx`; `eventhub-vista-dashboard/src/components/reports/ReportsHeader.tsx`; `eventhub-vista-dashboard/src/components/ui/page-header.tsx`; `eventhub-vista-dashboard/src/components/ui/form-layout.tsx`; `eventhub-vista-dashboard/src/components/ui/tabs.tsx`
- palavras-chave ou simbolos de busca: `VenueSettings`, `FormLayout`, `Informações Gerais`, `ReportsHeader`, `TabsList`, `proposalPrimaryColor`, `owners`, `logoFile`
- testes provaveis: `npm run build` e `npm run lint` no frontend; na tela, trocar de aba sem perder o que foi digitado, salvar e reabrir, e forcar erro de campo obrigatorio numa aba que nao esta visivel
- nao ler por padrao: `security`; `database`; `topics/` de preco, proposta publica ou apresentacao; backend

## Contexto informado na entrada

Pedido em chat, a partir da tela Configuracoes do espaco AR756. O card Informacoes Gerais empilha identidade, slogan, descricao, endereco, precos, horarios, redes, video, logo, cores e proprietarios. O painel ja tem abas em pilula branca, rotulo em maiusculas e aba ativa violeta com faixa inferior, como em Relatorios e Contratos.

## Problema atual

`/venue/:id/settings` (`VenueSettings`) e um unico formulario dentro de `FormLayout`. Tudo rola na mesma pagina. Nao ha como ir direto a endereco, preco ou apresentacao.

## Objetivo da mudanca

Em Configuracoes do espaco, o operador abre uma de quatro abas, edita so aquele grupo e salva uma vez, de qualquer aba, com o mesmo efeito de hoje.

## Escopo inicial percebido

So o frontend da tela de configuracoes do espaco. Um formulario, um envio. As abas escondem secoes. O titulo da pagina continua Configuracoes. O titulo unico Informacoes Gerais do card da lugar ao nome da secao na aba.

## Itens incluidos neste request

- aba GERAL: nome, e-mail, WhatsApp, capacidade maxima, slogan, descricao
- aba ENDERECO: rua, numero, complemento, bairro, cidade, estado, CEP
- aba PRECOS: modelo de precificacao, preco do modelo, preco minimo, pernoite, check-in, check-out, noites minimas, abertura, fechamento, duracao padrao do evento
- aba APRESENTACAO: URL do espaco, Instagram, Facebook, TikTok, video do tour, logo, cores da proposta, proprietarios
- visual da `TabsList` de Relatorios: pilula `bg-white/80 shadow-sm rounded-lg`, rotulo em maiusculas, aba ativa `bg-violet-100 text-violet-700` com `border-b-4 border-violet-500`
- Salvar, Deletar e Voltar fora do conteudo da aba, visiveis em qualquer uma
- ao falhar a validacao, a aba ativa passa a ser a primeira que tiver campo invalido, com a mensagem visivel

## Requisitos implicitos ja visiveis

- um `useForm` e um `FormLayout`; trocar de aba nao dispara salvamento
- o que foi digitado numa aba continua no formulario ao abrir outra
- pernoite continua na aba PRECOS, e check-in, check-out e noites minimas so aparecem quando ele esta ligado; sem pernoite, a mesma aba mostra abertura e fechamento
- proprietarios ficam no fim de APRESENTACAO
- o arquivo de logo escolhido e o preview continuam depois de trocar de aba
- o botao de voltar as cores padrao continua junto das cores, em APRESENTACAO
- campos obratorios de hoje continuam obrigatorios: nome, e-mail, endereco, capacidade e pelo menos um proprietario

## Casos de erro e borda ja percebidos

- Salvar com rua vazia estando em GERAL abre ENDERECO e mostra o erro da rua
- Salvar sem proprietario estando em GERAL abre APRESENTACAO e mostra o erro
- preco, horario e redes opcionais vazios continuam validos
- slogan alterado em GERAL, salvo a partir de PRECOS, reaparece ao reabrir a tela
- logo escolhido em APRESENTACAO nao se perde ao visitar PRECOS e voltar
- falha da API ao salvar mostra o erro na propria tela e mantem a aba e os valores

## Dependencias

- `VenueSettings` ja grava todos esses campos num unico envio
- o visual de aba ja existe em `ReportsHeader` e em `components/ui/page-header.tsx`
- o campo slogan ja entra neste mesmo formulario

## Restricoes e cuidados

- nao usar o `PageHeader` de listas: ele renderiza o botao Novo e o botao flutuante do celular
- nao criar uma quinta aba so para proprietarios
- nao dividir o salvamento em um envio por aba
- nao mudar o significado dos campos nem o payload
- nao alterar `CreateVenueForm`
- nao mexer em orcamento, proposta, formulario publico ou apresentacao do espaco
- nao ler nem versionar valores de `.env`

## Perguntas em aberto

- Nenhuma. Sao quatro abas, nesta ordem e com estes campos. O visual copia Relatorios. O salvamento continua unico, e erro de validacao abre a aba do primeiro campo invalido.

## Prioridade sugerida

Media. A tela funciona; a divisao so encurta o formulario.

## Faixa sugerida para task workflow

- `B` = executar com `tasking/task-workflow-prompt-normal.md`

## Candidato a spec

- `nao`
- motivo: uma tela, um formulario, quatro grupos ja definidos. Nao ha contrato novo, schema nem segunda jornada. Vira spec se o salvamento deixar de ser unico ou se o formulario de criar espaco entrar no mesmo trabalho.

## Sugestao de slug da spec

- nao se aplica

## Sugestao de nome do arquivo

- `abas-configuracoes-espaco-request.md`

## Operacao

- tipo: `task-request`
- faixa: `B`
- candidato a spec: `nao`
- execucao recomendada: `normal`
- proximo passo: `revisar`
- promovida para: `nao se aplica`
- entrada publica recomendada: `fw:run`
- derivacao repo-local: `nao se aplica`
