# Competitor Websites & Customer QR-Ordering Experiences — Feature Matrix vs Ours (India, 2025–2026)

> **Method note (read first):** This session's egress policy blocked direct page fetches. Every `WebFetch` and `curl` to petpooja.com, dotpe.in, restroworks.com, menutiger.com, wikipedia.org and others failed (proxy 403 / DNS ENOTFOUND). So I could not go through the sites page by page. I also could not open demo menus or watch YouTube walkthroughs. Every finding below comes from **web-search results that summarise the cited pages**, and each URL is the page the search engine attributed the claim to. Treat the claims as "vendor page says X (via search excerpt)", not as hands-on verification. Anything I could not tie to a page is marked **unverified**. A quick manual click-through of the key pages before external use is recommended, especially pricing, OTP flow and UPI handling.
>
> **Legend used in the matrix:** **Y** = vendor page (or a reliable listing) says yes · **N** = source says it is absent / not offered · **Add-on** = sold separately · **?** = unverified (nothing found either way) · **(3P)** = only a third-party or competitor source.

## Where exactly do we win and lose feature-for-feature?

### Takeaway
Two groups of competitors sit on either side of us.
- **POS suites** (Petpooja, DotPe/Rista, Restroworks, GoFrugal, Torqus) do far more: GST billing, inventory, aggregators, Tally, KDS/thermal printing, running table bills. They are priced at roughly ₹10k–₹1L+/year/outlet and sold through demos.
- **Low-cost Indian QR startups** (Scan & Order, MenuScan, QRSathi, AviQR, Ahaar Scan) undercut or match our price. Several already offer things we lack: multi-language menus, WhatsApp, GST bills, table sessions, Google-review/loyalty.

**Where we win:**
- Our UPI-intent + UTR reference model needs no payment gateway, so there is no MDR/commission on customer payments.
- We ship a kitchen display with late flags and live order tracking at a ₹199–₹459 price point.
- We offer customer self-cancel before kitchen start, an explicit privacy consent screen, and revocable per-table QRs.
- We include 3–25 staff seats with five roles, multi-outlet support and an Android vendor app.

**Where we lose:**
- Multi-language menus.
- Call-waiter / bill request.
- Feedback and loyalty.
- One running bill per table (table sessions).
- GST invoices.
- Direct thermal printing.
- WhatsApp.
- Aggregator and Tally integrations.
- Analytics beyond a daily dashboard.

### Cited Findings

#### Competitor profiles (what each site says)

