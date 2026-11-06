# Regras de Negócio — EventHub

**Objetivo:** Centralizar todas as regras de negócio do sistema EventHub em linguagem comportamental. Este documento é a fonte da verdade sobre o que o sistema deve ou não fazer, sem descrever estrutura de banco, implementação técnica ou código.

**Fontes:** [DOMAIN_MODEL.md](./DOMAIN_MODEL.md), [DATA_MODEL_EXPLAINED.md](./DATA_MODEL_EXPLAINED.md), [API_CONTRACTS.md](./API_CONTRACTS.md), [AUTHORIZATION_MODEL.md](./AUTHORIZATION_MODEL.md), [KNOWN_LIMITATIONS.md](../estado/integracao/KNOWN_LIMITATIONS.md), [INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md](../estado/integracao/INTEGRACAO_FRONT_BACK_ANALISE_ATUAL.md).

---

## 1. Princípios Gerais

- **Identificação única:** Organização tem nome único no sistema. Venue tem nome único. Usuário tem e-mail único.
- **Vínculos únicos:** Um mesmo usuário não pode estar vinculado mais de uma vez à mesma organização. Um mesmo par (vínculo usuário–organização, venue) não pode ter mais de uma permissão de venue; cada vínculo usuário–organização tem no máximo uma permissão de organização.
- **Escopo de dados:** Dados de um venue pertencem à organização desse venue. Dados de uma proposta pertencem ao venue da proposta. Acesso a dados deve respeitar esse escopo.
- **Convenções não fixas:** O sistema não define oficialmente convenção única para valores monetários (casas decimais, moeda) nem para fuso horário nas datas; o comportamento deve ser consistente dentro de cada fluxo.
- **Sem máquina de estados oficial:** O ciclo de vida da proposta (rascunho → enviada → aprovada/rejeitada → paga) é inferido de campos (approved, termsAccepted, paid, amountPaid); não existe enum oficial de status nem transições centralizadas.

---

## 2. Organização

### Criação

- Qualquer usuário autenticado pode criar organização.
- Organização deve ter nome único no sistema.
- Uso típico assume pelo menos um venue por organização (não é regra enforced).

### Permissões

- Usuários acessam a organização mediante vínculo (UserOrganization).
- Cada vínculo usuário–organização possui no máximo uma permissão de organização (role e lista de permissões).
- Permissões na organização (ex.: ver venues, donos, site, contratos, permissões, informações) são definidas no frontend; o backend não valida por rota essas permissões — apenas exige ou não token.

### Exclusão

- Organização pode ser excluída por quem tiver permissão de uso da rota (hoje: usuário autenticado). Efeito sobre venues, propostas e demais entidades vinculadas segue o que estiver definido na aplicação (ex.: cascata).

### Escopo de dados

- Dados da organização (informações, site, contratos, cláusulas, anexos, imagens/textos) pertencem à organização. Venues, propostas e donos estão no escopo da organização a que o venue pertence.

---

## 3. Usuário

### Pertencimento à organização

- Usuário acessa o sistema de organizações apenas através de vínculos (UserOrganization). Um usuário pode pertencer a mais de uma organização.
- O par (usuário, organização) é único: não pode haver dois vínculos iguais.

### Permissões

- Dentro da organização, o usuário pode ter permissões de organização (uma por vínculo) e, por venue, permissões de venue (uma por par vínculo usuário–organização e venue).
- Permissões de venue cobrem visualização e edição de áreas (informações, preços, eventos, calendário, contatos, serviços, despesas, propostas, notificações, configuração, nova proposta, etc.) e de proposta (informações, datas, histórico, contato, pagamento, documentos, escala, lista de presença, envio). Quem pode fazer cada ação é restrito no frontend por essas permissões; o backend não valida essas strings por recurso.

### Limitações

- Usuário não pode ter mais de uma sessão/permissão de organização por vínculo usuário–organização.
- Usuário não pode ter mais de uma permissão de venue para o mesmo par (vínculo usuário–organização, venue).

