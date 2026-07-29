# Relatório de Auditoria Técnica de SEO - Zacon Contabilidade

**Data:** 2026-07-28
**Projeto:** Zacon Contabilidade
**URL:** https://zacon.com.br
**Stack:** Next.js 15 + React 19 + TypeScript

---

## 1. Problemas Encontrados

### 1.1 Rastreada, mas não indexada no momento (12 páginas)

| URL | Causa Raiz | Status |
|-----|------------|--------|
| `/opengraph-image` | Metadata route do Next.js sendo rastreada como página | ✅ Corrigido |
| `/apple-icon` | Metadata route do Next.js sendo rastreada como página | ✅ Corrigido |
| `/icon` | Metadata route do Next.js sendo rastreada como página | ✅ Corrigido |
| `/blog?q={search_term_string}` | SearchAction schema gerando URL de template | ✅ Corrigido |
| `/contabilidade-centro` | URL antiga (redirect 301 já existe para /contabilidade/centro) | ✅ Redirect funcional |
| `/contabilidade-canasvieiras` | URL antiga (redirect 301 já existe) | ✅ Redirect funcional |
| `/contabilidade/jurere` | Página dinâmica com conteúdo suficiente | ⏳ Aguardar reindexação |
| `/contabilidade-para-clinicas` | URL antiga (redirect 301 já existe para /contabilidade-para/clinicas) | ✅ Redirect funcional |
| `/contabilidade-para/clinicas` | Baixa autoridade/internal linking insuficiente | ✅ Corrigido (Footer) |
| `/blog/planejamento-tributario-como-pagar-menos-impostos` | Conteúdo de qualidade, aguardar crawl budget | ⏳ Aguardar |

### 1.2 Detectada, mas não indexada no momento (22 páginas)

| URL | Causa Raiz | Status |
|-----|------------|--------|
| `/blog` | Página lista, baixa prioridade do Google | ⏳ Normal para blogs |
| `/blog/*` (vários posts) | Conteúdo novo, aguardando crawl budget | ⏳ Normal |
| `/contabilidade-para/advogados` | Internal linking insuficiente | ✅ Corrigido (Footer) |
| `/contabilidade-para/dentistas` | Internal linking insuficiente | ✅ Corrigido (Footer) |
| `/contabilidade-para/engenheiros` | Internal linking insuficiente | ✅ Corrigido (Footer) |
| `/contabilidade-para/medicos` | Internal linking insuficiente | ✅ Corrigido (Footer) |
| `/contabilidade/centro` | Internal linking parcial | ✅ Corrigido (Footer) |
| `/contabilidade/trindade` | Não estava no Footer | ✅ Corrigido (Footer) |

---

## 2. Correções Implementadas

### 2.1 robots.ts - Bloqueio de Metadata Routes

**Arquivo:** `app/robots.ts`

**Problema:** O Google estava rastreando rotas de metadata do Next.js (`/opengraph-image`, `/apple-icon`, `/icon`, `/twitter-image`) como se fossem páginas comuns, resultando em "Rastreada, mas não indexada".

**Solução:** Adicionadas regras de `Disallow` para:
- `/opengraph-image*`
- `/twitter-image*`
- `/apple-icon*`
- `/icon*`
- `/*/opengraph-image*` (subpastas)
- `/*/twitter-image*` (subpastas)
- `/blog?*` (query strings de busca)

### 2.2 schema.ts - Remoção do SearchAction

**Arquivo:** `lib/schema.ts`

**Problema:** O `WebSiteSchema` incluía um `SearchAction` com URL template:
```javascript
urlTemplate: `${siteConfig.url}/blog?q={search_term_string}`
```
O Google interpretou isso como uma página real e tentou indexar `/blog?q={search_term_string}`.

**Solução:** Removido o `SearchAction` do schema, já que não existe funcionalidade de busca implementada no blog. Adicionado comentário explicativo para futura implementação.

