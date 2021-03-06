# How to customize your marketplace?

Before reading, should have your marketplace up and running and your should be able to access it via browser. If not, see the [installation instructions](../README.md).

There are a few settings you have to change to enable all customizations options. You can change these settings directly to database, or use Rails console.

## Make yourself a super admin

There are two admin roles in Sharetribe: Marketplace admin (defined in `community_memberships.admin`) and Super admin (`people.is_admin`).

Make yourself a super admin by setting your `people.is_admin` to `true` (int value 1). This will allow you to administrate all the marketplaces. It also enables some features that are not enabled to marketplace admins such as Admin > Braintree Payment API keys

## Enable all customization options

* Plan level (`communities.plan_level`): Change the plan\_level value to number 4. This will enable Admin > Integrations (Facebook, Twitter, Google Analytics e.g) and allow you to add custom CSS/JavaScript to the page head.
* Categories (`communities.category_change_allowed`): Change to `true` (int value 1). This will enable Admin > Listing categories.
* Custom listing fields (`communities.custom_fields_allowed`): Change to `true` (int value 1). This will enable Admin > Listing fields.
* Privacy policy (`communities.privacy_policy_change_allowed`): Change to `true` (int value 1). This will enable editing content of About > Privacy page
* Terms: (`communities.terms_change_allowed`): Change to `true` (int value 1). This will enable editing content of About > Terms of use page
* Logo (`communities.logo_change_allowed`): Change to `true` (int value 1). This will enable logo change in Admin > Community look and feel

## Customize transaction types

There are several transaction types in Sharetribe. Transaction type defined the type of the listing, e.g. is this listing about selling a product, renting or maybe giving a way for free. Transaction type belongs to one or many categories. In pratice this means that if you have categories "clothes" and "appartments", you might choose that only clothes and be sold and only appartments can be rented.

Transaction types have a direction. For example, "Selling old books" is an offer. "Looking for an appartment" is a request. There's one special transaction type, Inquiry, which is neither offer nor request.

Available transaction types:

* `Sell` (offer): Selling products (defaults: price field)
* `Rent` (offer): Renting products (defaults: price field, price per timeunit)
* `Lend` (offer): Lending for free (defaults: no price field)
* `Give` (offer): Give away for free (defauls: no price field)
* `Service` (offer): Selling services (defaults: price field)
* `ShareForFree` (offer): Sharing spaces for free (defaults: price field) DEPRECATED!
* `Request` (request): A general request. Doesn't specify whether it's a request to buy or rent.
* `Inquiry` (neither offer or request): A general message

The transaction types are defined in `transaction_types` table. The translations are defined in `transaction_type_translations`. 

`transaction_types` table have a following customization columns:

* `price_field`: Is price field available or not. Only offer's can have price field.
* `price_quantity_placeholder`: A placeholder text for price quantity, e.g. price $10 per hour. Possible values: 
  * `mass`: "piece, kg, l, m2, ..."
  * `time`: "hour, day, month, ..."
  * `long_time`: "week, month, ..."

You can add new transaction types by adding a new row to `transaction_types` table and translations to `transaction_type_translations`. **Important:** The translations are cached. If you change a translation, you need to go to `transaction_type` table and change the `updated_at` column of that transaction_type.

After you have successfully created a transaction type, you need to go to Admin > Categories and select which transaction types are available in which category.

**A word of warning!** Don't overuse transaction types! We have noticed that the best marketplaces usually have just one transaction type.
