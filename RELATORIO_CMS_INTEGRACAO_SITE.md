# RELATÓRIO TÉCNICO COMPLETO: ANÁLISE DO CMS E INTEGRAÇÃO COM SITE

**Data:** 2026-08-03
**Versão:** 1.0
**Branch Analisado:** login2.0
**Diretórios:** `/BackendFastTeam` e `/FrontendFastTeam`

---

## ÍNDICE

1. [Análise da Implementação do CMS](#1-análise-da-implementação-do-cms)
2. [Fluxo Esperado da Integração](#2-fluxo-esperado-da-integração)
3. [Por Que NÃO Está Funcionando - CAUSA RAIZ](#3-por-que-não-está-funcionando---causa-raiz)
4. [Auditoria Completa da Integração](#4-auditoria-completa-da-integração)
5. [Integração Site ↔ CMS](#5-integração-site--cms)
6. [Atualização em Tempo Real](#6-atualização-em-tempo-real)
7. [O Que Está Faltando](#7-o-que-está-faltando)
8. [Correções Necessárias](#8-correções-necessárias)
9. [Guia de Integração para Sites Externos](#9-guia-de-integração-para-sites-externos)

---

## 1. ANÁLISE DA IMPLEMENTAÇÃO DO CMS

### 1.1 Arquitetura Geral

O CMS do FastTeam foi implementado como um **Headless CMS multi-tenant** completo, seguindo arquitetura modular.

#### Estrutura de Diretórios - Backend

```
app/modules/cms/
├── __init__.py                          # Documentação do módulo
├── controllers/
│   ├── cms_controller.py                # API interna (JWT autenticada)
│   ├── public_api_controller.py         # API pública (API Key)
│   └── __init__.py
├── models/
│   ├── page.py                          # Páginas institucionais
│   ├── post.py                          # Posts/artigos do blog
│   ├── category.py                      # Categorias hierárquicas
│   ├── tag.py                           # Tags para posts
│   ├── author.py                        # Autores de conteúdo
│   ├── media.py                         # Mídia (imagens, vídeos, docs)
│   ├── revision.py                      # Versionamento de conteúdo
│   ├── redirect.py                      # Redirecionamentos de URL
│   └── __init__.py
├── services/
│   ├── page_service.py                  # Lógica de páginas
│   ├── post_service.py                  # Lógica de posts
│   ├── category_service.py              # Lógica de categorias
│   ├── tag_service.py                   # Lógica de tags
│   ├── author_service.py                # Lógica de autores
│   ├── media_service.py                 # Upload e gerenciamento
│   ├── revision_service.py              # Versionamento
│   ├── redirect_service.py              # Redirecionamentos
│   ├── seo_service.py                   # Análise SEO (Yoast-like)
│   ├── slug_service.py                  # Geração de slugs
│   ├── ai_content_service.py            # Geração com IA
│   └── __init__.py
└── tasks/
    ├── cms_tasks.py                     # Tarefas Celery assíncronas
    └── __init__.py
```

#### Estrutura de Diretórios - Frontend

```
src/components/CMS/
├── CMS.js (componente principal - hub)
├── CMS.css
├── PageEditor/
│   ├── PageEditor.jsx
│   └── PageEditor.css
├── PostEditor/
│   ├── PostEditor.jsx
│   └── PostEditor.css
├── Editor/
│   ├── TipTapEditor.jsx (editor rico baseado em Tiptap v3.29.2)
│   ├── MenuBar.jsx (barra de ferramentas)
│   ├── SlashMenu.jsx (menu "/" para comandos)
│   ├── AutoSaveIndicator.jsx
│   └── extensions/ (20+ extensões customizadas)
├── Media/
│   ├── MediaLibrary.jsx
│   ├── MediaPicker.jsx
│   └── MediaUploader.jsx
├── SEO/
│   └── SeoPanel.jsx (análise de SEO)
├── Preview/
│   └── PreviewPanel.jsx
├── AI/
│   └── AIGenerateButton.jsx
├── Revisions/
│   └── RevisionHistory.jsx
└── components/
    ├── AuthorModal.jsx
    ├── CategoryModal.jsx
    └── TagModal.jsx
```

### 1.2 Models (Modelos de Dados)

#### CMSPage - Páginas Institucionais
- **Campos básicos:** id, workspace_id, title, slug, content (TipTap JSON), excerpt
- **Status:** draft, pending_review, scheduled, published, archived
- **Tipos:** page, landing, contact, about, services
- **SEO completo:** seo_title, seo_description, seo_keywords, focus_keyword
- **Open Graph:** og_title, og_description, og_image_id
- **Twitter Card:** twitter_card, twitter_title, twitter_description, twitter_image_id
- **Schema.org:** schema_type, schema_data, schema_markup (JSON-LD)
- **Sitemap:** sitemap_priority (0.0-1.0), sitemap_frequency, exclude_from_sitemap
- **Hierarquia:** parent_id, menu_order, template
- **Customização:** custom_css, custom_js, custom_fields (JSONB)
- **Tracking:** view_count, reading_time
- **Soft delete:** is_deleted, deleted_at

#### CMSPost - Posts/Artigos
- Herda todos os campos de SEO e Sitemap de CMSPage
- **Campos adicionais:** category_id, author_id, is_featured, is_sticky, allow_comments
- **Relacionamentos:** tags (many-to-many), related_posts, related_services

#### CMSCategory - Categorias Hierárquicas
- **Hierarquia:** parent_id, level, path (materializado)
- **Visual:** color, icon, featured_image_id
- **SEO:** seo_title, seo_description

#### CMSTag - Tags
- Campos: name, slug, description, color
- Relacionamento many-to-many com posts via `cms_post_tags`

#### CMSAuthor - Autores
- Link opcional com User do sistema
- Redes sociais: social_links (JSONB)
- Avatar customizado

#### CMSMedia - Arquivos
- Tipos: image, video, document, audio
- Metadados extraídos: dimensões, duração, EXIF
- Armazenamento: `/uploads/cms/{workspace_id}/{year}/{month}/{uuid}.{ext}`

#### CMSRevision - Versionamento
- Snapshot completo de cada alteração
- Tipos: created, updated, published, reverted

#### CMSRedirect - Redirecionamentos
- Tipos: 301 (permanente), 302 (temporário)
- Hit tracking: hit_count, last_hit_at

### 1.3 Migrations Criadas

**cms001_add_cms_tables.py:**
- Adiciona `is_active` e `cms_api_key` ao Workspace
- Cria todas as tabelas do CMS com índices

**cms002_add_cms_module_access.py:**
- Adiciona 'CMS' ao enum `modulenameenum`
- Cria registros de ModuleAccess para todos os workspaces

### 1.4 API Interna (Autenticada com JWT)

**Prefix:** `/api/cms`

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | /pages | Criar página |
| GET | /pages | Listar páginas |
| GET | /pages/:id | Obter página |
| PUT | /pages/:id | Atualizar página |
| DELETE | /pages/:id | Deletar página |
| POST | /pages/:id/publish | Publicar |
| POST | /pages/:id/duplicate | Duplicar |
| POST | /posts | Criar post |
| GET | /posts | Listar posts |
| GET | /posts/:id | Obter post |
| PUT | /posts/:id | Atualizar post |
| DELETE | /posts/:id | Deletar post |
| POST | /posts/:id/publish | Publicar |
| GET | /categories | Listar categorias |
| POST | /categories | Criar categoria |
| PUT | /categories/:id | Atualizar categoria |
| DELETE | /categories/:id | Deletar categoria |
| GET | /tags | Listar tags |
| POST | /tags | Criar tag |
| DELETE | /tags/:id | Deletar tag |
| GET | /authors | Listar autores |
| POST | /authors | Criar autor |
| PUT | /authors/:id | Atualizar autor |
| DELETE | /authors/:id | Deletar autor |
| POST | /media | Upload de arquivo |
| GET | /media | Listar mídia |
| PUT | /media/:id | Atualizar metadados |
| DELETE | /media/:id | Deletar mídia |
| GET | /revisions/:type/:id | Listar revisões |
| POST | /revisions/:id/restore | Restaurar revisão |
| POST | /redirects | Criar redirect |
| GET | /redirects | Listar redirects |
| PUT | /redirects/:id | Atualizar redirect |
| DELETE | /redirects/:id | Deletar redirect |
| POST | /seo/score | Calcular score SEO |
| GET | /ai/status | Status da IA |
| POST | /ai/generate/article | Gerar artigo |
| POST | /ai/generate/page | Gerar página |
| POST | /ai/improve | Melhorar texto |
| POST | /ai/generate/meta | Gerar meta tags |

### 1.5 API Pública (Autenticada com API Key)

**Prefix:** `/api/v1/cms`
**Autenticação:** Header `X-API-Key`

| Método | Endpoint | Descrição | Cache |
|--------|----------|-----------|-------|
| GET | /pages | Listar páginas publicadas | 5 min |
| GET | /pages/:slug | Obter página por slug | 5 min |
| GET | /posts | Listar posts publicados | 5 min |
| GET | /posts/:slug | Obter post por slug | 5 min |
| GET | /categories | Listar categorias | 10 min |
| GET | /categories/:slug | Categoria com posts | 5 min |
| GET | /tags | Listar tags | 10 min |
| GET | /tags/:slug | Tag com posts | 5 min |
| GET | /authors | Listar autores | 10 min |
| GET | /authors/:slug | Autor com posts | 5 min |
| GET | /sitemap | Dados do sitemap | 1 hora |

---

## 2. FLUXO ESPERADO DA INTEGRAÇÃO

### 2.1 Fluxo Ideal (Não Implementado Completamente)

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUXO ESPERADO                          │
└─────────────────────────────────────────────────────────────────┘

     ┌──────────────┐
     │     CMS      │
     │ (Admin Panel)│
     └──────┬───────┘
            │
            ▼
┌────────────────────────┐
│   Salvar Conteúdo      │
│ (Página/Post/SEO/etc)  │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│   Evento Disparado     │  ← NÃO IMPLEMENTADO
│ content.published      │
│ content.updated        │
│ content.deleted        │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│  Integração do Site    │  ← NÃO EXISTE
│ (Provider não criado)  │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│ Requisição HTTP/Webhook│  ← NÃO IMPLEMENTADO
│ POST → URL do Site     │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│   Site Recebe          │
│   Atualização          │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│   Revalidação          │
│ revalidatePath()       │
│ revalidateTag()        │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│ Atualização do Sitemap │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│ Atualização das        │
│ Páginas                │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│   SEO Atualizado       │
└────────────────────────┘
```

### 2.2 Fluxo Atual (Polling Manual)

```
┌──────────────┐          ┌──────────────┐
│     CMS      │          │     Site     │
│ (Admin Panel)│          │  (Next.js)   │
└──────┬───────┘          └──────┬───────┘
       │                         │
       │ 1. Publica              │
       │    conteúdo             │
       │                         │
       │                         │ 2. Site faz polling
       │                         │    periódico para
       │ ◄───────────────────────┤    buscar atualizações
       │    GET /api/v1/cms/*    │
       │                         │
       │ 3. Retorna              │
       │    dados ─────────────► │
       │                         │
       │                         │ 4. Renderiza
       │                         │    conteúdo
       │                         │
       │                         │ 5. NÃO há revalidação
       │                         │    automática
       │                         │
```

---

## 3. POR QUE NÃO ESTÁ FUNCIONANDO - CAUSA RAIZ

### 3.1 DIAGNÓSTICO DEFINITIVO

**A integração "SITE" não aparece na tela de Integrações porque:**

### ⚠️ O PROVIDER "SITE" NUNCA FOI CRIADO NO BANCO DE DADOS

Após análise completa do código e migrations, foi identificado que:

1. **Não existe migration que cria o provider "site"**
2. **Não existe seed que cria o provider "site"**
3. **Não existe comando CLI que cria o provider "site"**
4. **O código do provider "site" não foi implementado**

### 3.2 Evidências

#### Migration que cria providers (`cloudapi001_add_cloud_api_support.py`):

```python
# APENAS whatsapp_cloud_api é criado!
op.execute("""
    INSERT INTO integration_providers
    (key, name, category, default_label, description, icon_key, is_active, ...)
    VALUES (
        'whatsapp_cloud_api',
        'WhatsApp Cloud API (Oficial)',
        'messaging',
        ...
    )
""")
```

#### Serviço de Integrações (`integrations_service.py`):

```python
# Schemas de credenciais existentes - SEM "site"
CREDENTIAL_SCHEMAS: Dict[str, Type[BaseModel]] = {
    "whatsapp_evolution": EvolutionWhatsAppCredentials,
    "email_smtp": EmailSmtpCredentials,
}
```

#### Frontend - Mapeamento de ícones (`Integrations.js`):

```javascript
// Nenhum ícone "site" mapeado
const ICON_MAP = {
    whatsapp: FaWhatsapp,
    email: FaEnvelope,
    instagram: FaInstagram,
    other: FaPlug,
};
```

### 3.3 Cadeia de Falha

```
┌─────────────────────────────────────────────────────────────┐
│               CADEIA DE CAUSA RAIZ                          │
└─────────────────────────────────────────────────────────────┘

1. Tabela integration_providers NÃO tem registro "site"
                    │
                    ▼
2. GET /api/integrations/providers retorna lista SEM "site"
                    │
                    ▼
3. Frontend useIntegrations() recebe providers SEM "site"
                    │
                    ▼
4. Tela de Integrações renderiza APENAS providers recebidos
                    │
                    ▼
5. Integração "Site" NÃO APARECE na interface
                    │
                    ▼
6. Usuário NÃO consegue cadastrar URL do site
                    │
                    ▼
7. Webhooks NÃO podem ser configurados
                    │
                    ▼
8. Site NÃO recebe atualizações automáticas
```

### 3.4 O Que Foi Verificado

| Item | Status | Detalhes |
|------|--------|----------|
| Provider no banco | ❌ NÃO EXISTE | Nenhum registro com key="site" |
| Migration | ❌ NÃO EXISTE | Nenhuma migration cria provider site |
| Seed | ❌ NÃO EXISTE | Nenhum comando seed cria provider site |
| CLI command | ❌ NÃO EXISTE | `bootstrap-admin` e `seed-crm` não criam providers |
| Enum IntegrationProvider | ❌ NÃO INCLUI | Não há valor "site" no enum |
| Frontend filter | ✅ NÃO FILTRA | Frontend não esconde "site" (ele simplesmente não existe) |
| Feature flag | ✅ NÃO EXISTE | Não há feature flag bloqueando |
| Permissão | ✅ NÃO IMPEDE | Não há permissão específica que impede |
| Módulo desabilitado | ✅ NÃO | CMS está habilitado |
| Rota não criada | ✅ ROTAS OK | Rotas de providers funcionam |
| Componente React | ✅ OK | Renderiza providers corretamente |
| Backend error | ✅ NÃO | Nenhum erro no backend |

### 3.5 Providers que Existem vs. Que Deveriam Existir

| Provider | Status no DB | Status no Código |
|----------|--------------|------------------|
| whatsapp_cloud_api | ✅ Criado pela migration | ✅ Funcional |
| whatsapp_evolution | ❌ NÃO criado | ⚠️ Schema existe, mas sem registro |
| email_smtp | ❌ NÃO criado | ⚠️ Schema existe, mas sem registro |
| instagram | ❌ NÃO criado | ⚠️ Filtrado no frontend |
| **site** | ❌ NÃO EXISTE | ❌ NÃO IMPLEMENTADO |

---

## 4. AUDITORIA COMPLETA DA INTEGRAÇÃO

### 4.1 Backend

| Componente | Arquivo | Status |
|------------|---------|--------|
| Model IntegrationProvider | `app/modules/integrations/models/IntegrationProvider.py` | ✅ Existe |
| Model WorkspaceIntegration | `app/modules/integrations/models/WorkspaceIntegration.py` | ✅ Existe |
| Controller Integrations | `app/modules/integrations/controllers/integrations_controller.py` | ✅ Funcional |
| Service Integrations | `app/modules/integrations/services/integrations_service.py` | ⚠️ Sem "site" |
| Schema Credenciais Site | - | ❌ NÃO EXISTE |
| Webhook Service | - | ❌ NÃO IMPLEMENTADO |
| Event Dispatcher | - | ❌ NÃO IMPLEMENTADO |

### 4.2 Frontend

| Componente | Arquivo | Status |
|------------|---------|--------|
| Integrations.js | `src/components/Integrations/Integrations.js` | ✅ Funcional |
| useIntegrations hook | `src/hooks/useIntegrations.js` | ✅ Funcional |
| AddIntegrationModal | `src/components/Integrations/Modals/AddIntegrationModal.js` | ⚠️ Sem modal "site" |
| Site icon | - | ❌ NÃO MAPEADO |
| Site credentials form | - | ❌ NÃO EXISTE |

### 4.3 Banco de Dados

| Tabela | Status | Detalhes |
|--------|--------|----------|
| integration_providers | ✅ Existe | Apenas 1 registro (whatsapp_cloud_api) |
| workspace_integrations | ✅ Existe | Funcional |
| cms_webhooks | ❌ NÃO EXISTE | Tabela não foi criada |
| cms_webhook_events | ❌ NÃO EXISTE | Tabela não foi criada |

### 4.4 Migrations

| Migration | Status | O Que Faz |
|-----------|--------|-----------|
| cms001_add_cms_tables | ✅ Existe | Cria tabelas CMS |
| cms002_add_cms_module_access | ✅ Existe | Adiciona enum CMS |
| a835978628dd_add_integration_tables | ✅ Existe | Cria tabelas integrações (SEM seed) |
| cloudapi001_add_cloud_api_support | ✅ Existe | Cria APENAS whatsapp_cloud_api |
| **site_integration_add** | ❌ NÃO EXISTE | NÃO FOI CRIADA |

### 4.5 Enums

| Enum | Valor "site" | Status |
|------|--------------|--------|
| ModuleNameEnum | ✅ CMS existe | OK |
| IntegrationCategoryEnum | ❌ Sem "web" ou "site" | FALTANDO |

### 4.6 Serviços de Eventos

| Serviço | Status |
|---------|--------|
| Event Bus | ❌ NÃO IMPLEMENTADO |
| Webhook Dispatcher | ❌ NÃO IMPLEMENTADO |
| Queue Worker para Webhooks | ❌ NÃO IMPLEMENTADO |

### 4.7 Testes

| Tipo | Status |
|------|--------|
| Unit tests CMS | ❌ NÃO EXISTEM |
| Integration tests CMS | ❌ NÃO EXISTEM |
| E2E tests Integrations | ❌ NÃO EXISTEM |

---

## 5. INTEGRAÇÃO SITE ↔ CMS

### 5.1 Como DEVERIA Funcionar

#### Quando usuário CRIA uma página:

```
Backend CMS → Evento content.created → Webhook →
→ POST https://meusite.com/api/revalidate
  Headers:
    X-Webhook-Secret: "secret_configurado"
    Content-Type: application/json
  Body:
    {
      "event": "content.created",
      "type": "page",
      "id": "uuid-da-pagina",
      "slug": "/sobre-nos",
      "timestamp": "2026-08-03T10:30:00Z"
    }
```

#### Quando usuário ALTERA uma página:

```
Backend CMS → Evento content.updated → Webhook →
→ POST https://meusite.com/api/revalidate
  Body:
    {
      "event": "content.updated",
      "type": "page",
      "id": "uuid-da-pagina",
      "slug": "/sobre-nos",
      "changes": ["title", "content", "seo_description"],
      "timestamp": "2026-08-03T11:00:00Z"
    }
```

#### Quando usuário ALTERA SEO:

```
Backend CMS → Evento seo.updated → Webhook →
→ POST https://meusite.com/api/revalidate
  Body:
    {
      "event": "seo.updated",
      "type": "page",
      "id": "uuid-da-pagina",
      "slug": "/sobre-nos",
      "seo": {
        "title": "Novo Título SEO",
        "description": "Nova descrição",
        "keywords": ["palavra1", "palavra2"]
      },
      "timestamp": "2026-08-03T11:30:00Z"
    }
```

#### Quando usuário ALTERA slug:

```
Backend CMS → Eventos [redirect.created, content.updated] → Webhook →
→ POST https://meusite.com/api/revalidate
  Body:
    {
      "event": "slug.changed",
      "type": "page",
      "id": "uuid-da-pagina",
      "old_slug": "/sobre-nos",
      "new_slug": "/quem-somos",
      "redirect_created": true,
      "redirect_type": 301,
      "timestamp": "2026-08-03T12:00:00Z"
    }
```

#### Quando usuário PUBLICA um artigo:

```
Backend CMS → Evento content.published → Webhook →
→ POST https://meusite.com/api/revalidate
  Body:
    {
      "event": "content.published",
      "type": "post",
      "id": "uuid-do-post",
      "slug": "/blog/meu-artigo",
      "category": "tecnologia",
      "tags": ["tag1", "tag2"],
      "author": "joao-silva",
      "timestamp": "2026-08-03T14:00:00Z"
    }
```

#### Quando usuário REMOVE um artigo:

```
Backend CMS → Evento content.deleted → Webhook →
→ POST https://meusite.com/api/revalidate
  Body:
    {
      "event": "content.deleted",
      "type": "post",
      "id": "uuid-do-post",
      "slug": "/blog/meu-artigo",
      "timestamp": "2026-08-03T15:00:00Z"
    }
```

### 5.2 Especificação da Requisição Webhook

| Campo | Valor |
|-------|-------|
| **Endpoint** | URL configurada pelo usuário (ex: `https://meusite.com/api/revalidate`) |
| **Método HTTP** | POST |
| **Headers** | `X-Webhook-Secret`: Secret configurado pelo usuário |
| | `Content-Type`: application/json |
| | `X-CMS-Event`: Tipo do evento |
| | `X-CMS-Timestamp`: Timestamp ISO8601 |
| **Autenticação** | HMAC-SHA256 signature no header `X-Webhook-Signature` |
| **Timeout** | 30 segundos |
| **Retries** | 3 tentativas com backoff exponencial (1s, 5s, 30s) |

### 5.3 Payload Completo Esperado

```json
{
  "event": "content.published",
  "workspace_id": 1,
  "content": {
    "type": "post",
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "slug": "meu-artigo",
    "title": "Título do Artigo",
    "excerpt": "Resumo do artigo...",
    "status": "published",
    "published_at": "2026-08-03T14:00:00Z",
    "updated_at": "2026-08-03T14:00:00Z",
    "category": {
      "slug": "tecnologia",
      "name": "Tecnologia"
    },
    "tags": [
      {"slug": "nextjs", "name": "Next.js"},
      {"slug": "react", "name": "React"}
    ],
    "author": {
      "slug": "joao-silva",
      "name": "João Silva"
    },
    "seo": {
      "title": "Título SEO | Meu Site",
      "description": "Meta description do artigo",
      "og_image": "/api/cms/media/image.jpg"
    }
  },
  "paths_to_revalidate": [
    "/blog/meu-artigo",
    "/blog",
    "/blog/categoria/tecnologia",
    "/sitemap.xml"
  ],
  "tags_to_revalidate": [
    "post",
    "blog",
    "category-tecnologia",
    "sitemap"
  ],
  "timestamp": "2026-08-03T14:00:00Z"
}
```

### 5.4 Resposta Esperada do Site

```json
{
  "success": true,
  "revalidated": [
    "/blog/meu-artigo",
    "/blog",
    "/blog/categoria/tecnologia",
    "/sitemap.xml"
  ],
  "timestamp": "2026-08-03T14:00:05Z"
}
```

---

## 6. ATUALIZAÇÃO EM TEMPO REAL

### 6.1 Fluxo de Revalidação Next.js

```
┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
│   CMS       │     │  Webhook    │     │    Site         │
│ (FastTeam)  │────▶│  Delivery   │────▶│   (Next.js)     │
└─────────────┘     └─────────────┘     └────────┬────────┘
                                                  │
                                                  ▼
                                        ┌─────────────────┐
                                        │ API Route:      │
                                        │ /api/revalidate │
                                        └────────┬────────┘
                                                  │
                         ┌────────────────────────┼────────────────────────┐
                         │                        │                        │
                         ▼                        ▼                        ▼
               ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
               │ revalidatePath  │    │ revalidateTag   │    │ Regenerar       │
               │ ('/blog/slug')  │    │ ('blog-posts')  │    │ Sitemap         │
               └─────────────────┘    └─────────────────┘    └─────────────────┘
                         │                        │                        │
                         └────────────────────────┼────────────────────────┘
                                                  │
                                                  ▼
                                        ┌─────────────────┐
                                        │ Páginas         │
                                        │ Atualizadas!    │
                                        └─────────────────┘
```

### 6.2 Implementação Esperada no Site Next.js

```typescript
// app/api/revalidate/route.ts

import { revalidatePath, revalidateTag } from 'next/cache';
import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';

export async function POST(request: NextRequest) {
  // 1. Verificar secret
  const secret = request.headers.get('X-Webhook-Secret');
  if (secret !== process.env.CMS_WEBHOOK_SECRET) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // 2. Verificar signature (HMAC)
  const signature = request.headers.get('X-Webhook-Signature');
  const body = await request.text();
  const expectedSignature = crypto
    .createHmac('sha256', process.env.CMS_WEBHOOK_SECRET!)
    .update(body)
    .digest('hex');

  if (signature !== `sha256=${expectedSignature}`) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 401 });
  }

  // 3. Processar payload
  const payload = JSON.parse(body);
  const { event, content, paths_to_revalidate, tags_to_revalidate } = payload;

  // 4. Revalidar paths
  const revalidated: string[] = [];

  if (paths_to_revalidate) {
    for (const path of paths_to_revalidate) {
      revalidatePath(path);
      revalidated.push(path);
    }
  }

  // 5. Revalidar tags
  if (tags_to_revalidate) {
    for (const tag of tags_to_revalidate) {
      revalidateTag(tag);
    }
  }

  // 6. Regenerar sitemap se necessário
  if (event === 'content.published' || event === 'content.deleted') {
    revalidatePath('/sitemap.xml');
    revalidated.push('/sitemap.xml');
  }

  return NextResponse.json({
    success: true,
    revalidated,
    timestamp: new Date().toISOString()
  });
}
```

### 6.3 Regeneração do Sitemap

```typescript
// app/sitemap.ts

export default async function sitemap() {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL;

  // Buscar dados do CMS
  const response = await fetch(`${process.env.CMS_API_URL}/api/v1/cms/sitemap`, {
    headers: {
      'X-API-Key': process.env.CMS_API_KEY!,
    },
    next: {
      tags: ['sitemap'],
      revalidate: 3600 // 1 hora como fallback
    }
  });

  const { urls } = await response.json();

  return urls.map((url: any) => ({
    url: `${baseUrl}${url.loc}`,
    lastModified: url.lastmod,
    changeFrequency: url.changefreq,
    priority: parseFloat(url.priority),
  }));
}
```

---

## 7. O QUE ESTÁ FALTANDO

### 7.1 Backend

| Item | Prioridade | Descrição |
|------|------------|-----------|
| Migration provider "site" | 🔴 CRÍTICA | Criar migration que insere provider site no banco |
| Schema credenciais site | 🔴 CRÍTICA | Definir campos: webhook_url, secret |
| Webhook Service | 🔴 CRÍTICA | Implementar envio de webhooks |
| Event Dispatcher | 🟡 ALTA | Sistema de eventos para disparo de webhooks |
| Retry Logic | 🟡 ALTA | Lógica de retry com backoff exponencial |
| Webhook Log | 🟡 ALTA | Tabela para logging de tentativas |
| API Key Generation UI | 🟡 ALTA | Endpoint para gerar/regenerar API key |
| Rate Limiting API pública | 🟡 ALTA | Proteger API contra abuso |

### 7.2 Frontend

| Item | Prioridade | Descrição |
|------|------------|-----------|
| Ícone "site" em ICON_MAP | 🔴 CRÍTICA | Adicionar ícone para provider site |
| Modal de configuração Site | 🔴 CRÍTICA | Formulário para webhook_url e secret |
| Teste de conexão webhook | 🟡 ALTA | Botão para testar envio de webhook |
| Log de webhooks enviados | 🟡 ALTA | Visualização de histórico |
| Gerador de API Key | 🟡 ALTA | UI para gerar/copiar API key |

### 7.3 Banco de Dados

| Tabela | Prioridade | Descrição |
|--------|------------|-----------|
| Registro provider "site" | 🔴 CRÍTICA | INSERT em integration_providers |
| cms_webhooks | 🟡 ALTA | Configurações de webhook por workspace |
| cms_webhook_events | 🟡 ALTA | Log de envios |

### 7.4 API

| Endpoint | Prioridade | Descrição |
|----------|------------|-----------|
| POST /api/cms/api-key/generate | 🔴 CRÍTICA | Gerar nova API key |
| GET /api/cms/webhooks | 🟡 ALTA | Listar webhooks configurados |
| POST /api/cms/webhooks/test | 🟡 ALTA | Testar envio de webhook |
| GET /api/cms/webhooks/logs | 🟡 ALTA | Histórico de envios |

### 7.5 Eventos

| Evento | Prioridade | Trigger |
|--------|------------|---------|
| content.created | 🔴 CRÍTICA | Ao criar página/post |
| content.updated | 🔴 CRÍTICA | Ao atualizar página/post |
| content.published | 🔴 CRÍTICA | Ao publicar página/post |
| content.unpublished | 🔴 CRÍTICA | Ao despublicar |
| content.deleted | 🔴 CRÍTICA | Ao deletar |
| seo.updated | 🟡 ALTA | Ao alterar SEO |
| slug.changed | 🟡 ALTA | Ao alterar slug |
| media.uploaded | 🟢 MÉDIA | Ao fazer upload |

### 7.6 Site (Next.js)

| Item | Prioridade | Descrição |
|------|------------|-----------|
| API Route /api/revalidate | 🔴 CRÍTICA | Endpoint para receber webhooks |
| Verificação HMAC | 🔴 CRÍTICA | Segurança do webhook |
| Integração com fetch | 🟡 ALTA | Usar API pública do CMS |
| Tags de cache | 🟡 ALTA | Implementar tags para revalidação |
| Sitemap dinâmico | 🟡 ALTA | Usar endpoint /api/v1/cms/sitemap |

### 7.7 CMS (Admin Panel)

| Item | Prioridade | Descrição |
|------|------------|-----------|
| Tela de configuração do Site | 🔴 CRÍTICA | Formulário para URL e secret |
| Exibição da API Key | 🔴 CRÍTICA | Mostrar/copiar API key |
| Status de conexão | 🟡 ALTA | Indicador visual de webhook funcionando |
| Preview antes de publicar | 🟡 ALTA | Ver como ficará no site |

---

## 8. CORREÇÕES NECESSÁRIAS

### 8.1 Lista Priorizada

| # | Problema | Causa Raiz | Impacto | Arquivos | Como Corrigir | Dificuldade | Risco |
|---|----------|------------|---------|----------|---------------|-------------|-------|
| 1 | Provider "site" não existe | Nenhuma migration cria o provider | 🔴 CRÍTICO: Integração impossível | `migrations/versions/` | Criar migration que insere provider "site" | Baixa | Baixo |
| 2 | Schema de credenciais não existe | Código não foi implementado | 🔴 CRÍTICO: Não salva configurações | `app/modules/integrations/services/integrations_service.py` | Adicionar SiteCredentials ao CREDENTIAL_SCHEMAS | Baixa | Baixo |
| 3 | Ícone "site" não mapeado | Frontend não tem ícone | 🟡 ALTO: UI quebrada | `src/components/Integrations/Integrations.js` | Adicionar `site: FaGlobe` ao ICON_MAP | Muito Baixa | Muito Baixo |
| 4 | Modal de configuração site | UI não existe | 🟡 ALTO: Não configura URL | `src/components/Integrations/Modals/` | Criar SiteConfigModal.js | Média | Baixo |
| 5 | Webhook service não implementado | Código não existe | 🔴 CRÍTICO: Não envia notificações | `app/modules/cms/services/` | Criar webhook_service.py | Alta | Médio |
| 6 | Event dispatcher não existe | Sistema de eventos não implementado | 🔴 CRÍTICO: Webhooks não disparam | `app/modules/cms/` | Implementar sistema de eventos | Alta | Médio |
| 7 | Tabela cms_webhooks não existe | Migration não criada | 🟡 ALTO: Não persiste configurações | `migrations/versions/` | Criar migration | Média | Baixo |
| 8 | API Key generation UI | Endpoint existe mas UI não | 🟡 ALTO: Usuário não consegue gerar | `src/components/CMS/` | Criar componente ApiKeyManager | Média | Baixo |
| 9 | Rate limiting API pública | Não implementado | 🟢 MÉDIO: API vulnerável a abuso | `app/modules/cms/controllers/public_api_controller.py` | Implementar rate limiting | Média | Médio |
| 10 | Testes automatizados | Não existem | 🟢 MÉDIO: Regressões possíveis | `tests/` | Criar suite de testes | Alta | Muito Baixo |

### 8.2 Ordem de Implementação Sugerida

```
FASE 1 - Habilitar Provider "Site" (1-2 dias)
├── 1. Criar migration provider "site"
├── 2. Adicionar SiteCredentials schema
├── 3. Adicionar ícone no frontend
└── 4. Criar modal de configuração

FASE 2 - Implementar Webhooks (3-5 dias)
├── 5. Criar tabela cms_webhooks
├── 6. Implementar WebhookService
├── 7. Implementar EventDispatcher
└── 8. Adicionar eventos nos services existentes

FASE 3 - Melhorias (2-3 dias)
├── 9. API Key generation UI
├── 10. Webhook test button
├── 11. Webhook logs
└── 12. Rate limiting

FASE 4 - Qualidade (contínuo)
├── 13. Testes unitários
├── 14. Testes de integração
└── 15. Documentação
```

---

## 9. GUIA DE INTEGRAÇÃO PARA SITES EXTERNOS

### COMO CONECTAR SEU SITE AO CMS FASTTEAM

---

### Passo 1: Obter suas Credenciais

#### 1.1 API Key

1. Acesse o painel administrativo do FastTeam
2. Vá em **Configurações** → **CMS**
3. Na seção "API Key", clique em **Gerar Nova Chave**
4. Copie a chave gerada (formato: 64 caracteres alfanuméricos)
5. **IMPORTANTE:** Guarde esta chave em local seguro. Ela não poderá ser visualizada novamente.

#### 1.2 Webhook Secret (quando implementado)

1. Ainda em **Configurações** → **CMS**
2. Na seção "Integrações", clique em **Configurar Site**
3. Informe a URL do seu site (ex: `https://meusite.com`)
4. Um webhook secret será gerado automaticamente
5. Copie e guarde o secret

---

### Passo 2: Configurar Variáveis de Ambiente no seu Site

Crie ou edite o arquivo `.env.local` na raiz do seu projeto Next.js:

```env
# API do CMS FastTeam
CMS_API_URL=https://api.fastteam.com.br
CMS_API_KEY=sua_api_key_de_64_caracteres

# Webhook (para revalidação automática)
CMS_WEBHOOK_SECRET=seu_webhook_secret

# URL pública do seu site
NEXT_PUBLIC_SITE_URL=https://meusite.com
```

---

### Passo 3: Criar o Cliente da API

Crie o arquivo `lib/cms.ts`:

```typescript
// lib/cms.ts

const CMS_API_URL = process.env.CMS_API_URL!;
const CMS_API_KEY = process.env.CMS_API_KEY!;

interface CMSFetchOptions {
  tags?: string[];
  revalidate?: number;
}

async function cmsFetch<T>(
  endpoint: string,
  options: CMSFetchOptions = {}
): Promise<T> {
  const { tags = [], revalidate = 300 } = options;

  const response = await fetch(`${CMS_API_URL}/api/v1/cms${endpoint}`, {
    headers: {
      'X-API-Key': CMS_API_KEY,
      'Content-Type': 'application/json',
    },
    next: {
      tags,
      revalidate,
    },
  });

  if (!response.ok) {
    throw new Error(`CMS API error: ${response.status}`);
  }

  return response.json();
}

// ==================== PÁGINAS ====================

export interface CMSPage {
  id: string;
  slug: string;
  title: string;
  excerpt: string;
  content: any; // TipTap JSON
  featured_image: string | null;
  page_type: string;
  template: string;
  reading_time: number;
  seo: {
    title: string;
    description: string;
    keywords: string[];
    canonical_url: string;
    og_title: string;
    og_description: string;
    og_image: string;
    schema_type: string;
  };
  published_at: string;
  updated_at: string;
}

export async function getPages() {
  return cmsFetch<{ pages: CMSPage[]; meta: any }>('/pages', {
    tags: ['pages'],
  });
}

export async function getPageBySlug(slug: string) {
  return cmsFetch<CMSPage>(`/pages/${slug}`, {
    tags: ['pages', `page-${slug}`],
  });
}

// ==================== POSTS ====================

export interface CMSPost {
  id: string;
  slug: string;
  title: string;
  excerpt: string;
  content: any;
  featured_image: string | null;
  reading_time: number;
  view_count: number;
  is_featured: boolean;
  category: {
    id: string;
    slug: string;
    name: string;
  };
  author: {
    id: string;
    slug: string;
    name: string;
    avatar: string;
  };
  tags: Array<{
    id: string;
    slug: string;
    name: string;
  }>;
  seo: {
    title: string;
    description: string;
    og_image: string;
  };
  published_at: string;
  updated_at: string;
}

export async function getPosts(params?: {
  page?: number;
  per_page?: number;
  category?: string;
  tag?: string;
  author?: string;
  search?: string;
}) {
  const searchParams = new URLSearchParams();
  if (params?.page) searchParams.set('page', String(params.page));
  if (params?.per_page) searchParams.set('per_page', String(params.per_page));
  if (params?.category) searchParams.set('category', params.category);
  if (params?.tag) searchParams.set('tag', params.tag);
  if (params?.author) searchParams.set('author', params.author);
  if (params?.search) searchParams.set('search', params.search);

  const query = searchParams.toString();
  return cmsFetch<{ posts: CMSPost[]; meta: any }>(
    `/posts${query ? `?${query}` : ''}`,
    { tags: ['posts'] }
  );
}

export async function getPostBySlug(slug: string) {
  return cmsFetch<CMSPost>(`/posts/${slug}`, {
    tags: ['posts', `post-${slug}`],
  });
}

// ==================== CATEGORIAS ====================

export interface CMSCategory {
  id: string;
  slug: string;
  name: string;
  description: string;
  color: string;
  icon: string;
  post_count: number;
}

export async function getCategories() {
  return cmsFetch<{ categories: CMSCategory[] }>('/categories', {
    tags: ['categories'],
    revalidate: 600,
  });
}

export async function getCategoryBySlug(slug: string) {
  return cmsFetch<{ category: CMSCategory; posts: CMSPost[]; meta: any }>(
    `/categories/${slug}`,
    { tags: ['categories', `category-${slug}`] }
  );
}

// ==================== TAGS ====================

export interface CMSTag {
  id: string;
  slug: string;
  name: string;
  post_count: number;
}

export async function getTags() {
  return cmsFetch<{ tags: CMSTag[] }>('/tags', {
    tags: ['tags'],
    revalidate: 600,
  });
}

// ==================== AUTORES ====================

export interface CMSAuthor {
  id: string;
  slug: string;
  name: string;
  avatar: string;
  bio?: string;
  social_links?: Record<string, string>;
  post_count: number;
}

export async function getAuthors() {
  return cmsFetch<{ authors: CMSAuthor[] }>('/authors', {
    tags: ['authors'],
    revalidate: 600,
  });
}

export async function getAuthorBySlug(slug: string) {
  return cmsFetch<{ author: CMSAuthor; posts: CMSPost[]; meta: any }>(
    `/authors/${slug}`,
    { tags: ['authors', `author-${slug}`] }
  );
}

// ==================== SITEMAP ====================

export interface CMSSitemapUrl {
  type: 'page' | 'post' | 'category';
  slug: string;
  loc: string;
  lastmod: string;
  changefreq: string;
  priority: string;
}

export async function getSitemap() {
  return cmsFetch<{ urls: CMSSitemapUrl[]; total: number; generated_at: string }>(
    '/sitemap',
    { tags: ['sitemap'], revalidate: 3600 }
  );
}

// ==================== HELPERS ====================

export function getMediaUrl(path: string | null): string | null {
  if (!path) return null;
  if (path.startsWith('http')) return path;
  return `${CMS_API_URL}${path}`;
}
```

---

### Passo 4: Criar o Renderizador de Conteúdo TipTap

Crie o arquivo `components/TipTapRenderer.tsx`:

```tsx
// components/TipTapRenderer.tsx

import Image from 'next/image';
import Link from 'next/link';
import { getMediaUrl } from '@/lib/cms';

interface TipTapNode {
  type: string;
  content?: TipTapNode[];
  text?: string;
  attrs?: Record<string, any>;
  marks?: Array<{ type: string; attrs?: Record<string, any> }>;
}

interface TipTapRendererProps {
  content: {
    type: 'doc';
    content: TipTapNode[];
  };
}

export function TipTapRenderer({ content }: TipTapRendererProps) {
  if (!content?.content) return null;

  return (
    <div className="prose prose-lg max-w-none">
      {content.content.map((node, index) => (
        <RenderNode key={index} node={node} />
      ))}
    </div>
  );
}

function RenderNode({ node }: { node: TipTapNode }) {
  switch (node.type) {
    case 'paragraph':
      return (
        <p>
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </p>
      );

    case 'heading':
      const HeadingTag = `h${node.attrs?.level || 2}` as keyof JSX.IntrinsicElements;
      return (
        <HeadingTag>
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </HeadingTag>
      );

    case 'text':
      let text: React.ReactNode = node.text;

      // Aplicar marks (bold, italic, etc.)
      node.marks?.forEach((mark) => {
        switch (mark.type) {
          case 'bold':
            text = <strong>{text}</strong>;
            break;
          case 'italic':
            text = <em>{text}</em>;
            break;
          case 'underline':
            text = <u>{text}</u>;
            break;
          case 'strike':
            text = <s>{text}</s>;
            break;
          case 'code':
            text = <code>{text}</code>;
            break;
          case 'link':
            text = (
              <Link
                href={mark.attrs?.href || '#'}
                target={mark.attrs?.target}
                rel={mark.attrs?.target === '_blank' ? 'noopener noreferrer' : undefined}
              >
                {text}
              </Link>
            );
            break;
          case 'highlight':
            text = <mark style={{ backgroundColor: mark.attrs?.color }}>{text}</mark>;
            break;
          case 'textStyle':
            text = <span style={{ color: mark.attrs?.color }}>{text}</span>;
            break;
        }
      });

      return <>{text}</>;

    case 'bulletList':
      return (
        <ul>
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </ul>
      );

    case 'orderedList':
      return (
        <ol start={node.attrs?.start}>
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </ol>
      );

    case 'listItem':
      return (
        <li>
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </li>
      );

    case 'blockquote':
      return (
        <blockquote>
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </blockquote>
      );

    case 'codeBlock':
      return (
        <pre>
          <code className={`language-${node.attrs?.language || 'plaintext'}`}>
            {node.content?.map((child) => child.text).join('')}
          </code>
        </pre>
      );

    case 'image':
      const src = getMediaUrl(node.attrs?.src);
      if (!src) return null;

      return (
        <figure>
          <Image
            src={src}
            alt={node.attrs?.alt || ''}
            width={node.attrs?.width || 800}
            height={node.attrs?.height || 600}
            className="rounded-lg"
          />
          {node.attrs?.title && (
            <figcaption>{node.attrs.title}</figcaption>
          )}
        </figure>
      );

    case 'youtube':
      return (
        <div className="aspect-video">
          <iframe
            src={`https://www.youtube.com/embed/${node.attrs?.src}`}
            width={node.attrs?.width || '100%'}
            height={node.attrs?.height || 400}
            allowFullScreen
            className="w-full rounded-lg"
          />
        </div>
      );

    case 'table':
      return (
        <table>
          <tbody>
            {node.content?.map((child, i) => (
              <RenderNode key={i} node={child} />
            ))}
          </tbody>
        </table>
      );

    case 'tableRow':
      return (
        <tr>
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </tr>
      );

    case 'tableCell':
      return (
        <td colSpan={node.attrs?.colspan} rowSpan={node.attrs?.rowspan}>
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </td>
      );

    case 'tableHeader':
      return (
        <th colSpan={node.attrs?.colspan} rowSpan={node.attrs?.rowspan}>
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </th>
      );

    case 'horizontalRule':
      return <hr />;

    case 'hardBreak':
      return <br />;

    // Extensões customizadas do FastTeam CMS
    case 'alert':
      return (
        <div className={`alert alert-${node.attrs?.type || 'info'} p-4 rounded-lg my-4`}>
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </div>
      );

    case 'callout':
      return (
        <div className="callout p-4 border-l-4 border-blue-500 bg-blue-50 my-4">
          {node.content?.map((child, i) => (
            <RenderNode key={i} node={child} />
          ))}
        </div>
      );

    case 'accordion':
      return (
        <details className="my-4">
          <summary className="cursor-pointer font-semibold">
            {node.attrs?.title || 'Clique para expandir'}
          </summary>
          <div className="mt-2">
            {node.content?.map((child, i) => (
              <RenderNode key={i} node={child} />
            ))}
          </div>
        </details>
      );

    case 'faq':
      return (
        <div className="faq my-4">
          <h4 className="font-semibold">{node.attrs?.question}</h4>
          <div className="mt-2">
            {node.content?.map((child, i) => (
              <RenderNode key={i} node={child} />
            ))}
          </div>
        </div>
      );

    case 'cta':
      return (
        <div className="cta text-center p-6 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg my-6">
          <h3 className="text-xl font-bold mb-2">{node.attrs?.title}</h3>
          <p className="mb-4">{node.attrs?.description}</p>
          <Link
            href={node.attrs?.buttonUrl || '#'}
            className="inline-block px-6 py-3 bg-white text-blue-600 rounded-lg font-semibold"
          >
            {node.attrs?.buttonText || 'Saiba mais'}
          </Link>
        </div>
      );

    case 'steps':
      return (
        <ol className="steps list-none p-0">
          {node.content?.map((child, i) => (
            <li key={i} className="flex items-start mb-4">
              <span className="flex-shrink-0 w-8 h-8 flex items-center justify-center bg-blue-500 text-white rounded-full mr-3">
                {i + 1}
              </span>
              <div className="flex-1">
                <RenderNode node={child} />
              </div>
            </li>
          ))}
        </ol>
      );

    default:
      // Renderizar conteúdo filho se existir
      if (node.content) {
        return (
          <>
            {node.content.map((child, i) => (
              <RenderNode key={i} node={child} />
            ))}
          </>
        );
      }
      return null;
  }
}
```

---

### Passo 5: Criar Páginas do Blog

#### 5.1 Listagem de Posts (`app/blog/page.tsx`)

```tsx
// app/blog/page.tsx

import Link from 'next/link';
import Image from 'next/image';
import { getPosts, getMediaUrl } from '@/lib/cms';

export const revalidate = 300; // Revalidar a cada 5 minutos

export default async function BlogPage() {
  const { posts, meta } = await getPosts({ per_page: 12 });

  return (
    <main className="container mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8">Blog</h1>

      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
        {posts.map((post) => (
          <article key={post.id} className="bg-white rounded-lg shadow-lg overflow-hidden">
            {post.featured_image && (
              <Link href={`/blog/${post.slug}`}>
                <Image
                  src={getMediaUrl(post.featured_image)!}
                  alt={post.title}
                  width={400}
                  height={250}
                  className="w-full h-48 object-cover"
                />
              </Link>
            )}

            <div className="p-6">
              {post.category && (
                <Link
                  href={`/blog/categoria/${post.category.slug}`}
                  className="text-sm text-blue-600 hover:underline"
                >
                  {post.category.name}
                </Link>
              )}

              <h2 className="text-xl font-semibold mt-2 mb-3">
                <Link href={`/blog/${post.slug}`} className="hover:text-blue-600">
                  {post.title}
                </Link>
              </h2>

              <p className="text-gray-600 mb-4 line-clamp-3">
                {post.excerpt}
              </p>

              <div className="flex items-center justify-between text-sm text-gray-500">
                <div className="flex items-center">
                  {post.author?.avatar && (
                    <Image
                      src={getMediaUrl(post.author.avatar)!}
                      alt={post.author.name}
                      width={24}
                      height={24}
                      className="rounded-full mr-2"
                    />
                  )}
                  <span>{post.author?.name}</span>
                </div>
                <span>{post.reading_time} min de leitura</span>
              </div>
            </div>
          </article>
        ))}
      </div>

      {/* Paginação */}
      {meta.pages_count > 1 && (
        <div className="flex justify-center mt-8 gap-2">
          {Array.from({ length: meta.pages_count }, (_, i) => (
            <Link
              key={i + 1}
              href={`/blog?page=${i + 1}`}
              className={`px-4 py-2 rounded ${
                meta.page === i + 1
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-200 hover:bg-gray-300'
              }`}
            >
              {i + 1}
            </Link>
          ))}
        </div>
      )}
    </main>
  );
}
```

#### 5.2 Post Individual (`app/blog/[slug]/page.tsx`)

```tsx
// app/blog/[slug]/page.tsx

import { Metadata } from 'next';
import Image from 'next/image';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getPostBySlug, getPosts, getMediaUrl } from '@/lib/cms';
import { TipTapRenderer } from '@/components/TipTapRenderer';

interface Props {
  params: { slug: string };
}

// Gerar páginas estáticas para todos os posts
export async function generateStaticParams() {
  const { posts } = await getPosts({ per_page: 100 });
  return posts.map((post) => ({ slug: post.slug }));
}

// Gerar metadata dinâmico para SEO
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  try {
    const post = await getPostBySlug(params.slug);

    return {
      title: post.seo?.title || post.title,
      description: post.seo?.description || post.excerpt,
      openGraph: {
        title: post.seo?.title || post.title,
        description: post.seo?.description || post.excerpt,
        images: post.seo?.og_image ? [getMediaUrl(post.seo.og_image)!] : [],
        type: 'article',
        publishedTime: post.published_at,
        modifiedTime: post.updated_at,
        authors: post.author ? [post.author.name] : [],
      },
      twitter: {
        card: 'summary_large_image',
        title: post.seo?.title || post.title,
        description: post.seo?.description || post.excerpt,
        images: post.seo?.og_image ? [getMediaUrl(post.seo.og_image)!] : [],
      },
    };
  } catch {
    return {
      title: 'Post não encontrado',
    };
  }
}

export default async function PostPage({ params }: Props) {
  let post;

  try {
    post = await getPostBySlug(params.slug);
  } catch {
    notFound();
  }

  // Schema.org JSON-LD
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: post.title,
    description: post.excerpt,
    image: post.featured_image ? getMediaUrl(post.featured_image) : undefined,
    datePublished: post.published_at,
    dateModified: post.updated_at,
    author: post.author ? {
      '@type': 'Person',
      name: post.author.name,
    } : undefined,
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />

      <article className="container mx-auto px-4 py-8 max-w-4xl">
        {/* Breadcrumbs */}
        <nav className="text-sm mb-6">
          <Link href="/" className="text-gray-500 hover:text-blue-600">Home</Link>
          <span className="mx-2">/</span>
          <Link href="/blog" className="text-gray-500 hover:text-blue-600">Blog</Link>
          {post.category && (
            <>
              <span className="mx-2">/</span>
              <Link
                href={`/blog/categoria/${post.category.slug}`}
                className="text-gray-500 hover:text-blue-600"
              >
                {post.category.name}
              </Link>
            </>
          )}
        </nav>

        {/* Header */}
        <header className="mb-8">
          <h1 className="text-4xl font-bold mb-4">{post.title}</h1>

          <div className="flex items-center gap-4 text-gray-600 mb-6">
            {post.author && (
              <div className="flex items-center">
                {post.author.avatar && (
                  <Image
                    src={getMediaUrl(post.author.avatar)!}
                    alt={post.author.name}
                    width={40}
                    height={40}
                    className="rounded-full mr-2"
                  />
                )}
                <span>{post.author.name}</span>
              </div>
            )}
            <span>•</span>
            <time dateTime={post.published_at}>
              {new Date(post.published_at).toLocaleDateString('pt-BR', {
                day: 'numeric',
                month: 'long',
                year: 'numeric',
              })}
            </time>
            <span>•</span>
            <span>{post.reading_time} min de leitura</span>
          </div>

          {/* Tags */}
          {post.tags?.length > 0 && (
            <div className="flex flex-wrap gap-2">
              {post.tags.map((tag) => (
                <Link
                  key={tag.id}
                  href={`/blog/tag/${tag.slug}`}
                  className="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm hover:bg-gray-200"
                >
                  #{tag.name}
                </Link>
              ))}
            </div>
          )}
        </header>

        {/* Featured Image */}
        {post.featured_image && (
          <Image
            src={getMediaUrl(post.featured_image)!}
            alt={post.title}
            width={1200}
            height={630}
            className="w-full rounded-lg mb-8"
            priority
          />
        )}

        {/* Content */}
        <div className="prose prose-lg max-w-none">
          <TipTapRenderer content={post.content} />
        </div>

        {/* Share buttons */}
        <div className="mt-8 pt-8 border-t">
          <p className="font-semibold mb-4">Compartilhe este artigo:</p>
          <div className="flex gap-4">
            <a
              href={`https://twitter.com/intent/tweet?url=${encodeURIComponent(
                `${process.env.NEXT_PUBLIC_SITE_URL}/blog/${post.slug}`
              )}&text=${encodeURIComponent(post.title)}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-400 hover:text-blue-600"
            >
              Twitter
            </a>
            <a
              href={`https://www.linkedin.com/shareArticle?mini=true&url=${encodeURIComponent(
                `${process.env.NEXT_PUBLIC_SITE_URL}/blog/${post.slug}`
              )}&title=${encodeURIComponent(post.title)}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-700 hover:text-blue-900"
            >
              LinkedIn
            </a>
            <a
              href={`https://wa.me/?text=${encodeURIComponent(
                `${post.title} - ${process.env.NEXT_PUBLIC_SITE_URL}/blog/${post.slug}`
              )}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-green-500 hover:text-green-700"
            >
              WhatsApp
            </a>
          </div>
        </div>
      </article>
    </>
  );
}
```

---

### Passo 6: Criar Endpoint de Revalidação (Webhook)

Crie o arquivo `app/api/revalidate/route.ts`:

```typescript
// app/api/revalidate/route.ts

import { revalidatePath, revalidateTag } from 'next/cache';
import { NextRequest, NextResponse } from 'next/server';
import crypto from 'crypto';

export async function POST(request: NextRequest) {
  // 1. Verificar webhook secret
  const secret = request.headers.get('X-Webhook-Secret');

  if (secret !== process.env.CMS_WEBHOOK_SECRET) {
    console.error('Webhook: Invalid secret');
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }

  // 2. Verificar assinatura HMAC (se implementado no CMS)
  const signature = request.headers.get('X-Webhook-Signature');
  const bodyText = await request.text();

  if (signature) {
    const expectedSignature = crypto
      .createHmac('sha256', process.env.CMS_WEBHOOK_SECRET!)
      .update(bodyText)
      .digest('hex');

    if (signature !== `sha256=${expectedSignature}`) {
      console.error('Webhook: Invalid signature');
      return NextResponse.json(
        { error: 'Invalid signature' },
        { status: 401 }
      );
    }
  }

  // 3. Processar payload
  let payload;
  try {
    payload = JSON.parse(bodyText);
  } catch {
    return NextResponse.json(
      { error: 'Invalid JSON' },
      { status: 400 }
    );
  }

  const { event, content, paths_to_revalidate, tags_to_revalidate } = payload;

  console.log(`Webhook recebido: ${event}`, {
    type: content?.type,
    slug: content?.slug,
  });

  const revalidated: string[] = [];
  const errors: string[] = [];

  // 4. Revalidar paths específicos
  if (paths_to_revalidate && Array.isArray(paths_to_revalidate)) {
    for (const path of paths_to_revalidate) {
      try {
        revalidatePath(path);
        revalidated.push(path);
      } catch (error) {
        errors.push(`Failed to revalidate path: ${path}`);
      }
    }
  }

  // 5. Revalidar tags de cache
  if (tags_to_revalidate && Array.isArray(tags_to_revalidate)) {
    for (const tag of tags_to_revalidate) {
      try {
        revalidateTag(tag);
        revalidated.push(`tag:${tag}`);
      } catch (error) {
        errors.push(`Failed to revalidate tag: ${tag}`);
      }
    }
  }

  // 6. Revalidações padrão baseadas no evento
  try {
    switch (event) {
      case 'content.created':
      case 'content.published':
        if (content?.type === 'post') {
          revalidatePath('/blog');
          revalidatePath(`/blog/${content.slug}`);
          revalidateTag('posts');
          if (content.category?.slug) {
            revalidatePath(`/blog/categoria/${content.category.slug}`);
          }
        } else if (content?.type === 'page') {
          revalidatePath(`/${content.slug}`);
          revalidateTag('pages');
        }
        // Sempre revalidar sitemap
        revalidatePath('/sitemap.xml');
        revalidateTag('sitemap');
        break;

      case 'content.updated':
        if (content?.type === 'post') {
          revalidatePath(`/blog/${content.slug}`);
          revalidatePath('/blog');
          revalidateTag('posts');
          revalidateTag(`post-${content.slug}`);
        } else if (content?.type === 'page') {
          revalidatePath(`/${content.slug}`);
          revalidateTag('pages');
          revalidateTag(`page-${content.slug}`);
        }
        break;

      case 'content.deleted':
      case 'content.unpublished':
        if (content?.type === 'post') {
          revalidatePath('/blog');
          revalidateTag('posts');
        } else if (content?.type === 'page') {
          revalidateTag('pages');
        }
        revalidatePath('/sitemap.xml');
        revalidateTag('sitemap');
        break;

      case 'category.updated':
        revalidatePath('/blog');
        revalidateTag('categories');
        if (content?.slug) {
          revalidatePath(`/blog/categoria/${content.slug}`);
        }
        break;

      case 'author.updated':
        revalidateTag('authors');
        if (content?.slug) {
          revalidatePath(`/blog/autor/${content.slug}`);
        }
        break;
    }
  } catch (error) {
    console.error('Webhook: Error during default revalidation', error);
  }

  console.log(`Webhook processado: ${revalidated.length} itens revalidados`);

  return NextResponse.json({
    success: true,
    event,
    revalidated,
    errors: errors.length > 0 ? errors : undefined,
    timestamp: new Date().toISOString(),
  });
}

// Suporte a GET para teste manual
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const secret = searchParams.get('secret');

  if (secret !== process.env.CMS_WEBHOOK_SECRET) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Revalidar tudo
  revalidateTag('posts');
  revalidateTag('pages');
  revalidateTag('categories');
  revalidateTag('authors');
  revalidateTag('sitemap');
  revalidatePath('/blog');
  revalidatePath('/sitemap.xml');

  return NextResponse.json({
    success: true,
    message: 'All content revalidated',
    timestamp: new Date().toISOString(),
  });
}
```

---

### Passo 7: Criar Sitemap Dinâmico

Crie o arquivo `app/sitemap.ts`:

```typescript
// app/sitemap.ts

import { MetadataRoute } from 'next';
import { getSitemap } from '@/lib/cms';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL!;

  // Páginas estáticas do site
  const staticPages = [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: 'daily' as const,
      priority: 1,
    },
    {
      url: `${baseUrl}/blog`,
      lastModified: new Date(),
      changeFrequency: 'daily' as const,
      priority: 0.8,
    },
    {
      url: `${baseUrl}/contato`,
      lastModified: new Date(),
      changeFrequency: 'monthly' as const,
      priority: 0.5,
    },
  ];

  // Buscar URLs do CMS
  try {
    const { urls } = await getSitemap();

    const cmsPages = urls.map((url) => ({
      url: `${baseUrl}${url.loc}`,
      lastModified: new Date(url.lastmod),
      changeFrequency: url.changefreq as MetadataRoute.Sitemap[0]['changeFrequency'],
      priority: parseFloat(url.priority),
    }));

    return [...staticPages, ...cmsPages];
  } catch (error) {
    console.error('Erro ao buscar sitemap do CMS:', error);
    return staticPages;
  }
}
```

---

### Passo 8: Configurar next.config.js

```javascript
// next.config.js

/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'api.fastteam.com.br',
        pathname: '/api/cms/media/**',
      },
      // Adicione outros domínios se necessário
    ],
  },

  // Habilitar revalidação sob demanda
  experimental: {
    // Se usar App Router, estas configurações são padrão
  },
};

module.exports = nextConfig;
```

---

### Passo 9: Testar a Integração

#### 9.1 Testar API Pública

```bash
# Listar posts
curl -X GET "https://api.fastteam.com.br/api/v1/cms/posts" \
  -H "X-API-Key: sua_api_key"

# Obter post específico
curl -X GET "https://api.fastteam.com.br/api/v1/cms/posts/meu-primeiro-post" \
  -H "X-API-Key: sua_api_key"

# Obter sitemap
curl -X GET "https://api.fastteam.com.br/api/v1/cms/sitemap" \
  -H "X-API-Key: sua_api_key"
```

#### 9.2 Testar Revalidação Manual

```bash
# Forçar revalidação de todo o conteúdo
curl "https://meusite.com/api/revalidate?secret=seu_webhook_secret"
```

#### 9.3 Testar Webhook

```bash
curl -X POST "https://meusite.com/api/revalidate" \
  -H "X-Webhook-Secret: seu_webhook_secret" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "content.published",
    "content": {
      "type": "post",
      "slug": "teste",
      "title": "Post de Teste"
    },
    "paths_to_revalidate": ["/blog", "/blog/teste"],
    "tags_to_revalidate": ["posts"]
  }'
```

---

### Checklist Final

- [ ] API Key obtida e configurada em `.env.local`
- [ ] Webhook Secret configurado (quando disponível)
- [ ] `lib/cms.ts` criado com cliente da API
- [ ] `components/TipTapRenderer.tsx` criado
- [ ] Páginas do blog implementadas
- [ ] Endpoint `/api/revalidate` funcionando
- [ ] `sitemap.ts` configurado
- [ ] `next.config.js` com domínios de imagem
- [ ] Testes de conexão realizados
- [ ] Deploy em produção realizado

---

### Troubleshooting

| Problema | Solução |
|----------|---------|
| "API key required" | Verificar se `CMS_API_KEY` está no `.env.local` |
| "Invalid API key" | Confirmar que a API key está correta no painel do CMS |
| Imagens não carregam | Adicionar domínio em `next.config.js` remotePatterns |
| 404 em posts | Verificar se o post está publicado no CMS |
| Webhook não dispara | Aguardar implementação do sistema de webhooks |
| Revalidação não funciona | Verificar se `CMS_WEBHOOK_SECRET` está correto |

---

**Documento gerado automaticamente pela análise do Git Diff**
**FastTeam CMS - Versão 1.0**
