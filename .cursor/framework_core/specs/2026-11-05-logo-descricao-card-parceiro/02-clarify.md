# Clarify — Logo, descricao e card vertical do parceiro

## Perguntas criticas

- A logo fica em storage privado com URL assinada? Nao. Ela aparece numa pagina publica, no mesmo papel da foto de servico.
- Esta spec fecha o buraco de auth das rotas de contato? Nao. Esse buraco ja esta em `topics/auth-and-security.md#Riscos confirmados` e fica de fora.

## Respostas confirmadas

- Logo e descricao sao opcionais. O pedido e o request dizem isso.
- A ordem do card e avatar, nome, descricao, redes.
- O preview fica no fim do formulario, acima de Cadastrar, e acompanha a digitacao.
- A funcao nao entra no preview nem no card publico. Continua no cadastro e no painel.
- O painel edita os mesmos campos no fornecedor.
- Trocar a logo deixa o contato com uma imagem so.

## Requisitos implicitos confirmados

- rede vazia nao vira icone; `indicationLinks` ja faz isso
- a pagina de indicacoes so lista parceiros daquele orcamento
- migration de producao e aditiva
- sem logo, sem descricao ou sem rede, o card nao quebra

## Premissas assumidas

- Limite da descricao: 400 caracteres depois do trim. Risco se estiver errado: o texto do card fica curto ou longo demais; mudar o numero nao muda o desenho.
- Sem logo, a inicial e a primeira letra do nome, em maiuscula. Sem nome, o circulo fica vazio. Risco: nome com emoji ou simbolo gera uma inicial estranha; aceitavel.
- Textos de espera do preview: "Seu nome" e "Descrição do serviço". No card publico esses textos nao aparecem.
- Titulo do bloco de preview: "Seu card".
- A logo gravada tem no maximo 512 px de largura, WebP. Risco: marca muito detalhada perde fino; 512 basta para um avatar.
- O preview navega ao clicar na rede, com a mesma URL do card publico, em nova aba. E-mail abre o cliente de e-mail. Campo vazio continua sem icone.
- Cliente que mandar `logoUrl` no JSON e ignorado, sem erro. Risco: um cliente antigo que esperasse gravar URL pronta nao consegue; nao ha esse cliente hoje.

## Perguntas de erro e borda ainda abertas

- Nenhuma que mude o recorte. Tamanho, tipos e limpeza da logo estao decididos no design.

## Itens bloqueantes

- Nenhum.

## O que pode seguir mesmo com lacunas

- `T-01` pode comecar. Auth das rotas de contato permanece como divida conhecida e nao entra nas tasks.
