# **Nexus Library: Function Reference**

Welcome to the official documentation for the Nexus Library. This document provides a comprehensive overview of the functions available within the library, designed to help developers create powerful and feature-rich addons for Garry's Mod.

**Legend:**

* \[SHRD\] \- **Shared**: Can be used on both the server and the client.  
* \[SV\] \- **Server**: Can only be used on the server.  
* \[CL\] \- **Client**: Can only be used on the client.

## **\[SHRD\] Core & Loader Functions**

*These functions are essential for loading your addon's files and are available on both the client and server.*

| Function | Description |
| :---- | :---- |
| Nexus:LoadDirectory(dir, loadFirst) | Recursively loads all .lua files in a specified directory. loadFirst is an optional table of file paths to prioritize. |
| Nexus:LoadFile(path) | Loads a single file, automatically detecting its realm (cl\_, sv\_, sh\_). |
| Nexus:LoadServer(path) | Includes a server-side script. |
| Nexus:LoadClient(path) | Includes a client-side script and sends it to clients. |
| Nexus:LoadShared(path) | Includes a shared script and sends it to clients. |
| hook.Add("Nexus:Loaded", name, func) | A hook that is called after the Nexus Library and its modules have been fully loaded. |

## **\[SHRD\] In-Game Config Builder (v2)**

*Use this fluent builder to create powerful, in-game configuration menus for your addons. All functions are chained.*

| Function | Description |
| :---- | :---- |
| Nexus.Builder:Start() | Initializes a new configuration builder instance. |
| :SetName(name) | Sets the unique name and ID for your addon's configuration page. |
| :AddLabel({text}) | Adds a simple text label to the menu. |
| :AddButtons({id, label, buttons, onChange}) | Adds a row of buttons. Each button can have a text and a value. The onChange callback is fired on the server when a value is changed. |
| :AddTextEntry({id, label, placeholder, isNumeric, onChange}) | Adds a text input field. Can be set to numeric only. |
| :AddMultiTextEntry({id, label, entries, onChange}) | Adds a row of multiple text input fields. |
| :AddKeyTable({id, label, placeholder, defaultValue, onChange}) | Creates a key-value table editor, ideal for things like admin ranks or chat commands. |
| :AddTable({id, label, values, isPercentage, onChange}) | Creates an advanced, multi-column table editor. Supports text entries, checkboxes, and combo boxes within the table. Can be configured to act as a percentage/weight table. |
| :End() | Finalizes the configuration and registers it with the library. |

## **\[CL\] VGUI Elements (v2)**

*A modern, consistent, and theme-able set of UI components. This is the recommended version for all new UI development.*

### **Frame (Nexus:V2:Frame)**

The main window for your UI.

| Method | Description |
| :---- | :---- |
| :SetTitle(title) | Sets the text in the header. |
| :SetLogo(imgurId) | Sets the logo in the header. |
| :AddHeaderButton(icon, onClick) | Adds a clickable icon button to the header. |
| :HideHeaderButton() | Hides the default language selection button. |
| :SetBarIcon(icon, title, sub, onClick) | Adds a special-purpose, large button in the header. |
| :SelectContent(panelName) | Creates and docks a panel to fill the frame's content area. |
| PANEL:OnRefresh() | Hook called when the language changes, so you can recreate the UI. |

### **Button (Nexus:V2:Button)**

A standard clickable button.

| Method | Description |
| :---- | :---- |
| :SetIcon(imgurId) | Sets an icon for the button. |
| :SetColor(color) | Overrides the default button color. |
| :SetSecondary() | Applies the secondary theme color to the button. |
| :AutoWide(padding) | Automatically sizes the button's width to fit its text. |

### **TextEntry (Nexus:V2:TextEntry)**

A field for user text input.

| Method | Description |
| :---- | :---- |
| :SetPlaceholder(text) | Sets the placeholder text shown when the entry is empty. |
| :SetNumeric(boolean) | If true, only allows numbers to be entered. |
| :SetMultiLine(boolean) | Allows the text entry to have multiple lines. |
| :CenterPlaceholder() | Centers the placeholder text. |
| :GetValue() / :GetText() | Returns the current text in the entry. |
| :SetText(text) | Sets the current text. |
| PANEL:OnChange() | Hook called when the text value changes. |

### **ComboBox (Nexus:V2:ComboBox)**

A dropdown menu for selecting options.

| Method | Description |
| :---- | :---- |
| :AddChoice(text, onClick) | Adds an item to the dropdown. |
| :OnSelect(index, value) | Hook called when an item is selected. |
| :SetValue(text) | Sets the currently displayed text. |
| :GetValue() | Gets the currently displayed text. |

### **CheckBox (Nexus:V2:CheckBox)**

A toggleable checkbox.

| Method | Description |
| :---- | :---- |
| :SetState(boolean) | Sets the checked state. |
| :GetState() | Returns the current checked state (true or false). |
| PANEL:OnStateChanged(state) | Hook called when the checkbox is toggled. |

