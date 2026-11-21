# Design

## Visao geral da solucao

Um bloco de endereco, com o CEP no topo, chama a base postal no navegador quando ha 8 digitos. O valor continua no react-hook-form de cada tela. O estado de "buscando" e o erro ficam no bloco. Numero e complemento a pessoa digita. ViaCEP primeiro; BrasilAPI uma vez se a primeira nao servir. Lista de cidades so como reserva.

## Passada transversal

- architecture: sim, na fronteira. O browser passa a chamar ViaCEP, BrasilAPI e IBGE. Nao ha servico nosso novo e nao ha ADR.
- database: nao. Nenhum campo novo. O formato do CEP e da UF muda so no valor que o formulario ja envia.
- design: sim. CEP primeiro, erro no campo, loading no proprio CEP, select so na reserva.
- observability: nao. Sem metrica nem alerta. O sinal e o erro no campo, sem registrar o CEP.
- security: sim. Endereco de cliente e proprietario e dado pessoal. Sai so o CEP de 8 digitos, ou a sigla da UF para listar municipios.
- patterns/06: sim, timeout e degradacao. A busca e GET, entao repetir nao duplica efeito. Uma reserva, sem fila de tentativas, porque a pessoa esta esperando o campo.

## Componentes e modulos impactados

- modulo puro novo em `eventhub-vista-dashboard/src/lib/`: montar a URL, ler a resposta, decidir o que preencher, normalizar CEP e UF
- bloco novo em `eventhub-vista-dashboard/src/components/address/`: campos, mascara, selects e a chamada
- painel: `CreateVenueForm.tsx` (nomes em `data.`), `VenueSettings.tsx`, `pf-contract-form.tsx`, `pj-contract-form.tsx`, `OwnerForm.tsx`
- publico: `PFContractPersonalInfoForm.tsx`, `PJContractPersonalInfoForm.tsx`, com o visual de `ContractPublicField.tsx`
- site da organizacao: `EditVenueForm.tsx`, so cidade e estado; o CEP fica no estado local do bloco

## Reuso previsto

- `Input` e `FormField` que os formularios ja usam. UF e cidade, na reserva, usam `select` nativo: a lista de municipios nao cabe no Select do painel, e o teste enxerga as opcoes
- `publicLabelClass` e `inputClassName` da superficie publica
- react-hook-form ja presente; sem Zustand e sem React Query para o CEP
- as 27 siglas numa constante do modulo; municipios sob demanda

## Contratos e dados

- ViaCEP: `GET https://viacep.com.br/ws/{cep}/json/`. Usar `logradouro`, `bairro`, `localidade`, `uf`. Ignorar `complemento`, `ibge`, `gia`, `ddd`, `siafi`. `erro: true` ou HTTP ruim e falha.
- BrasilAPI: `GET https://brasilapi.com.br/api/cep/v2/{cep}`. Usar `street`, `neighborhood`, `city`, `state`. Ignorar coordenadas.
- IBGE, so quando o select de cidade aparece: `GET https://servicodados.ibge.gov.br/api/v1/localidades/estados/{UF}/municipios`. Guardar a lista da UF em memoria enquanto a pagina estiver aberta.
- Timeout de 4 segundos por chamada. Troca de CEP aborta a chamada anterior.
- CEP no formulario: so digitos. A mascara `99999-999` e so visual. `inputMode` numerico e `autoComplete="postal-code"`.
- UF gravada pela busca ou pelo select: sigla maiuscula. Texto com mais de duas letras permanece ate a busca ou o select substituir.
- Mapa de nomes: proposta `adressComplement`; espaco e proprietario `complement`; criar espaco prefixo `data.`. O bloco recebe os nomes.
- `EditVenueForm`: CEP local, fora do `onSubmit`. `setValue` so em `city` e `state`.
- Ordem no bloco: CEP, logradouro e numero, complemento e bairro, cidade e UF.

## Falhas, casos de borda e invariantes

- Invariante: numero e complemento do formulario so mudam se a pessoa digitar.
- Invariante: resposta de um CEP nao escreve por cima de outro CEP ja digitado.
- Sucesso com rua ou bairro: esses campos e cidade/UF recebem o texto da base; o que a base nao trouxe na rua ou no bairro fica vazio. Widgets continuam input.
- Sucesso sem rua e sem bairro: rua e bairro ficam vazios; UF fica a sigla; cidade vira select do IBGE se o nome bater com um municipio. Sem bate, cidade fica texto com o nome da base.
- Falha total: nenhum campo de endereco e apagado. Erro: "Nao encontramos esse CEP. Confira os numeros ou preencha a cidade e o estado." UF vira select das 27. Cidade vira select do IBGE depois que ha uma sigla. Se o IBGE falhar, cidade volta a ser texto.
- Valor inicial "Sao Paulo" / "SP" nao marca a busca como feita.
- Busca em andamento mostra "Buscando CEP..." no CEP e nao trava o resto do formulario.

## Decisoes arquiteturais importantes

- Sem proxy no backend: o CEP nao e segredo e a API do EventHub nao precisa de rota nova.
- Sem retry em sequencia alem da BrasilAPI: a segunda espera ja chega a cerca de 8 segundos.
- Sem gravar codigo IBGE: o relatorio compara o nome, e coluna nova esta fora.
- Descartado: catalogo de ruas. Descartado: select de todas as cidades antes do CEP.
- Descartado: preencher complemento com o `complemento` da ViaCEP, que nao e apartamento nem sala.

## Riscos e mitigacoes

- CEP de cliente em servico de terceiro: a URL leva so os 8 digitos; teste garante que o restante do formulario nao entra na requisicao.
- Base devolve logradouro abreviado: o campo fica editavel.
- Dois CEPs seguidos: `AbortController` e a resposta so aplica se os digitos ainda forem os mesmos.

## Rollout, observabilidade e rollback

- Publicar o frontend. A API atual ja aceita os mesmos campos.
- Rollback: voltar os formularios aos inputs atuais. Nada de banco para desfazer.
- Sem dashboard. Falha aparece no CEP.

## Estrategia de validacao

- `T-01`: fetch injetado, sem rede. CEP cheio, CEP generico, ViaCEP com erro e BrasilAPI ok, as duas falhando, resposta atrasada, complemento da ViaCEP ignorado, URL so com o CEP.
- `T-02`: o bloco renderiza a ordem, o loading, o erro, os selects e nao trata o valor inicial de Sao Paulo como busca.
- `T-03` a `T-05`: cada tela usa o bloco e o payload de salvamento ja existente segue com CEP em digitos. `EditVenueForm` nao envia CEP.
- Browser, na ultima task de tela: digitar um CEP valido numa tela do painel e ver os quatro campos; o contrato publico entra se a pagina abrir sem login.

## Fontes

- `task-requests/preenchimento-endereco-por-cep-request.md`
- `topics/frontend-application.md#Cuidados`
- `topics/auth-and-security.md#Riscos confirmados`
- `framework_global/framework-libs/design/rules/06_forms_and_input_ux.md`
- `framework_global/framework-libs/design/rules/05_component_states_and_variants.md`
- `framework_global/framework-libs/patterns/rules/06_senior_engineering_concepts.md`
- `framework_global/framework-libs/security/index.md#Quando esta lib e obrigatoria`
