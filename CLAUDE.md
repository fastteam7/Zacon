# CLAUDE.md — Convenções do Projeto ZACON

## Stack Tecnológica

- **Framework:** Next.js 15 (App Router)
- **React:** React 19
- **Linguagem:** TypeScript (strict mode)
- **Estilização:** Tailwind CSS 4
- **Renderização:** Server Components por padrão; Client Components apenas quando necessário (`"use client"`)

## Bibliotecas Padrão

> **IMPORTANTE:** Usar sempre estas bibliotecas. Não inventar alternativas.

| Categoria | Biblioteca |
|-----------|------------|
| Base UI | shadcn/ui + Radix UI |
| Componentes de Impacto Visual | Magic UI / Aceternity UI |
| Microinterações | Motion (ex-Framer Motion) |
| Scroll Cinematográfico | GSAP + ScrollTrigger + Lenis |
| 3D | React Three Fiber + Drei |
| Formulários | react-hook-form + zod |
| Ícones | Lucide React |

## Padrão de Design

### Referências de Qualidade
- **Stripe, Linear, Vercel, Apple** — hierarquia tipográfica forte, espaçamento generoso, microinterações sutis
- **Proibido:** gradientes genéricos de IA, layouts genéricos, cores saturadas sem propósito

### Fluxo Obrigatório para Interfaces
1. **ANTES de criar qualquer interface:** usar a skill `/frontend-design`
2. **APÓS implementar:** validar visualmente com Playwright MCP (abrir página, capturar screenshot, iterar)
3. **ANTES de usar APIs de React 19/Next.js 15/Tailwind 4:** consultar Context7 MCP

### Princípios Visuais
- Tipografia: hierarquia clara (display → heading → body → caption)
- Espaçamento: generoso, usar sistema de 8px
- Cores: paleta restrita, contraste acessível
- Animações: sutis, propositais, respeitar `prefers-reduced-motion`

## SEO Técnico (Obrigatório em Toda Página)

### Checklist
- [ ] JSON-LD / Schema.org adequado ao tipo de página:
  - `Organization` (página institucional)
  - `LocalBusiness` (página de contato/localização)
  - `Service` (páginas de serviços)
  - `FAQPage` (páginas com FAQ)
  - `BreadcrumbList` (navegação estruturada)
  - `Article` (blog posts)
- [ ] Meta tags completas:
  - `title` (50-60 caracteres)
  - `description` (150-160 caracteres)
  - `canonical`
  - Open Graph (`og:title`, `og:description`, `og:image`, `og:url`)
  - Twitter Cards (`twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`)
- [ ] `sitemap.xml` gerado via convenções do Next.js (`app/sitemap.ts`)
- [ ] `robots.txt` via Next.js (`app/robots.ts`)
- [ ] Hierarquia de headings correta: **um h1 por página**, sequência lógica (h1 → h2 → h3)
- [ ] HTML semântico: `<header>`, `<main>`, `<nav>`, `<article>`, `<section>`, `<footer>`
- [ ] Imagens: `next/image`, alt descritivo, dimensões explícitas (`width`, `height`)

## GEO (Generative Engine Optimization)

Para otimização em motores de IA (ChatGPT, Perplexity, Claude):

- [ ] Manter `llms.txt` na raiz pública descrevendo o site para crawlers de IA
- [ ] FAQs estruturadas com schema `FAQPage` nas páginas-chave
- [ ] Conteúdo em blocos autocontidos e semânticos (fácil de citar por LLMs)
- [ ] Permitir crawlers de IA relevantes no `robots.txt`:
  ```
  User-agent: GPTBot
  Allow: /

  User-agent: Claude-Web
  Allow: /

  User-agent: PerplexityBot
  Allow: /
  ```

## Performance (Orçamento Obrigatório)

| Métrica | Limite |
|---------|--------|
| LCP (Largest Contentful Paint) | < 2.5s |
| INP (Interaction to Next Paint) | < 200ms |
| CLS (Cumulative Layout Shift) | < 0.1 |

### Práticas Obrigatórias
- Code splitting automático do Next.js
- Lazy loading de componentes pesados:
  ```tsx
  const Heavy3D = dynamic(() => import('./Heavy3D'), {
    ssr: false,
    loading: () => <Skeleton />
  })
  ```
