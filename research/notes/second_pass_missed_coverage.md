# Second-pass coverage sweep: competitors and review sources missed in round 1 (India QR ordering / restaurant billing, 2025–2026)

> **Method and what was blocked (read first).** I searched on 2026-10-12. Before searching, I skimmed the six existing notes in this folder. Round 1 already covers: Petpooja, DotPe/Rista, Restroworks, Torqus, GoFrugal, eZee, Vyapar (incl. Table app Play reviews), myBillBook, Swipe, Khatabook, Marg, Thrive, Zomato/Swiggy dine-in, Paytm Scan to Order (2020), MenuTiger and about 35 QR-menu tools (incl. Scan & Order/scanorder.in, Ahaar Scan, Bikayi, WhatsApp catalogue), Zobaze Play listings, the Toast/Technomic diner surveys, the Pune 2026 QR privacy incident and the LocalCircles UPI-MDR survey. This pass covers only what is **not** in those notes.
>
> **Blocked:** every `WebFetch` failed with DNS `ENOTFOUND`. That includes loyverse.com, scanorder.in, youtube.com (search results page) and facebook.com/ads/library. So:
> - **No YouTube view counts, upload dates or comments** could be read.
> - **The Meta Ad Library and Facebook/Instagram page ratings** could not be opened.
> - **No Google Maps listing** surfaced in search for any vendor office.
>
> Everything below comes from web-search result snippets and summaries. Those can be out of context, so treat them as such. Wherever a URL is cited, the claim is what the search tool attributed to that page.

## Q1. Missed competitors relevant to small Indian stalls/cafes (price, free tier, features, traction, segment fit)

### Takeaway
None of the missed names is a new direct QR-ordering threat with fresh funding. The relevant additions fall into three groups:
- **Free or cheap generic POS apps** that tea stalls can use today: Loyverse (free), Waiterio (free tier capped at about 100 orders/month), Zobaze (paid from about ₹239) and TallyPrime (about ₹750/mo).
- **Loyalty/CRM layers** that sit on top of POS: Reelo, about 17k businesses, $1M raised in 2024.
- **Small new QR+billing entrants:** Biller.app and Servingoo (Jaipur).

I found **no evidence** of a current free POS or QR menu from Swiggy, Zomato, BharatPe, Pine Labs, OkCredit, PhonePe or JioMart Partner aimed at restaurants. Paytm's restaurant ordering is still documented only for 2020. I also found no 2025–2026 funding round for an Indian dine-in QR-ordering startup.

### Cited Findings

