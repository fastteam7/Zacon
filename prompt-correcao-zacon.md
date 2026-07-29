# PROMPT — Correção completa do site zacon.com.br (Next.js)

Você é um engenheiro sênior especializado em Next.js (App Router), SEO técnico, GEO/AEO e conteúdo para SEO local. Vai trabalhar no repositório do site **zacon.com.br** — escritório de contabilidade em Ingleses, Florianópolis/SC. O site já usa SSR/SSG, JSON-LD e robots.txt corretos. Sua missão é corrigir os problemas abaixo, **nesta ordem de prioridade**, criando um commit separado por bloco. Antes de alterar qualquer coisa, mapeie a estrutura do projeto (`app/`, componentes, onde o metadata e o JSON-LD são gerados) e me mostre o plano de execução.

---

## BLOCO 1 — Bugs técnicos críticos (fazer primeiro)

### 1.1 Canonicals inconsistentes com o sitemap (9 URLs — 30% do site)
O sitemap.xml lista URLs no formato com barra (`/contabilidade/centro`, `/contabilidade/trindade`, `/contabilidade/canasvieiras`, `/contabilidade/jurere`, `/contabilidade-para/medicos`, `/contabilidade-para/advogados`, `/contabilidade-para/dentistas`, `/contabilidade-para/engenheiros`, `/contabilidade-para/clinicas`), mas as tags `<link rel="canonical">` dessas páginas apontam para versões com hífen (`/contabilidade-centro`, `/contabilidade-para-medicos` etc.).

- Localize onde o canonical é gerado (provavelmente em `generateMetadata` ou num componente compartilhado) e corrija para que **canonical = URL real da página = URL do sitemap**, sempre no formato com barra.
- Verifique se as URLs com hífen existem como rotas; se existirem, crie **redirect 301** delas para as versões canônicas em `next.config.js`.
- Ao final, rode um script que percorra todas as 30 URLs do sitemap e valide: status 200 + canonical idêntico à URL do sitemap. Me mostre o resultado.

### 1.2 H1 duplicado nos 10 artigos do blog
Cada post do blog renderiza dois `<h1>` idênticos (provavelmente um oculto no template). Encontre no template/layout do blog e deixe **um único `<h1>` por página**, rebaixando o duplicado para `<h2>` ou removendo-o.

### 1.3 Meta descriptions estouradas
Reescreva todas as meta descriptions para **150–160 caracteres**, mantendo palavra-chave principal + bairro/cidade + CTA. Prioridade:
- Home: hoje com 225 caracteres
- `/contabilidade/centro` (379), `/contabilidade/canasvieiras` (371), `/contabilidade/trindade` (364), `/contabilidade/jurere` (349)
- Depois valide todas as demais páginas e ajuste as que passarem de 160.

### 1.4 Schema AggregateRating ausente
A Zacon tem 4,9 estrelas com 28 avaliações no Google, mas isso não está marcado no site. Adicione `aggregateRating` (ratingValue 4.9, reviewCount 28) ao schema `LocalBusiness`/`AccountingService` da home, e avalie adicionar 2–3 blocos `Review` com depoimentos reais que eu vou fornecer (deixe o componente pronto com placeholders claramente marcados `[DEPOIMENTO_REAL_AQUI]` — nunca invente reviews).

### 1.5 Brotli
O servidor entrega apenas gzip. Verifique se a compressão é responsabilidade do nginx/CDN ou do Next. Se for configurável no projeto, habilite Brotli; se for infra, gere para mim o snippet de configuração nginx pronto para eu aplicar.

---

## BLOCO 2 — Imagens (hoje o site tem ZERO `<img>`)

- Crie a estrutura de imagens do site usando `next/image` com lazy loading, `alt` descritivo com palavra-chave local (ex.: "Equipe da Zacon Contabilidade em Ingleses, Florianópolis") e formatos WebP/AVIF.
- Pontos obrigatórios de inserção: foto da equipe e do escritório na home e em `/sobre`; foto/avatar de cada profissional; imagem de capa (OG image) em cada artigo do blog; certificado CRC digitalizado em `/sobre`.
- Eu vou fornecer as fotos reais. Enquanto isso, deixe os componentes prontos com placeholders nomeados (`/public/images/equipe.webp` etc.) e gere uma **lista de imagens necessárias com dimensões recomendadas** para eu produzir.
- Gere OG images dinâmicas (ou estáticas) para os posts do blog — hoje o Twitter Card é `summary_large_image` mas sem imagem real.

---

## BLOCO 3 — Conteúdo das páginas de serviço (thin content)

Padrão atual: 197–338 palavras por página de serviço. Meta: **800–1.200 palavras únicas** por página, sem enrolação, com estrutura fixa:

