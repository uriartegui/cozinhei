"""
TheMealDB → Supabase (sem tradução, inglês)
"""

import os
import json
import requests
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_SERVICE_KEY"]

HEADERS_SUPABASE = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal",
}

CATEGORIES = [
    "Chicken", "Beef", "Pork", "Seafood", "Pasta",
    "Vegetarian", "Dessert", "Lamb", "Side", "Starter",
]

CATEGORY_MAP = {
    "Chicken": "Frango",
    "Beef": "Carnes",
    "Pork": "Carnes",
    "Seafood": "Peixes",
    "Pasta": "Massas",
    "Vegetarian": "Vegetariano",
    "Dessert": "Sobremesas",
    "Lamb": "Carnes",
    "Side": "Acompanhamentos",
    "Starter": "Entradas",
}


def get_meal_ids(category: str) -> list:
    resp = requests.get(
        f"https://www.themealdb.com/api/json/v1/1/filter.php?c={category}",
        timeout=10,
    )
    meals = resp.json().get("meals") or []
    return [m["idMeal"] for m in meals]


def get_meal_detail(meal_id: str) -> dict | None:
    resp = requests.get(
        f"https://www.themealdb.com/api/json/v1/1/lookup.php?i={meal_id}",
        timeout=10,
    )
    meals = resp.json().get("meals") or []
    return meals[0] if meals else None


def extract_ingredients(meal: dict) -> list:
    ingredients = []
    for i in range(1, 21):
        ing  = (meal.get(f"strIngredient{i}") or "").strip()
        meas = (meal.get(f"strMeasure{i}")    or "").strip()
        if ing:
            ingredients.append(f"{meas} {ing}".strip())
    return ingredients


def recipe_exists(name: str) -> bool:
    resp = requests.get(
        f"{SUPABASE_URL}/rest/v1/recipes",
        headers=HEADERS_SUPABASE,
        params={"name": f"eq.{name}", "select": "id", "limit": "1"},
    )
    return len(resp.json()) > 0


def insert_recipe(recipe: dict) -> bool:
    resp = requests.post(
        f"{SUPABASE_URL}/rest/v1/recipes",
        headers=HEADERS_SUPABASE,
        data=json.dumps(recipe),
    )
    return resp.status_code in (200, 201)


def main(target: int = 300):
    seen_ids: set = set()
    total = 0

    print(f"Iniciando. Meta: {target} receitas\n")

    for category in CATEGORIES:
        if total >= target:
            break

        print(f"[{total}/{target}] Categoria: {category}")
        ids = [i for i in get_meal_ids(category) if i not in seen_ids]
        seen_ids.update(ids)

        for meal_id in ids:
            if total >= target:
                break

            meal = get_meal_detail(meal_id)
            if not meal:
                continue

            name = meal["strMeal"]

            if recipe_exists(name):
                print(f"  Já existe: {name}")
                continue

            steps = [
                s.strip()
                for s in (meal.get("strInstructions") or "").replace("\r\n", "\n").split("\n")
                if s.strip()
            ]

            record = {
                "name":         name,
                "description":  "",
                "ingredients":  extract_ingredients(meal),
                "steps":        steps,
                "cooking_time": "30 minutes",
                "servings":     "4 servings",
                "image_url":    meal.get("strMealThumb", ""),
                "source_url":   f"https://www.themealdb.com/meal/{meal_id}",
                "category":     CATEGORY_MAP.get(category, "Outras"),
            }

            if insert_recipe(record):
                total += 1
                print(f"  ✓ [{total}] {name}")

    print(f"\nConcluído! {total} receitas inseridas.")


if __name__ == "__main__":
    main(target=300)