---

## 4. Venue

### Criação

- Venue só existe vinculado a uma organização (organizationId obrigatório).
- Nome do venue deve ser único.
- Criação de venue exige usuário autenticado; modelo de preço e preços (por pessoa, por dia, por faixa, etc.) devem seguir o modelo configurado para o venue.

### Associação à organização

- Todo venue pertence a uma única organização. Dados do venue (serviços, despesas, metas, contatos, taxas sazonais, notificações, FAQ, configuração de e-mail, imagens e textos de site) estão no escopo dessa organização.

### Visibilidade

- Dados públicos do venue (para site/landing) podem ser consultados sem autenticação.
- Listagem de venues, atualização, exclusão e análises exigem autenticação; a listagem pode ser filtrada por organização e nome. O usuário pode ter acesso apenas aos venues para os quais possui permissão (lista de venues permitidos).

---

## 5. Proposal (Orçamento)

### Criação

- Proposta é sempre vinculada a um venue (venueId obrigatório).
- Existem fluxos por pessoa e por dia; datas de início e fim devem ser coerentes (início não posterior ao fim); totais e preço base devem ser coerentes com as regras do fluxo e capacidade (ex.: máximo de convidados). Essas validações estão nos use cases, não em um único lugar centralizado.
- Criação de proposta pode ser feita sem autenticação (fluxo público para o cliente preencher).

### Status permitidos

- Não há enum oficial de status. O estado é inferido de campos: aprovada (approved), termos aceitos (termsAccepted), paga (paid), valor pago (amountPaid), contato (contact). Transições entre rascunho, enviada, aprovada/rejeitada e paga (parcial/total) não são centralizadas.

### Alterações

- Atualização de proposta por pessoa ou por dia exige autenticação.
- Atualização de dados pessoais da proposta pode ser permitida sem autenticação (fluxo do cliente).
- Alterações devem manter consistência entre total, valor pago e pagamentos registrados.

### Cancelamento

- Exclusão de proposta exige autenticação. Comportamento sobre eventos na agenda, pagamentos e documentos vinculados segue o que a aplicação definir (ex.: remoção em cascata).

### Pagamento

- Proposta pode ter vários pagamentos. O valor total pago na proposta deve refletir a soma dos pagamentos (amountPaid e paid conforme regras da aplicação).

### Associação a eventos e pessoas

- Proposta pode ter pessoas (convidados ou trabalhadores) e eventos na agenda (DateEvent). Eventos na agenda do venue podem ou não estar vinculados a uma proposta (proposalId opcional). Pessoas e eventos estão no escopo da proposta.

### Permissões de visualização e edição

- Consulta de proposta por ID pode ser feita sem autenticação (visualização pública pelo cliente).
- Listar, atualizar e excluir propostas exigem autenticação. No frontend, visualização e edição são restritas por permissões de proposta (ver informações, datas, histórico, contato, pagamento, documentos, escala, lista de presença, envio). O backend não valida essas permissões por rota.

---

## 6. Pagamentos

### Pagamento parcial

- O sistema permite mais de um pagamento por proposta. O valor total pago na proposta pode ser menor ou igual ao total da proposta (pagamento parcial ou total).

### Atualização de status

- Pagamentos podem ser criados e atualizados (valor, data, método, comprovante). A proposta deve ter seu valor pago e indicador de “pago” atualizados de forma coerente com a soma dos pagamentos.

### Exclusão

- Um pagamento pode ser excluído. A exclusão deve refletir no valor pago e no status de pagamento da proposta (proposta não pode indicar valor pago maior que a soma dos pagamentos restantes).

### Consistência

- Cada pagamento está vinculado a uma proposta e a um venue (ambos obrigatórios). O valor do pagamento deve ser maior que zero (validação explícita não confirmada em todos os pontos). A soma dos valores dos pagamentos de uma proposta não deve exceder o que a aplicação considerar como total da proposta, e o valor pago na proposta deve ser consistente com essa soma.

