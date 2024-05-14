# Terralis

I've made this Android app using Flutter 2.5.1 and used Android Studio to develop. 

The goal was to help a small artisanal cosmetics company (Terralis) and its stock control.

All stock control, product sales and product recipes are stored in **Google Sheets**.

Even with this app, it was necessary to **keep** the direct use of **Spreadsheets** online and functional.

I built a **Web App** just for demonstration, but the SQLite features don't work because sqflite doesn't support web apps.

## Plugins
- sqflite 2.0.2
- gsheets 0.4.2
- uuid 3.0.6

## Functionalities
- Receipts (Recebimentos).
  - Works offline with SQLite database and sends information about sales (ex.: products sold, money received) to Google Sheets.
- Terralis Recipes (Receitas Terralis)
  - Get information about Terralis recipes types in Google Sheets. Ex.: Soap, Shampoo, Deodorant.
  - By selecting one of the types, get information about these recipes in Google Sheets.
  - Displays all ingredients of the selected recipe allowing to customize each ingredient individually.
  - Produce (Dar baixa) button. Highly complex action.
    - Based on all the ingredients in the selected recipe, this functionality scans all the Stock Control (Controle de Estoque) in Google Sheets.
    - Then, for each recipe ingredient, it calculates the remaining quantity after the recipe is produced and updates Google Sheets.
    - All changes in Google Sheets are stored in the History (Histórico) spreadsheet, informing the old and the new quantity in the Stock Control for further analysis.
    - This functionality also has a dry run feature that doesn't update the Stock Control, but reports all changes to the History (Histórico) spreadsheet for analysis.
    - If there's not enough of some ingredient in Stock Control or another error, the app warns the user and reports everything in the History (Histórico) spreadsheet.
- Yoga-se Recipes (Receitas Yoga-se)
  - All the features of Terralis Recipes, but for another brand.