**Global free POS used by Indian small F&B**
- **Loyverse:**
  - Freemium POS. The core is free, with paid add-ons; Capterra shows a "starting price $0.01" plus a free trial. Target businesses include cafes and restaurants. A reviewer says "FREE actually means FREE… paid add-ons… reasonably priced" — [Capterra India: Loyverse POS](https://www.capterra.in/software/150632/loyverse-pos); [Capterra India reviews](https://www.capterra.in/reviews/150632/loyverse-pos)
  - Limits per a GetApp review: no staff management, online ordering or delivery management — [GetApp: Loyverse](https://www.getapp.com/all-software/a/loyverse-pos/)
  - A competitor (PosBytz) says many features are "basic level" and it supports only Android and iPad. This is a competitor-authored source, so it is biased — [PosBytz: Loyverse alternatives](https://posbytz.com/ae/blog/best-loyverse-alternatives)
  - I found no INR pricing, India install counts or QR self-ordering feature for Loyverse; loyverse.com was blocked.
- **Waiterio:**
  - Capterra India lists a free version, a free trial and a starting price of $19, with tiers of $39 and $59/month plus order-volume charges — [Capterra India: Waiterio](https://www.capterra.in/software/157873/waiterio)
  - FitGap says "Pricing from $39 per month" with no free trial — [FitGap: Waiterio](https://us.fitgap.com/products/waiterio). Another FitGap page describes a permanent free plan of up to 100 orders/month — [FitGap](https://us.fitgap.com/products/006813/waiterio)
  - The sources conflict, and I found no INR price.
  - The iOS app is free with no in-app purchases — [AppPricingLab](https://apppricinglab.com/app/apple/848943564)

**Indian generic billing apps (price/traction gaps not filled in round 1)**
- **Zobaze:**
  - Techjockey lists a starting price of ₹239 + GST (₹282 incl. GST). The billing period and which tier this is are not stated — [Techjockey: Zobaze POS](https://techjockey.com/detail/zobaze-pos)
  - Capterra India: priced "per feature", for teams of 2–10 users — [Capterra India: Zobaze](https://www.capterra.in/software/183696/zobaze-pos)
  - Company: founded 2015, Hyderabad. The only recorded funding is an incubator/accelerator round (Appscale Academy) on 3 Mar 2022, with no amount — [CB Insights: Zobaze](https://www.cbinsights.com/company/zobaze/financials)
  - The main Zobaze POS app is reported at 1,000,000+ installs. The café app ("Restaurant POS: Café Billing") is at 100,000+ installs and 4.6★ — search summary of Play listings via [G2: Zobaze](https://www.g2.com/sellers/zobaze) / [GetApp UK](https://www.getapp.co.uk/software/2061415/zobaze-pos). The 1M figure is from a search summary and was not verified on Play.
  - I found no QR self-ordering feature.
- **Vyapar Table:**
  - G2 describes it as a restaurant billing/POS app with GST bills, table management and KOT — [G2: Vyapar](https://www.g2.com/sellers/vyapar-c1224904-3c56-4eae-bbb0-95ed28356c76)
  - Vyapar's restaurant page lists KOT and calls the Android app "free". It shows a ₹0/month "Silver Plan" billed annually + GST, but that may apply to general Vyapar, not Table — [Vyapar restaurant billing](https://vyaparapp.in/free/restaurant-billing-software)
  - Vyapar's blog mentions a 15-day trial — [Vyapar blog](https://vyaparapp.in/blog/vyapar-for-restaurants/)
  - IndiaMART reseller prices for general Vyapar: Gold mobile ₹719/yr, Silver desktop ₹3,059/yr — [IndiaMART: Cloud Next Solutions](https://m.indiamart.com/cloud-next-solutions/?pos=1)
  - I found no official Table-specific price.
- **TallyPrime (café/restaurant):**
  - Tally's own café billing page says TallyPrime can "manage the status of all your tables, from ordering to billing" and has POS billing.
  - Plans: 1 month 750, 3 months 2,250 (discounted to 2,138), 12 months 9,000 (discounted to 8,100), each + 18% GST. The currency is presumed ₹; a lifetime figure was ambiguous — [Tally: Billing software for café](https://tallysolutions.com/billing-software/cafe/); [Tally restaurant accounting](https://tallysolutions.com/accounting-software/restaurant/)
  - I found no priced first-party "restaurant/KOT TDL add-on". Third-party Tally customisation is sold on IndiaMART without standard prices — [IndiaMART Tally customization](https://m.indiamart.com/impcat/tally-customization-services.html)
- **Other cheap restaurant billing apps not in round 1:**
  - BillClap: KOT printing, from ₹4,999/yr — [BillClap](https://www.billclap.com/billing-software-for-restaurants)
  - TMBill: from ₹5,999 excl. GST per Techjockey; Capterra shows "₹120 flat rate per year" (likely a listing error) — [Techjockey TMBill](https://www.techjockey.com/detail/tmbill-pos); [Capterra TMBill](https://www.capterra.com/p/189771/TMBill-POS/alternatives/)
  - RoyalPOS: ₹5,999/yr with Swiggy/Zomato support — [RoyalPOS](https://royalpos.in/pos-software-in-india)
  - HisaabNow: advertises a bilingual Hindi/English interface — [Capterra India: HisaabNow](https://www.capterra.in/software/1100298/Hisaabnow)

**New/small QR + billing entrants (closest to our segment)**
- **Biller.app:** a restaurant POS with billing, KOT, GST invoices, kitchen display, "table-QR self-ordering", inventory and Razorpay payments. Integrations list BharatPe, Razorpay, PhonePe and Google Pay. The features are vendor self-description on an aggregator, with no price or traction visible — [Capterra India: Biller app](https://www.capterra.in/software/1110754/Biller-app); [GetApp NZ](https://www.getapp.co.nz/software/2142919/biller-app)
- **Servingoo (Jaipur):** LinkedIn describes QR menus, online ordering, billing and analytics in one platform, with a "launch July 1" (year not shown in the snippet). No price or traction — [LinkedIn: Servingoo](https://linkedin.com/company/getservingoo)
- **Smart QR Order:** a global hospitality POS/QR menu with a **Hindi** video guide ("Restaurant ki apni website kaise banaayein") covering profile, digital menu and table-QR setup — [Smart QR Order video guides](https://smartqrorder.com/video-guides)
- **Cheap QR menu vendors with India-specific 2026 content:**
  - QRFlow: an India guide on dynamic QR menus that recommends Hindi scan instructions — [QRFlow](https://qrflow.in/resources/qr-code-menu-for-restaurants-in-india-2026-save-18000year-on-reprints)
  - eRestro — [eRestro blog](https://erestro.in/blog/qr-menus-that-work-for-indian-diners)
  - MenuManager.in: claims a 30-minute setup from ₹799/month — [MenuManager QR ordering](https://menumanager.in/qr-ordering-system/)
  - No pricing was verified for QRFlow or eRestro.

**Payment/fintech merchant apps**
- **BharatPe:** Tracxn lists it in "QR code payments" (Series E, $584M total funding). I found no menu, ordering or restaurant-billing product; it appears only as a payments integration in third-party POS — [Tracxn QR code payments](https://tracxn.com/d/trending-themes/startups-in-qr-code-payments/__fZa8dxdIcxQ7el0-P_gRtHNHw0lNXp6021k0FNDqY8I); [Capterra: Biller app](https://www.capterra.in/software/1110754/Biller-app)
- **Pine Labs:** the hospitality page offers PoS terminals with "restaurant billing software and applications integration", contactless payments, payment links and merchant cashback offers. Table-side QR ordering was not confirmed. This is a payments-terminal play for larger restaurants, not tea stalls — [Pine Labs hospitality](https://pinelabs.com/hospitality)
- **OkCredit:** no restaurant ordering or billing product surfaced in search (absence of evidence only).
- **Paytm:**
  - The "Scan to Order" blog pages (testimonials, product page) are still on Paytm Business. The only dated coverage is from 2020 — [Paytm Business blog: Scan to Order testimonials](https://business.paytm.com/blog/scan-to-order-testimonials/); [Paytm Business blog: Scan to Order](https://business.paytm.com/blog/scantoorder-dining-powered-by-paytm/); [The Paypers (2020)](https://thepaypers.com/payments/news/paytm-launches-contactless-feature-for-restaurants-and-eateries)
  - The current Paytm for Business app listing mentions payment links and QR or card-machine collection, but no menus — [mwm.ai: Paytm for Business](https://mwm.ai/apps/paytm-for-business/1351301966)
- **PhonePe Business:** no restaurant menu or ordering feature found.
- **Axis Bank "Digital Dukaan"** (with Visa): an Android smart-POS app offering payments acceptance (card/UPI), quick billing, inventory and a digital khata. It is aimed at kiranas, with no restaurant/KOT/table features found — [Axis Bank press release](https://www.axis.bank.in/about-us/press-releases/axis-bank-launches-digital-dukaan-an-enhanced-payments-and-business-management-solution-for-merchants)
- **JioMart Partner:** a B2B wholesale-ordering app for kiranas. Jio Smart Kirana provides POS systems. Nothing restaurant-specific was found — [MixRank: JioMart Partner](https://mixrank.com/playstore/apps/com.jio.bapp); [Jio Commerce case study](https://www.jiocommerce.io/casestudies/jio-mart)

**Swiggy/Zomato "free POS"**
- I found no evidence of a free Swiggy or Zomato POS launched in 2025. Zomato's June 2024 restaurant-services hub said it would "introduce POS device integrations" — [Deccan Herald (Jun 2024)](https://deccanherald.com/business/companies/zomato-extends-its-restaurant-services-hub-offering-pan-india-3083485)
- UrbanPiper, whose investors include Zomato and Swiggy, sells a POS that ingests orders from both — [UrbanPiper restaurant billing](https://urbanpiper.com/restaurant-billing)

**Loyalty/CRM (Reelo, "TapTap")**
- **Reelo (Ahmedabad):**
  - Raised $1M from Gokul Rajaram in April 2024. Reports say over 17,000 businesses onboarded across India, the Middle East and Africa, engaging 16M+ customers, in 9 countries with US plans. The founding year conflicts: 2017 vs 2021 — [Outlook Business](https://www.outlookbusiness.com/corporate/reelo-raises-1-million-from-silicon-valley-based-angel-investor-gokul-rajaram-report); [YourStory roundup 29 Apr 2024](https://social.yourstory.com:443/2024/04/startup-news-and-updates-daily-roundup-april-29-2024)
  - Pricing conflicts: Capterra shows a starting price of ₹30,000 (period unclear) with a free version and trial — [Capterra India: Reelo](https://www.capterra.in/software/1050827/reelo). A competitor blog gives ₹3,000–8,000/month — [DineOpen loyalty blog](https://www.dineopen.com/blog/best-restaurant-loyalty-program-software-india.html)
  - Petpooja's blog says Reelo integrates with 35+ Indian POS systems, and that Reelo and Bingage charge a separate monthly fee for WhatsApp campaigns and referrals — [Petpooja blog](https://blog.petpooja.com/?p=45527)
  - Capterra rating: 3.9/5 from 7 reviews; value for money 3.3/5 — [Capterra UK: Reelo](https://www.capterra.co.uk/software/1050827/reelo)
- **TapTap:** no results for an Indian restaurant-loyalty product with this name. The name may be wrong; ask the requester.

**Funding / startup databases (Inc42, Entrackr, YourStory, Tracxn)**
- Tracxn (Oct 2025): 428 Restaurant SaaS startups in India, of which 28 are funded and 16 are Series A+. Petpooja is the top name, listed as Series C with "$11M total funding" — [Tracxn Restaurant SaaS India](https://tracxn.com/d/explore/restaurant-saas-startups-in-india/__aEoQyNayDOyz6h41CEe6tPRpjv1YtPV-0geHSnIPaK4/companies)
  - Entrackr separately reports a $15.5M Series C — [Entrackr](https://entrackr.com/news/petpooja-raises-155-mn-series-c-at-over-3x-valuation-premium-10512396). The figures conflict, probably because Tracxn's total is stale.
- Eat App (reservations, UAE) raised a $10M Series B extension in Jan 2026 and acquired the Indian reservations platform **ReserveGo** in 2026. That is adjacent (reservations), not QR ordering — [Wikipedia: Eat App](https://en.wikipedia.org/wiki/Eat_App)
- peAR (AR dining menus): pre-Series A led by Inflection Point Ventures and LetsVenture, about a year old per the search tool. Not QR ordering — [Entrepreneur India](https://india.entrepreneur.com/finance/ar-based-dining-app-pearraises-pre-series-a-funding/391714)
- Context: Indian startups raised $2.9B in Q3 2026, and investors favour profitability — [Entrackr](https://entrackr.com/); [Inc42 IPO tracker](https://inc42.com/features/indian-startup-ipo-tracker-2026/)
- I found **no** Inc42, Entrackr or YourStory report of a 2025–2026 round for an Indian dine-in QR-ordering startup.

**WhatsApp Business catalogue flows (additions to round 1)**
- Meta (2021): over 8M catalogues on WhatsApp, about 1M of them in India. Carts let a customer send a multi-item order as one message, and items can be hidden when out of stock — [ETV Bharat (Apr 2021)](https://www.etvbharat.com/english/science-and-technology/whatsapp-makes-shopping-easy-on-its-business-platform/na20210407143929977)
- Petpooja's blog: a WhatsApp catalogue "does not update itself", and orders land in an inbox rather than in billing — [Petpooja blog](https://blog.petpooja.com/?p=48904)
- Vendor claim: catalogue plus in-chat payment "work best for menus under ~40 items" — [TimelinesAI](https://timelines.ai/create-whatsapp-food-order-system) (vendor, unverified)

### Inferences
- **For a tea stall, the real "competitor" is a free generic app** (Loyverse, Vyapar free tier, Zobaze, WhatsApp catalogue), not a funded QR startup. None of these offers diner self-ordering by QR, which leaves our QR-ordering niche open at the bottom end.
- **Fintechs have not productised dine-in ordering** (Paytm's 2020 product appears dormant; PhonePe, BharatPe, Pine Labs and OkCredit have none). The risk is that one of them bundles a free menu or ordering feature onto its soundbox or QR base. No signal of this was found in 2025–2026.
- **Loyalty is a separate paid layer** that owners already buy (Reelo has about 17k businesses). Our "not used for marketing" privacy stance conflicts with that upsell path. This is a positioning choice to make deliberately.

### Gaps
- No INR pricing for Loyverse or Waiterio, and no official Zobaze or Vyapar Table price page (sites were blocked).
- Biller.app and Servingoo: no price, launch date or customer counts.
- "TapTap" and "Swiggy DotPe-like website builder" could not be identified.
- Zobaze's user and merchant counts are not verified.

## Q2. YouTube reviews/demos (Petpooja, DotPe, Zobaze, Vyapar, MenuTiger, QR menu setup)

### Takeaway
youtube.com was blocked (DNS failure), so **no view counts, upload dates or top comments could be captured**. Search surfaced mostly **vendor-made tutorials**: Petpooja's official tutorial channel, Hindi demo and shortcut videos, and English demo playlists. It surfaced no independent Indian "review" videos and no DotPe, Zobaze or Vyapar Table videos.

### Cited Findings
- **Petpooja:**
  - Official channel "Petpooja Tutorials" offers step-by-step walkthroughs, feature demos and training masterclasses — [YouTube @PetpoojaTutorials](https://www.youtube.com/@PetpoojaTutorials)
  - "Petpooja Restaurant Software Demo in Hindi", described as a partial demo of the POS module and posted about 1,400 days ago (about late 2022) per the search tool — [YouTube](https://www.youtube.com/watch?v=y12pNLvkMt8)
  - Third-party "PetPooja Software Demo || Pet Pooja Restaurant Billing…" — [YouTube](https://m.youtube.com/watch?v=ML7YzSdBR-M)
  - "Petpooja POS Shortcut Keys" (Hindi), posted about 100 days ago (about mid-2026) — [YouTube](https://www.youtube.com/watch?v=czrXu-qcjQs)
  - English demo playlist — [YouTube playlist](https://www.youtube.com/playlist?list=PLtrAnRaaM7hnVwn7zIPJqsLURwHLT5Lop)
  - Another Petpooja video — [YouTube](https://www.youtube.com/watch?v=UpeIMdczpF4)
  - Themes from the titles: training and how-to (billing speed, shortcuts), not reviews.
- **Generic QR menu setup videos (English):**
  - "How to create a FREE QR code menu for restaurants" — [YouTube](https://www.youtube.com/watch?v=W1_UrBJrtp4)
  - "QR Menu Code Order & Pay at the Table" — [YouTube](https://m.youtube.com/watch?v=QyOeSxTuHNk)
- **Hindi QR-ordering setup:** found only as a vendor-hosted guide from Smart QR Order — [smartqrorder.com/video-guides](https://smartqrorder.com/video-guides)
- **DotPe:** no YouTube demo surfaced. Its 2020 McDonald's North & East rollout worked like this: scan a store QR, order in the browser, pay via UPI/GPay/card/Paytm, and receive order updates on WhatsApp — [Entrepreneur India](https://india.entrepreneur.com/news-and-trends/dotpe-collaborates-with-mcdonalds-india-north-east-to/354700). KrASIA describes DotPe as B2B2C with no consumer app; the QR is its only consumer touchpoint — [KrASIA](https://kr-asia.com/dotpe-challenges-zomato-and-swiggy-with-fb-enterprise-tools-startup-stories)
- **Zobaze, Vyapar Table, MenuTiger (India):** no YouTube videos surfaced in search.

### Inferences
- Indian POS vendors use YouTube mainly for **training content**, and Hindi demos exist. A Hindi "set up QR ordering in 5 minutes on your phone" video is a gap in search visibility that we could fill cheaply (weak inference, based only on what search surfaced).

### Gaps
- All view counts, likes, dates and comments. youtube.com was unreachable, and the search snippets carried no counts.
- Independent creator reviews (as opposed to vendor tutorials) were not found. They may exist but not be indexed by this search tool.

## Q3. Facebook / Instagram (Meta Ad Library, page ratings, comment themes)

### Takeaway
**Blocked.** facebook.com, including the Ad Library, returned DNS `ENOTFOUND`, and search returned no Facebook or Instagram page ratings or ad copy for Petpooja, DotPe, Zobaze or QR-menu startups. The substitutes found are B2B review sites and employee-review sites.

### Cited Findings
- **Petpooja ratings (B2B review sites, substitute for Facebook ratings):**
  - G2: 4.7/5 from 289 reviews, about 85% five-star — [G2: Petpooja](https://www.g2.com/sellers/petpooja)
  - Capterra: 4.6/5 from 37 reviews (92% positive) — [Capterra](https://www.capterra.com/p/172163/Petpooja-Restaurant-Management-Platform/reviews/)
  - Techjockey: 4.2/5 from 50 reviews, with support rated highest — [Techjockey](https://www.techjockey.com/reviews/petpooja-pos)
  - Rannkly aggregate: 4.2 across about 1,105 reviews on multiple platforms — [Rannkly](https://www.rannkly.com/company/reviews/petpooja-reviews-ratings)
  - Dates and counts vary by snapshot.
- **DotPe:** consumer-complaint site Voxya lists complaints against "Digital Showroom Dotpe Private Limited", including one from October 2024 alleging a refund was not paid and a website was never built. Only 2 complaints in total (1 resolved), so this is anecdotal — [Voxya](https://voxya.com/consumer-complaints/-/236512)
  - The grievance officer is at Sector 39, Gurugram (grievance.redressal@dotpe.in) — [InCred partner doc](https://assets.incred.com/incred-website/doc/Partnership/InCred%20PL%20Digital%20Partner%20-%20DotPe.pdf)
  - (Round 1 already cited Voxya.)

### Inferences
- With Meta unreachable, the business-buyer sentiment proxies are G2, Capterra and Techjockey (Petpooja is consistently 4.2–4.7) and Play reviews (round 1). Those sources skew toward satisfied customers that vendors solicit.

### Gaps
- Meta Ad Library ad counts, creatives and run dates for any vendor.
- Facebook page star ratings and Instagram comment themes. Both need manual browser access.

## Q4. Google Maps reviews of competitor offices (Petpooja Ahmedabad, DotPe Gurugram, Rista, Zobaze)

### Takeaway
No Google Maps rating or review text surfaced for any of the four offices, and Maps could not be fetched. What search returns instead is **employee** ratings: Petpooja about 4.1–4.3 on AmbitionBox, DotPe about 3.2–3.3. These are not customer sentiment.

### Cited Findings
- **Petpooja (Ahmedabad):**
  - AmbitionBox: 4.3/5 from 604 reviews on one page and 4.1/5 from 476 reviews on another snapshot (employee reviews) — [AmbitionBox Petpooja](https://ambitionbox.com/photos/petpooja-photos); [page 2](https://ambitionbox.com/photos/petpooja-photos?page=2)
  - Indeed: 4.5/5 — [Indeed](https://in.indeed.com/cmp/Petpooja)
  - Rannkly reports Glassdoor at 3.8 — [Rannkly](https://www.rannkly.com/company/reviews/petpooja-reviews-ratings)
- **DotPe (Gurugram):** AmbitionBox 3.2/5 from 275 reviews (another snapshot: 3.3 from 250). The weakest areas are promotions and job security, and one employee review calls the Gurgaon operation a "scam" (anecdotal, employee opinion) — [AmbitionBox DotPe](https://ambitionbox.com/overview/dotpe-overview)
- **Rista, Zobaze:** nothing found.

### Inferences
- DotPe's weak employee scores, together with the round-1 privacy incident and refund complaints, are consistent with an organisation under strain after its pivot. This is a weak, circumstantial inference.

### Gaps
- Actual Google Maps star ratings and review themes for all four offices. These need a browser session.

## Q5. Diner side in India: surveys and articles on QR menus (likes, dislikes, privacy, phone numbers, UPI)

### Takeaway
The only India-specific diner survey found is **Dineout, April 2020 (lockdown era, 20 cities)**: about 81% would rather scan a QR and order than handle physical menus, and 60% preferred wallet/digital payments. It is dated and pandemic-skewed. Newer evidence is US-based and shows rising resistance (US Foods 2024: Gen Z paper-menu preference jumped). I found **no 2023–2026 Indian survey on QR-menu privacy or phone-number collection**. The 2026 Pune incident (round 1) remains the main India privacy datapoint.

### Cited Findings
- **Dineout survey (India, 20 cities, reported 27 Apr 2020):**
  - 81% would rather scan a QR to order than use physical or tablet menus.
  - 84% prefer digital feedback.
  - 60% prefer wallet-based digital payments over cash or cards.
  - 77% were eager to dine out again.
  - Sources: [IANSlife](https://www.ianslife.in/food-fitness/indias-food-trends-post-covid-19-era); [National Herald](https://www.nationalheraldindia.com/lifestyle/indias-food-trends-for-a-post-covid-19-era)
  - Restaurant India gives the QR figure as 80.8% — [Restaurant India](https://www.restaurantindia.in/article/962-people-would-prefer-to-be-seated-immediately-at-their-pre-reserved-seat-post-lockdown-dineout-report.13644)
- **US Foods 2024 "Diner Dispatch" (US):** 90% of Gen Z preferred paper menus over QR in 2024, up from 69% in 2023. Not India — [Business Wire (Oct 2024)](https://www.businesswire.com/news/home/20241008659223/en)
- **India trade press (anecdotal):** a restaurateur says guests "prefer a digital menu over paper menu books" — [Restaurant India](https://www.restaurantindia.in/article/restaurants-in-india-focus-on-digital-friendly-menu.13823)
- **Vendor material frames data capture as a benefit to the restaurant:** QR ordering captures phone, email and order history — [MenuManager](https://menumanager.in/qr-ordering-system/)
  - MenuTiger publishes an "I hate QR code menus" rebuttal piece (vendor) — [MenuTiger blog](https://www.menutiger.com/blog/i-hate-qr-code-menus)
- **India-specific QR UX tips from vendors** (Hindi scan instructions, etc.) — [QRFlow](https://qrflow.in/resources/qr-code-menu-for-restaurants-in-india-2026-save-18000year-on-reprints); [eRestro](https://erestro.in/blog/qr-menus-that-work-for-indian-diners) (vendor, unverified)
- **LocalCircles:** no QR-menu diner survey found. Its 2026 UPI merchant-MDR survey is already in round 1.

### Inferences
- The positive Indian number (81%) is a **pandemic-era artefact**. Post-pandemic US data shows a swing back to paper. For India, assume a mixed reception and offer a paper/QR hybrid, especially for older diners.
- Indian vendors pitch phone-number capture as a marketing asset (MenuManager, Reelo-style loyalty), while diners' privacy concerns surface through incidents (Pune 2026) rather than surveys. Optional-phone ordering is defensible but cannot yet be backed by Indian survey data.

### Gaps
- No 2023–2026 Indian survey on diner QR attitudes, phone-number reluctance, or UPI-at-table behaviour specific to restaurants.
- No Reddit, Instagram or YouTube diner comments could be retrieved (blocked or not indexed).