**1. Petpooja — Scan & Order (add-on to Petpooja POSS)**
- Each table gets its own QR. Scanning opens the menu in the phone browser with no app: "the diner never downloads an app" — [Petpooja blog: What is Scan and Order](https://blog.petpooja.com/industry-business-guides/what-is-scan-and-order-qr-ordering-indian-restaurants/)
- Flow: browse categories → tap items → **select variations and add-ons** → submit. An **OTP / validation code** confirms the order and the KOT fires through Petpooja POSS after staff validate it. Pages differ on whether the OTP goes to the customer's phone or is validated by the captain — [Petpooja Scan & Order](https://www.petpooja.com/poss/scan-and-order); [Petpooja blog](https://blog.petpooja.com/industry-business-guides/what-is-scan-and-order-qr-ordering-indian-restaurants/)
- **Repeat orders:** the guest rescans the same QR and new items "join the running bill". The product page says "Take and manage multiple orders from the same table" — [Petpooja blog](https://blog.petpooja.com/industry-business-guides/what-is-scan-and-order-qr-ordering-indian-restaurants/); [petpooja.com/scan-and-order](https://www.petpooja.com/scan-and-order)
- **Customer details:** an older Petpooja blog says the diner enters a phone number or email, then selects a payment method — [Petpooja blog: new ways of taking orders](https://blog.petpooja.com/poss/advanced-ways-of-placing-orders-at-restaurant/)
- **Payment:** the product page shows "Pay at counter" or "pay online". The guide says payment from the phone is "possible (depends on setup)". Petpooja Pay+ (card/UPI/QR at the counter) runs via partners such as Razorpay and Paytm — [Petpooja Scan & Order](https://www.petpooja.com/poss/scan-and-order); [Petpooja Finance blog](https://blog.petpooja.com/industry-business-guides/petpooja-finance-money-layer-in-pos/)
- **Dine-in vs takeaway:** sources conflict. The newer guide says "The system works for dine-in only". An older COVID-era post says QR codes can be placed outside for takeaway — [Petpooja blog (new)](https://blog.petpooja.com/industry-business-guides/what-is-scan-and-order-qr-ordering-indian-restaurants/); [Petpooja Covid toolkit](https://blog.petpooja.com/operations-workflows/petpoojas-covid-19-toolkit-technology-to-battle-the-virus/)
- **Call waiter / bill:** a separate paid **hardware** add-on, the "Wireless Calling Device", with buttons for water, waiter, bill and cancel. Alerts go to the POS, Captain App and TV — [Petpooja waiter calling](https://petpooja.com/waiter-calling). Whether the QR web flow itself has call-waiter is **unverified**.
- **Kitchen:** KOT goes through the POS. KDS is sold as an add-on — [Petpooja integrations blog](https://blog.petpooja.com/poss/must-have-integrations-for-managing-your-restaurant/); [Petpooja token management](https://www.petpooja.com/poss/online-order-token-management)
- **Integrations:** Swiggy/Zomato, website and WhatsApp orders on a single screen, with menu push to aggregators and "zero commission on integrating" aggregators. There is a Tally integration (sales, GST, expenses). Integration counts conflict: 200+ on the integrations page vs 150+ elsewhere — [Petpooja integrations](https://www.petpooja.com/poss/restaurant-integrations); [Petpooja online order management](https://www.petpooja.com/poss/online-order-management-software)
- **Other modules:** GST billing and inventory ([Petpooja Invoice blog](https://blog.petpooja.com/finance-compliance/petpooja-invoice-features/)), CRM ([petpooja.com/crm](https://www.petpooja.com/crm)) and customer feedback management ([petpooja.com/customer-feedback-management](https://www.petpooja.com/customer-feedback-management))
- **Pricing:** not published by Petpooja (3P). Third-party listings put it at ~₹10,000 / ₹20,000 / ₹40,000 per outlet per year. Techjockey lists the top tier at ₹30,000. Techjockey places Scan & Order in the mid tier, while Capterra lists it under "POSS Lite" with a custom quote. Servyn says QR table ordering is a separate add-on charge — [Capterra](https://www.capterra.com/p/172163/Petpooja-Restaurant-Management-Platform/pricing/); [Techjockey](https://www.techjockey.com/detail/petpooja-pos); [Servyn](https://servyn.in/guides/petpooja-software-price-comparison/). The Scan & Order add-on price is **unverified**.
- **Support:** "24x7 Customer Support" in "18+ Indian languages". Phone numbers conflict across pages (+91 7969223344, +91 7046223344, +91 91043 69797) — [Petpooja support](https://www.petpooja.com/poss/support); [Petpooja home](https://www.petpooja.com/)
- **Trust:** "1,50,000 businesses trust Petpooja" (self-reported) — [Petpooja about](https://www.petpooja.com/about-us)
- **Self-serve signup / setup time:** **unverified**. Pricing isn't public, which suggests a sales-led model (inference).

**2. DotPe (QR ordering + Rista POS; Rista is presented on dotpe.in)**
- Onboarding: merchants add menus and locations, then generate QR codes for tables and takeaway. The homepage headline is "Go live in 5 simple steps" — [DotPe home (via search)](https://dotpe.in/). The full 5-step list is **unverified**.
- Pitch: "Provide a contactless ordering experience, accept payments & more with your store's QR code" — [dotpe.in](https://dotpe.in/)
- Rista POS (on DotPe's site) offers "Simplified QR based ordering", reservations, an "advanced waiter app", billing and KOTs — [DotPe Rista page](https://dotpe.in/rista-restaurant-management-software.html)
- **Customer flow (press, 2020–21):** scan → menu → select → pay by card, net banking or UPI. Follow-up communication happens over the customer's WhatsApp number — [CRN](https://www.crn.in/?p=35820); [Outlook Business](https://www.outlookbusiness.com/magazine/business/story/with-nrais-blessing-this-fintech-start-up-is-dreaming-big-should-restaurant-aggregators-be-worried-5964). Whether a current OTP or login is required is **unverified**.
- **WhatsApp:** DotPe sells a WhatsApp Business API / marketing product — [DotPe WhatsApp](https://dotpe.in/whatsapp-for-business/)
- **Fees:** the only figure found is a 2020-era "flat transaction fee of Rs.1–1.5 on every order" — [Outlook Business](https://www.outlookbusiness.com/magazine/business/story/with-nrais-blessing-this-fintech-start-up-is-dreaming-big-should-restaurant-aggregators-be-worried-5964). A competitor blog claims 2–3% commission on online orders (3P, competitor-authored) — [Billfeeds](https://billfeeds.com/blog/dotpe-vs-billfeeds.html). Current MDR, settlement time and pricing are **unverified**.
- **Trust:** Starbucks, McDonald's (North & East), Haldiram's, Social, Chili's, Barista and Cafe Delhi Heights were cited in 2020–21 coverage — [Entrepreneur India](https://india.entrepreneur.com/news-and-trends/dotpe-collaborates-with-mcdonalds-india-north-east-to/354700); [Outlook Business](https://www.outlookbusiness.com/enterprise/feature/with-nrais-blessing-this-fintech-start-up-is-dreaming-big-should-restaurant-aggregators-be-worried-5964). Vendor claims include "98% cut in third-party commissions" for a burger chain and "60% direct orders" — [dotpe.in](https://dotpe.in/); [dotpe.tech](https://dotpe.tech/)
- **Privacy incident:** in Sept 2024 a user reported that inspecting a cafe's DotPe QR API calls exposed customers' names, phone numbers and order details. The post was taken down after a legal notice from DotPe — [Benzinga India](https://in.benzinga.com/news/24/09/41019389/how-this-person-accessed-sensitive-user-information-by-just-scanning-cafe-qr-code)
- Reviewer-noted limits (3P): "KDS is basic", "limited offline mode" — [restrofi.com comparison](https://restrofi.com/blog/restaurant-pos-alternatives-india)

**3. Rista (DotPe's restaurant POS)**
- "Secure QR code solutions for a contactless and efficient ordering, and payment experience". A direct-ordering module generates and manages QR codes. Vendor claims "up to 27% higher AOV via digital ordering" — [ristaapps.com](https://ristaapps.com/); [Rista POS](https://ristaapps.com/Restaurant-pos-software)
- POS: dine-in orders with table no., KOTs, split payments, multi-brand billing, two-way aggregator integration, auto-accept of aggregator orders, inventory — [Rista POS](https://ristaapps.com/restaurant-point-of-sale-software); [Rista inventory](https://ristaapps.com/restaurant-inventory-management)
- WhatsApp Business API product — [Rista WhatsApp](https://ristaapps.com/whatsapp-business-api)
- **Trust:** "trusted by 100k+ merchants across India" — [ristaapps.com](https://ristaapps.com/)
- **Price (3P):** starting ₹1,00,000 + GST — [Techjockey](https://www.techjockey.com/detail/rista-pos)
- Guest-facing flow, OTP, UPI handling and Tally are **unverified**.

**4. Restroworks (formerly POSist) — RestroSCAN**
- "Table and takeaway QR code ordering", with guests customising orders and paying from their phones — [RestroSCAN](https://www.restroworks.com/restroscan-qr-code-ordering/); [Restroworks QR ordering system](https://www.restroworks.com/qr-code-ordering-system/)
- Menu changes sync in real time and only in-stock items are shown. Add-ons and combos are recommended dynamically — [Restroworks QR ordering system](https://www.restroworks.com/qr-code-ordering-system/); [Restroworks glossary](https://www.restroworks.com/glossary/qr-code-ordering/)
- Order status: customers get notifications at confirmation, preparation and delivery, plus wait-time/delay info. There is also a Customer Order Display — [Restroworks customer order display](https://www.restroworks.com/customer-order-display/)
- Payments: QR code payment and multiple tenders. A Capterra reviewer mentions Paytm/EDC — [Restroworks COD page](https://www.restroworks.com/customer-order-display/); [Capterra reviews](https://www.capterra.com/p/142877/Restroworks/reviews/?page=3)
- Feedback collection is supported — [Restroworks QR ordering system](https://www.restroworks.com/qr-code-ordering-system/). Call-waiter was **not found**.
- **Pricing:** custom / not published. Capterra shows "$200 per user per year" — [SaaSworthy](https://www.saasworthy.com/product/restroworks/pricing); [Capterra](https://www.capterra.com/p/142877/Restroworks/pricing/)
- **Trust:** 25,000+ locations in 53 countries; Taco Bell, Subway, Nando's, Carl's Jr and others; "3 million+ transactions per day", "500+ third-party integrations", "purpose-built for large chains" — [Restroworks POS page](https://www.restroworks.com/restaurant-pos-system/); [Restroworks LLM info](https://www.restroworks.com/llm-info/). Country counts vary across pages (35/50/52/53).

**5. Thrive (Thrive Now)**
- Table setup: Business Dashboard → Settings → Table Management (single or bulk upload) → download table-specific QR codes. The help article is ~4.5 years old — [Thrive help](https://help.thrivenow.in/416/restaurant-configuration-thrive-download-table-specific)
- **Table ordering:** "place multiple orders in succession, attributed to their table number … pay for the total of the orders in a single settlement" (a running table bill). There is also a QSR/instant mode (order and pay immediately) and a view-only menu — [Thrive dine-in](https://about.thrivenow.in/dine-in)
- **Payments:** via Razorpay — [Razorpay App Store: Thrive](https://razorpay.com/app-store/thrive/)
- **Pricing:** "3% per delivery and takeaway orders and dine-in mode is free to use"; setup free — [Thrive pricing](https://about.thrivenow.in/pricing); [Thrive feedback system](https://about.thrivenow.in/feedback-system). An older blog says "flat Re.1 for dine-in orders" (conflict) — [Thrive blog](https://about.thrivenow.in/post/online-ordering-system-for-restaurants). The marketing suite costs ₹349 / ₹1,049 / ₹1,249 per month (₹299 / ₹899 / ₹999 billed annually) — [Thrive pricing](https://about.thrivenow.in/pricing)
- **Feedback:** digital forms with CSAT, polls and NPS. CRM segments and automated campaigns — [Thrive feedback](https://about.thrivenow.in/feedback-system); [Thrive marketing](https://about.thrivenow.in/marketing)
- **Trust:** "9500+ restaurants across 76 cities" ([Razorpay App Store](https://razorpay.com/app-store/thrive)) vs "14,000 restaurants across 80 cities" in 2023 (Coca-Cola India investment) ([BeverageDaily](https://www.beveragedaily.com/Article/2023/04/18/Coca-Cola-India-invests-in-food-delivery-company-Thrive/)). The counts conflict.

**6. GoFrugal (ServQuick / restaurant POS; "OrderEasy")**
- "Order Easy – Gofrugal" on the App Store is an **e-commerce ordering app** (phone-number registration, "three taps ordering", order status). It is not a table-QR product — [App Store: Order Easy](https://apps.apple.com/us/app/-/id1460509872)
- GoFrugal's table QR offering is "Contactless Dining". Each table gets a unique QR, orders "directly reflect on your billing system and kitchen display screen", guests can add kitchen notes and special requests and settle bills, and there is no app (browser) — [GoFrugal contactless dining](https://www.gofrugal.com/restaurant/contactless-dining/); [GoFrugal blog](https://www.gofrugal.com/blog/contactless-ordering-for-restaurants/)
- **Setup (ServQuick KB):** Masters → Digital Menu → create menu → map items → generate table QRs. Optional **table request approval** notifies the POS so staff can accept. Turning approval off requires regenerating the QRs — [GoFrugal community KB](https://community.gofrugal.com/portal/en/kb/servquick/general/articles/contactless-dine-in-servquick)
- KDS + KOT and online payment integration — [GoFrugal KDS](https://www.gofrugal.com/restaurant/kitchen-display-system.html); [GoFrugal contactless dining](https://www.gofrugal.com/restaurant/contactless-dining/)
- **Pricing:** a very old page says "INR 500 per user, per month" for POS. A QR-specific price is **unverified** — [GoFrugal cloud POS](https://www.gofrugal.com/cloud/restaurant-point-of-sale.html)
- **Trust:** "nearly two decades" (self-reported). No customer count found.

**7. Torqus (now presented as "inresto + Torqus")**
- The homepage title is "inresto + Torqus – The Complete Restaurant Management…". Modules include POS, KOT app, supply chain, loyalty/CRM, online ordering site/app and call-centre routing — [torqus.com](https://www.torqus.com/); [Torqus loyalty](https://www.torqus.com/loyalty-and-crm-programs-module.html); [Torqus SCM](https://www.torqus.com/supply-chain-management.html)
- inresto (Dineout's B2B arm) historically offered "digital menus, pre-ordering, table booking, digital payments and digital feedback" — [Restaurant India (DLF malls)](https://www.restaurantindia.in/news/dlf-malls-goes-digital-to-promote-contactless-dining-across-malls.n19374)
- A Torqus table-QR ordering product page was **not found**. QR ordering flow, pricing and trust counts are **unverified**.

**8. MenuTiger (global SaaS; not India-specific)**
- Plans: Freemium (1 store, up to 10 tables/QRs), then Regular $17, Advanced $46 and Premium $119 per month, with 15% off annual billing and a **14-day free trial** on paid plans — [MenuTiger help: plans](https://menutiger.helpscoutdocs.com/article/153-what-are-the-different-plans-and-subscriptions-available); [MenuTiger blog: menu price](https://www.menutiger.com/blog/qr-code-menu-price). A blog gives Premium as $199 (conflict).
- **Commission-free**. Payments via PayPal, Stripe, Adyen and Venmo. **No UPI / Indian gateway found** — [MenuTiger blog](https://www.menutiger.com/blog/best-qr-code-menu-for-restaurants)
- **"Hot Actions"**: guests tap Request at the table to ask for cleaning, bill-out or water, and staff see requests on the dashboard — [MenuTiger waiter call blog](https://www.menutiger.com/blog/restaurant-waiter-call-button-system)
- **19 languages**, allergens and portion sizes, feedback survey and emailed feedback reports — [MenuTiger features](https://www.menutiger.com/features); [MenuTiger pricing](https://www.menutiger.com/pricing)
- KDS on Advanced/Premium only, POS integration (Square), white-label and multi-store on paid plans — [MenuTiger KDS blog](https://www.menutiger.com/blog/kitchen-display-system)
- Self-serve: every new account starts on Freemium — [MenuTiger help](https://menutiger.helpscoutdocs.com/article/153-what-are-the-different-plans-and-subscriptions-available)

**9. FineDine (global SaaS)**
- Pricing page: Starter $29, Growth $69, Premium $135 per month (billed annually, 20% saving). The homepage FAQ says "from $49/month" (conflict). No lock-in, no hidden fees. The trial has some features locked — [FineDine pricing](https://www.finedinemenu.com/en/pricing/); [FineDine AI home](https://www.finedinemenu.com/en/ai-home-/)
- Dine-in QR per table. **Quick Service** mode creates a separate ticket per order; **Full Service** mode keeps one open ticket per table — [FineDine QR dine-in ordering settings](https://support.finedinemenu.com/en/articles/6062415-qr-dine-in-ordering-settings)
- **Call Waiter** and other service requests go to the dashboard — [FineDine service requests](https://support.finedinemenu.com/en/articles/3395875-how-to-set-up-dine-in-service-requests)
- **Languages:** Starter 1, Growth/Premium unlimited (pages variously say 40 languages) — [FineDine pricing](https://www.finedinemenu.com/en/pricing/)
- Online payment requires a gateway integration. The FAQ lists international credit cards. **No UPI or Indian gateway found** — [FineDine mobile order & pay](https://www.finedinemenu.com/en/solutions/qr-payment-system-mobile/); [FineDine pricing](https://www.finedinemenu.com/en/pricing/)
- India-specific pricing in INR is **unverified**.

**10. GloriaFood (Oracle)**
- Free ordering and table reservations. Paid add-ons: online payments ~$29/mo, POS $49/mo/location, promo marketing $19/mo, branded apps $59/mo (3P, figures vary) — [Capterra](https://capterra.com/p/198378/GloriaFood/); [Toolradar](https://toolradar.com/tools/gloriafood/pricing); [CostBench](https://costbench.com/software/food-delivery-platform/gloriafood/)
- **Closed to new restaurants since early 2025. End of life 30 April 2027** (one source says 31 March 2027). The sources are mostly competitors — [Storekit](https://gloria-food.storekit.com/blog/gloriafood-closed-to-new-restaurants); [Restolabs](https://www.restolabs.com/gloria-food-alternative); [Gosnappy](https://gosnappy.io/blog/gloriafood-is-shutting-down-what-restaurant-operators-should-do/); [Fleksa](https://fleksa.com/en/blog/gloriafood-shutdown-checklist-2027). A competitor rates its QR ordering "Limited" with no pay-at-table (3P) — [Storekit compare](https://gloria-food.storekit.com/compare)
- **Implication:** not a live competitor for new Indian signups.

**11. Indian small-stall-focused startups (discovered)**
- **Scan & Order (scanorder.in)** — closest direct price competitor.
  - Basic **₹199 for 31 days**, Popular **₹699 for 182 days**, Business **₹999 for 399 days**; **30-day free trial**.
  - Basic includes full QR menu & table ordering, real-time order notifications, basic sales analytics, takeaway + dine-in, email support. Popular adds advanced analytics, table management and discount codes. Business adds a mobile app and onboarding support.
  - Ordering works in the mobile browser. WhatsApp is used for support only.
  - Sources: [scanorder.in](https://scanorder.in/); [scanorder.in blog](https://scanorder.in/blog/best-qr-code-ordering-systems-for-restaurants-in-india)
  - UPI, KDS and roles are **unverified**.
- **MenuScan (menuscan.in)**
  - Table QR → browser ordering, kitchen tickets, POS, **GST invoices on table close**, cash/UPI/card, **WhatsApp alerts per order**, sold-out marks, **shared table sessions with separate bills**, multi-location login, **menus in 22 Indian languages**.
  - Gateway named as Razorpay/PhonePe on one page and PayU on others.
  - Pricing conflicts: "from ₹250/month, 7-day trial" vs ₹129 / ₹249 / ₹499 vs a ₹250–₹750 range.
  - Sources: [menuscan.in](https://menuscan.in/); [MenuScan features](https://menuscan.in/features); [MenuScan FAQ](https://menuscan.in/faq); [MenuScan blog](https://menuscan.in/blog/best-qr-ordering-system-2026)
- **QRSathi (qrsathi.in)**
  - A single printed QR gives menu + **WhatsApp ordering** + **UPI deep link** + **Google review prompt** + **loyalty stamp card**.
  - "No app, sign-up or phone number" for customers; Hindi & regional languages; ₹0 to start; ~3-minute setup.
  - Source: [qrsathi.in](https://qrsathi.in/)
- **Also seen (not profiled in depth):**
  - **AviQR**: free Starter capped at 20 items, 50 orders/day and 1 QR; 9 Indian menu languages; Razorpay — [aviqr.com](https://aviqr.com/); [itechguides](https://www.itechguides.com/products/aviqr/)
  - **Ahaar Scan**: ₹399/mo or ₹2,999/yr, UPI/card with next-day settlement, zero commission — [GetApp](https://www.getapp.com/all-software/a/ahaar-scan/)
  - **Dinehere**: ₹499/mo, loyalty — [Capterra](https://www.capterra.com/p/10038917/Dinehere/)
  - **QR FOOD MENU**: from ₹499/mo, WhatsApp ordering, PayU — [qrfoodmenu.com](https://www.qrfoodmenu.com/)
  - **Zyrio**: Bluetooth bill printing — [zyrio.in](https://www.zyrio.in/)
  - **Orderzy**: free to restaurants; diners pay a platform fee — [Capterra](https://www.capterra.co.uk/software/1105128/Orderzy)

#### FEATURE MATRIX

Columns: **PP** = Petpooja Scan & Order · **DP/R** = DotPe + Rista · **RW** = Restroworks RestroSCAN · **TH** = Thrive · **GF** = GoFrugal Contactless Dining · **TQ** = Torqus/inresto · **MT** = MenuTiger · **FD** = FineDine · **GL** = GloriaFood · **S&O** = scanorder.in · **MS** = MenuScan · **QS** = QRSathi · **Ours**

Cited sources for each cell are in the profiles above. "?" = unverified.

| Feature | PP | DP/R | RW | TH | GF | TQ | MT | FD | GL | S&O | MS | QS | **Ours** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **Onboarding / commercial** | | | | | | | | | | | | | |
| Public pricing | N (3P only) | N | N (custom) | Y (dine-in free; 3% delivery/TA) | N (old ₹500/user/mo) | N | Y ($0–119) | Y ($29–135, conflicting) | Y (free + add-ons) | Y (₹199/31d) | Y (conflicting ₹129–750) | Y (₹0 start) | **Y ₹199/₹299/₹459/mo** |
| Self-serve signup | ? (demo-led, inferred) | ? | N (sales-led, inferred) | ? | ? | ? | Y (Freemium) | Y (trial) | N (closed to new) | Y | Y (no card) | Y (~3 min) | **Y** |
| Free trial / free tier | ? | ? | N (Capterra) | Dine-in free | ? | ? | Freemium + 14-day | Trial (some locked) | Free (closed) | 30-day trial | 7-day trial | Free tier | **14-day trial** |
| Per-order commission on dine-in | No (subscription) | Rs1–1.5/order (2020) / 2–3% (3P) – ? | ? | Free (older: Re1) | ? | ? | 0% | ? | 0% | ? | ? | ? | **0% (no gateway)** |
| **Customer ordering** | | | | | | | | | | | | | |
| Browser ordering, no app | Y | Y | Y (phone; browser implied) | ? | Y | ? | ? | Y (QR menu) | ? | Y | Y | Y | **Y** |
| QR per table | Y | Y | Y | Y | Y | ? | Y | Y | ? (3P "Limited") | Y | Y | N (single QR) | **Y (revocable)** |
| Takeaway via QR | Conflicting (new: dine-in only) | Y | Y | Y (QSR mode) | ? | ? | ? | Y (Quick Service mode) | ? | Y | ? | ? | **Dine-in only (per brief)** |
| Customer login / OTP | OTP/validation code (mandatory per page) | ? (WhatsApp number used) | ? | ? | Staff approval option | ? | ? | ? | ? | ? | ? | No phone number needed | **Optional OTP** |
| Staff approval before kitchen (anti-prank) | Y | ? | ? | ? | Y (optional) | ? | ? | ? | ? | ? | ? | ? | ? (not in brief) |
| Repeat orders join one table bill (table session) | Y | ? | ? | Y | ? | ? | ? | Y (Full Service) | ? | ? | Y | ? | **N** |
| Notes / special instructions | ? | ? | ? | ? | Y | ? | ? | ? | ? | ? | ? | ? | ? (not in brief) |
| Live order tracking for customer | ? | ? | Y (stage notifications) | ? | ? | ? | ? | ? | ? | ? | ? | ? | **Y (Growth+)** |
| Customer self-cancel | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | **Y (before kitchen starts)** |
| Token numbers | Y (token mgmt, POS) | ? | Y (customer order display) | ? | ? | ? | ? | ? | ? | ? | ? | ? | **Y** |
| Call waiter / bill request | Add-on hardware | ? | ? | ? | ? | ? | Y (Hot Actions) | Y | ? | ? | ? | ? | **N** |
| Feedback / ratings | Y (module) | ? | Y | Y (CSAT/NPS) | ? | Y (inresto digital feedback) | Y (survey) | ? | ? | ? | ? | Y (Google review prompt) | **N** |
| Loyalty / CRM | Y (CRM) | Y (WhatsApp mktg) | ? | Y (CRM, campaigns) | ? | Y (loyalty module) | ? | ? | Paid promo add-on | Discount codes (Popular) | ? | Y (stamp card) | **N** |
| Multi-language menu | ? | ? | ? | ? | ? | ? | Y (19) | Y (plan-dependent) | ? | ? | Y (22 Indian) | Y (Hindi/regional) | **N** |
| Privacy consent shown to customer | ? | ? (2024 data-exposure report) | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | **Y** |
| **Menu** | | | | | | | | | | | | | |
| Variants / add-ons | Y | ? | Y (add-ons, combos) | ? | ? | ? | ? | ? | ? | ? | ? | ? | **Y** |
| Veg / egg / non-veg tags | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | **Y** |
| Item photos | ? | ? | ? | ? | ? | ? | ? | Y (AI photo credits) | ? | ? | ? | ? | **Y** |
| Out-of-stock / sold out | ? | ? | Y | ? | ? | ? | ? | ? | ? | ? | Y | ? | ? (not in brief; daily hours only) |
| Item time scheduling | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | **Y (daily hours)** |
| Allergens / portion sizes | ? | ? | ? | ? | ? | ? | Y | ? | ? | ? | ? | ? | Portions Y |
| Outlet-specific menus | ? | Y (multi-brand) | ? | ? | ? | ? | Y (multi-store) | ? | ? | ? | ? | ? | **Y** |
| Bulk menu import | ? | ? | ? | Y (bulk tables) | ? | ? | ? | ? | ? | ? | ? | ? | **Y (CSV)** |
| **Payments** | | | | | | | | | | | | | |
| Pay from phone | Setup-dependent | Y (card/NB/UPI) | Y | Y (Razorpay) | Y | ? | Y (PayPal/Stripe etc.) | Y (gateway req.) | Paid add-on | ? | Y | Y (UPI deep link) | **Y (UPI intent)** |
| Indian UPI | Y (Pay+, counter) | Y | Y (Paytm, 3P) | Y (via Razorpay) | ? | ? | **Not found** | **Not found** | ? | ? | Y | Y | **Y** |
| Gateway (auto-reconcile) vs intent | Gateway partners | Gateway | Gateway | Gateway (Razorpay) | Gateway | ? | Gateway | Gateway | Gateway | ? | Gateway (Razorpay/PhonePe/PayU) | Intent / deep link | **Intent + customer UTR (manual verify)** |
| Cash / pay at counter | Y | ? | Y | ? | ? | ? | ? | ? | ? | ? | Y | ? | **Y** |
| Settlement time disclosed | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | **N/A (direct to merchant UPI)** |
| **Kitchen** | | | | | | | | | | | | | |
| KOT | Y | Y | Y | ? | Y | Y (KOT app) | ? | ? | ? | ? | Y | ? | **Y (browser print dialog)** |
| KDS | Add-on | Y ("basic", 3P) | Y (COD) | ? | Y | ? | Y (Adv/Premium) | Dashboard | ? | Notifications | ? | ? | **Y (late flags)** |
| Direct thermal / Bluetooth printing | Y (POS) | Y (POS) | Y (POS) | ? | Y (POS) | Y | ? | ? | ? | ? | ? | ? | **N** |
| New-order alert | Y | Y | Y | ? | Y | ? | Y | Y | Y | Y | Y (WhatsApp) | ? | **Y (sound/notification)** |
| **Back office** | | | | | | | | | | | | | |
| GST invoice / billing | Y | Y | Y | ? | Y | Y | N (not India) | ? | ? | ? | Y | ? | **N** |
| Inventory | Y | Y | ? | ? | Y | Y (SCM) | ? | ? | ? | ? | ? | ? | **N** |
| Reports / analytics | Y (Insight module) | Y | Y | Y | Y | Y | Y (detailed on higher tiers) | ? | ? | Basic → advanced | ? | ? | **Daily dashboard only** |
| Staff roles / seats | Y (POS, captain app) | Y (waiter app) | Y | ? | Y | Y | Users by plan | ? | ? | ? | ? | ? | **Y: 5 roles, 3/8/25 seats** |
| Multi-outlet | Y | Y | Y (chains) | ? | Y | Y | Y (paid) | Y (Premium, ?) | Y (per location) | ? | Y | ? | **Y** |
| Aggregators (Swiggy/Zomato) | Y | Y | Y | (alternative to them) | Y (online ordering) | Y (online ordering) | N | ? | N | N | ? | N | **N** |
| Tally | Y | ? | ? | ? | ? | ? | N | N | N | ? | ? | ? | **N** |
| WhatsApp | Y | Y | ? | Y (marketing) | ? | ? | ? | ? | ? | Support only | Y (alerts) | Y (ordering) | **N** |
| Offline mode | Y (POS desktop; ?) | "Limited" (3P) | ? | ? | ? | ? | ? | ? | ? | ? | ? | ? | **N** |
| Android vendor app | Y (Captain app) | Y | ? | ? | ? | Y (billing app) | ? | ? | Y | Business plan | ? | ? | **Y** |
| **Support & trust** | | | | | | | | | | | | | |
| Support channels | 24x7, 18+ Indian languages, phone/email | ? | ? | ? | ? | ? | ? | ? | Reduced since 2025 (3P) | Email (Basic); WhatsApp | ? | ? | ? |
| Claimed scale | 1,50,000 businesses | McD, Starbucks etc. (2020) | 25,000+ locations, 53 countries | 9,500+ / 14,000 (conflict) | "nearly two decades" | ? | ? | ? | Shutting down Apr 2027 | ? | ? | ? | — |

### Inferences
- **Our clear wins:**
  - **Price vs POS suites.** ₹199–₹459/month (₹2.4k–₹5.5k/yr) vs Petpooja's ~₹10k–₹40k/yr/outlet (3P) and Rista's ~₹1L (3P).
  - **No per-transaction fees on customer payments**, because UPI goes straight to the merchant's VPA.
  - A **kitchen display with late flags** in the base offering, where Petpooja sells KDS as an add-on and MenuTiger gates it to Advanced/Premium.
  - **Customer self-cancel before kitchen start**, which none of the competitor pages mentioned.
  - **Explicit privacy consent.** This is a differentiator worth marketing given DotPe's 2024 data-exposure report.
  - **Revocable per-table QRs.** GoFrugal requires regenerating QRs when settings change.
- **Where we tie:** browser ordering, table QR, add-ons, photos, multi-outlet, staff roles, new-order alerts and an Android app. These are common, not differentiators.
- **Where we lose vs low-cost Indian startups (the more dangerous set):**
  - Scan & Order's ₹999 for 399 days works out to ~₹75/month. That undercuts our ₹199 entry plan on an annual basis.
  - MenuScan bundles GST invoices, table sessions, WhatsApp alerts and 22 Indian languages at a similar or lower price.
  - QRSathi offers a free tier with WhatsApp ordering, UPI deep link, Google review prompt and loyalty.
- **Where we lose vs POS suites:** GST billing, inventory, aggregators, Tally, thermal printing, running table bills, mature analytics, 24x7 multilingual support and large trust numbers.
- **Global SaaS (MenuTiger, FineDine):** they win on call-waiter, languages and feedback. However, no Indian UPI rail was found for either, which is a real weakness for Indian small vendors. GloriaFood is effectively out of the market (closed to new signups, EOL April 2027).
- **UPI intent + UTR** is both a strength and a weakness:
  - Strength: zero fees.
  - Weakness: manual verification. Gateway-based competitors (Thrive/Razorpay, MenuScan, DotPe) auto-confirm payment, while we rely on the customer-entered UTR, which is open to fake-UTR fraud. Neither weakness was documented by competitors; this is an inference.

### Gaps
- No page-by-page visual verification. Direct fetches were blocked (see method note), and demo menus and YouTube walkthroughs could not be opened.
- **Unverified:**
  - Veg/egg/non-veg tags, item scheduling and photos for nearly all competitors.
  - Customer self-cancel and order tracking for most competitors.
  - Payment settlement times, current DotPe fees/MDR, the Petpooja Scan & Order add-on price, Restroworks pricing, GoFrugal QR pricing, and Torqus QR ordering in general.
  - Terms of service around refunds and auto-renewal, and privacy policies. No search result surfaced these pages for any vendor.
  - Staff role definitions for competitors.
- Whether DotPe currently requires OTP login is unknown. Sources are 2020–2024.

## What "must-have" features do ALL competitors have that we lack (table stakes)?

### Takeaway
- No single feature we lack is confirmed for *every* competitor.
- **Near-universal among India-relevant competitors** (all POS suites plus at least one cheap startup):
  - A way to **bill the table** (running bill / table session and/or GST invoice).
  - **Payment confirmation without manual checking** (gateway).
  - **Some printer path** (POS thermal printing).
- **Rapidly becoming table stakes even at the low end:**
  - **Multi-language menus.**
  - **WhatsApp touchpoints.**
  - **Feedback/review capture.**
  - **Call-waiter/bill request** (in global SaaS).

### Cited Findings
- **Running bill / table session:**
  - Petpooja ("new items join the running bill") — [Petpooja blog](https://blog.petpooja.com/industry-business-guides/what-is-scan-and-order-qr-ordering-indian-restaurants/)
  - Thrive ("single settlement" for multiple orders at a table) — [Thrive dine-in](https://about.thrivenow.in/dine-in)
  - FineDine Full Service ("one open ticket per table") — [FineDine settings](https://support.finedinemenu.com/en/articles/6062415-qr-dine-in-ordering-settings)
  - MenuScan ("shared table sessions with separate bills") — [menuscan.in](https://menuscan.in/)
  - GoFrugal (guests "settle their bills") — [GoFrugal contactless dining](https://www.gofrugal.com/restaurant/contactless-dining/)
- **GST invoices / billing:**
  - Petpooja — [Petpooja Invoice blog](https://blog.petpooja.com/finance-compliance/petpooja-invoice-features/)
  - Rista POS — [Rista POS](https://ristaapps.com/restaurant-point-of-sale-software)
  - GoFrugal (QR orders "reflect on your billing system") — [GoFrugal](https://www.gofrugal.com/restaurant/contactless-dining/)
  - MenuScan ("GST invoices generated when the waiter closes a table") — [menuscan.in](https://menuscan.in/)
- **Gateway payments with auto-confirmation:**
  - Thrive (Razorpay) — [Razorpay App Store](https://razorpay.com/app-store/thrive/)
  - DotPe (card/NB/UPI) — [CRN](https://www.crn.in/?p=35820)
  - Restroworks — [Restroworks](https://www.restroworks.com/qr-code-ordering-system/)
  - MenuScan (Razorpay/PhonePe/PayU) — [menuscan.in](https://menuscan.in/)
  - AviQR (Razorpay) — [itechguides](https://www.itechguides.com/products/aviqr/)
  - Ahaar Scan (next-day settlement) — [GetApp](https://www.getapp.com/all-software/a/ahaar-scan/)
- **Multi-language:**
  - MenuTiger, 19 languages — [MenuTiger features](https://www.menutiger.com/features)
  - FineDine, unlimited on Growth+ — [FineDine pricing](https://www.finedinemenu.com/en/pricing/)
  - MenuScan, 22 Indian languages — [menuscan.in](https://menuscan.in/)
  - QRSathi, Hindi & regional — [qrsathi.in](https://qrsathi.in/)
  - AviQR, 9 Indian languages — [itechguides](https://www.itechguides.com/products/aviqr/)
- **Call waiter / bill request:**
  - MenuTiger Hot Actions — [MenuTiger](https://www.menutiger.com/blog/restaurant-waiter-call-button-system)
  - FineDine Call Waiter — [FineDine](https://support.finedinemenu.com/en/articles/3395875-how-to-set-up-dine-in-service-requests)
  - Petpooja hardware calling device — [Petpooja](https://petpooja.com/waiter-calling)
- **Feedback:**
  - Restroworks — [Restroworks](https://www.restroworks.com/qr-code-ordering-system/)
  - Thrive CSAT/NPS — [Thrive](https://about.thrivenow.in/feedback-system)
  - MenuTiger survey — [MenuTiger pricing](https://www.menutiger.com/pricing)
  - Petpooja feedback module — [Petpooja](https://www.petpooja.com/customer-feedback-management)
  - QRSathi Google review prompt — [qrsathi.in](https://qrsathi.in/)
  - inresto digital feedback — [Restaurant India](https://www.restaurantindia.in/news/dlf-malls-goes-digital-to-promote-contactless-dining-across-malls.n19374)
- **WhatsApp:**
  - Petpooja (WhatsApp orders on one screen) — [Petpooja integrations](https://www.petpooja.com/poss/restaurant-integrations)
  - DotPe — [DotPe WhatsApp](https://dotpe.in/whatsapp-for-business/)
  - Rista — [Rista WhatsApp](https://ristaapps.com/whatsapp-business-api)
  - MenuScan alerts — [menuscan.in](https://menuscan.in/)
  - QRSathi ordering — [qrsathi.in](https://qrsathi.in/)
  - QR FOOD MENU ordering — [qrfoodmenu.com](https://www.qrfoodmenu.com/)
- **Aggregator integration (POS suites only):**
  - Petpooja — [Petpooja](https://www.petpooja.com/poss/online-order-management-software)
  - Rista — [Rista](https://ristaapps.com/restaurant-point-of-sale-software)
  - Restroworks "500+ integrations" — [Restroworks LLM info](https://www.restroworks.com/llm-info/)
- **Sales analytics even in the cheapest startup tier:** Scan & Order Basic includes "basic sales analytics" — [scanorder.in](https://scanorder.in/)

### Inferences
- **Must-fix for credibility with sit-down restaurants:** a **table session / one bill per table**. Every serious dine-in competitor checked (Petpooja, Thrive, FineDine, MenuScan, GoFrugal) supports it. Our per-order token model fits tea stalls and QSR counters but not table-service restaurants.
- **Must-fix for the Indian small-vendor segment:**
  - **Multi-language (at least Hindi + one regional).** Three of the four Indian startups checked have it.
  - **Some WhatsApp touchpoint** (order alert to the owner, or a receipt/link to the customer).
- **GST invoices** are table stakes once a vendor is GST-registered. They are less critical for unregistered tea stalls, which is a segment where we can still compete without them (inference).
- **Aggregator, Tally and inventory** are table stakes only in the POS-suite tier. We should position against the startups, not against Petpooja.
- **Payment confirmation:** competitors overwhelmingly use gateways. Our UPI intent + UTR saves fees but leaves owners checking their bank app. A lightweight "mark paid" or reconciliation flow is likely expected (inference).

### Gaps
- I could not confirm that *every* competitor lacks or has customer self-cancel, veg tags or item scheduling, so these cannot be called table stakes either way.
- Analytics depth beyond "reports exist" was not verifiable for most vendors.

## Customer-ordering UX differences (steps to order, login friction, payment friction)

### Takeaway
Everyone uses scan-and-order in the browser with no app. The differences are in the friction gates and the payment step:
- **Petpooja** adds an **OTP/validation code + staff validation** before the KOT fires.
- **GoFrugal** offers optional **staff table-request approval**.
- **Older Petpooja and DotPe flows** collect a **phone number/email or WhatsApp** contact.
- **QRSathi** markets **"no app, sign-up or phone number"**.
- **Gateway-based payment** (DotPe, Thrive, MenuScan) adds a gateway hop but auto-confirms.
- **Our flow** (optional OTP, privacy consent, UPI intent, then UTR entry) is low-login-friction. However, the **UTR entry is an extra manual step** that gateway competitors don't need.

### Cited Findings
- **Petpooja steps:** scan → browse categories → select item variations/add-ons → submit → OTP/validation code → staff validate → KOT. Repeat orders add to the running bill. Payment is "pay at counter" or "pay online", setup-dependent — [Petpooja Scan & Order](https://www.petpooja.com/poss/scan-and-order); [Petpooja blog](https://blog.petpooja.com/industry-business-guides/what-is-scan-and-order-qr-ordering-indian-restaurants/)
- **Petpooja (older flow):** enter phone number or email → select payment method → order confirmed — [Petpooja blog](https://blog.petpooja.com/poss/advanced-ways-of-placing-orders-at-restaurant/)
- **GoFrugal:** scan → browse → kitchen notes/special requests → place order → checkout/settle bill. GoFrugal markets it as "three steps". Optional table-request approval by staff — [GoFrugal blog](https://www.gofrugal.com/blog/contactless-ordering-for-restaurants/); [GoFrugal KB](https://community.gofrugal.com/portal/en/kb/servquick/general/articles/contactless-dine-in-servquick)
- **DotPe:** scan → menu micro-site → select → pay by card/NB/UPI. Restaurants then connect with the customer over WhatsApp (2020–21) — [CRN](https://www.crn.in/?p=35820); [Outlook Business](https://www.outlookbusiness.com/magazine/business/story/with-nrais-blessing-this-fintech-start-up-is-dreaming-big-should-restaurant-aggregators-be-worried-5964)
- **Restroworks:** order + pay from phone, add-on/combo upsell during the journey, stage notifications (confirmation, preparation, delivery), wait-time info — [Restroworks](https://www.restroworks.com/qr-code-ordering-system/); [Restroworks COD](https://www.restroworks.com/customer-order-display/)
- **Thrive:** table mode allows multiple orders and one settlement. QSR mode means order and pay immediately — [Thrive dine-in](https://about.thrivenow.in/dine-in)
- **MenuTiger:** in-menu "Request" button for bill, water or cleaning — [MenuTiger](https://www.menutiger.com/blog/restaurant-waiter-call-button-system)
- **QRSathi:** one QR for menu, WhatsApp order, UPI deep link and review prompt. "No app, sign-up or phone number" — [qrsathi.in](https://qrsathi.in/)
- **Privacy risk precedent:** a 2024 report that DotPe QR API calls exposed customer names, phones and orders — [Benzinga India](https://in.benzinga.com/news/24/09/41019389/how-this-person-accessed-sensitive-user-information-by-just-scanning-cafe-qr-code)

### Inferences
- **Approximate step counts:**
  - **Ours:** scan → (consent) → add items with portions/add-ons → (optional OTP) → place → choose UPI (app switch) or cash → enter UTR → track/token. That is about 6–8 taps, with one app switch and one manual field.
  - **Petpooja:** about 5–7 taps plus a mandatory OTP and a staff-validation wait.
  - **Gateway flows (DotPe/Thrive):** similar tap count, but payment confirmation is automatic.
- **Login friction:** our *optional* OTP is a selling point against Petpooja's mandatory OTP/validation and the older phone/email capture. QRSathi goes further (no phone number at all).
- **Payment friction:** our UPI intent avoids the gateway page and fees. The UTR entry, though, adds a step and creates a reconciliation burden for the owner. Gateway competitors avoid both, at a cost of ~2% + GST on Razorpay-type rails ([DomainIndia guide](https://domainindia.com/support/kb/upi-payment-integration-phonepe-paytm-razorpay)).
- **Missing in-flow conveniences vs competitors:** call-waiter/bill request (MenuTiger, FineDine), adding to a running table bill (Petpooja, Thrive, FineDine, MenuScan), language switch (MenuTiger, FineDine, MenuScan, QRSathi), and a post-meal feedback/review prompt (QRSathi, Thrive, MenuTiger).
- **Unique in-flow positives for us:** self-cancel before kitchen start and live tracking (on Growth+). Restroworks is the only competitor found with comparable stage notifications, and it is an enterprise product.

### Gaps
- No competitor demo flow was actually walked through, because demo menus and YouTube could not be accessed. Step counts are reconstructed from vendor text and are approximate.
- The current mandatory/optional status of phone/OTP capture at DotPe, Thrive, MenuScan and Scan & Order is **unverified**.
- Whether any Indian competitor uses UPI *intent* (deep link) vs a gateway, beyond QRSathi's "UPI deep link" wording, is **unverified**.