- Componentes 3D e vídeo: **SEMPRE lazy**
- Analisar bundle antes de adicionar dependências novas:
  ```bash
  npx @next/bundle-analyzer
  ```

## Acessibilidade (WCAG 2.2 AA)

- [ ] Contraste de cores: mínimo 4.5:1 (texto normal), 3:1 (texto grande)
- [ ] Focus states visíveis em todos os elementos interativos
- [ ] Navegação completa por teclado
- [ ] Skip links para conteúdo principal
- [ ] Labels em todos os inputs
- [ ] Respeitar `prefers-reduced-motion`:
  ```tsx
  // GSAP
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    gsap.globalTimeline.timeScale(0)
  }

  // Motion
  <motion.div
    initial={shouldReduceMotion ? false : { opacity: 0 }}
    animate={{ opacity: 1 }}
  />
  ```

## Fluxo de Trabalho

### Features Não Triviais
1. **Iniciar com:** `/feature-dev`
   - Segue 7 fases: Requisitos → Exploração → Arquitetura → Implementação → Testes → Review → Docs

### Replicar Padrão de Site de Referência
1. **Usar Firecrawl MCP** para estudar a estrutura antes de implementar
2. Extrair: hierarquia, espaçamentos, tipografia, cores, animações
3. Adaptar ao contexto da ZACON (não copiar literalmente)

### Consulta de Documentação
1. **Usar Context7 MCP** antes de usar qualquer API nova
2. Evita alucinações e APIs deprecated

### Validação Visual
1. **Usar Playwright MCP** para capturar screenshots
2. Comparar com referências de design
3. Iterar até resultado premium

## MCPs Configurados

### Context7 (Ativo)
Documentação atualizada de bibliotecas. Elimina APIs alucinadas.
```
Uso: Consultar antes de usar APIs de React 19, Next.js 15, Tailwind 4
```

### Playwright (Ativo)
Navegador real para validação visual.
```
Uso: Abrir páginas, capturar screenshots, validar responsividade
```

### Firecrawl (Ativo - Requer API Key)
Scraping para estudar sites de referência.
```
Configurar: export FIRECRAWL_API_KEY="sua-api-key"
Obter key: https://firecrawl.dev
```

### Figma MCP (Pendente)
Leitura de designs e extração de tokens.
```
Requisito: Figma Desktop rodando com Dev Mode MCP habilitado
Configuração: Figma Desktop → Preferences → Enable MCP Server
Transport: HTTP local na porta padrão do Figma
```

## Skills Instaladas

### /frontend-design
Design intencional, evita layouts genéricos de IA.
```
Uso: /frontend-design antes de criar qualquer interface nova
```

### /feature-dev
Fluxo de 7 fases para features complexas.
```
Uso: /feature-dev [descrição da feature]
Fases: Requisitos → Exploração → Arquitetura → Implementação → Testes → Review → Docs
```

## Estrutura de Pastas

```
ZaconF/
├── app/                    # App Router (Next.js 15)
│   ├── layout.tsx          # Layout raiz
│   ├── page.tsx            # Homepage
│   ├── sitemap.ts          # Sitemap dinâmico
│   ├── robots.ts           # Robots.txt
│   └── [rotas]/            # Rotas dinâmicas
├── components/
│   ├── ui/                 # shadcn/ui components
│   └── sections/           # Seções de página
├── lib/
│   └── utils.ts            # Utilitários (cn, etc.)
├── public/
│   ├── llms.txt            # Para crawlers de IA
│   └── team/               # Imagens da equipe
└── styles/
    └── globals.css         # Tailwind + custom CSS
```

## Comandos Úteis

```bash
# Desenvolvimento
npm run dev

# Build de produção
npm run build

# Análise de bundle
npx @next/bundle-analyzer

# Lint
npm run lint
```

## Pendências de Configuração

1. **Firecrawl API Key:** Obter em https://firecrawl.dev e configurar variável de ambiente
2. **Figma Desktop MCP:** Habilitar quando Figma Desktop estiver rodando
3. **llms.txt:** Criar arquivo público para GEO