### **ScrollPanel (Nexus:V2:ScrollPanel)**

A panel with a vertical scrollbar for oversized content.

| Method | Description |
| :---- | :---- |
| :GetCanvas() | Returns the inner panel where child elements should be parented. |

### **Navbar (Nexus:V2:Navbar)**

A horizontal bar with selectable tabs.

| Method | Description |
| :---- | :---- |
| :AddItem(text, onClick, icon, id) | Adds a new tab to the navbar. |
| :SelectItem(id) | Programmatically selects a tab. |

### **Sidebar (Nexus:V2:Sidebar)**

A vertical bar with selectable tabs.

| Method | Description |
| :---- | :---- |
| :AddItem(text, onClick, icon, id) | Adds a new item to the sidebar. |
| :AddSpacer() | Adds a visual dividing line. |
| :SelectItem(id) | Programmatically selects an item. |

## **\[SV\] Server-Side Functions**

*These functions are exclusively for server-side scripts.*

### **General & Player Interaction**

| Function | Description |
| :---- | :---- |
| Nexus:ChatMessage(ply, messageTbl) | Sends a formatted chat message to a specific player. messageTbl is a table of colors and text, e.g., {color\_white, "Hello, ", Color(255,0,0), "world\!"}. |
| Nexus:Notify(ply, type, seconds, text, phraseAddon) | Shows a notification on the player's screen. If phraseAddon is provided, it will use the language system to translate text. |
| Nexus:PopupAsk(ply, text, callback) | Shows a confirmation popup to a player. The callback function is executed on the server if the player clicks "Yes". |

### **In-Game Config**

| Function | Description |
| :---- | :---- |
| Nexus:GetValue(id) | Retrieves the saved value for a given configuration ID. |
| Nexus:SetValue(id, value) | Sets and saves a value for a given configuration ID. This does **not** automatically network to clients. |

### **Database**

| Function | Description |
| :---- | :---- |
| Nexus:InitializeDatabase(name, type, data, callback) | Initializes a database connection. type can be "mysql" or "sql". data includes login details and initial queries. Returns a database object to the callback. |
| DB:Query(query, callback) | Executes a SQL query. The callback receives the results and the last insert ID. |
| DB:StartTransaction() | Begins a new database transaction (for MySQL). |
| DB:AddTransaction(query) | Adds a query to the current transaction. |
| DB:EndTransaction(callback) | Executes the transaction. |
| DB:Disconnect() | Closes the database connection. |

## **\[CL\] Client-Side Functions**

*These functions are exclusively for client-side scripts.*

### **UI & VGUI**

| Function | Description |
| :---- | :---- |
| Nexus:GetColor(name) | Retrieves a color from the current theme (e.g., "primary", "background", "red"). |
| Nexus:GetMargin(size) | Gets a consistent, scaled margin value. size can be "large", "normal", or "small". |
| Nexus:GetScale(number) | Scales a number based on the user's screen resolution for consistent UI sizing. |
| Nexus:GetFont({size, bold, dontScale}) | Creates and caches a font with the specified options. |
| Nexus:QueryPopup(text, onYes, onNo, ...) | Displays a simple "Yes/No" popup to the user. |
| Nexus:DermaMenu(optionsTbl, onClicked, ...) | A replacement for DermaMenu that matches the Nexus theme. |
| Nexus:DrawRoundedGradient(...) | Draws a rounded rectangle with a gradient. |
| Nexus:DrawRoundedBox(r, x, y, w, h, col) | Draws a highly performant rounded box. |
| Nexus.Masks.Start() / .Source() / .End() | A powerful alternative to stencils for creating complex visual effects and masks. |

### **User Settings**

| Function | Description |
| :---- | :---- |
| Nexus:GetSetting(id, default) | Gets a value from the client's local settings file. |
| Nexus:SetSetting(id, value) | Saves a value to the client's local settings file. |

### **Imgur & Helpers**

| Function | Description |
| :---- | :---- |
| Nexus:GetImgur(id) | Downloads an Imgur image, caches it, and returns a material. |
| Nexus:DrawImgur(id, x, y, w, h, ...) | Draws the cached Imgur material to the screen. |
| Nexus:GetTextColor(backgroundColor) | Returns the ideal text color (light/dark) for a given background color to ensure readability. |

## **\[SHRD\] Language Functions**

*Functions for managing multi-language support in your addons.*

| Function | Description |
| :---- | :---- |
| Nexus:AddLanguages(addon, lang, tbl) | Adds a table of language phrases for a specific addon and language code (e.g., "en", "fr"). |
| Nexus:GetPhrase(phrase, addon, ply) | Retrieves a translated phrase for the player's selected language. |
| Nexus:IsLanguageLoaded(lang) | Checks if all phrases for a given language are loaded across all addons. |
| Nexus:LoadLanguage(lang, callback) | \[CL\] Initiates a download of missing language phrases via Google Translate. |

