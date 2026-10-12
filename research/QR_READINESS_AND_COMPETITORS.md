# Owner decisions, not code, now block the QR launch

Tech2Software QR Ordering is **finished as software but not as a business**. Both repos pass their test suites: 107 backend tests, 68 frontend unit tests, 3 end-to-end tests, a clean `npm audit` and a clean gitleaks scan ([STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md)). Even so, nothing is merged to `master`, nothing is deployed, and no production domain exists. Cashfree has never processed even a sandbox payment. The product also has **no Terms, Privacy Policy, Refund policy, support contact or GST decision**, and Cashfree will not activate a merchant without the legal and contact pages. Of the nine launch blockers, almost all are waiting on the owner's go-ahead, credentials, a CA or a lawyer, not on engineering. On price, QR Starter at ₹199/month sits in the middle of a crowded Indian low-cost band. Scan & Order sells 399 days for ₹999 (about ₹75/month), Ahaar Scan charges ₹2,999/year and MenuScan ₹250/month. All three are far below Petpooja, whose Lite tier with "limited" Scan & Order costs roughly ₹7,080 a year before hardware. Two internal pricing problems need fixing before money is taken. A coding choice makes **monthly billing half the price per day of yearly billing**. And **QR Pro sells "analytics" and "priority support" that do not exist**. We win on kitchen-side depth for the price: kitchen display, tokens, live tracking, five staff roles, and 0% commission with UPI paid straight to the vendor. We lose on Hindi and regional menus, WhatsApp, one bill per table, GST bills, printing and reports, all of which cheaper rivals already bundle. Play Store and review evidence shows that small owners punish money surprises and unanswered support far more than missing features. Our no-auto-renew, flat-price model can turn that into an advantage, but only once a real support channel and a refund policy exist. Two first-pass "competitors" are gone: Thrive shut down in December 2024, and GloriaFood no longer accepts new restaurants. Play Store pages, Facebook, YouTube and Google Maps were blocked during research, and many competitor prices are third-party, so a manual browser check list closes this report.

## Nine blockers stand between tested code and paying vendors

### The code baseline is strong; the deployment baseline is empty

