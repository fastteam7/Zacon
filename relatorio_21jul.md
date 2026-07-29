# Relatório de Configuração — 21 de Julho de 2026

## Resumo Executivo

Ambiente configurado para desenvolvimento front-end premium com foco em SEO técnico e GEO (Generative Engine Optimization). O projeto ZACON agora possui ferramentas especializadas para criar interfaces de alta qualidade, validar visualmente, consultar documentação atualizada e otimizar para motores de busca tradicionais e de IA.

---

## 1. MCPs Instalados

### 1.1 Context7 — Documentação Atualizada
**Status:** ✅ Ativo

**O que faz:**
- Fornece documentação atualizada de bibliotecas JavaScript/TypeScript
- Elimina "alucinações" de APIs que não existem ou estão deprecated
- Conecta-se a repositórios oficiais de documentação

**Quando usar:**
- Antes de usar qualquer API nova de React 19, Next.js 15 ou Tailwind 4
- Quando tiver dúvida sobre a sintaxe correta de uma função
- Para verificar se uma feature existe na versão atual da biblioteca

**Exemplos de comandos/prompts:**
```
"Consulte o Context7 para verificar como usar Server Actions no Next.js 15"

"Use o Context7 para encontrar a sintaxe correta de useFormStatus do React 19"

"Verifique no Context7 como configurar @apply no Tailwind 4"
```

---

### 1.2 Playwright — Validação Visual
**Status:** ✅ Ativo

**O que faz:**
- Controla um navegador real (Chromium)
- Captura screenshots de páginas
- Permite validar responsividade em diferentes viewports
- Pode interagir com elementos (cliques, formulários)

**Quando usar:**
- Após implementar qualquer interface nova
- Para validar que o design está conforme esperado
- Para testar responsividade em diferentes tamanhos de tela
- Para documentar o estado visual de uma feature

**Exemplos de comandos/prompts:**
```
"Abra http://localhost:3000 no Playwright e capture um screenshot da homepage"

"Use o Playwright para abrir a página de serviços em viewport mobile (375px) e capture screenshot"

"Valide visualmente se o hero da landing está com hierarquia tipográfica correta usando Playwright"

"Navegue até a seção de equipe e verifique se as imagens estão carregando corretamente"
```

---

### 1.3 Firecrawl — Scraping de Referências
**Status:** ⚠️ Ativo (requer API Key)

**O que faz:**
- Faz scraping de sites de referência
- Extrai estrutura HTML, CSS, hierarquia de conteúdo
- Permite estudar padrões de design de sites premium
- Não estoura contexto — processa e resume informações

**Quando usar:**
- Antes de implementar um padrão visual inspirado em outro site
- Para estudar como sites como Stripe, Linear, Vercel estruturam suas páginas
- Para extrair paleta de cores, tipografia, espaçamentos de referências

**Configuração pendente:**
```bash
# 1. Obter API Key em https://firecrawl.dev
# 2. Configurar variável de ambiente:
export FIRECRAWL_API_KEY="sua-api-key-aqui"

# Ou adicionar ao .env.local do projeto:
FIRECRAWL_API_KEY=sua-api-key-aqui
```

**Exemplos de comandos/prompts:**
```
"Use o Firecrawl para analisar a estrutura do hero da homepage da Stripe"

"Faça scraping da página de pricing da Linear e extraia a hierarquia de componentes"

"Analise com Firecrawl como o site da Vercel estrutura a navegação mobile"

"Estude a estrutura de FAQ do site da Apple usando Firecrawl"
```

---

### 1.4 Figma MCP — Extração de Design Tokens
**Status:** ❌ Pendente (requer Figma Desktop)

**O que faz:**
- Lê designs diretamente do Figma
- Extrai tokens de design (cores, tipografia, espaçamentos)
- Permite implementar designs com fidelidade pixel-perfect

**Configuração necessária:**
1. Abrir Figma Desktop
2. Ir em Preferences → Enable MCP Server
3. O MCP conectará automaticamente via HTTP local

**Quando estiver ativo, usar para:**
```
"Extraia os tokens de cor do arquivo Figma da ZACON"

"Leia as especificações de tipografia do componente Card no Figma"

"Importe os espaçamentos definidos no design system do Figma"
```

---

## 2. Skills Instaladas

### 2.1 /frontend-design — Design Intencional
**Status:** ✅ Ativo

**O que faz:**
- Estabelece framework de design antes de codar
- Identifica propósito, audiência e direção estética
- Evita padrões genéricos de IA (gradientes roxos, fontes system-ui genéricas)
- Propõe escolhas tipográficas, paletas e animações intencionais

