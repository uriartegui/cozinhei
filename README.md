# 🍳 Cozinhei
### Gerador Inteligente de Receitas com IA

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-orange)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-brightgreen)
![Language](https://img.shields.io/badge/language-Flutter%20%2F%20Dart-blue)
![Version](https://img.shields.io/badge/version-1.0.0--alpha-informational)
![License](https://img.shields.io/badge/license-Propriet%C3%A1rio-red)

> ⚠️ **Este é um projeto proprietário.** O código-fonte está disponível apenas para visualização. Cópia, uso comercial ou distribuição são proibidos sem autorização prévia. Veja [LICENSE](./LICENSE).

Cozinhei é um app mobile (Android e iOS) que usa Inteligência Artificial para gerar receitas personalizadas com base nos ingredientes que você tem em casa, na categoria que você quer cozinhar ou em filtros como "Rápido", "Saudável" e "Gourmet". As receitas são geradas com passos detalhados e profissionais, fotos reais e ajuste automático de quantidades para qualquer número de pessoas.

---

## 💡 O que o Cozinhei resolve

Quem cozinha em casa enfrenta todo dia os mesmos problemas:

- Não sabe o que cozinhar com o que tem disponível.
- Busca receitas genéricas que não consideram os ingredientes reais na geladeira.
- Receitas com passos vagos e sem quantidades precisas.
- Dificuldade de adaptar receitas para mais ou menos pessoas.

Cozinhei resolve isso gerando receitas sob medida, com ingredientes que você realmente tem, para o número de pessoas que precisa, com instruções detalhadas passo a passo.

---

## 🎯 Funcionalidades

- 🧠 **Geração de receitas com IA** — envia ingredientes, categoria e filtros; a IA gera receitas completas e detalhadas.
- 🧊 **Geladeira compartilhada em tempo real** — geladeira sincronizada entre membros da casa via Supabase Realtime. Cadastre ingredientes, quantidades, unidades e validade.
- 🗂️ **Sistema de 3 níveis de categoria** — Categoria → Subcategoria → Tags para filtrar exatamente o que quer cozinhar.
- 👨‍👩‍👧 **Ajuste de porções** — informe para quantas pessoas e a IA ajusta todos os ingredientes automaticamente.
- 📋 **Passos detalhados e profissionais** — cada passo inclui quantidades exatas, temperatura e tempo de preparo.
- 📸 **Fotos reais das receitas** — imagens buscadas automaticamente via Unsplash para cada receita gerada.
- 💾 **Salvar e favoritar** — salve receitas geradas e marque suas favoritas para acessar depois.
- 🌐 **Integração com TheMealDB** — quando disponível, busca receitas reais do banco de dados e as traduz para português.
- 🔄 **Gerar outras** — clique em "Gerar outras" para receber novas sugestões sem repetir as já mostradas.
- 🍽️ **Modo de preparo guiado** — tela dedicada para seguir o passo a passo durante o cozimento.
- 🏠 **Casa compartilhada** — crie uma casa, convide membros com código de convite e compartilhe geladeira e lista de compras em tempo real.
- 🛒 **Lista de compras colaborativa** — adicione itens com loja, marque como comprado e mova direto para a geladeira.
- 📋 **Histórico de atividades** — log em tempo real de tudo que acontece na geladeira: quem adicionou, editou ou removeu itens e quando.

---

## 🗂️ Sistema de Categorias

O app organiza receitas em 3 níveis progressivos:

**1. Categoria principal** (sempre visível)
> 🍳 Café da Manhã · 🍝 Massas · 🥩 Carnes · 🍗 Frango · 🐟 Peixes · 🥗 Saladas · 🥪 Lanches · 🍲 Sopas · 🍚 Arroz · 🍕 Pizzas · 🍰 Sobremesas · 🌎 Cozinhas do Mundo · 🥦 Vegetariano · 🎲 Aleatório

**2. Subcategoria** (aparece ao clicar na categoria)
> Ex: Massas → Macarrão, Lasanha, Nhoque, Espaguete, Ravioli, Penne

**3. Tags / Filtros** (aparecem ao selecionar subcategoria)
> ⚡ Rápido · 🔥 Air Fryer · 🥑 Saudável · 🌱 Vegano · 💪 Proteico · 💰 Econômico · 🍽️ Fácil · 👨‍🍳 Gourmet

---

## 🛠️ Stack Técnica

| Camada | Tecnologia |
|---|---|
| Linguagem | Dart |
| Framework | Flutter |
| State Management | Riverpod |
| Backend / Banco de dados | Supabase (PostgreSQL + Realtime) |
| Auth | Supabase Auth (anônimo) |
| Cache local | SharedPreferences |
| Navegação | go_router |
| Requisições HTTP | Dio |
| Imagens | cached_network_image |
| Injeção de Dependência | get_it |
| IA | Groq API (compatível OpenAI) |
| Fotos | Unsplash API |
| Receitas base | TheMealDB API |

---

## 🏗️ Arquitetura

O projeto segue **MVVM + Repository Pattern** com separação clara de responsabilidades:

```
lib/
├── core/
│   └── constants.dart          # Chaves de API (não commitado)
├── data/
│   ├── api/                    # Serviços Dio (Groq, Unsplash, MealDB)
│   │   └── model/              # DTOs de resposta das APIs
│   ├── database/               # Drift: tabelas, AppDatabase
│   └── repository/
│       ├── recipe_repository   # Lógica central: IA, MealDB, imagens, CRUD
│       ├── fridge_repository   # Geladeira e lista de compras (Supabase + cache)
│       ├── house_repository    # Criação, convite e exclusão de casa compartilhada
│       └── log_repository      # Histórico de atividades em tempo real
├── di/
│   └── injection.dart          # get_it: setup de dependências
├── model/
│   ├── recipe.dart             # Modelo de domínio
│   ├── recipe_filter.dart      # Categorias, subcategorias e tags
│   ├── fridge_item.dart        # Item da geladeira com quantidade, unidade e validade
│   ├── shopping_item.dart      # Item da lista de compras com loja
│   └── log_entry.dart          # Entrada de histórico de atividade
├── ui/
│   ├── navigation/             # go_router: rotas e ShellRoute com bottom nav
│   ├── screens/
│   │   ├── home/               # HomeScreen (geração principal)
│   │   ├── fridge/             # FridgeScreen (geladeira + compras + histórico)
│   │   ├── house/              # HouseSetupScreen (criar/entrar em casa)
│   │   ├── saved/              # SavedRecipesScreen
│   │   └── recipe/             # RecipeDetailScreen + CookingModeScreen
│   ├── theme/                  # Cores e gradientes do app
│   └── widgets/                # RecipeCard e widgets compartilhados
├── viewmodel/
│   ├── home_notifier.dart      # Estado da home, geração, filtros
│   ├── home_state.dart         # Classes de estado sealed
│   ├── fridge_notifier.dart    # Geladeira, compras e logs (Supabase Realtime)
│   ├── house_notifier.dart     # Estado da casa compartilhada
│   └── saved_recipes_notifier  # Receitas salvas e favoritas
├── providers.dart              # Todos os providers Riverpod
└── main.dart                   # Entrada: ProviderScope + go_router
```

---

## 🔄 Fluxo de geração de receitas

```
Usuário informa ingredientes / categoria / filtros
        ↓
Tem ingredientes da geladeira?
    ├── Sim → Busca no TheMealDB → encontrou?
    │           ├── Sim → Traduz com IA → exibe com badge "TheMealDB"
    │           └── Não → Gera com IA
    └── Não → Gera com IA diretamente
        ↓
Para cada receita gerada:
    → Busca foto no Unsplash (photoSearchTerm em inglês)
        ↓
Exibe cards com nome, tempo, foto e badge de categoria
```

---

## 📱 Telas do app

| Tela | Descrição |
|---|---|
| **Home** | Ingredientes, categorias 3 níveis, geração de receitas |
| **Geladeira** | Ingredientes com quantidade, unidade e validade — compartilhado em tempo real |
| **Lista de Compras** | Lista colaborativa com loja, marcação e envio para geladeira |
| **Histórico** | Log de atividades da casa com agrupamento por data |
| **Configurações da Casa** | Renomear, convidar membros ou excluir a geladeira |
| **Detalhe da Receita** | Ingredientes, passos detalhados, favoritar, modo preparo |
| **Modo Preparo** | Passo a passo guiado durante o cozimento |
| **Minhas Receitas** | Todas as receitas salvas com filtro de favoritas |

---

## 👨‍💻 Desenvolvedor

**Guilherme Uriarte** — Product & Mobile Development

📌 Status: 🟠 Em desenvolvimento ativo (Alpha)

---

## ⚖️ Licença e Direitos Autorais

```
Copyright (c) 2025-2026 Guilherme Uriarte. Todos os direitos reservados.
```

Este projeto é **software proprietário**. O código-fonte está disponível publicamente apenas para fins de avaliação e portfólio.

**É proibido**, sem autorização prévia por escrito:
- ❌ Copiar, modificar ou distribuir este código
- ❌ Usar este software para fins comerciais
- ❌ Criar produtos derivados baseados neste projeto
- ❌ Fazer engenharia reversa

**É permitido:**
- ✅ Visualizar o código-fonte para fins educacionais
- ✅ Abrir issues com sugestões ou relatórios de bugs

Para licenciamento comercial ou parcerias: **guiuriarte@gmail.com**

Veja o arquivo [LICENSE](./LICENSE) para os termos completos.