The walkthrough phases 1–6 are complete on branch `claude/magical-noether-ys2e87` in both `qr-code-ui` and `qr-code-bkd`. The code covers opaque, revocable per-table QR codes, outlet scoping, role-based access, idempotent ordering, a kitchen display, Cashfree hosted checkout with a signature-verified webhook, an optional diner OTP flow, and a production safety check that refuses to start with sample secrets ([BKD FIXES.md](file:///home/user/qr-code-bkd/FIXES.md); [UI FIXES.md](file:///home/user/qr-code-ui/FIXES.md)). But **"No pull requests are open yet. `master` in both repositories is still the pre-walkthrough code"**. That code is guessable QR, no outlet scoping, broken payments and Flyway never run ([STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md)). The deployment target is a single-host docker-compose stack (MySQL 8.4, Spring Boot, nginx on plain HTTP port 8080) that expects TLS from a load balancer that does not yet exist. `APP_UI_ORIGIN` still defaults to `http://localhost:8080` ([docker-compose.yml](file:///home/user/qr-code-bkd/docker-compose.yml); [.env.example](file:///home/user/qr-code-bkd/.env.example)). The integration risk is concrete: **"none of this has been run against Cashfree's live API"**. Until a vendor can pay, every trial vendor loses access on day 15 and their customers' QR codes start returning 404 ([BKD FIXES.md ISSUE-002](file:///home/user/qr-code-bkd/FIXES.md); [PublicService.java:396-406](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/publicapi/PublicService.java)).

### P0: must be done before the first real vendor

The table merges the code-readiness blockers with the compliance requirements found in the second pass. "Unblocked by" names the person or thing that actually releases the item.

| # | Item | Why it blocks | Unblocked by |
|---|---|---|---|
| B1 | Open PRs, review and merge the branch to `master` in both repos | `master` is the insecure pre-walkthrough code ([STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md)) | **Owner go-ahead**, then a reviewer |
| B2 | Production host, public domain, DNS, a TLS terminator in front of nginx:8080, and `APP_UI_ORIGIN` set to the HTTPS origin | Nothing is deployed, and no domain appears anywhere in either repo. HSTS only works behind TLS ([BKD README](file:///home/user/qr-code-bkd/README.md)) | **Owner** (domain and hosting choice), then ops |
| B3 | Production secrets: MySQL passwords, `JWT_SECRET`, admin credentials and the 32-byte `TENANT_CREDENTIAL_ENCRYPTION_KEY`, kept in a secret manager | `ProductionSafetyCheck` refuses to start without them or with sample values ([BKD FIXES.md phase 6 BN5](file:///home/user/qr-code-bkd/FIXES.md)) | **Owner/ops** |
| B4 | A way to pay after the trial. Either (a) Cashfree KYC, a sandbox payment, then a live small-value test with `CASHFREE_ENV=production`, or (b) deliberate launch on manual "grant plan" activation | Without (a) or (b), vendors lose access on day 15. Cashfree activation usually takes about 24 working hours after KYC ([Cashfree onboarding FAQ](https://www.cashfree.com/docs/help/onboarding-related/onboarding-faqs)) | **Owner**: Cashfree merchant account. Path (a) also depends on B5 and B6 |
| B5 | Publish Terms of Service with a Data Processing Addendum, a Privacy Policy, a Refund and Cancellation policy, and About/Contact pages showing the registered business name, address, email and phone. Name a grievance contact | The routes only include `''`, `order`, admin and vendor pages, and the footer says only "© Tech2Software" ([app.routes.ts](file:///home/user/qr-code-ui/src/app/app.routes.ts); [landing.html:62-63](file:///home/user/qr-code-ui/src/app/features/landing/landing.html)). **Cashfree lists Terms, About us, Contact us (email and phone) and Privacy policy as mandatory**, and refund policy as conditional ([Cashfree onboarding FAQ](https://www.cashfree.com/docs/help/onboarding-related/onboarding-faqs)). Play also needs a privacy URL | **Owner + lawyer** for the content; the code work is trivial |
| B6 | A published support channel (WhatsApp Business plus phone, in Hindi and English) shown in the app | With SMS off, a locked-out owner is told to "contact Tech2Software support", but no contact detail appears anywhere. Pro sells "Priority support" ([forgot-password.ts:25](file:///home/user/qr-code-ui/src/app/features/forgot-password/forgot-password.ts); [qr-plans.ts](file:///home/user/qr-code-ui/src/app/plan/qr-plans.ts)) | **Owner** chooses the channel and staffs it |
| B7 | Install the daily backup cron, set up off-host copies, and run a restore drill | The runbook says "Do this before launch". The scripts were "not run against a full compose stack" ([RUNBOOK.md](file:///home/user/qr-code-bkd/docs/RUNBOOK.md)) | **Ops**, plus a backup destination |
| B8 | Old printed `/order?v=<id>` QR codes: enable `PUBLIC_VENDOR_ID_LINKS=true` only while vendors reprint, then turn it off | "Old printed QR codes stop working on deploy" ([STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md)) | **Owner/ops**. Only matters if live vendors already exist, which is unknown |
| B9 | GST status and price display: confirm registration with a CA, choose "+ GST" or "incl. GST", show it on every pricing surface, and issue receipts or tax invoices | No GST, tax or invoice code exists anywhere (grep over [UI/src](file:///home/user/qr-code-ui/src) and [BKD/src/main](file:///home/user/qr-code-bkd/src/main)). The CCPA's 2023 dark-patterns guidelines ban **drip pricing** ([Mondaq](https://www.mondaq.com/india/dodd-frank-consumer-protection-act/1379670/understanding-dark-patterns-guidelines-for-consumer-protection)). In Aug 2026 the CCPA fined Zepto ₹7 lakh for fees revealed late in checkout ([Business Standard](https://www.business-standard.com/industry/news/ccpa-fines-indigo-zepto-bookmyshow-dark-patterns-quick-commerce-penalty-126080600580_1.html)) | **Owner + CA**, then code for invoices |
| B10 | Decide the pricing policy before the first live payment: the bonus-days rule, seat limits and outlet pricing. This report elevates it from should-fix S3 | Every payment writes an entitlement, so changing the rule after vendors have paid becomes a customer-relations problem. Resellers should not be paid commission on the anomaly ([QrSubscriptionService.java:157-167](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrSubscriptionService.java); [BKD FIXES.md ISSUE-020](file:///home/user/qr-code-bkd/FIXES.md)) | **Owner** |

On GST, registration becomes compulsory only once aggregate turnover passes **₹20 lakh a year**. Notification 10/2017-Integrated Tax exempts small inter-state service suppliers below that line ([GSTZen](https://gstzen.in/a/integrated-tax-notification-102017-seeks-to-exempt-persons-making-inter-state-supplies-of-taxable-services-from-registration-under-section-232.html)). SaaS is taxed at 18% ([Kintsugi](https://trykintsugi.com/sales-tax-guides/apac/india)). E-invoicing applies only above ₹5 crore ([Tax2win](https://tax2win.in/guide/e-invoicing-gst)). ₹20 lakh a year is about 837 Starter subscriptions a month. The threshold counts all of Tech2Software's PAN-wide service income, though, so the CA must check whether existing software-development revenue already crosses it. An unregistered supplier must not show or charge GST. The lowest-effort compliant launch is therefore "₹199 (no GST charged)" plus a payment receipt. If Tech2Software is registered, it needs tax invoices on every payment.

### P1: should be fixed before launch, or within the first weeks

| # | Item | Unblocked by | Source |
|---|---|---|---|
| S1 | The setup wizard still says "Connect a thermal printer", lists "Bluetooth Printer" and "LAN / Network Printer", and shows "✓ Connected". Saving there calls the PRINTER-gated endpoint, which will probably return 403 for Starter (found by reading the code, not by running it) | Code | [setup-wizard.html:140-175](file:///home/user/qr-code-ui/src/app/features/setup/setup-wizard.html) |
| S2 | Plan copy sells kitchen slips as Growth/Pro, but "Print Slip" and "Print KOT" call `window.print()` with no plan check. Only saving a printer preference is gated | Owner policy, then code | [orders.ts:174](file:///home/user/qr-code-ui/src/app/features/vendor/orders/orders.ts); [kitchen.ts:90](file:///home/user/qr-code-ui/src/app/features/vendor/kitchen/kitchen.ts) |
| S4 | Admin "grant plan" resets the entitlement to start today, so a manually renewed vendor loses their remaining days. The webhook path extends from the current end date. This matters because manual activation is the fallback until Cashfree is tested | Code | [QrSubscriptionService.java:75-80](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrSubscriptionService.java) |
| S5 | Paid flags with nothing behind them: PAYMENT_GATEWAY, ANALYTICS and PRIORITY_SUPPORT (see next section) | Owner: remove them or build them | [BKD FIXES.md phase 2 B7a](file:///home/user/qr-code-bkd/FIXES.md) |
| S6 | SMS provider plus TRAI DLT registration. This enables `SMS_ENABLED` for sign-up verification and self-serve password reset. DLT entity registration costs about ₹5,900 and takes 2–7 working days ([Avancezone](https://avancezone.com/dlt-registration-for-bulk-sms)); OTP SMS costs about ₹0.13–0.25 each ([Message Central](https://www.messagecentral.com/blog/sms-otp-pricing-india)) | Owner (provider account and DLT), then a real `SmsSender` bean | [SmsConfig.java:19](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/otp/SmsConfig.java) |
| S7 | External uptime monitor on `/api/health`. "Nothing inside the stack pages anyone" | Ops | [RUNBOOK.md](file:///home/user/qr-code-bkd/docs/RUNBOOK.md) |
| S8 | Full-stack backup and restore test. Only the database steps were tested | Ops | [STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md) |
| S9 | Force the super-admin to change the `.env` password on first login | Code or an ops procedure | [BKD FIXES.md ISSUE-001](file:///home/user/qr-code-bkd/FIXES.md) |
| S10 | DPDP basics. Expand the checkout notice into an itemised notice; set a retention period for diner name and mobile with an anonymise job (none exists: no retention, purge or `@Scheduled` code); add an erasure route, a grievance contact and a breach runbook | Owner/lawyer for policy, then code | grep over [BKD/src/main/java](file:///home/user/qr-code-bkd/src/main/java); [customer-order.html:221-229](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html) |
| S11 | Renewal reminders. With no email or SMS, nothing warns a vendor before the trial or plan lapses and their QR codes start returning 404. Only an in-app days-left badge exists | Email or SMS provider, then code | [BKD FIXES.md phase 4 A1](file:///home/user/qr-code-bkd/FIXES.md) |
| S12 | The README still describes Redis, which was removed in ISSUE-033 | Docs | [BKD README](file:///home/user/qr-code-bkd/README.md) |
| S13 | Get a one-time legal opinion that UPI intent to the vendor's own VPA is not payment-aggregator activity. RBI's Sept 2025 Master Direction regulates entities that *handle funds*, and Tech2Software never touches diner money ([RBI notification 12896](https://www.rbi.org.in/Scripts/NotificationUser.aspx?Id=12896); [PhonePe explainer](https://business.phonepe.com/articles/what-is-a-payment-aggregator-meaning-pg-difference-and-rbi-rules-explained)) | Lawyer | [RBI notification 12896](https://www.rbi.org.in/Scripts/NotificationUser.aspx?Id=12896) |
| S14 | Check whether kitchen staff still land on `/vendor/dashboard` instead of the kitchen view. This was open in September and was never confirmed fixed | Code check | [UI FIXES.md ISSUE-003](file:///home/user/qr-code-ui/FIXES.md) |
| S15 | Load testing. The page-flow audit listed it as a gap and nothing records it being done | Ops/code | [page-flow-audit.md](file:///home/user/qr-code-ui/plan/page-flow-audit.md) |

The DPDP timeline makes S10 cheap now and mandatory later. The DPDP Rules were notified on 13–14 Nov 2025. The main fiduciary duties (notice, security, breach reporting, retention, rights) apply from about **13–14 May 2027**, and penalties reach **₹250 crore** for security failures that lead to a breach ([SCC Online](https://www.scconline.com/blog/post/2025/12/26/digital-personal-data-protection-rules-2025-key-highlights/); [Seclore](https://www.seclore.com/fundamentals/dpdp-rules-2025-compliance-guide/)). For diner data, the restaurant is the data fiduciary and Tech2Software is its processor. That arrangement needs a written processing contract, which is why the Terms must carry a Data Processing Addendum ([Treelife](https://treelife.in/legal/data-fiduciary-vs-data-processor-redrafting-your-b2b-vendor-dpas/)). For owner and staff accounts, Tech2Software is itself the fiduciary.

### Android track: a blocker only if the APK ships at launch

Vendors can run the product as a web app, so the Capacitor APK can follow later. If it does ship at launch, A1–A3 become P0.

| # | Item | Unblocked by |
|---|---|---|
| A1 | `environment.apk-prod.ts` still points at `https://REPLACE-WITH-YOUR-API-HOST/api`, and the release build refuses to run with that placeholder ([environment.apk-prod.ts](file:///home/user/qr-code-ui/src/environments/environment.apk-prod.ts)) | Owner (the domain from B2) |
| A2 | Create the release keystore and `keystore.properties`. Without them the APK is unsigned ([ANDROID.md](file:///home/user/qr-code-ui/ANDROID.md)) | Owner (keystore custody) |
| A3 | Play Console account (one-time US$25). An **organisation account needs a D-U-N-S number, which can take up to about 30 days**. A new **personal** account must first run a closed test with **12 testers for 14 continuous days** ([Play Console Help](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en); [Capgo](https://capgo.app/blog/how-to-create-apple-developer-and-google-play-developer-accounts/)) | Owner: start the D-U-N-S request now |
| A3b | Privacy policy URL, Data safety form, and **in-app plus web-link account deletion**. Google says deactivation alone is not enough ([Play Console Help 13327111](https://support.google.com/googleplay/android-developer/answer/13327111)) | B5, then code (a delete/anonymise job does not exist yet) |
| A3c | Content rating, a reviewer demo login, and listing assets | Owner |
| A3d | Check Play Payments policy before showing a "Buy plan" button inside the APK. Keeping purchases web-only is the safe default | Owner/legal (not researched) |
| A4 | Cashfree returns to the web origin, not back into the app ([UI FIXES.md phase 1 S1](file:///home/user/qr-code-ui/FIXES.md)) | Code (deep link); acceptable after launch |
| A5 | R8 minify is off, pending keep-rules and a device test ([UI FIXES.md N3b](file:///home/user/qr-code-ui/FIXES.md)) | Code |
| A6 | The APK already targets API 36, which is required for new apps and updates from **31 Aug 2026**. API 36 removes orientation locks on large screens and the edge-to-edge opt-out, so test on a tablet ([Play target API](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-419); [DEV](https://dev.to/mr_manushukla/android-target-api-36-is-due-aug-31-2026-api-37-is-next-the-play-store-migration-checklist-2f9i)) | QA |

### P2: after launch

The documented post-launch backlog covers several areas. Product items are table sessions (one bill per party), per-outlet token sequences, assigning orders to a cook and per-outlet reports ([STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md); [BKD FIXES.md phase 5 B2](file:///home/user/qr-code-bkd/FIXES.md)). Scaling and operations items are moving in-memory rate limits to the database or Redis before running more than one instance, metrics, tracing and in-stack alerting, and a staging build. Provider-dependent items are email (SES or SendGrid), automatic UPI verification (which needs a gateway that collects for vendors), and direct thermal printing (which needs a printer model and a native plugin). Minor items are the single platform time zone and the native `confirm()` dialogs ([RUNBOOK](file:///home/user/qr-code-bkd/docs/RUNBOOK.md); [UI FIXES.md](file:///home/user/qr-code-ui/FIXES.md)). Regulatory follow-ups are full DPDP compliance by May 2027, monthly tracking against the ₹20 lakh GST threshold, and RBI e-mandate rules if auto-renew is ever added. Those rules allow renewals under ₹15,000 without per-debit authentication but require a pre-debit notice at least 24 hours ahead, and every Tech2Software price (the largest is ₹8,262) is under that cap ([RBI](https://www.rbi.org.in/Scripts/NotificationUser.aspx?Id=12341); [NPCI](https://www.npci.org.in/PDF/npci/rupay/2022/Circular-RuPay-AutoPay-AFA-Limit-enhancement-and-compliance.pdf)). Feature gaps against competitors are covered in the recommendations.

A **minimum viable launch is B1, B2, B3, B5, B6 and B7, with manual activation (B4b), on the web only**. Cashfree, the APK and SMS can then follow in sequence, because each depends on the legal pages and the domain.

## Five internal findings undercut the current price sheet

### The 30-day bonus makes monthly the cheapest way to buy

The server grants `months × 30 + 30` days on **every** verified payment, renewals included. While a plan is running, each payment extends from the current end date, so every ₹199 monthly payment buys 60 days ([QrPlan.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrPlan.java); [QrSubscriptionService.java:157-167](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrSubscriptionService.java)). The subscription page calls it a "Limited launch offer". Nothing in the code limits it in time or to the first payment ([subscription.html:12](file:///home/user/qr-code-ui/src/app/features/subscription/subscription.html)). The landing page's promise that "yearly and two-year billing are cheaper per month" is therefore false ([landing.html:57](file:///home/user/qr-code-ui/src/app/features/landing/landing.html)).

| Plan | Monthly: price / days → per 30 days | Yearly: price / days → per 30 days | 2-year: price / days → per 30 days | Cheapest way to cover year 1 under current code |
|---|---|---|---|---|
| QR Starter | ₹199 / 60 → **₹99.50** | ₹2,029.80 / 390 → ₹156.14 | ₹3,582 / 750 → ₹143.28 | 14-day trial + 6 monthly payments = **₹1,194** (374 days) |
| QR Growth | ₹299 / 60 → **₹149.50** | ₹3,049.80 / 390 → ₹234.60 | ₹5,382 / 750 → ₹215.28 | **₹1,794** |
| QR Pro | ₹459 / 60 → **₹229.50** | ₹4,681.80 / 390 → ₹360.14 | ₹8,262 / 750 → ₹330.48 | **₹2,754** |

The effect is that list revenue is halved for any vendor who notices, and the yearly and two-year plans become traps for vendors who do not. Both outcomes are bad, and the second invites complaints once someone does the arithmetic.

### Three paid features have nothing behind them

QR Pro's real differences over Growth are **25 seats instead of 8, and the words "Priority support"**. The `ANALYTICS` flag gates nothing because no analytics feature exists. `PRIORITY_SUPPORT` gates nothing because no support channel exists at all ([BKD FIXES.md phase 2 B7a](file:///home/user/qr-code-bkd/FIXES.md)). Growth and Pro both include `PAYMENT_GATEWAY`, which stores encrypted PhonePe PG credentials that **no code path ever uses**, and the UI has no screen to enter them ([TenantPaymentConfigService.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/payment/TenantPaymentConfigService.java)). "Advanced analytics", "Multi-location readiness" and "Customer payment gateway" were already removed from the buyer-facing bullets because they "did not exist", but "Priority support" remains ([qr-plans.ts](file:///home/user/qr-code-ui/src/app/plan/qr-plans.ts)). Printing has the opposite mismatch: it is sold as a Growth/Pro feature but works on every plan, and the setup wizard still claims a printer connection that does not exist.

### Pricing basics are undecided

The seat limits of 3, 8 and 25 are labelled in the code docs as **"my proposal, not your policy"** ([BKD FIXES.md ISSUE-020](file:///home/user/qr-code-bkd/FIXES.md)). Outlets are unlimited and unpriced, so a ₹199 Starter vendor can run ten branches ([page-flow-audit.md](file:///home/user/qr-code-ui/plan/page-flow-audit.md)). No price says whether it includes GST, and no document records Tech2Software's GST registration. Stale planning documents still mention a ₹100 Starter price and a ₹149-per-seat charge that was never billed. Any external comparison must use the numbers in `QrPlan.java`, not those documents ([design spec](file:///home/user/qr-code-ui/docs/superpowers/specs/2026-06-17-qr-ordering-platform-design.md); [production-readiness.md](file:///home/user/qr-code-ui/plan/production-readiness.md)).

### Lapse is silent and brutal

When a trial or plan lapses, the public menu returns **404 "Vendor not found"**, so every printed table QR stops working at once ([PublicService.java:396-406](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/publicapi/PublicService.java)). No email or SMS reminder exists to warn the vendor first. Combined with "nothing renews automatically" ([landing.html:44](file:///home/user/qr-code-ui/src/app/features/landing/landing.html)), the predictable failure is a busy stall whose customers suddenly see an error page. That is exactly the kind of moment that produces a 1-star review.

### Payment and phone handling carry trust risk

UPI payments are **never automatically verified**. The customer may type a UTR, but staff must check their bank app before tapping Mark Paid ([BKD FIXES.md phase 3 O3](file:///home/user/qr-code-bkd/FIXES.md)), and a fake UTR can pass at a busy counter. Checkout also **requires** the diner's name and a 10-digit mobile number ([customer-order.html:171-177](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html)), and staff can see those numbers. That is the exact exposure behind the May 2026 Pune incident, where a restaurant employee used a phone number captured through a QR menu to send a woman late-night messages ([India TV](https://www.indiatvnews.com/trending/news/pune-woman-qr-code-menu-restaurant-employee-late-night-messages-viral-video-harassment-2026-05-14-1041098)). The consent checkbox and the "not used for marketing" notice are good ([customer-order.html:221](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html)). Mandatory phone capture is weaker than QRSathi's "no app, sign-up or phone number" pitch ([qrsathi.in](https://qrsathi.in/)).

## Indian rivals crowd the ₹0–₹500 band, and two first-pass names are gone

### The real "Lite" competitors fall into six groups

The research separates the market into six groups.

The **direct low-cost Indian QR-ordering startups** are the dangerous set. They include Scan & Order (scanorder.in), MenuScan, Ahaar Scan, QRSathi, AviQR, Orderzy, Dinehere, DineOpen, Restrofi, MenuManager, QR FOOD MENU and Scanmyfood.

The **entry tiers of the POS suites** are next: Petpooja POSS Lite with "limited" Scan & Order, GrowVyapar Smart Dine-In, GoFrugal and Rista. These are sold through sales teams, which suggests that is how they win customers.

**Free or cheap generic billing apps** have no diner self-ordering: Vyapar and its Table app, Zobaze, myBillBook, Swipe, Khatabook, Loyverse and TallyPrime. For a tea stall these are the realistic alternative, along with **UPI QR plus a notebook, which costs nothing**.

**Commission or diner-fee models** include DotPe, Orderzy and Menuthere's capped free tier.

**Global QR-menu SaaS** (MenuTiger, FineDine, Menubly, Uniqode, QRCodeChimp, IAMenu) prices in US dollars and has no native UPI.

The last group is **dead, closed or dormant**: Thrive, GloriaFood, Bikayi, Paytm Scan to Order (last documented in 2020) and Zomato contactless dining (2020).

Swiggy and Zomato do not sell a QR table-ordering tool to stalls. Their dine-in play is consumer payments and discovery (Swiggy Dineout, Zomato's District app, launched Nov 2024), for which NRAI complained in 2022 of **4–12% commission plus forced 15–40% discounts** ([Storyboard18](https://www.storyboard18.com/brand-marketing/zomato-to-launch-district-app-in-4-weeks-deepinder-goyal-45677.htm); [Inc42](https://inc42.com/buzz/zomato-pay-swiggy-diner-may-adversely-impact-restaurant-industry-in-the-long-run-nrai/)). Fintechs have not built dine-in ordering either: no menu or ordering product was found from PhonePe, BharatPe, Pine Labs or OkCredit.

### The second review pass overrides several first-pass claims

**Thrive is gone.** YourStory reported in December 2024 that it would shut down. The CEO cited a "lack of resources" in a market "dominated by a few well-funded giants", and the restaurant-side units were moved to unnamed partners ([YourStory](https://yourstory.com/2024/12/food-delivery-startup-thrive-to-shut-down-operations); [Inc42](https://inc42.com/buzz/coca-cola-backed-foodtech-startup-thrive-shuts-operations)). Its ₹299/₹899 plans and free dine-in are a frozen legacy rate card, not a live offer. Thrive was backed by Jubilant and Coca-Cola, claimed 14,000+ restaurants, and still could not sustain a ~3% direct-ordering model. Its main lesson is about vendor-survival risk, which buyers will also apply to us.

**GloriaFood has closed to new signups.** Its homepage banner gives end of service as 30 April 2027, while Oracle's food-and-beverage pages reportedly say 31 March 2027, so plan on the earlier date ([AppInstitute](https://appinstitute.com/gloriafood-shutting-down-alternatives/); [Menuro](https://menuro.io/blog/gloriafood-shutting-down-2027/)).

**MenuScan's entry price is ₹250/month.** Its tiers are Premium at ₹600 and Premium + POS at ₹750. No ₹129 tier exists on any indexed page, and its yearly figures do not reconcile, so quote monthly prices ([MenuScan blog](https://menuscan.in/blog/best-qr-ordering-system-2026); [MenuScan FAQ](https://menuscan.in/faq)).

**DineCard and QRSeva are menu-only.** DineCard charges $9/month globally and ₹99/month in India; QRSeva's ₹199 price was not reconfirmed. Neither should be compared with us on ordering ([dinecard.in](https://www.dinecard.in/); [QRSeva](https://www.qrseva.com/compare/qrseva-vs-menubly)).

**Menuthere's own price card is in US dollars**: Free (50 orders a month), Lite $9 and Pro $39, with 0% commission. The ₹299 figure came from a competitor's blog ([Menuthere](https://menuthere.com/alternatives/foodpanda)).

**DineOpen's price is unresolvable.** Its own pages variously show ₹299/month, ₹899/month all-in, and $20/$50/$99 ([DineOpen pricing](https://www.dineopen.com/pricing); [DineOpen billing app](https://www.dineopen.com/restaurant-billing-app)).

**Petpooja still publishes no price**, and no free plan was found.

**DotPe has no public rate card.** The only published figure is the 2020 rate of ₹1–1.5 per order. Its September 2024 data exposure of diner names, phone numbers and orders is confirmed by several outlets, and DotPe attributed it to "human error" ([Outlook Business](https://www.outlookbusiness.com/magazine/business/story/with-nrais-blessing-this-fintech-start-up-is-dreaming-big-should-restaurant-aggregators-be-worried-5964); [Benzinga India](https://in.benzinga.com/news/24/09/41019389/how-this-person-accessed-sensitive-user-information-by-just-scanning-cafe-qr-code)).

### Year-1 cost for a small stall puts us mid-pack

The table uses one scenario throughout: **a single-outlet tea stall or small café using the owner's own phone, no printer, about 30 orders a day (≈900 a month) at about ₹100 each (≈₹90,000 a month)**. Where a vendor quotes prices excluding GST, 18% is added. Whether our own prices carry GST is undecided (B9). If Tech2Software registers and quotes "+ GST", add 18%: Starter yearly becomes ₹2,395.

| Vendor and entry plan | Published entry price | Year-1 cost for the scenario | Does the entry plan cover 900 orders/month? | Source quality |
|---|---|---|---|---|
| **Ours, QR Starter** | ₹199/mo; ₹2,029.80/yr; 14-day trial | **₹1,194** under current code (6 monthly payments); ₹2,029.80 yearly; ₹2,189 monthly if the bonus is limited to the first payment | Yes, unlimited orders | Code ([QrPlan.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrPlan.java)) |
| Ours, QR Growth / Pro | ₹299 / ₹459 per month | ₹3,049.80 / ₹4,681.80 yearly | Yes | Code |
| Scan & Order (scanorder.in) | ₹199 for 31 days; ₹699 for 182 days; ₹999 for 399 days; 30-day trial | **₹999** (the 399-day plan, ≈₹75/mo) | Yes | Official ([scanorder.in](https://scanorder.in/)) |
| Ahaar Scan | ₹399/mo or ₹2,999/yr; zero commission | **₹2,999**, plus any gateway charge on UPI/card (not published) | Yes | Third-party, consistent ([GetApp](https://www.getapp.com/all-software/a/ahaar-scan/)) |
| MenuScan Basic | ₹250/mo; 7-day trial | **₹3,000** (yearly figures conflict) | Item limits by tier | Official, inconsistent ([MenuScan blog](https://menuscan.in/blog/best-qr-ordering-system-2026)) |
| DineOpen | ₹299/mo (also ₹899/mo all-in) | ₹3,588–₹10,788 | Unclear; one page says "KOT requires paid plan" | Official, conflicting |
| Dinehere Starter | ₹499/mo; a free version exists | ₹5,988 | Yes | Third-party, 0 reviews ([Capterra](https://www.capterra.com/p/10038917/Dinehere/)) |
| Petpooja POSS Lite (Scan & Order "limited") | ~6,000 + GST/yr (or $67 + GST) | **≈₹7,080 + hardware** | Limits undocumented | Third-party, conflicting ([Capterra](https://www.capterra.com/p/172163/Petpooja-Restaurant-Management-Platform/pricing/); [SoftwareSuggest](https://www.softwaresuggest.com/petpooja/pricing)) |
| Petpooja Core / Growth (full Scan & Order) | ₹10,000 / ₹20,000 + GST per outlet | ₹11,800 / **₹23,600**, plus hardware (competitors claim ₹15,000+) | Yes | Third-party ([Techjockey](https://www.techjockey.com/detail/petpooja-pos)) |
| Restrofi Premium | ₹699/outlet/mo or ₹6,999 first year, excl. GST; includes thermal KOT | ₹8,259 | Yes | Official ([Restrofi](https://restrofi.com/pricing)) |
| Menuthere Lite | Free (50 orders/mo) or $9/mo | ≈₹10,363 (the free tier is far too small) | Free: no. Lite: yes | Official, USD ([Menuthere](https://menuthere.com/alternatives/foodpanda)) |
| GrowVyapar Smart Dine-In | ₹12,999/yr; needs a thermal printer | ₹12,999 + printer | Yes | Official ([GrowVyapar](https://www.growvyapar.in/services/best-restaurant-billing-software)) |
| DotPe QR | Quote only; ₹1–1.5/order (2020) | ≈₹10,950–₹16,425 on 2020 rates (10,950 orders); current rate unknown | Yes | Dated third-party |
| Orderzy | Free to the restaurant; the diner pays an undisclosed fee | ₹0 to the vendor | Yes | Third-party ([Capterra India](https://www.capterra.in/software/1105128/Orderzy)) |
| AviQR free | 20 items, 50 orders/day, 1 QR; paid tiers "launching soon" | ₹0 | Orders yes; 20 items and 1 QR are tight | Official/third-party ([itechguides](https://www.itechguides.com/products/aviqr/)) |
| QRSathi | "Free to start"; paid price not found | ₹0 + unknown | Unknown | Official ([qrsathi.in](https://qrsathi.in/)) |
| MenuTiger | Freemium (2 tables, 200 QR orders/mo); Regular $17/mo; no UPI | ₹0 (capped) or ≈₹16,600 on annual billing | Free: no | Official ([MenuTiger help](https://menutiger.helpscoutdocs.com/article/153-what-are-the-different-plans-and-subscriptions-available)) |
| DineCard (menu only) | ₹99/mo or ₹999/yr (India); $9 globally | ₹999, but no ordering | n/a | Official |
| Free generic billing (Vyapar Table, Loyverse, Zobaze free tier) | ₹0 entry | ₹0, but no diner QR ordering | n/a | Mixed |

Three conclusions follow. First, **we are not the cheapest**. Scan & Order's ₹999 for 399 days, with a 30-day trial, undercuts our best yearly price by half. Ahaar Scan's ₹2,999 a year is near our Starter yearly price but includes gateway-confirmed payments, WhatsApp ordering, loyalty and coupons. Second, we sit **one-third to one-tenth of the POS-suite price** for comparable QR ordering, and need no hardware. Third, the **free tiers fail at real volume**. Menuthere caps at 50 orders a month, MenuTiger at 200 QR orders a month on two tables, and AviQR at 20 items and one QR. A stall doing 30 orders a day outgrows all of them in days, which is our opening. The exceptions are Orderzy, which pushes the cost onto diners, and QRSathi, whose paid tier is unknown.

### Commission models lose above a modest volume

A gateway charging 2% plus 18% GST (2.36% effective) costs more than our ₹199 Starter once card or UPI sales pass about **₹8,432 a month**. A 3% commission crosses ₹199 at ₹6,633 a month. A ₹1-per-order fee crosses it at 199 orders a month. These are calculations based on Razorpay's and Cashfree's standard 2% + GST ([Razorpay](https://razorpay.com/blog/razorpay-payment-gateway-pricing-explained/); [Cashfree](https://www.cashfree.com/en/payment-gateway-charges/)). The new 0.4% UPI MDR from 15 Oct 2026 applies only to P2M payments above ₹2,000, and **merchants receiving up to ₹1 lakh a month via UPI QR are exempt** ([Morung Express](https://morungexpress.com/npci-reveals-mdr-on-upi-payments-above-rs-2000-from-oct-15-small-merchants-continue-to-benefit); [BusinessToday](https://www.businesstoday.in/latest/economy/story/upi-mdr-gst-npci-says-small-merchants-and-96-of-transactions-remain-unaffected-from-october-15-557039-2026-09-22)). A stall's typical orders therefore stay fee-free under our UPI-intent model. Owners are intensely fee-averse: in a LocalCircles survey of 32,796 merchants, **only 17% would bear an MDR of 0.3% or more, and 41% would bear none** ([LocalCircles](https://www.localcircles.com/a/press/page/upi-merchant-survey)). "0% commission, and your money goes straight to your own UPI" is a sound pitch to that audience.

## Feature by feature, we win the kitchen and lose the table

The matrix compares our product with the competitors that matter most to a small Indian stall or café. **Y** means the vendor's page or a reliable listing says yes. **N** means absent. **?** means unverified, which is common because demo menus could not be opened. **3P** means third-party only.

| Feature | **Ours** | Scan & Order | MenuScan | Ahaar Scan | QRSathi | Orderzy | AviQR (free) | Petpooja Lite / Scan & Order | DotPe / Rista | MenuTiger | DineCard |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Entry price | ₹199/mo | ₹199/31d; ₹999/399d | ₹250/mo | ₹399/mo; ₹2,999/yr | ₹0 start | ₹0 (diner fee) | ₹0 | ~₹6k+GST/yr (3P) | Quote | $0 / $17 | ₹99/mo |
| Trial / free tier | 14-day, no card | 30-day | 7-day | ? | Free | Free | Free, capped | Conflicting | None listed | Freemium | 14-day |
| Commission on orders | 0% | ? | ? | 0% | ? | Diner pays | ? | Subscription | ₹1–1.5/order (2020) | 0% | n/a |
| Per-table QR | **Y, revocable** | Y | Y | Y | N (one QR) | Y (3P) | N (1 QR) | Y | Y | Y | Menu QR |
| Browser ordering, no app | Y | Y | Y | Y | Via WhatsApp | Y | ? | Y | Y | Y | N (menu only) |
| Takeaway / delivery ordering | Counter QR only | Y | ? | Y | WhatsApp | ? | ? | Conflicting | Y | Y | N |
| Variants / add-ons | Y | ? | ? | ? | ? | ? | ? | Y | ? | Y | n/a |
| Veg/egg/non-veg tags, photos, item hours | **Y** | ? | ? | ? | ? | ? | ? | ? | ? | Allergens | ? |
| Sold-out toggle | Y | ? | Y | ? | ? | ? | ? | ? | Y (sync bugs reported) | ? | ? |
| Multi-language menu | **N (English only)** | ? | **Y (22 Indian)** | Y (Hindi) | Y (Hindi/regional) | ? | Y (9 Indian) | Support in 18+ languages | ? | Y (19, paid) | Y (AI) |
| Diner phone required | **Y (mandatory)**; OTP optional and off | ? | ? | ? | **N** | ? | ? | OTP/validation | WhatsApp number (2020) | ? | n/a |
| UPI | Y (intent to vendor's VPA) | ? | Y | Y | Y (deep link) | Y | Y (Razorpay) | Y | Y | **N** | n/a |
| Payment auto-confirmed | **N (manual UTR)** | ? | Y (gateway) | Y (next-day settlement) | N | ? | Y | Setup-dependent | Y | Y (Stripe/PayPal) | n/a |
| Cash / pay at counter | Y | ? | Y | ? | ? | Y | ? | Y | ? | Custom method | n/a |
| Token numbers | **Y** | ? | ? | ? | ? | ? | ? | Y | ? | ? | n/a |
| Live tracking for diner | Y (Growth+) | ? | ? | Stages (vendor side) | ? | ? | ? | ? | ? | ? | n/a |
| Diner self-cancel | **Y** | ? | ? | ? | ? | ? | ? | ? | ? | ? | n/a |
| One bill per table (session) | **N** | ? | **Y** | ? | ? | **Y** | ? | **Y** | ? | ? | n/a |
| Call waiter / bill request | N | ? | ? | ? | ? | ? | ? | Hardware add-on | ? | **Y** | n/a |
| Feedback / Google review prompt | N | ? | ? | ? | **Y** | ? | ? | Y (module) | ? | Y | ? |
| Loyalty / coupons | N | Discount codes | ? | **Y** | Y (stamp card) | ? | Paid, "soon" | CRM add-on | WhatsApp marketing | ? | Offers |
| WhatsApp | **N** | Support only | Alerts per order | Ordering | Ordering | ? | Paid campaigns | Y | Y | ? | ? |
| Kitchen display | **Y (late flags)** | Notifications | Kitchen tickets | Dashboard stages | ? | Y (queue) | ? | Add-on | Y ("basic", 3P) | Paid tiers | n/a |
| KOT print | Y (browser print dialog) | ? | Y | Not mentioned | ? | ? | ? | Y | Y | ? | n/a |
| Direct thermal / Bluetooth print | **N** | ? | ? | ? | ? | ? | ? | Y | Y | ? | n/a |
| GST invoice | **N** | ? | **Y (on table close)** | GST/tip config | ? | Itemised bills | ? | Y | Y | N | n/a |
| Inventory | N | ? | ? | ? | ? | ? | ? | **N in Lite** | Y | ? | n/a |
| Reports | Today-only dashboard; filtered order list; no export | Basic, then advanced | ? | Analytics | ? | ? | Basic | "Limited" in Lite | Y | Higher tiers | ? |
| Staff roles / seats | **5 roles; 3/8/25 seats** | ? | Multi-location login | ? | ? | ? | Paid, "soon" | Captain app | Waiter app | 1 admin on free | ? |
| Multi-outlet | Y (unlimited, unpriced) | ? | Y | ? | ? | ? | Paid, "soon" | **N in Lite** | Y | Paid | ? |
| Swiggy/Zomato | N | N | ? | ? | N | Alongside POS | ? | Y | Y | N | N |
| Offline mode | N | ? | ? | ? | ? | ? | ? | Y (local server) | Claimed "offline for days" | ? | N |
| Android vendor app | APK built, not on Play | Business plan only | ? | Listed by one directory | ? | ? | ? | Y | Y | Web | ? |
| Privacy consent screen | **Y** | ? | ? | ? | ? | ? | ? | ? | 2024 data exposure | ? | n/a |

Sources by column. Ours: [QrPlan.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrPlan.java), [customer-order.html](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html), [BKD FIXES.md](file:///home/user/qr-code-bkd/FIXES.md). Scan & Order: [scanorder.in](https://scanorder.in/) and its [blog](https://scanorder.in/blog/best-qr-code-ordering-systems-for-restaurants-in-india). MenuScan: [menuscan.in](https://menuscan.in/), [features](https://menuscan.in/features). Ahaar Scan: [Capterra India](https://www.capterra.in/software/1108120/Ahaar-Scan), [GetApp](https://www.getapp.com/all-software/a/ahaar-scan/). QRSathi: [qrsathi.in](https://qrsathi.in/). Orderzy: [Capterra India](https://www.capterra.in/software/1105128/Orderzy). AviQR: [aviqr.com](https://aviqr.com/), [itechguides](https://www.itechguides.com/products/aviqr/). Petpooja: [Scan & Order](https://www.petpooja.com/poss/scan-and-order), [blog](https://blog.petpooja.com/industry-business-guides/what-is-scan-and-order-qr-ordering-indian-restaurants/), [Capterra pricing](https://www.capterra.com/p/172163/Petpooja-Restaurant-Management-Platform/pricing/), [Offline POS](https://www.petpooja.com/offline-pos). DotPe/Rista: [dotpe.in](https://dotpe.in/), [Rista POS](https://ristaapps.com/restaurant-point-of-sale-software), [Rista on Play](https://play.google.com/store/apps/details?id=com.ristaapps.business&hl=en_IN). MenuTiger: [help center](https://menutiger.helpscoutdocs.com/article/153-what-are-the-different-plans-and-subscriptions-available), [integrations](https://menutiger.helpscoutdocs.com/article/175-integrate-third-party-services), [Hot Actions](https://www.menutiger.com/blog/restaurant-waiter-call-button-system). DineCard: [hunted.space](https://hunted.space/product/dinecard).

The pattern is consistent. **We are strongest where the order meets the kitchen.** Our base offer includes a kitchen display with late flags, where Petpooja sells KDS as an add-on and MenuTiger keeps it for paid tiers. We also have token numbers, diner live tracking, diner self-cancel, revocable table QRs, five staff roles with seat limits, outlet-scoped menus, CSV menu import, veg/egg/non-veg tags and item hours. None of the competitor pages mentioned diner self-cancel, and the only comparable stage notifications found were Restroworks', an enterprise product ([Restroworks](https://www.restroworks.com/customer-order-display/)).

**We are weakest where the order meets the table and the bill.** Every serious dine-in competitor checked supports repeat orders joining one running bill: Petpooja, MenuScan, Orderzy, FineDine's Full Service mode, and Thrive before it closed. Our model is strictly one order per token ("Orders are per table, not per sitting", [BKD FIXES.md phase 3 Q2](file:///home/user/qr-code-bkd/FIXES.md)). That fits tea stalls and QSR counters but not sit-down cafés. Multi-language menus are now standard even in free tiers: MenuScan offers 22 Indian languages, AviQR 9, QRSathi Hindi and regional languages, and Ahaar Scan Hindi. A WhatsApp touchpoint appears in almost every Indian rival. Gateway competitors confirm payments automatically, while our cashier opens a bank app to check each one.

## Reviews say owners punish money surprises and silence

### Play Store and B2B review sites tell the same story

All Play Store figures below come from search-engine snapshots of uncertain date, because play.google.com could not be fetched directly.

| App (package) | Play rating / reviews / installs | Other stores | Dominant written complaint |
|---|---|---|---|
| Petpooja Merchant (`com.petpooja.billing`) | ~4.5★ / 25–26.4K / 500K+ | iOS ~4.7★ / 8,600 | A 2026 update hid previous-day sales; sales calls bounce to an unanswered support line; "they only call u for subscriptions" ([Play](https://play.google.com/store/apps/details?id=com.petpooja.billing&hl=en_IN)) |
| Zomato Restaurant Partner | ~4.5★ / 70–72K / 5M+ | iOS 2.7–3.7★ | ₹10,000 onboarding fee; ticket loops; discounts the owner never created; missed order alerts ([Play](https://play.google.com/store/apps/details/Zomato_Restaurant_Partner?id=com.application.services.partner&hl=en_US); [App Store](https://apps.apple.com/in/app/zomato-restaurant-partner/id1515073489?see-all=reviews&platform=iphone)) |
| Swiggy Partner | ~3.9★ / 42.6K | iOS "Swiggy Owner" 1.9★ | Ad deductions larger than the orders they bring; fees charged while the outlet showed offline; busy support lines ([Play](https://play.google.com/store/apps/details?id=in.swiggy.partnerapp&hl=en_IN)) |
| DotPe Digital Showroom | ~4.0★ / ~202K / 10M+ | iOS 3.4★ / 575 | "No refund policy" after ₹8,000 for undelivered work; a promised lifetime free plan not restored ([App Store](https://apps.apple.com/in/app/digital-showroom-business-app/id1544439745?see-all=reviews&platform=iphone)) |
| Rista POS | ~4.3★ / 1–1.2K / 100K+ | AppBrain 4.0★ | "Mostly buggy"; item turn-off not syncing; escalation failed even with the CEO involved ([Play](https://play.google.com/store/apps/details?id=com.ristaapps.business&hl=en_IN)) |
| Vyapar | ~4.8★ / 171–196K / 10M+ | iOS ~3.5★ | Slow support; staff devices locked with "License Expired"; split payments wrong in reports ([Play](https://play.google.com/store/apps/details?id=in.android.vyapar)) |
| Vyapar Table (restaurant/KOT) | 100K+; no aggregate rating | — | Trial length "not clearly communicated"; slow Bluetooth printing ([AppBrain](https://www.appbrain.com/app/table-restaurant-billing-app/in.android.restaurant_billing)) |
| Zobaze Restaurant POS | ~4.6★ / 1.1–1.2K / 100K+ | — | No split payment; no KOT before payment; Epson printers unsupported; users want a UPI QR on receipts ([Play](https://play.google.com/store/apps/details?id=com.zobaze.restaurant.pos&hl=en_US); [AppBrain](https://www.appbrain.com/app/restaurant-caf%C3%A9-billing-pos/com.zobaze.restaurant.pos)) |
| myBillBook | ~4.4★ / ~149K / 10M+ | — | Slowness; invoice customisation behind a paywall ([AppBrain](https://www.appbrain.com/app/mybillbook-invoice-billing-app/com.valorem.flobooks)) |
| Swipe | 5.0★ shown / ~15K / 1M+ | iOS 4.8★ | A 5.0 average on 15K reviews needs a sanity check ([Play](https://play.google.com/store/apps/details?id=in.swipe.app&hl=en_IN)) |
| Torqus Edge | 4.0★ / 115 / 5K+ | — | Last updated Sept 2019, effectively dormant ([Play](https://play.google.com/store/apps/details?id=com.torqus.notiapp&gl=US)) |

High Play averages mislead. The same brands score far lower on iOS: Zomato 2.7–3.7, Swiggy 1.9, DotPe 3.4, Vyapar about 3.5. The written 1–2★ reviews cluster on **money and being ignored**, not on missing features. Off-store sites agree. Petpooja scores 4.7/5 on G2 (289 reviews) and 4.6/5 on Capterra (37), but its Trustpilot TrustScore is 3.2. One Trustpilot reviewer says Petpooja "confirmed my full refund in writing on 12 December 2025" with nothing credited weeks later ([G2](https://www.g2.com/sellers/petpooja); [Trustpilot](https://www.trustpilot.com/review/petpooja.com)). DotPe scores 2.5/5 on Trustpilot, from only four reviews ([Trustpilot](https://www.trustpilot.com/review/www.dotpe.in)). Restroworks gets 4.8 on SoftwareSuggest for support but only 2.7 for value ([SoftwareSuggest](https://www.softwaresuggest.com/restroworks)). Employee ratings are a weak proxy, but they point the same way: Petpooja 4.1–4.3 on AmbitionBox and DotPe 3.2–3.3 ([AmbitionBox](https://ambitionbox.com/overview/dotpe-overview)).

The **QR-ordering category on Play Store India is thin and unbranded.** No QR-first vendor app with large installs or many reviews surfaced. The POS majors use their Android apps as companions to sales-led deals, so a self-serve vendor app with a good listing could rank cheaply against generic "restaurant billing / KOT" apps.

### The diner side is mixed, and privacy is the live wire

The only India-specific diner survey is Dineout's April 2020 lockdown-era study. It found **81% would rather scan a QR than handle physical menus** and 60% preferred wallet payments ([IANSlife](https://www.ianslife.in/food-fitness/indias-food-trends-post-covid-19-era)). Post-pandemic US data has swung back. Toast found 81% prefer a physical menu and only 1% prefer QR codes ([Toast](https://pos.toasttab.com/blog/on-the-line/qr-code-menu-insights)). Technomic found 88% prefer paper and 57% call QR menus a chore ([Restaurant Business](https://www.restaurantbusinessonline.com/technology/customers-really-dont-qr-code-menus)). US Foods found Gen Z's paper preference rose to 90% in 2024 ([Business Wire](https://www.businesswire.com/news/home/20241008659223/en)). No 2023–2026 Indian survey on QR privacy exists. The India signals are incidents instead: DotPe's 2024 API exposure and the 2026 Pune phone-number harassment case. UPI itself is near-universal, with 94% of small merchants having adopted it and about 658M UPI QR codes deployed ([Business Standard](https://www.business-standard.com/finance/news/small-merchants-built-upi-s-reach-here-s-what-government-data-shows-126081700057_1.html)). QR *payment* is therefore normal, while QR *menus and ordering* remain contested, especially among older diners.

## Why a vendor picks us, and why they walk away

A vendor should choose us for six reasons, each of which answers a documented pain. The **price is visible and flat**: no setup fee, no hardware, no commission, no ads wallet, and **nothing renews automatically**. That directly answers the refund, renewal and hidden-charge complaints that dominate DotPe, Zomato, Swiggy and Petpooja reviews. **Money goes straight to the vendor's own UPI ID**, so we never hold funds, never delay settlement and charge no gateway fee. That matters to a merchant base where 41% reject any MDR at all. At ₹199–₹299 a vendor gets **kitchen-grade operations** that cheap rivals lack or leave unverified: a kitchen display with late flags, daily token numbers, diner live tracking, self-cancel, alerts, and five staff roles with seat limits. The QR codes are **revocable per table**, and the **privacy consent screen** is explicit, a credible contrast to DotPe's exposure. Outlets are already supported. And once the APK is on Play, it would compete in a category with no strong branded QR-ordering app.

A vendor would choose a competitor for just as many reasons, and most are fixable. **Scan & Order is cheaper per year and gives 30 trial days.** **MenuScan** bundles GST invoices, shared table sessions, WhatsApp alerts and 22 Indian languages at ₹250. **Ahaar Scan** confirms payments through a gateway and adds WhatsApp ordering, loyalty, coupons and Hindi. **QRSathi** is free, asks diners for no phone number, and prompts Google reviews. **Orderzy** costs the vendor nothing and runs one combined bill. **Petpooja** is one system for billing, GST, Swiggy/Zomato, Tally, offline mode and printing, with support in 18+ Indian languages and a brand that claims 1,00,000+ outlets ([Petpooja support](https://www.petpooja.com/support); [Petpooja blog](https://blog.petpooja.com/industry-business-guides/best-restaurant-pos-software-india/)). A tea stall may decide **UPI QR plus a notebook, or a free billing app, is enough**.

Today we also lose on things unrelated to features. There is no support number, no Terms or refund policy, and no track record. The Play app is not live. Mandatory diner phone capture creates privacy exposure. Manual UTR checks open the door to fake-payment fraud. And customers' QR codes go dark on the day the plan lapses. Thrive's closure shows buyers are right to ask whether a small vendor will survive. The answer to that question is transparent terms, data export and a responsive human, not a feature list.

## Recommendations: fix the offer, then sell the stall segment

### Pricing

**Fix the bonus first.** Grant the 30 bonus days on the **first paid purchase only**, or scale them so that longer commitments always win (for example 0 days on monthly, 30 on yearly and 60 on two-year). Then the landing-page claim about yearly savings becomes true. Remove "Limited launch offer" or give it a real end date. Change the admin grant path to extend from the current end date (S4).

**Rebuild or drop Pro.** Until analytics and a staffed priority channel exist, Pro sells nothing beyond seats. The options are to fold seats into an add-on and keep two plans, or to make Pro real with item-wise and day-wise reports, CSV export, multi-outlet reporting and a WhatsApp support SLA. Remove PAYMENT_GATEWAY from Growth until a vendor can actually use their PhonePe credentials.

**Decide printing.** Either gate printing to Growth+ as sold, or keep it free and change the copy. Printing through the browser dialog is weak enough that charging for it invites complaints.

**Price outlets.** Unlimited free outlets on a ₹199 plan undercut Growth and Pro. Restrofi, for comparison, prices per outlet ([Restrofi](https://restrofi.com/pricing)).

**Answer the ₹75/month band.** Scan & Order (₹999 for 399 days) and Ahaar Scan (₹2,999 a year) anchor the yearly price. Once the bonus is fixed, Starter yearly at ₹2,029.80 is defensible only if it visibly beats them on kitchen features and support. A limited free entry tier would answer QRSathi, AviQR and Menuthere at the bottom: for example, one outlet, a few tables and a monthly order cap below a busy stall's volume. Evidence on tea-stall pricing points to a free core with a ₹99–199 upgrade ([OrderIt guide](https://orderitnow.in/blog/best-free-affordable-restaurant-billing-software-in-india-2026-under-%E2%82%B95000-year/); [LocalCircles](https://www.localcircles.com/a/press/page/upi-merchant-survey)). Treat that as a hypothesis to test, not a finding.

**Show GST treatment everywhere**, consistent with the CA's decision (B9).

**Keep diner OTP off by default.** At about ₹0.20 per SMS, 100 orders a day costs about ₹600 a month in OTPs, three times the Starter price ([Authgear](https://www.authgear.com/post/best-otp-service-providers/)). Use SMS only for vendor sign-up and password reset. WhatsApp authentication costs about ₹0.115–0.145 plus provider markup ([Whautomate](https://whautomate.com/whatsapp-business-api-pricing-india); [AiSensy](https://m.aisensy.com/blog/whatsapp-business-pricing/)).

### Positioning

Do not position against Petpooja as a POS replacement. Position as **"the ₹199 order-to-kitchen layer for stalls, kiosks, food courts and QSR counters"**: zero commission, the vendor's own UPI, no hardware, cancel any time, and a human on WhatsApp. For cafés already on a billing app, pitch it as a **complement**. Petpooja Lite itself bundles only "limited" Scan & Order, so a café can add our ordering without replacing its POS. Lead with the trust promises the review evidence shows owners want: a visible price, the trial end date shown in the app, no auto-renew, a stated refund rule, and a published support response time. Market the **privacy stance** (consent screen, revocable QR, data never sold) explicitly. Back it up by making diner phone numbers optional, or masking them from non-owner staff. Our "not used for marketing" promise rules out a Reelo-style loyalty upsell, which reaches about 17,000 businesses ([Outlook Business](https://www.outlookbusiness.com/corporate/reelo-raises-1-million-from-silicon-valley-based-angel-investor-gokul-rajaram-report)). That is a deliberate trade-off and should stay one.

### Must-build features, ranked by evidence

| Priority | Feature | Why (evidence) |
|---|---|---|
| Now | Renewal reminders, plus a grace period that keeps the menu viewable rather than returning 404 | Silent QR death on lapse; trial nudges lift conversion. No-card trials convert at about 4–6% median and 18% at better performers ([Userpilot](https://userpilot.com/blog/free-trial-conversion-rate/); [Flint](https://www.flint.com/blog/b2b-saas-free-trial-conversion-rate-statistics)) |
| Now | Account deletion (in-app and web) and a diner data retention job | Play policy; DPDP |
| Now | Fix the wizard printer claims and the printing copy | False claims become refund disputes |
| 30–60 days | **Hindi plus one regional language** for the diner menu, then the vendor UI | MenuScan offers 22 languages, AviQR 9, and QRSathi and Ahaar Scan Hindi |
| 30–60 days | **Table session**: repeat orders join one bill, with a "request bill" button | Petpooja, MenuScan, Orderzy and FineDine all have it |
| 30–60 days | Reports owners actually use: today vs yesterday, cash vs UPI split, item-wise sales, CSV export | Petpooja's update that hid yesterday's sales drew complaints; Zobaze and Vyapar split-payment errors |
| 30–60 days | WhatsApp touchpoint: a shareable menu/order link, and an order-ready or receipt message to the diner on opt-in | Present in almost every Indian rival |
| 60–90 days | Feedback and Google-review prompt; call-waiter or water request | QRSathi, MenuTiger, FineDine, Thrive (legacy) |
| 60–90 days | Optional auto-confirmed payments through the **vendor's own** gateway credentials, which keeps the vendor as merchant of record and outside PA licensing | Removes manual UTR checks and fake-UTR fraud. The credential storage already exists but is unused ([TenantPaymentConfigService.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/payment/TenantPaymentConfigService.java)); a vendor-held gateway stays outside PA licensing, which applies to entities handling funds ([RBI notification 12896](https://www.rbi.org.in/Scripts/NotificationUser.aspx?Id=12896)) |
| 60–90 days | Bluetooth 58/80 mm ESC/POS printing via a native plugin, with a **published list of tested printers** | Printer compatibility is the top hardware complaint in Zobaze and Vyapar Table reviews |
| Later | A simple GST bill for registered vendors; a UPI QR on the slip | MenuScan; Zobaze feature requests |
| Skip for now | Aggregators, Tally, inventory | These are table stakes only in the POS tier, which is not our segment |

### Launch checklist, compliance and go-to-market

| When | Item | Type |
|---|---|---|
| Before launch | CA confirms GST status; prices labelled accordingly; receipts or tax invoices issued | Legal |
| Before launch | Terms with a Data Processing Addendum (processing on instruction, security, breach notice, sub-processors, deletion on exit); Privacy Policy covering both vendor and diner data; Refund/Cancellation; About/Contact; grievance officer | Platform (Cashfree) + legal |
| Before launch | Itemised diner notice linked to the Privacy Policy; retention period; breach runbook (notify the vendor at once; the fiduciary reports to the Board within 72 hours) | DPDP best practice now, law from May 2027 ([Seclore](https://www.seclore.com/fundamentals/dpdp-rules-2025-compliance-guide/)) |
| Before launch | Cashfree KYC, a sandbox payment, a small live payment, and a current fee quote. Confirm whether UPI carries the 2% platform fee, because sources conflict ([Xflowpay](https://www.xflowpay.com/blog/cashfree-payment-gateway-charges)) | Platform |
| Before launch | Legal opinion that the UPI-intent model is not payment-aggregator activity | Best practice |
| Before launch | WhatsApp Business number and phone line in Hindi and English, with a stated response time | Best practice; incumbents set the bar at multilingual 24x7 ([Petpooja support](https://www.petpooja.com/support)) |
| Before Play | D-U-N-S / organisation account or the 12-tester, 14-day closed test; Data safety form; privacy URL; account deletion; API 36 tablet test; Play billing policy check | Platform |
| Before SMS | DLT entity, header and templates; provider at about ₹0.15–0.25 per SMS | TRAI rules |
| Go-to-market | WhatsApp-first demos with a 60-second Hindi video and a demo QR. Indian vendors' YouTube content is almost all vendor tutorials, so a Hindi "set up QR ordering on your phone in five minutes" video fills a visible gap ([Smart QR Order guides](https://smartqrorder.com/video-guides)) | Best practice |
| Go-to-market | Cluster selling in food courts and markets; assisted setup that builds the menu from a photo and prints the QRs | Best practice |
| Go-to-market | Local agents and resellers on recurring commission. Petpooja reportedly pays 10% recurring ([Bitscale](https://bitscale.ai/directory/petpooja)); pay only after the bonus anomaly is fixed. Also partner with menu printers, POS/printer dealers, CAs and UPI soundbox field agents | Best practice |
| Go-to-market | Messaging: "0% commission, money straight to your UPI, no hardware, no auto-renew". Prepare an FAQ on the 15 Oct 2026 UPI MDR change, which exempts small merchants | Best practice |
| After launch | Track trial-to-paid, the ₹20 lakh GST threshold, the UPI MDR Supreme Court challenge, and full DPDP compliance by May 2027 | Ongoing |

## What could not be verified and needs a manual browser check

Direct page fetches were blocked throughout both research passes. The blocked sites included play.google.com, apps.apple.com, AppBrain, facebook.com and the Meta Ad Library, youtube.com, Google Maps, Reddit, Trustpilot, Capterra, Techjockey, SoftwareSuggest, cashfree.com, NPCI, MeitY and most vendor sites. Every external fact in this report comes from search-engine summaries of the cited pages, not from reading them. No archive.org snapshot could be retrieved.

| Area | What to check by hand | Why it matters |
|---|---|---|
| Play Store | Ratings, review counts, installs and last-update dates for Petpooja, Rista, Zobaze, Vyapar/Table, DotPe, Zomato/Swiggy Partner; Swipe's 5.0★ on 15K reviews; whether Zobaze's main app really has 1M+ installs; whether any rival (Scan & Order, MenuScan, Ahaar Scan, QRSathi) has a Play listing at all | All figures are snapshots of uncertain date, and en_IN and en_US pages disagree |
| Facebook / Instagram | Page star ratings, comment themes, and Meta Ad Library ad counts and creatives for Petpooja, DotPe, Zobaze and the QR startups | Completely blocked; no data at all |
| YouTube | View counts, upload dates and top comments for Petpooja tutorials and QR-setup videos; whether independent Indian review videos exist | Blocked; only titles surfaced |
| Google Maps | Ratings and reviews for the Petpooja (Ahmedabad), DotPe (Gurugram), Rista and Zobaze offices | Nothing surfaced; only employee ratings were found |
| Reddit, MouthShut, Justdial | Owner threads on POS and QR tools | Blocked |
| Third-party prices | Petpooja Lite (₹6,000 vs $67) and the Scan & Order add-on price and limits; MenuScan's yearly prices; DineOpen's real price; Menuthere INR; QRSathi and QR FOOD MENU paid tiers; Scan & Order's UPI, KDS and roles; Orderzy's diner fee; DotPe's current fee; Ahaar Scan's official site; Dinehere; Restroworks; GoFrugal QR pricing; whether competitors quote incl. or excl. GST | Many figures come from directories or rival vendors' blogs |
| Closures | GloriaFood's end date from Oracle directly (31 Mar vs 30 Apr 2027); whether anyone took over Thrive Direct; whether about.thrivenow.in still resolves | Second-pass conclusions rest on secondary sources |
| Names not found | "Possier", "Bijli", "MenuDash", "Waiterlez", "Mnu", "Menuonline", "iMenuApp" and "TapTap". None was found as an Indian restaurant product; confirm the intended names | May be misspellings |
| Regulation | The NPCI MDR circular text (the ₹300 cap conflict and the P2PM definition); the DPDP gazette wording (Rule 3 notice list, 90-day grievance window, 48-hour erasure notice); the exact GST SAC (998314 vs 997331); whether Cashfree needs a GSTIN; Cashfree's live UPI fee; Play billing policy for B2B subscriptions bought in-app; the US$25 Play fee and DLT fee from primary pages | Legal and platform pages were blocked |
| Internal | Run the screens live: the wizard 403 on Starter, the kitchen login landing page, the end-to-end Cashfree flow; confirm whether live vendors with old QR codes exist; confirm GST registration; run a load test | Internal findings come from reading code, not running it |

## Conclusion

The meaningful gap is no longer engineering. It is a business that has not yet been allowed to exist: no domain, no contract with customers, no way to take money, and no one answering the phone. That reframes the launch as a two-week sprint of owner decisions (merge, domain, secrets, legal pages, support number, GST label, bonus rule), not a quarter of coding. It also means the cheapest, fastest competitive move is to fix the trust surface the review evidence shows owners care about most. Feature parity can come after.

On competition, the threat is not Petpooja; it is a swarm of thin Indian startups at ₹75–₹400 a month. Many have weak footprints of their own: a lovable.app subdomain, zero reviews, conflicting price pages. They already ship the diner-facing basics we lack: Hindi menus, WhatsApp, one bill per table, a review prompt. Our kitchen-side depth is real but invisible to a stall owner choosing from a pricing page. The winning version of this product is that kitchen depth plus those four diner basics, sold at a fixed bonus-free price with a human on WhatsApp. That combination is something no verified rival currently offers.