**Quando usar:**
- **SEMPRE** antes de criar qualquer interface nova
- Antes de redesenhar uma seção existente
- Quando precisar definir a identidade visual de uma feature

**Exemplos de comandos/prompts:**
```
/frontend-design Criar uma landing page para escritório de contabilidade premium

/frontend-design Redesenhar a seção de serviços com estética minimalista e profissional

/frontend-design Hero section para homepage — deve transmitir confiança e modernidade

/frontend-design Página de equipe com cards de membros — estilo editorial, não corporativo genérico
```

**Fluxo recomendado:**
1. Rodar `/frontend-design` com descrição do que será criado
2. Receber proposta de design (tipografia, cores, layout, animações)
3. Aprovar ou ajustar direção
4. Implementar seguindo as especificações
5. Validar com Playwright

---

### 2.2 /feature-dev — Desenvolvimento Estruturado
**Status:** ✅ Ativo

**O que faz:**
- Guia desenvolvimento em 7 fases estruturadas
- Usa agentes especializados para cada fase
- Reduz erros e retrabalho
- Documenta decisões arquiteturais

**As 7 Fases:**
1. **Discovery:** Entender requisitos e contexto
2. **Codebase Exploration:** Mapear código existente relevante
3. **Clarifying Questions:** Resolver ambiguidades
4. **Architecture Design:** Propor abordagens com trade-offs
5. **Implementation:** Codar a feature
6. **Quality Review:** Revisar bugs, segurança, convenções
7. **Summary:** Documentar o que foi feito

**Quando usar:**
- Features que afetam múltiplos arquivos
- Funcionalidades com decisões arquiteturais
- Integrações complexas
- Qualquer coisa que não seja uma mudança trivial

**Exemplos de comandos/prompts:**
```
/feature-dev Implementar sistema de agendamento de consultas com calendário integrado

/feature-dev Adicionar autenticação de clientes com área restrita

/feature-dev Criar blog com CMS headless e otimização SEO

/feature-dev Implementar calculadora de tributos interativa para página de serviços

/feature-dev Adicionar animações de scroll cinematográficas na homepage usando GSAP
```

---

## 3. Como o CLAUDE.md se Conecta às Ferramentas

O arquivo `CLAUDE.md` na raiz do projeto serve como "manual de instruções" que o Claude Code lê automaticamente. Ele conecta as ferramentas no fluxo diário assim:

### Fluxo de Criação de Interface

```
┌─────────────────────────────────────────────────────────────┐
│  1. REQUISITOS                                               │
│     └── /feature-dev (se feature complexa)                  │
│         └── Fase Discovery + Clarifying Questions            │
├─────────────────────────────────────────────────────────────┤
│  2. DESIGN                                                   │
│     └── /frontend-design                                     │
│         └── Define tipografia, cores, layout, animações      │
├─────────────────────────────────────────────────────────────┤
│  3. REFERÊNCIAS (se aplicável)                               │
│     └── Firecrawl MCP                                        │
│         └── Estuda estrutura de sites de referência          │
├─────────────────────────────────────────────────────────────┤
│  4. DOCUMENTAÇÃO                                             │
│     └── Context7 MCP                                         │
│         └── Consulta APIs de React 19/Next.js 15/Tailwind 4 │
├─────────────────────────────────────────────────────────────┤
│  5. IMPLEMENTAÇÃO                                            │
│     └── Segue convenções do CLAUDE.md                        │
│         └── Server Components, shadcn/ui, SEO checklist      │
├─────────────────────────────────────────────────────────────┤
│  6. VALIDAÇÃO                                                │
│     └── Playwright MCP                                       │
│         └── Screenshot, verificação visual, responsividade   │
├─────────────────────────────────────────────────────────────┤
│  7. REVIEW (se /feature-dev ativo)                           │
│     └── Fase Quality Review                                  │
│         └── Bugs, segurança, convenções                      │
└─────────────────────────────────────────────────────────────┘
```

### Checklist de SEO (do CLAUDE.md)

O CLAUDE.md define um checklist obrigatório que deve ser seguido em toda página:

- JSON-LD com schema correto
- Meta tags completas
- Hierarquia de headings
- Imagens otimizadas
- HTML semântico

O Claude Code verifica automaticamente esses itens durante implementação.

### Orçamento de Performance (do CLAUDE.md)

| Métrica | Limite | Ferramenta de Verificação |
|---------|--------|---------------------------|
| LCP | < 2.5s | Lighthouse, Playwright |
| INP | < 200ms | Web Vitals |
| CLS | < 0.1 | Lighthouse |

---

## 4. Exemplos Práticos

### Criar uma Landing Premium

