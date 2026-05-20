import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

DATA_DIR = Path("data")

print("Loading datasets...")
customers = pd.read_csv(DATA_DIR / "olist_customers_dataset(1).csv")
orders = pd.read_csv(DATA_DIR / "olist_orders_dataset.csv", parse_dates=[
    "order_purchase_timestamp",
    "order_delivered_customer_date",
    "order_estimated_delivery_date"
])
reviews = pd.read_csv(DATA_DIR / "olist_order_reviews_dataset.csv")
items = pd.read_csv(DATA_DIR / "olist_order_items_dataset.csv")
payments = pd.read_csv(DATA_DIR / "olist_order_payments_dataset.csv")
products = pd.read_csv(DATA_DIR / "olist_products_dataset.csv")
translation = pd.read_csv(DATA_DIR / "product_category_name_translation.csv")

print("\n1. Low Ratings Analysis")
ratings = reviews["review_score"].value_counts().sort_index()
print(ratings)

print("\n2. Top Revenue Categories")
cat_df = (
    items.merge(products[["product_id", "product_category_name"]], on="product_id", how="left")
         .merge(translation, on="product_category_name", how="left")
         .groupby("product_category_name_english")["price"]
         .sum()
         .sort_values(ascending=False)
         .head(10)
)
print(cat_df)

print("\n3. Top Sellers")
top_sellers = items.groupby("seller_id")["price"].sum().sort_values(ascending=False).head(10)
print(top_sellers)

print("\n4. Payment Methods")
payment_summary = payments.groupby("payment_type")["payment_value"].agg(["count", "sum"])
print(payment_summary)

print("\n5. Top States by Sales")
sales = (
    orders.merge(customers[["customer_id", "customer_state"]], on="customer_id")
          .merge(payments[["order_id", "payment_value"]], on="order_id")
          .groupby("customer_state")["payment_value"]
          .sum()
          .sort_values(ascending=False)
          .head(10)
)
print(sales)

# Simple chart
plt.figure(figsize=(10, 5))
cat_df.sort_values().plot(kind="barh")
plt.title("Top 10 Product Categories by Revenue")
plt.xlabel("Revenue")
plt.tight_layout()
plt.savefig("top_categories_revenue.png")
print("\nChart saved as top_categories_revenue.png")

print("\nAnalysis complete.")