---

## 7. Autorização

### Quem pode fazer o quê (regras funcionais)

- **Criar/editar/excluir organização:** usuário autenticado (backend exige token); no frontend, sujeito às permissões de organização.
- **Criar/editar/excluir venue:** usuário autenticado; no frontend, sujeito às permissões de venue (ex.: editar informações).
- **Listar venues:** usuário autenticado; o usuário vê apenas os venues para os quais tem permissão (lista de venues permitidos).
- **Ver dados públicos do venue ou da organização:** qualquer pessoa, sem autenticação.
- **Criar proposta:** pode ser feito sem autenticação (fluxo público).
- **Ver proposta por ID:** pode ser feito sem autenticação (visualização pelo cliente).
- **Listar, atualizar e excluir propostas:** usuário autenticado; no frontend, sujeito às permissões de proposta.
- **Criar/editar/excluir pagamentos, documentos, pessoas, eventos na agenda, escalas:** hoje o backend não exige token em todas essas rotas; o comportamento desejado é que apenas quem tem acesso ao venue/proposta possa realizar essas ações. No frontend, o fluxo normal exige usuário logado e permissões.
- **Gerenciar permissões de organização e de venue:** usuário autenticado; no frontend, sujeito às permissões de ver/gerir permissões.

### Lacuna atual

- O backend não identifica o usuário por rota (req.userId não é definido de forma confiável) e não valida permissões por recurso (VIEW_ORG_*, VIEW_VENUE_*, VIEW_PROPOSAL_*, etc.). Portanto, “quem pode” é efetivamente: para rotas com token, qualquer usuário autenticado; para rotas sem token, qualquer pessoa. A regra de negócio é que ações sobre dados restritos devem ser apenas de quem tem permissão sobre o recurso; a implementação ainda não garante isso no servidor.

---

## 8. Contratos

### Contratos — ordem das cláusulas

- Ao montar um contrato, a ordem de seleção das cláusulas define `position` (1, 2, 3…).
- A API deve retornar `clauses` ordenadas por `position` ascendente.
- O PDF do contrato numera cláusulas (I, II, III…) nessa mesma ordem.
- Cláusulas sem `position` aparecem por último.

---

## 9. Restrições Críticas

As seguintes situações **nunca** devem ser permitidas ou devem ser evitadas pelo sistema:

- **Organização com nome duplicado:** duas organizações não podem ter o mesmo nome.
- **Venue com nome duplicado:** dois venues não podem ter o mesmo nome.
- **Usuário vinculado duas vezes à mesma organização:** o par (usuário, organização) deve ser único.
- **Duas permissões de venue para o mesmo (vínculo usuário–organização, venue):** apenas uma permissão por esse par.
- **Duas permissões de organização para o mesmo vínculo usuário–organização:** apenas uma por vínculo.
- **Proposta sem venue:** toda proposta deve ter venue definido.
- **Pagamento sem proposta ou sem venue:** todo pagamento deve estar vinculado a uma proposta e a um venue.
- **Documento sem proposta:** todo documento deve estar vinculado a uma proposta (vínculo a pagamento é opcional).
- **Data de início da proposta posterior à data de fim:** início deve ser anterior ou igual ao fim.
- **Valor pago na proposta superior à soma dos pagamentos:** o valor pago registrado na proposta não pode ser maior que a soma dos valores dos pagamentos da proposta.
- **Serviço com nome duplicado no mesmo venue:** nome do serviço deve ser único por venue.
- **Dono duplicado no mesmo venue:** o par (dono, venue) deve ser único (OwnerVenue).

---

*Documento criado a partir da análise dos documentos listados nas fontes. Manter alinhado a DOMAIN_MODEL.md, API_CONTRACTS.md e AUTHORIZATION_MODEL.md quando houver mudanças de regra.*