1. Resposta direta no primeiro parágrafo (formato AEO: responder em 2–3 frases "o que é / para quem / quanto custa em média / prazo") — isso é o que IAs generativas e featured snippets extraem.
2. H2 com dores específicas do público + como o serviço resolve
3. H2 "Como funciona" (passo a passo — manter/expandir o schema HowTo onde existir)
4. H2 com dados quantitativos verificáveis (prazos legais, alíquotas 2026, valores de referência, multas)
5. FAQ com 5–8 perguntas reais de busca + schema FAQPage (replicar em TODAS as páginas de serviço — hoje só algumas têm)
6. CTA + links internos contextuais para 2–3 páginas relacionadas com âncora rica

**Canibalização:** consolide `/servicos/departamento-pessoal` e `/servicos/folha-de-pagamento` em uma única página robusta "Departamento Pessoal e Folha de Pagamento em Florianópolis", com redirect 301 da página descontinuada e atualização do sitemap e dos links internos.

Aplique a mesma estrutura e profundidade às 4 páginas de bairro (hoje ~385–400 palavras genéricas): cada uma precisa de conteúdo realmente específico do bairro (perfil de empresas da região, como funciona o atendimento remoto/presencial a partir de Ingleses — sem alegar unidade física que não existe).

---

## BLOCO 4 — Blog: atualização e EEAT

- Atualize os 10 artigos: título e conteúdo de "2024" → **2026** (IR 2026, eSocial 2026, tabelas do Simples Nacional 2026 com dados corretos e verificados — se não tiver certeza de um valor legal/tributário, marque `[VERIFICAR]` em vez de inventar).
- Adicione `dateModified` real no schema BlogPosting e visível na página ("Atualizado em ...").
- **Autor humano:** troque a autoria genérica "ZACON Contabilidade" por **Jucélia Alves de Lima, Contadora — CRC/SC** no schema (`author` tipo `Person`) e visível no post, com mini-bio e link para página de biografia.
- Meta de profundidade: o artigo de abertura de empresa tem 558 palavras; o concorrente que rankeia (Imagem Contabilidade) tem 2.360. Expanda os artigos principais para **1.800–2.500 palavras** com tabelas, listas numeradas e dados concretos.
- Adicione links contextuais no corpo de cada artigo apontando para as páginas de serviço relacionadas (âncoras ricas, 3–5 por artigo).

---

## BLOCO 5 — Páginas novas (GEO/AEO/intenção comercial)

Crie, seguindo o mesmo padrão de metadata + schema do site:

1. **/quanto-custa-contador-florianopolis** — página com faixas de preço reais em tabela, metodologia transparente, schema FAQPage. Intenção comercial de alto valor hoje dominada por concorrentes. (Vou fornecer as faixas de preço da Zacon; deixe placeholders.)
2. **/simulador-simples-nacional** — calculadora interativa Simples Nacional x Lucro Presumido (client component), com tabelas 2026 e explicação indexável em SSR ao redor da ferramenta.
3. **/perguntas-frequentes** — hub central de FAQ (30+ perguntas organizadas por tema) consolidando e linkando os FAQs das páginas internas, com schema FAQPage.
4. **/glossario-contabil** — glossário de termos contábeis (formato que LLMs citam com frequência), com `DefinedTerm` schema.
5. Páginas de bairro adicionais: **/contabilidade/cachoeira-do-bom-jesus** e **/contabilidade/rio-vermelho** (norte da ilha, próximos a Ingleses), já no padrão de profundidade do Bloco 3.
6. **Páginas de biografia** para os 5 profissionais (Jucélia Alves de Lima, Luciane Moraes, Heloisa Pinheiro Ventura, Mario Torres, Adriano Schneider) com schema `Person`, credenciais e foto (placeholder).
7. Em `/sobre`: seção de história institucional incluindo, com sensibilidade, o fundador Jair Zanette (hoje só existe no schema, invisível ao usuário), + depoimentos de clientes (placeholders), número de clientes atendidos e selos/certificações.

Atualize sitemap.xml e navegação (menu/rodapé/home) para que **todas** as páginas — incluindo as de bairro e persona, hoje semi-órfãs — tenham links de entrada reais a partir do menu ou de seções da home, não dependendo só do sitemap.

---

## Regras gerais

- Nunca invente dados factuais (preços, avaliações, depoimentos, valores legais). Use placeholders `[FORNECER]`/`[VERIFICAR]` e me entregue ao final a lista consolidada de tudo que preciso fornecer ou validar.
- Todo conteúdo em português do Brasil, tom profissional e direto, sem clichês genéricos ("atendimento humanizado", "excelência") — priorize afirmações específicas e verificáveis, que é o que GEO/AEO exige.
- Mantenha o padrão de título "Serviço + Florianópolis | ZACON" e a hierarquia H1 único → H2 seções → H3 itens.
- Após cada bloco: rode build, valide schema (sem erros no formato JSON-LD), confira que nenhum canonical/sitemap quebrou, e me apresente um resumo do que foi alterado antes de seguir para o próximo bloco.

Comece pelo mapeamento do projeto e pelo plano do Bloco 1.