```
1. Iniciar com design:
   /frontend-design Landing page para ZACON — escritório de contabilidade consultiva.
   Público: empresários e empreendedores de SC. Transmitir: confiança, modernidade,
   expertise. Evitar: estética corporativa genérica, azul-marinho clichê.

2. Estudar referência (se houver):
   "Use Firecrawl para analisar a estrutura da homepage da Linear e extrair
   os padrões de hierarquia visual e animações de scroll"

3. Consultar documentação:
   "Consulte Context7 para verificar como implementar scroll-driven animations
   no React 19 com a nova API"

4. Implementar seguindo CLAUDE.md:
   - Server Components por padrão
   - shadcn/ui para componentes base
   - Motion para microinterações
   - JSON-LD de Organization
   - Meta tags completas

5. Validar visualmente:
   "Abra localhost:3000 no Playwright, capture screenshot do hero em
   1440px e 375px, verifique se a hierarquia tipográfica está clara"
```

### Validar Visual com Playwright

```
"Use o Playwright MCP para:
1. Abrir http://localhost:3000
2. Capturar screenshot em desktop (1440x900)
3. Capturar screenshot em tablet (768x1024)
4. Capturar screenshot em mobile (375x812)
5. Verificar se o CTA principal está visível above the fold em todos os viewports"
```

### Consultar Docs via Context7

```
"Antes de implementar, consulte o Context7 para:
1. Verificar a sintaxe atual de generateMetadata no Next.js 15
2. Confirmar como usar a diretiva 'use server' em Server Actions
3. Checar se useOptimistic existe no React 19 e como usar"
```

### Estudar Site de Referência com Firecrawl

```
"Use o Firecrawl para analisar https://stripe.com/br:
1. Extrair a estrutura do hero (elementos, hierarquia)
2. Identificar a paleta de cores usada
3. Mapear as animações de entrada dos elementos
4. Documentar o padrão de espaçamento entre seções"
```

### Rodar /feature-dev

```
/feature-dev Implementar área do cliente com:
- Login via magic link (email)
- Dashboard com documentos do cliente
- Upload de arquivos para contador
- Notificações de prazos fiscais
- Histórico de comunicações

Considerar: segurança de dados sensíveis, UX mobile-first,
integração futura com sistema contábil
```

---

## 5. Pendências de Configuração

### 5.1 Firecrawl API Key
**Prioridade:** Alta (se for usar scraping de referências)

**Passos:**
1. Acessar https://firecrawl.dev
2. Criar conta (tem tier gratuito)
3. Gerar API Key
4. Adicionar ao ambiente:
   ```bash
   # Terminal
   export FIRECRAWL_API_KEY="fc-xxxxxxxx"

   # Ou .env.local
   FIRECRAWL_API_KEY=fc-xxxxxxxx
   ```
5. Reiniciar Claude Code para carregar a variável

### 5.2 Figma Desktop MCP
**Prioridade:** Média (se usar designs no Figma)

**Passos:**
1. Abrir Figma Desktop (não funciona na versão web)
2. Menu → Preferences → Experimental Features
3. Habilitar "Enable MCP Server"
4. Reiniciar Figma Desktop
5. O Claude Code detectará automaticamente

### 5.3 Bibliotecas de Animação (não instaladas ainda)
**Prioridade:** Baixa (instalar quando necessário)

```bash
# GSAP + ScrollTrigger + Lenis (scroll cinematográfico)
npm install gsap @studio-freight/lenis

# Motion (microinterações)
npm install motion

# React Three Fiber + Drei (3D)
npm install @react-three/fiber @react-three/drei three
```

---

## 6. Checklist de Validação

- [x] Context7 MCP instalado e conectado
- [x] Playwright MCP instalado e conectado
- [x] Firecrawl MCP instalado (aguardando API key)
- [ ] Figma MCP (aguardando Figma Desktop)
- [x] Skill /frontend-design instalada
- [x] Skill /feature-dev instalada
- [x] CLAUDE.md criado com convenções
- [x] llms.txt criado para GEO
- [ ] Firecrawl API key configurada
- [ ] Bibliotecas de animação instaladas (quando necessário)

---

## 7. Próximos Passos Recomendados

1. **Configurar Firecrawl API Key** para habilitar scraping de referências
2. **Rodar `/frontend-design`** para definir identidade visual refinada da ZACON
3. **Usar Playwright** para capturar estado atual e identificar melhorias
4. **Implementar melhorias de SEO** seguindo checklist do CLAUDE.md
5. **Criar páginas faltantes** (serviços, contato, blog) usando o fluxo completo

---

*Relatório gerado em 21 de Julho de 2026*
