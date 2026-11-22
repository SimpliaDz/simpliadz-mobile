# Mobile point of sale

The mobile POS is a server-authoritative counter-sale flow. The app never calculates or persists sale totals locally; it renders the `Sale` returned by the API after each operation.

## Flow

1. Select an active location and price list.
2. Optionally select an open cash session.
3. Create a draft sale with `POST /sales`.
4. Search products using `GET /pos/products`, or scan a barcode using `GET /pos/products/by-barcode/{barcode}`.
5. Add each selected variant using `POST /sales/{id}/lines`.
6. Record a payment using `POST /sales/{id}/payments`; the mobile client creates a GUID idempotency key for safe retries.
7. Reload the sale and complete it using `POST /sales/{id}/complete` once its server-calculated balance is zero.

## Current scope

The first mobile POS release supports walk-in sales, product search/barcode scan, one-unit line additions, payment, and completion. Cash-session management, customer selection, discounts, line removal, historical sales, and returns remain separate operational pages to add in later milestones.

Cash payments may require an open session when the selected location has registers. The API validates this rule and all prices, stock, permissions, and totals.