### 2.3 schema.ts - Remoção de Reviews com Placeholders

**Arquivo:** `lib/schema.ts`

**Problema:** O `OrganizationSchema` continha reviews com placeholders:
```javascript
name: "[FORNECER_NOME_CLIENTE_1]"
reviewBody: "[FORNECER_DEPOIMENTO_REAL_1]"
```
Placeholders no schema podem prejudicar a confiança do Google no conteúdo.

**Solução:** Removidos os reviews temporariamente. Adicionado comentário com formato esperado para quando houver depoimentos reais.

### 2.4 next.config.js - Headers X-Robots-Tag

**Arquivo:** `next.config.js`

**Problema:** Mesmo com bloqueio no robots.txt, o Google pode rastrear URLs por outros meios (links, sitemaps de terceiros).

**Solução:** Adicionados headers HTTP `X-Robots-Tag: noindex, nofollow` para:
- `/opengraph-image*`
- `/twitter-image*`
- `/apple-icon*`
- `/icon*`
- `/:path*/opengraph-image*`
- `/:path*/twitter-image*`

### 2.5 Footer.tsx - Melhoria de Internal Linking

**Arquivo:** `app/_components/Footer.tsx`

**Problema:** Páginas de nichos (`/contabilidade-para/*`) e alguns bairros não tinham links no Footer, resultando em baixa autoridade interna.

**Solução:**
1. Adicionados todos os 5 nichos ao Footer:
   - Contabilidade para Médicos
   - Contabilidade para Advogados
   - Contabilidade para Dentistas
   - Contabilidade para Engenheiros
   - Contabilidade para Clínicas

2. Expandida a lista de bairros para incluir:
   - Trindade
   - Cachoeira do Bom Jesus

3. Criada nova seção "Especialidades" para destacar os nichos.

---

## 3. Arquivos Modificados

| Arquivo | Tipo de Modificação |
|---------|---------------------|
| `app/robots.ts` | Adicionadas regras de Disallow para metadata routes |
| `lib/schema.ts` | Removido SearchAction e reviews com placeholders |
| `next.config.js` | Adicionados headers X-Robots-Tag |
| `app/_components/Footer.tsx` | Expandido internal linking para nichos e bairros |

---

## 4. Pendências

### 4.1 Ações que não puderam ser automatizadas

| Item | Descrição | Responsável |
|------|-----------|-------------|
| Depoimentos reais | Adicionar reviews reais no `lib/schema.ts` quando disponíveis | Cliente |
| Google Search Console | Solicitar reindexação das páginas corrigidas | Cliente/SEO |
| Sitemap resubmit | Reenviar sitemap após deploy | Cliente/SEO |
| Verificação GSC | Adicionar código de verificação do Google em `lib/seo.ts` | Cliente |

### 4.2 URLs antigas ainda no índice

O Google ainda pode ter URLs antigas indexadas que agora redirecionam (301):
- `/contabilidade-centro` → `/contabilidade/centro`
- `/contabilidade-canasvieiras` → `/contabilidade/canasvieiras`
- `/contabilidade-para-clinicas` → `/contabilidade-para/clinicas`
- etc.

**Ação necessária:** Aguardar o Google processar os redirects 301. Isso pode levar de 2 a 8 semanas.

---

## 5. Configurações Manuais Necessárias

### 5.1 Google Search Console

1. **Solicitar indexação manual** para URLs prioritárias:
   - `/contabilidade-ingleses`
   - `/contabilidade/centro`
   - `/contabilidade/canasvieiras`
   - `/contabilidade-para/medicos`
   - `/blog` (página principal)

2. **Validar correções** de URLs problemáticas:
   - Ir em "Cobertura" → "Rastreada, mas não indexada"
   - Selecionar uma URL corrigida
   - Clicar em "Validar correção"

3. **Reenviar sitemap**:
   - Ir em "Sitemaps"
   - Excluir sitemap antigo (se houver)
   - Adicionar: `https://zacon.com.br/sitemap.xml`

