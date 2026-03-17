-- Tabela principal de receitas
CREATE TABLE recipes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  description TEXT,
  ingredients JSONB NOT NULL,  -- ["200g de frango", "2 tomates"]
  steps       JSONB NOT NULL,  -- ["Passo 1: ...", "Passo 2: ..."]
  cooking_time TEXT,
  servings    TEXT,
  image_url   TEXT,
  source_url  TEXT,
  category    TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Índice de busca full-text no nome da receita
CREATE INDEX recipes_name_fts ON recipes USING GIN (to_tsvector('portuguese', name));

-- Índice nos ingredientes (busca dentro do array JSON)
CREATE INDEX recipes_ingredients_gin ON recipes USING GIN (ingredients);

-- Função para buscar receitas por lista de ingredientes
CREATE OR REPLACE FUNCTION search_recipes_by_ingredients(ingredient_list TEXT[])
RETURNS TABLE (
  id UUID,
  name TEXT,
  description TEXT,
  ingredients JSONB,
  steps JSONB,
  cooking_time TEXT,
  servings TEXT,
  image_url TEXT,
  source_url TEXT,
  category TEXT,
  match_count INT
)
LANGUAGE SQL
AS $$
  SELECT
    r.id,
    r.name,
    r.description,
    r.ingredients,
    r.steps,
    r.cooking_time,
    r.servings,
    r.image_url,
    r.source_url,
    r.category,
    (
      SELECT COUNT(*)::INT
      FROM unnest(ingredient_list) ing
      WHERE EXISTS (
        SELECT 1 FROM jsonb_array_elements_text(r.ingredients) elem
        WHERE elem ILIKE '%' || ing || '%'
      )
    ) AS match_count
  FROM recipes r
  WHERE (
    SELECT COUNT(*)::INT
    FROM unnest(ingredient_list) ing
    WHERE EXISTS (
      SELECT 1 FROM jsonb_array_elements_text(r.ingredients) elem
      WHERE elem ILIKE '%' || ing || '%'
    )
  ) > 0
  ORDER BY match_count DESC
  LIMIT 10;
$$;

-- Habilitar acesso anônimo de leitura (RLS)
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Leitura pública de receitas"
  ON recipes FOR SELECT
  USING (true);