### 5.2 Monitoramento pós-deploy

Verificar após 7 dias:
1. Se metadata routes ainda aparecem no GSC
2. Se novas páginas foram indexadas
3. Se redirects 301 estão consolidando autoridade

---

## 6. Plano de Ação Priorizado

### Alta Prioridade (Imediato após deploy)

| # | Ação | Impacto |
|---|------|---------|
| 1 | Deploy das correções | Base para todas as outras ações |
| 2 | Reenviar sitemap no GSC | Acelera reindexação |
| 3 | Solicitar indexação de `/contabilidade-ingleses` | Página mais importante para SEO local |
| 4 | Solicitar indexação de `/contabilidade/centro` | Segunda página mais importante |
| 5 | Validar correção de `/opengraph-image` no GSC | Confirma que Google entendeu a correção |

### Média Prioridade (Primeira semana)

| # | Ação | Impacto |
|---|------|---------|
| 6 | Solicitar indexação de páginas de nichos | Expande presença em buscas específicas |
| 7 | Solicitar indexação de posts do blog | Aumenta tráfego orgânico |
| 8 | Adicionar depoimentos reais ao schema | Melhora rich snippets |
| 9 | Verificar Core Web Vitals no GSC | Identifica problemas de performance |

### Baixa Prioridade (Próximas 2-4 semanas)

| # | Ação | Impacto |
|---|------|---------|
| 10 | Monitorar evolução de indexação | Acompanhamento contínuo |
| 11 | Criar mais conteúdo para páginas thin | Melhora qualidade percebida |
| 12 | Obter backlinks para páginas locais | Aumenta autoridade do domínio |

---

## 7. Estimativa de Impacto

### Indexação

| Métrica | Antes | Esperado (30 dias) | Esperado (90 dias) |
|---------|-------|--------------------|--------------------|
| Páginas indexadas | ~20 | ~35 | ~45 |
| URLs em "Rastreada, não indexada" | 12 | 3-5 | 0-2 |
| URLs em "Detectada, não indexada" | 22 | 10-12 | 5-8 |

### Posicionamento

| Termo | Posição Atual | Esperado (90 dias) |
|-------|---------------|-------------------|
| contabilidade ingleses | Top 10 | Top 5 |
| contabilidade florianópolis | Top 20 | Top 10 |
| contador florianópolis | Top 20 | Top 10 |
| abrir empresa florianópolis | Top 30 | Top 15 |

**Nota:** Estimativas baseadas na qualidade técnica do site e conteúdo. Resultados reais dependem de fatores externos (concorrência, backlinks, sazonalidade).

---

## 8. Próximos Passos

### Imediatamente após deploy

1. Acessar Google Search Console
2. Ir em "Sitemaps" → Reenviar `sitemap.xml`
3. Ir em "Inspeção de URL" → Testar URLs corrigidas
4. Solicitar indexação para páginas prioritárias

### Após 7 dias

1. Verificar "Cobertura" no GSC
2. Confirmar que metadata routes não aparecem mais
3. Verificar se novos posts estão sendo indexados

### Após 30 dias

1. Analisar relatório de desempenho no GSC
2. Comparar cliques e impressões
3. Ajustar estratégia conforme necessário

---

## Conclusão

A auditoria identificou problemas técnicos que estavam impedindo a indexação correta do site:

1. **Metadata routes do Next.js** sendo tratadas como páginas
2. **SearchAction com URL de template** sendo indexada
3. **Internal linking insuficiente** para páginas de nichos
4. **Placeholders no schema** prejudicando confiança

Todas as correções foram implementadas diretamente no código. Após o deploy, é essencial seguir o plano de ação no Google Search Console para acelerar a reindexação e maximizar os resultados das correções.

O site está tecnicamente otimizado seguindo as melhores práticas do Google Search Central e do Next.js 15.

---

*Relatório gerado automaticamente pela auditoria de SEO*
