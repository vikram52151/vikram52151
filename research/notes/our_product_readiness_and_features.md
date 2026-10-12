# Tech2Software QR Ordering — production readiness and complete feature/pricing inventory

Scope: local code and docs only, read on 12 Oct 2026. Both repos are on branch `claude/magical-noether-ys2e87`. The branch is in sync with `origin`: `git status -sb` shows `## claude/magical-noether-ys2e87...origin/claude/magical-noether-ys2e87`. Remotes are `github.com/vikram52151/qr-code-ui` and `github.com/vikram52151/qr-code-bkd`. Sources are given as local file paths. Line numbers are approximate where a range is shown.

Abbreviations: UI = `/home/user/qr-code-ui`, BKD = `/home/user/qr-code-bkd`, STATUS = `/home/user/vikram52151/QR_ORDERING_STATUS.md`.

---

## 1. Plans, prices, billing cycles, trial, bonus days, seat limits, and plan features (and how they are enforced)

### Takeaway
There are three plans: QR Starter at ₹199/month, QR Growth at ₹299/month and QR Pro at ₹459/month. Yearly billing is 15% off and two-year billing is 25% off. Every plan has a one-time 14-day trial. Every paid purchase adds a flat 30 bonus days, and this applies to each payment, including monthly renewals. Seat limits are 3, 8 and 25 staff and are enforced on the server. Of the plan-specific feature flags, only PRINTER (the preference setting only), PAYMENT_GATEWAY (credential storage only) and ORDER_TRACKING are enforced. ANALYTICS and PRIORITY_SUPPORT gate nothing because no such feature exists. Prices exclude any GST handling, and the product generates no invoices.

### Cited Findings

**Source of truth for the plan catalogue**
- The plans are defined in the server enum `QrPlan`, whose comment reads "The server-authoritative QR subscription catalogue. UI prices are display only". Prices are stored in paise (₹199 = 19900). — [BKD/src/main/java/com/tech2software/qrorder/subscription/QrPlan.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrPlan.java)
  - `QR_STARTER("QR Starter", 19900, 3, [DIGITAL_MENU, QR_ORDERING, UPI_CASH, ORDER_DASHBOARD])`
  - `QR_GROWTH("QR Growth", 29900, 8, [... + ORDER_TRACKING, PRINTER, PAYMENT_GATEWAY])`
  - `QR_PRO("QR Pro", 45900, 25, [... + ANALYTICS, PRIORITY_SUPPORT])`
  - `TRIAL_DAYS = 14` and `PAID_BONUS_DAYS = 30`.
  - The price formula is `price(cycle) = monthly × months − round(monthly × months × discount)`.
  - The paid entitlement formula is `paidEntitlementDays(cycle) = months × 30 + 30`.
- Billing cycles are `MONTHLY(1, 0.0)`, `YEARLY(12, 0.15)` and `TWO_YEAR(24, 0.25)`. — [BKD/.../subscription/QrBillingCycle.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrBillingCycle.java)
- The UI copy in `qr-plans.ts` uses the same paise prices as a fallback and says "The server's /api/public/plans wins for prices". The UI's discount maths matches the server (0 / 0.15 / 0.25). — [UI/src/app/plan/qr-plans.ts](file:///home/user/qr-code-ui/src/app/plan/qr-plans.ts)
- The public catalogue endpoint `GET /api/public/plans` returns monthly, yearly and two-year prices, trial days, bonus days and the feature list. — [BKD/.../subscription/QrPlanCatalogController.java:11](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrPlanCatalogController.java)

**Computed prices.** These are computed from the server formula and were verified with a script run against the formula above.

| Plan | Monthly | Yearly (12 mo, −15%) | 2-year (24 mo, −25%) | Days granted per payment (M / Y / 2Y) |
|---|---|---|---|---|
| QR Starter | ₹199.00 | ₹2,029.80 (list ₹2,388, saves ₹358.20; ≈₹169.15/mo) | ₹3,582.00 (list ₹4,776, saves ₹1,194; ≈₹149.25/mo) | 60 / 390 / 750 |
| QR Growth | ₹299.00 | ₹3,049.80 (list ₹3,588, saves ₹538.20; ≈₹254.15/mo) | ₹5,382.00 (list ₹7,176, saves ₹1,794; ≈₹224.25/mo) | 60 / 390 / 750 |
| QR Pro | ₹459.00 | ₹4,681.80 (list ₹5,508, saves ₹826.20; ≈₹390.15/mo) | ₹8,262.00 (list ₹11,016, saves ₹2,754; ≈₹344.25/mo) | 60 / 390 / 750 |

— Derived from [QrPlan.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrPlan.java) and [QrBillingCycle.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrBillingCycle.java)

**Trial**
- The trial lasts 14 days and is limited to one per tenant (`trialUsed`). It is refused when a paid plan is still active. The vendor picks a plan and cycle for the trial, and `sub.setPlan(plan)` gives the trial that plan's features and seats. — [BKD/.../subscription/QrSubscriptionService.java:54-65](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrSubscriptionService.java); [BKD/FIXES.md ISSUE-016](file:///home/user/qr-code-bkd/FIXES.md)
- The landing page says "14-day free trial on every plan, no payment details needed. Paying for a plan adds 30 bonus days. Nothing renews automatically." — [UI/src/app/features/landing/landing.html:44](file:///home/user/qr-code-ui/src/app/features/landing/landing.html)

**Bonus days**
- The subscription page describes the bonus as a "Limited launch offer: pay today and get 30 extra days". — [UI/src/app/features/subscription/subscription.html:12-20](file:///home/user/qr-code-ui/src/app/features/subscription/subscription.html)
- The code applies the bonus on every verified webhook payment. The relevant line is `sub.setEntitlementEnd(base.plusDays(plan.paidEntitlementDays(cycle)))`. When the paid plan is still running, `base` is the current end date. This means each monthly renewal adds 60 days. — [QrSubscriptionService.java:157-167](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrSubscriptionService.java)

**Auto-renewal and billing model**
- Nothing renews automatically. There is no mandate or autopay. Each checkout is a one-off Cashfree order, and the copy "Autopay mandate will be shown" was removed. — [UI/FIXES.md phase 1 S3](file:///home/user/qr-code-ui/FIXES.md); [BKD/FIXES.md ISSUE-002, BN1-BN3](file:///home/user/qr-code-bkd/FIXES.md)

**Staff seats**
- The limits are Starter 3, Growth 8 and Pro 25. `StaffService.create()` refuses a new staff account once the limit is reached.
- The seat numbers are not settled pricing. BKD/FIXES.md says: "**The seat numbers are my proposal, not your policy** … change them to whatever you actually sell." — [BKD/FIXES.md ISSUE-020](file:///home/user/qr-code-bkd/FIXES.md)
- An earlier per-seat charge of ₹149 per staff member per month was shown in the UI but never billed, and has been removed. — [UI/FIXES.md ISSUE-020](file:///home/user/qr-code-ui/FIXES.md). The old plan doc still describes it: "Each active additional staff user is ₹149/month". — [UI/plan/production-readiness.md](file:///home/user/qr-code-ui/plan/production-readiness.md)

**Feature enforcement on the server (`requireFeature`)**
- `PRINTER` gates only `PUT /api/vendor/printer`, which saves a printer name and type. — [BKD/.../vendor/VendorService.java:36](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/vendor/VendorService.java)
- `PAYMENT_GATEWAY` gates `PUT /api/vendor/payment-config`. That endpoint stores encrypted PhonePe PG credentials (`TenantPaymentProvider { UPI_INTENT, PHONEPE_PG }`). — [BKD/.../payment/TenantPaymentConfigService.java:20](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/payment/TenantPaymentConfigService.java)
- `ORDER_TRACKING` affects the public status endpoint. Without the feature, the endpoint returns `PLACED` and `trackingEnabled:false`. — [BKD/.../publicapi/PublicService.java:318](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/publicapi/PublicService.java); [BKD/FIXES.md phase 2 B7a](file:///home/user/qr-code-bkd/FIXES.md)
- BKD/FIXES.md states: "`ANALYTICS` and `PRIORITY_SUPPORT` have no feature in the product to gate yet." — [BKD/FIXES.md phase 2 B7a](file:///home/user/qr-code-bkd/FIXES.md)
- Enforcement follows `app.subscription.enforce`. — [BKD/FIXES.md phase 2](file:///home/user/qr-code-bkd/FIXES.md)

**Plan bullets shown to buyers**
- Starter: "Digital menu with a QR for each table, Customer orders with token numbers, UPI and cash payments, Live order screen, Up to 3 staff logins".
- Growth: "Everything in Starter, Customers see live order status, Kitchen slips through your printer, Up to 8 staff logins".
- Pro: "Everything in Growth, Priority support, Up to 25 staff logins".
- "Advanced analytics", "Multi-location readiness" and "Customer payment gateway" were removed from the bullets because they "did not exist".
- — [UI/src/app/plan/qr-plans.ts](file:///home/user/qr-code-ui/src/app/plan/qr-plans.ts)

**Expiry**
- A lapsed subscription reports `EXPIRED`, and the vendor is sent to the renew page. — [BKD/FIXES.md phase 1](file:///home/user/qr-code-bkd/FIXES.md)
- Expired vendors lose menu writes, order list/advance/mark-paid, and the ability to create QR codes, outlets and staff. — [BKD/FIXES.md ISSUE-028, B7b](file:///home/user/qr-code-bkd/FIXES.md)
- The public menu for a lapsed or suspended vendor returns 404 ("Vendor not found"), so the customer QR codes stop working. — [BKD/.../publicapi/PublicService.java:396-406](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/publicapi/PublicService.java)

**GST and invoices**
- `grep -i "gst|gstin|invoice|tax|hsn"` across the UI src and BKD src/main returns no product code. There is no GST, no tax line, no invoice and no receipt for subscription payments. — (grep over [UI/src](file:///home/user/qr-code-ui/src) and [BKD/src/main](file:///home/user/qr-code-bkd/src/main))
- The page-flow audit had already listed "invoice" as absent from the subscription flow. — [UI/plan/page-flow-audit.md](file:///home/user/qr-code-ui/plan/page-flow-audit.md)

### Inferences
- **Pricing anomaly: monthly is the cheapest option per day.** The flat 30-day bonus applies to every payment, so ₹199 monthly buys 60 days, which is about ₹99.50 per 30 days. Starter yearly works out to about ₹156 per 30 days (₹2,029.80 for 390 days), and Starter two-year to about ₹143 per 30 days. The same pattern holds for Growth (₹149.50 vs ₹234.60 vs ₹215.28) and Pro (₹229.50 vs ₹360.14 vs ₹330.48). This undercuts the "Yearly and two-year billing are cheaper per month" claim on the landing page ([landing.html:57](file:///home/user/qr-code-ui/src/app/features/landing/landing.html)) and needs a policy decision. For example, the bonus could apply only to the first payment.
- **Pro's extra value over Growth is thin.** The only real differences are "Priority support" and 25 seats instead of 8. ANALYTICS is not a feature, and no support channel exists (see Q5).
- **Growth's PAYMENT_GATEWAY flag stores PhonePe credentials that nothing uses.** No code outside `payment/TenantPaymentConfig*` references PHONEPE. The UI has no payment-config screen: the only PhonePe mentions are the labels "PhonePe, GPay, Paytm" on the UPI options. Paying customers on Growth or Pro get no gateway function from this flag.
- **Displayed prices make no mention of GST.** Whether they are GST-inclusive is undefined.

### Gaps
- No document says whether the ₹ prices include 18% GST, and no document states Tech2Software's GST registration status.
- The seat limits and the bonus policy are marked as proposals. No final pricing decision is recorded.
- There is no per-outlet price. Extra outlets are free and unlimited. This was noted as "additional outlet price/entitlement is not decided" in [page-flow-audit.md](file:///home/user/qr-code-ui/plan/page-flow-audit.md), and no outlet cap appears in `QrPlan`.

---

## 2. Customer-facing features (what a diner can do today)

### Takeaway
Customers use a browser with no login and no app. The flow covers per-table QR, a category menu with photos, veg/egg/non-veg tags and item hours, portions and add-ons, UPI intent or cash, an optional UTR reference, token numbers, live tracking on Growth and Pro, self-cancel while the order is NEW, a privacy-consent checkbox, and an optional SMS OTP that is off until an SMS provider exists. The page is English-only and needs a connection to order.

### Cited Findings
- **Per-table QR**
  - Each QR encodes `/order?t=<code>`, a 128-bit random code that can be revoked. "New QR" rotates the code and the old printout returns 404 immediately. Each vendor gets a "Counter" table automatically. — [BKD/FIXES.md phase 3 C1/Q3](file:///home/user/qr-code-bkd/FIXES.md)
  - The public endpoints are `GET /api/public/table/{code}`, `/table/{code}/menu` and `/qr/{code}.png`. — [BKD/.../publicapi/PublicController.java:30-77](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/publicapi/PublicController.java)
- **Menu browsing.** Customers browse by category tabs and see each item's photo, a veg or non-veg mark with its name in text, and price. Items outside their daily hours are hidden and refused at order time. — [UI/src/app/features/customer/customer-order.html:20-60](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html); [BKD/FIXES.md phase 5 M2](file:///home/user/qr-code-bkd/FIXES.md)
- **Portions and add-ons.** VARIANT groups require exactly one pick (e.g. Half/Full) and ADDON groups allow any number, each with an extra price. The server validates the picks and prices the line. Each combination becomes its own cart line. — [BKD/FIXES.md phase 5 M1/C5](file:///home/user/qr-code-bkd/FIXES.md); [customer-order.html:75-90](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html)
- **Checkout**
  - Checkout requires the customer's name and a 10-digit mobile number. — [customer-order.html:171-177](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html)
  - Payment options are "UPI payment — PhonePe, GPay, Paytm and more" and "Cash payment — Pay at the counter". — [customer-order.html:208-216](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html)
  - For UPI, the server builds a `upi://` intent to the vendor's own VPA, with the amount converted from paise to rupees. — [BKD/.../publicapi/PublicService.java:359-369](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/publicapi/PublicService.java); [BKD/FIXES.md ISSUE-044](file:///home/user/qr-code-bkd/FIXES.md)
- **UTR reference**
  - The customer can submit the UPI reference via `POST /api/public/orders/{id}/payment-reference`. The vendor sees it. This does not mark the order paid. — [BKD/FIXES.md phase 3 O3](file:///home/user/qr-code-bkd/FIXES.md); [PublicService.java:326-333](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/publicapi/PublicService.java)
  - **UPI payments are never automatically verified.** — [BKD/FIXES.md phase 3 O3 "Still open: automatic verification"](file:///home/user/qr-code-bkd/FIXES.md)
- **Token numbers.** Tokens run in a daily sequence per vendor (001, 002…), with a random fallback. — [BKD/FIXES.md ISSUE-031](file:///home/user/qr-code-bkd/FIXES.md); [BKD/.../order/OrderTokenAllocator.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/order/OrderTokenAllocator.java)
- **Live tracking**
  - Tracking shows New, Preparing, Ready and Completed, and is available on Growth and Pro only. Starter customers are told to "listen for the token". — [UI/FIXES.md phase 3 N6](file:///home/user/qr-code-ui/FIXES.md); [BKD/FIXES.md phase 2 B7a](file:///home/user/qr-code-bkd/FIXES.md)
  - Updates arrive by polling. The original design states "No WebSockets". — [UI/docs/superpowers/specs/2026-06-17-qr-ordering-platform-design.md:23](file:///home/user/qr-code-ui/docs/superpowers/specs/2026-06-17-qr-ordering-platform-design.md)
- **Self-cancel.** The customer can cancel while the order is NEW and unpaid. After that the server answers 409 "already being prepared". — [BKD/FIXES.md phase 5 C5](file:///home/user/qr-code-bkd/FIXES.md)
- **Privacy consent**
  - A checkbox is required on every order (`privacyAccepted`, and `consent_at` is recorded). The notice reads: "Your name and mobile number go to <business> … processed by Tech2Software … not sold or used for marketing." — [customer-order.html:220-230](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html); [BKD/FIXES.md phase 3 C2](file:///home/user/qr-code-bkd/FIXES.md)
- **Customer OTP**
  - The flow is built. Codes are hashed, expire in 5 minutes, allow 5 attempts, and are limited to 5 per hour per number.
  - It is **off by default (`CUSTOMER_OTP_ENABLED=false`)**. The only `SmsSender` logs the code: "No SMS provider configured: OTP for ******{} is {}". — [BKD/FIXES.md phase 3 C2](file:///home/user/qr-code-bkd/FIXES.md); [BKD/.../otp/SmsConfig.java:19](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/otp/SmsConfig.java); [BKD/.env.example](file:///home/user/qr-code-bkd/.env.example)
- **Duplicate-order protection.** An `Idempotency-Key` is required. A reused key with a different basket gets 409. The cart, key and token survive a page reload (stored in sessionStorage per table). — [BKD/FIXES.md phase 3 C4](file:///home/user/qr-code-bkd/FIXES.md); [UI/FIXES.md phase 3 C3/C4](file:///home/user/qr-code-ui/FIXES.md)
- **Accessibility.** An axe scan (WCAG 2 A/AA) found no serious or critical issues on the menu and checkout. The brand green was darkened to `#147A3A`. — [UI/FIXES.md phase 6 T1/N6](file:///home/user/qr-code-ui/FIXES.md)
- **Language.** The page is English only. `index.html` declares `lang="en"`, and no i18n or translation library is used. — [UI/src/index.html:2](file:///home/user/qr-code-ui/src/index.html); grep for `i18n|$localize|translate|hindi` returned no app usage

### Inferences
- Because UPI goes straight to the vendor's own VPA with only a manual UTR check, a customer can claim to have paid without paying. The cashier must check their bank or UPI app.
- The customer flow is not offline-capable. The service-worker config has only `assetGroups`, with no `dataGroups` for API caching ([UI/ngsw-config.json](file:///home/user/qr-code-ui/ngsw-config.json)), so placing an order needs network access.

### Gaps
- There is no table session or combined bill per party: "Orders are per table, not per sitting." — [BKD/FIXES.md phase 3 Q2](file:///home/user/qr-code-bkd/FIXES.md)
- The code has no customer-facing bill or receipt, and no feedback, rating, tipping, coupon or loyalty feature.

---

## 3. Vendor, staff and admin features; Android APK; languages; offline; integrations

### Takeaway
The vendor side covers the following: an order screen with date ranges; a kitchen display with late flags; KOT and slip printing through the device print dialog; a new-order beep, vibration and notification; a menu editor with options, photos, diet tags, item hours, per-outlet availability and CSV import; table QR management; outlets; and five staff roles. There is a basic today-only dashboard and no vendor reports. The admin portal handles vendor management, manual plan grants, password resets, an audit log and platform revenue and growth charts. A vendor/staff Android APK exists, built with Capacitor, but the release build has no production API host and is not on the Play Store. There are no third-party integrations except Cashfree for Tech2Software's own subscription billing, and that integration is untested against Cashfree's API.

### Cited Findings

**Vendor app routes**
- The vendor app has `/vendor/dashboard`, `/orders`, `/kitchen`, `/inventory` (the menu editor), `/operations` (outlets and staff) and `/settings`.
- It also has `/login`, `/signup`, `/forgot-password`, `/account/password`, `/subscription` and `/setup` (the wizard).
- — [UI/src/app/app.routes.vendor.ts](file:///home/user/qr-code-ui/src/app/app.routes.vendor.ts)

**Dashboard**
- The dashboard shows today's order count, today's revenue (null for KITCHEN and WAITER), the active menu item count, subscription days left, counts by status and recent orders. — [BKD/.../order/dto/DashboardResponse.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/order/dto/DashboardResponse.java)

**Orders**
- Orders can be filtered by Today, Yesterday, This Week (7 days), This Month (30 days) or All, and by status. — [BKD/.../order/OrderService.java:216-226](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/order/OrderService.java); [UI/.../vendor/orders/orders.ts:49-53](file:///home/user/qr-code-ui/src/app/features/vendor/orders/orders.ts)
- Staff can advance an order's status, cancel it, Mark Paid with an optional reference, and Undo payment. Mark Paid is audited with `paid_at` and `paid_by_user_id`. — [BKD/.../order/OrderController.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/order/OrderController.java); [BKD/FIXES.md ISSUE-032, phase 3 O3](file:///home/user/qr-code-bkd/FIXES.md)
- The screen polls every 8 seconds, skips polls while the tab is hidden, and shows a "Not updating — check the connection" banner after 30 seconds without a successful refresh. — [UI/FIXES.md ISSUE-005/049, phase 5 O5](file:///home/user/qr-code-ui/FIXES.md)
- There is no export (CSV, Excel or PDF) on the Orders page. A grep of orders.html and orders.ts for `export|csv|download` found only the print slip.

**Kitchen display**
- The kitchen display shows New, Preparing and Ready columns, oldest first. Orders older than 15 minutes are flagged late. — [UI/FIXES.md phase 5 O1](file:///home/user/qr-code-ui/FIXES.md)
- **Print KOT** uses `window.print()`, the device print dialog, and there is no printer queue. — [UI/.../vendor/kitchen/kitchen.ts:90-93](file:///home/user/qr-code-ui/src/app/features/vendor/kitchen/kitchen.ts)
- Not done: assigning orders to a cook, and direct printing. — [UI/FIXES.md phase 5 O1](file:///home/user/qr-code-ui/FIXES.md)

**New-order alerts**
- New orders trigger a Web Audio double beep, a vibration, and a system notification when the tab is in the background. Alerts must be enabled by a tap. — [UI/FIXES.md phase 5 O2](file:///home/user/qr-code-ui/FIXES.md)

**Menu editor (`/api/menu`)**
- Menu items support create, update, delete with confirmation, duplicate, an availability toggle and bulk import of up to 500 items from CSV (name, category, price, description, diet). — [BKD/.../menu/MenuController.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/menu/MenuController.java); [UI/FIXES.md phase 5 M2](file:///home/user/qr-code-ui/FIXES.md)
- Photos can be JPEG, PNG or WebP up to 1 MB. Items support veg/egg/non-veg tags, daily hours, VARIANT and ADDON option groups, and "Sold at: every outlet / one outlet". — [BKD/FIXES.md phase 5](file:///home/user/qr-code-bkd/FIXES.md); [UI/FIXES.md phase 5](file:///home/user/qr-code-ui/FIXES.md)
- The "inventory" here is the menu only. The design spec lists "Raw-material inventory (this is menu inventory only)" as out of scope. — [UI/docs/superpowers/specs/2026-06-17-qr-ordering-platform-design.md:104](file:///home/user/qr-code-ui/docs/superpowers/specs/2026-06-17-qr-ordering-platform-design.md)

**Outlets**
- The owner manages outlets (`/api/vendor/outlets`): list, create, update and deactivate. Each table belongs to an outlet. Menus are filtered per outlet. Non-owner staff see only their own outlet's orders. — [BKD/.../outlet/OutletController.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/outlet/OutletController.java); [BKD/FIXES.md phase 5 B2](file:///home/user/qr-code-bkd/FIXES.md)
- Not done: per-outlet token sequences and per-outlet reports. — [BKD/FIXES.md phase 5 B2](file:///home/user/qr-code-bkd/FIXES.md)

**Staff roles**
- The roles are VENDOR (owner), MANAGER, CASHIER, KITCHEN and WAITER. — [UI/src/app/core/permissions.ts](file:///home/user/qr-code-ui/src/app/core/permissions.ts)

| Action | Allowed roles |
|---|---|
| Advance an order | VENDOR, MANAGER, KITCHEN |
| Mark Paid | VENDOR, MANAGER, CASHIER |
| Cancel an order or reverse a payment | VENDOR, MANAGER |
| Edit the menu | VENDOR, MANAGER |
| See revenue | VENDOR, MANAGER, CASHIER |
| Manage the business | VENDOR only |
| Kitchen display | VENDOR, MANAGER, KITCHEN |

- The owner creates staff, deactivates them, and resets their password with a one-time password. New staff must change their password at first login. — [BKD/.../staff/StaffController.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/staff/StaffController.java); [BKD/FIXES.md phase 4 B12b](file:///home/user/qr-code-bkd/FIXES.md)
- The role matrix is tested in `RoleAccessMatrixTest`. — [BKD/FIXES.md phase 2 T1](file:///home/user/qr-code-bkd/FIXES.md)

**Settings**
- The owner's settings tabs cover profile, UPI ID, printer preference (Growth and Pro), QR tables, and account. QR tables can be listed, downloaded, rotated with New QR, switched on or off, added, and assigned to an outlet. Staff see only the Account tab. — [UI/FIXES.md phase 2 N8, phase 3](file:///home/user/qr-code-ui/FIXES.md); [UI/.../vendor/settings/settings.html](file:///home/user/qr-code-ui/src/app/features/vendor/settings/settings.html)
- The printer copy reads: "Slips print through your device's normal print dialog". — [settings.html:42](file:///home/user/qr-code-ui/src/app/features/vendor/settings/settings.html)

**Accounts**
- Sign-up captures business name, owner, mobile, email and password (6–72 characters).
- SMS OTP sign-up verification and SMS forgot-password work only with `SMS_ENABLED`, which is off by default. Without SMS, the admin resets the owner's password and the owner resets staff passwords.
- There is no email verification and nothing sends email. The fake Google/Facebook sign-in buttons were removed.
- — [BKD/FIXES.md phase 4 A1/A4/B12](file:///home/user/qr-code-bkd/FIXES.md); [UI/FIXES.md phase 4](file:///home/user/qr-code-ui/FIXES.md)

**Admin portal (`/admin`, web only)**
- Vendors can be listed, viewed, suspended, activated and extended. The admin can grant a plan (record a payment collected outside the system), reset an owner's password, and view the audit log (`/api/admin/audit`).
- Reports cover monthly revenue, vendor growth and a "QR Code Registry".
- — [BKD/.../admin/AdminController.java:49-119](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/admin/AdminController.java); [UI/.../admin/admin-portal.html:114-176](file:///home/user/qr-code-ui/src/app/features/admin/admin-portal.html)
- MRR is computed from ACTIVE subscriptions. — [BKD/FIXES.md ISSUE-017](file:///home/user/qr-code-bkd/FIXES.md)

**Android APK**
- The APK is built with Capacitor and contains vendor and staff routes only. Customer and admin routes are not bundled. Flavors are `dev` (`in.tech2software.qrorder.dev`, cleartext allowed) and `prod` (`in.tech2software.qrorder`, HTTPS only). — [UI/ANDROID.md](file:///home/user/qr-code-ui/ANDROID.md)
- The release build reads `environment.apk-prod.ts`, whose `apiBase` is still `'https://REPLACE-WITH-YOUR-API-HOST/api'`. The release build refuses to run while the placeholder is present. — [UI/src/environments/environment.apk-prod.ts](file:///home/user/qr-code-ui/src/environments/environment.apk-prod.ts)
- Release signing needs `android/keystore.properties`. Without it, the APK is unsigned. — [UI/ANDROID.md](file:///home/user/qr-code-ui/ANDROID.md)
- `versionCode 1`, `versionName "1.0"`, targetSdk 36. — [UI/android/app/build.gradle:9-11](file:///home/user/qr-code-ui/android/app/build.gradle); [UI/android/variables.gradle:4](file:///home/user/qr-code-ui/android/variables.gradle)
- Minify (R8) is off. `allowBackup` is false. — [UI/FIXES.md phase 1 N3b](file:///home/user/qr-code-ui/FIXES.md)
- The APK has no service worker. — [UI/ANDROID.md](file:///home/user/qr-code-ui/ANDROID.md)
- On Android, Cashfree returns to the web origin, not back into the app. — [UI/FIXES.md phase 1 S1](file:///home/user/qr-code-ui/FIXES.md)

**Web PWA**
- The web build has a manifest named "Tech2Software QR Ordering" and a service worker that caches the app shell and assets only. — [UI/public/manifest.webmanifest](file:///home/user/qr-code-ui/public/manifest.webmanifest); [UI/ngsw-config.json](file:///home/user/qr-code-ui/ngsw-config.json); [UI/src/app/app.config.ts:9-20](file:///home/user/qr-code-ui/src/app/app.config.ts)

**Languages.** The product is English only. No i18n framework or locale files exist. — [UI/src/index.html](file:///home/user/qr-code-ui/src/index.html); grep result

**Integrations**
- The only payment integration is Cashfree PG for Tech2Software's own subscription checkout (hosted checkout v3 SDK). Its signature-verified webhook is tested. **Order creation has never been run against Cashfree's live or sandbox API.** — [BKD/FIXES.md ISSUE-002, phase 1, phase 6 T1](file:///home/user/qr-code-bkd/FIXES.md); [UI/FIXES.md phase 1 S1](file:///home/user/qr-code-ui/FIXES.md)
- The CSP allows only `sdk.cashfree.com` and `*.cashfree.com` as third-party origins. — [UI/nginx.conf:19](file:///home/user/qr-code-ui/nginx.conf)
- A grep for `zomato|swiggy|whatsapp|tally|loyalty|reservation|websocket|escpos|petpooja` matched nothing except Bluetooth/LAN printer labels in the setup wizard and settings, which are preference strings only.

**Printing**
- Printing goes only through the browser print dialog. "Wiring a real thermal printer is still open product work." — [UI/FIXES.md ISSUE-019](file:///home/user/qr-code-ui/FIXES.md)
- Direct printing needs the printer model and "likely needs a native Android plugin". — [STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md)

### Inferences
- **"Reports/analytics" is limited to the today-only dashboard plus an order list with date filters.** There are no sales reports, item-wise sales, GST reports or exports. The Pro "ANALYTICS" flag has nothing behind it.

### Gaps
- It is unclear whether the kitchen login still lands on `/vendor/dashboard`. This was noted as still open in Sept ([UI/FIXES.md ISSUE-003 "Still open"](file:///home/user/qr-code-ui/FIXES.md)), no later phase says it was fixed, and it was not verified in code.

---

## 4. What is ABSENT compared with typical Indian restaurant POS / QR products

### Takeaway
Measured against typical restaurant POS feature sets, the product has no GST billing or invoicing, no raw-material inventory or recipes, no Zomato/Swiggy integration, no loyalty/CRM, no WhatsApp, no multi-language support, no direct thermal printing, no offline mode, no real reports or analytics, no reservations, no waiter ordering app, no table sessions or split bills, no discounts or coupons, no tips, no automatic UPI verification and no email. Most of these are confirmed absent by grep and by the docs' own "not done" lists.

### Cited Findings
| Capability | Status | Evidence |
|---|---|---|
| GST billing / tax invoice / bill print for customers | Absent (no gst, tax, invoice or hsn in code) | grep over [UI/src](file:///home/user/qr-code-ui/src), [BKD/src/main](file:///home/user/qr-code-bkd/src/main) |
| GST invoice for the vendor's own subscription | Absent | same grep; [page-flow-audit.md "invoice … absent"](file:///home/user/qr-code-ui/plan/page-flow-audit.md) |
| Raw-material inventory / recipes / stock | Absent by design | [spec §7 "Raw-material inventory"](file:///home/user/qr-code-ui/docs/superpowers/specs/2026-06-17-qr-ordering-platform-design.md) |
| Zomato / Swiggy aggregator integration | Absent | grep (no matches) |
| Loyalty / CRM / customer database / marketing | Absent. The privacy notice also promises data is "not used for marketing" | [customer-order.html:221-225](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html) |
| WhatsApp ordering or notifications | Absent | grep (no matches) |
| SMS | Built but disabled: only a logging sender | [SmsConfig.java:19](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/otp/SmsConfig.java) |
| Email (verification, receipts, renewal reminders) | Absent: "nothing sends email yet" | [BKD/FIXES.md phase 4 A1](file:///home/user/qr-code-bkd/FIXES.md) |
| Multi-language (Hindi or regional) | Absent | [index.html `lang="en"`](file:///home/user/qr-code-ui/src/index.html) |
| Direct thermal / Bluetooth / LAN printing (ESC/POS) | Absent: print dialog only | [UI/FIXES.md ISSUE-019, phase 5 O1](file:///home/user/qr-code-ui/FIXES.md); [spec §7](file:///home/user/qr-code-ui/docs/superpowers/specs/2026-06-17-qr-ordering-platform-design.md) |
| Offline mode (ordering or billing without internet) | Absent: service worker caches shell/assets only and the APK has no service worker | [ngsw-config.json](file:///home/user/qr-code-ui/ngsw-config.json); [ANDROID.md](file:///home/user/qr-code-ui/ANDROID.md) |
| Reports/analytics (item-wise, daily sales, export) | Absent beyond the today dashboard and a filtered order list. Per-outlet reports not done. Metrics not done | [DashboardResponse.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/order/dto/DashboardResponse.java); [BKD/FIXES.md phase 5 B2, phase 2 B7a](file:///home/user/qr-code-bkd/FIXES.md) |
| Table reservations | Absent | grep (no matches) |
| Waiter / captain order-taking app (staff entering orders) | Absent. WAITER can only view the dashboard and orders. Orders come only from the customer QR flow (`POST /api/public/orders`) | [permissions.ts](file:///home/user/qr-code-ui/src/app/core/permissions.ts); [PublicController.java:37](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/publicapi/PublicController.java) |
| Table sessions / running tab / split bill / merge tables | Absent: "Not done: a table session" | [BKD/FIXES.md phase 3 Q2](file:///home/user/qr-code-bkd/FIXES.md) |
| Discounts / coupons / service charge / tips | Not found in code | grep over DTOs/endpoints (no such fields in the endpoint list) |
| Automatic payment verification / customer payment gateway | Absent. The PAYMENT_GATEWAY flag stores PhonePe credentials that are never used | [BKD/FIXES.md phase 3 O3](file:///home/user/qr-code-bkd/FIXES.md); [TenantPaymentConfigService.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/payment/TenantPaymentConfigService.java) |
| Auto-renew / UPI Autopay mandate | Absent: "Nothing renews automatically" | [landing.html:44](file:///home/user/qr-code-ui/src/app/features/landing/landing.html) |
| Payroll / attendance / shift management | Absent | no such module in [BKD controllers](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder) |
| Tally / accounting export | Absent | grep (no matches) |
| Real-time push (WebSocket/SSE) | Absent: polling only | [spec line 23](file:///home/user/qr-code-ui/docs/superpowers/specs/2026-06-17-qr-ordering-platform-design.md) |
| Assign order to a cook | Absent | [STATUS "Remaining work"](file:///home/user/vikram52151/QR_ORDERING_STATUS.md) |
| iOS app | Absent: Android only | [ANDROID.md](file:///home/user/qr-code-ui/ANDROID.md) |

### Inferences
- The product is a QR menu and ordering plus kitchen-display tool. It is not a billing POS. In a competitor comparison, the honest positioning is low price and no customer app install, while conceding GST billing, aggregators, inventory and printers.

### Gaps
- Coupon, discount and tip absence is inferred from the endpoint list and DTO names. No full field-by-field read of `PlaceOrderRequest` was done for every possible field.

---

## 5. Production readiness — every remaining item, classified (Blocker / Should-fix-before-launch / Post-launch) with the unblocker

### Takeaway
The code is feature-complete for the six walkthrough phases. Tests and CI are green: 107 backend tests, 68 frontend unit tests and 3 E2E tests. However, **nothing is merged to `master`, nothing is deployed, no production domain exists, Cashfree has never processed a sandbox payment, SMS and email providers are absent, and the product has no Terms, Privacy Policy, refund policy or support contact.** Launch-blocking work is now mostly owner decisions and credentials rather than code.

### Cited Findings (status baseline)
- Phases 1–6 are done on `claude/magical-noether-ys2e87`. "No pull requests are open yet. `master` in both repositories is still the pre-walkthrough code (ui `33ef21a`, bkd `4b5e429`)." — [STATUS "Where the code is"](file:///home/user/vikram52151/QR_ORDERING_STATUS.md)
- Test and scan results:
  - Backend: 107 tests pass, including migrations applied to a real MySQL 8.4.
  - Frontend: 68 unit tests and 3 E2E tests pass.
  - `npm audit` of production dependencies: 0 vulnerabilities.
  - gitleaks: clean.
  - GitHub Actions: passing.
  - — [STATUS "Test and CI results"](file:///home/user/vikram52151/QR_ORDERING_STATUS.md)
- The deployment target is single-host docker-compose: MySQL 8.4, the Spring Boot backend, and the UI served by nginx on port 8080 over plain HTTP. "TLS should terminate at a load balancer or ingress in front of the UI container." — [BKD/docker-compose.yml](file:///home/user/qr-code-bkd/docker-compose.yml); [BKD/README.md](file:///home/user/qr-code-bkd/README.md); [UI/nginx.conf:2 `listen 8080`](file:///home/user/qr-code-ui/nginx.conf)
- `APP_UI_ORIGIN` defaults to `http://localhost:8080`. — [BKD/.env.example](file:///home/user/qr-code-bkd/.env.example)
- `ProductionSafetyCheck` refuses to start outside local/test with the sample JWT secret, an all-zero key or `admin123`. — [BKD/FIXES.md phase 6 BN5](file:///home/user/qr-code-bkd/FIXES.md)

### BLOCKERS (must be done before real vendors and customers)
| # | Item | Why | Unblocked by | Source |
|---|---|---|---|---|
| B1 | Merge `claude/magical-noether-ys2e87` to `master` in both repos (open PRs, review, merge) | `master` is pre-walkthrough code with all the P0s: guessable QR, no outlet scoping, broken payments, Flyway never ran | **Owner go-ahead** ("Your go-ahead to open pull requests") | [STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md) |
| B2 | Provision production: server/host, public domain, DNS, TLS terminator in front of nginx:8080, set `APP_UI_ORIGIN` to the HTTPS origin | Nothing is deployed. No domain is known anywhere in the repos. HSTS is only honoured behind TLS | **Owner** (domain and hosting choice), then ops | [BKD/README.md](file:///home/user/qr-code-bkd/README.md); [UI/FIXES.md phase 6 N9](file:///home/user/qr-code-ui/FIXES.md); [.env.example](file:///home/user/qr-code-bkd/.env.example) |
| B3 | Generate production secrets in `.env`: MySQL passwords, `JWT_SECRET`, `ADMIN_USERNAME`/`ADMIN_PASSWORD`, `TENANT_CREDENTIAL_ENCRYPTION_KEY` (base64 32-byte), stored in a secret manager | Compose and `ProductionSafetyCheck` refuse to start without them or with sample values | **Owner/ops** | [.env.example](file:///home/user/qr-code-bkd/.env.example); [docker-compose.yml](file:///home/user/qr-code-bkd/docker-compose.yml) |
| B4 | A way for vendors to pay after the 14-day trial: either (a) Cashfree sandbox keys plus one end-to-end sandbox payment, then production keys and `CASHFREE_ENV=production`, or (b) launch deliberately on manual admin activation (payment collected out of band, then "grant plan") | "none of this has been run against Cashfree's live API … Run a sandbox payment before enabling it for real vendors". Without (a) or (b), vendors lose access and their customer QR codes 404 on day 15 | **Owner**: Cashfree merchant account and sandbox keys. Alternatively, the owner decides on the manual process | [BKD/FIXES.md ISSUE-002, phase 1, phase 6 T1](file:///home/user/qr-code-bkd/FIXES.md); [STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md); [PublicService.java:396-406](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/publicapi/PublicService.java) |
| B5 | Publish Terms of Service, Privacy Policy and Refund/Cancellation policy pages, and link them from the landing page, sign-up and checkout | The web routes are only `''`, `order`, `admin/login`, `admin` and the vendor routes. There are no `/terms` or `/privacy` routes. The footer has only "© Tech2Software. All rights reserved." A grep for terms, privacy policy or refund finds nothing. The only privacy text is the short checkout notice | **Owner/legal** (content). Code work is trivial | [UI/src/app/app.routes.ts](file:///home/user/qr-code-ui/src/app/app.routes.ts); [landing.html:62-63](file:///home/user/qr-code-ui/src/app/features/landing/landing.html); [customer-order.html:221](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html) |
| B6 | A support channel: phone, email or WhatsApp, published in the app | With SMS off, an owner who forgets their password can only "contact Tech2Software support". No contact detail appears anywhere in the UI. The subscription failure message also says "contact support". Pro sells "Priority support" | **Owner** (choose a channel). Code: add contact details | [forgot-password.ts:25](file:///home/user/qr-code-ui/src/app/features/forgot-password/forgot-password.ts); [subscription.html:7](file:///home/user/qr-code-ui/src/app/features/subscription/subscription.html); [qr-plans.ts](file:///home/user/qr-code-ui/src/app/plan/qr-plans.ts) |
| B7 | Backups: install the daily `scripts/backup.sh` cron, set up off-host copies, and run a restore drill **before launch** | The runbook says "Do this before launch". The scripts were "not run against a full compose stack" | **Ops** (no input needed except the backup destination) | [BKD/docs/RUNBOOK.md](file:///home/user/qr-code-bkd/docs/RUNBOOK.md); [BKD/FIXES.md phase 6 B14c](file:///home/user/qr-code-bkd/FIXES.md); [STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md) |
| B8 | Old printed QR codes (`/order?v=<id>`): if any vendors already use them, set `PUBLIC_VENDOR_ID_LINKS=true` only while reprinting, then turn it off | "Old printed QR codes stop working on deploy" | **Owner/ops**. Only applies if there are existing live vendors | [STATUS "Before you deploy"](file:///home/user/vikram52151/QR_ORDERING_STATUS.md); [BKD/FIXES.md phase 3 C1](file:///home/user/qr-code-bkd/FIXES.md) |
| B9 | Tax treatment of subscription revenue: decide GST registration and whether prices include GST, and issue invoices or receipts for subscription payments | There is no invoice or GST code at all (grep). The prices on the landing page carry no tax wording | **Owner + accountant/CA**. Then code (invoice generation) | grep; [landing.html:44-57](file:///home/user/qr-code-ui/src/app/features/landing/landing.html) |

### SHOULD-FIX BEFORE LAUNCH
| # | Item | Unblocked by | Source |
|---|---|---|---|
| S1 | **Setup wizard printer step still makes the old false claims.** It says "Connect a thermal printer", "Bluetooth Printer — Connect via Bluetooth", "LAN / Network Printer — Connect via WiFi or LAN" and shows "✓ Connected". The ISSUE-019 copy fix was applied to Settings only. The wizard's save also calls the PRINTER-gated endpoint, which will probably return 403 for Starter or for trials on Starter (not verified by running) | Code (no input) | [UI/src/app/features/setup/setup-wizard.html:140-175](file:///home/user/qr-code-ui/src/app/features/setup/setup-wizard.html); [VendorService.java:36](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/vendor/VendorService.java) |
| S2 | **Plan copy does not match enforcement for printing.** The landing and Growth plan say kitchen slips are a Growth/Pro feature ("Print a slip … (Growth and Pro)"). However, "Print Slip" (Orders) and "Print KOT" (Kitchen) call `window.print()` with no plan check. Only saving a printer preference is gated. Either gate printing or change the copy | **Owner** (policy), then code | [landing.ts features](file:///home/user/qr-code-ui/src/app/features/landing/landing.ts); [orders.ts:174-177](file:///home/user/qr-code-ui/src/app/features/vendor/orders/orders.ts); [kitchen.ts:90-93](file:///home/user/qr-code-ui/src/app/features/vendor/kitchen/kitchen.ts) |
| S3 | **Pricing policy decisions are open.** The 30-day bonus on every payment makes monthly the cheapest option per day (see Q1). The seat limits are an unconfirmed "proposal". Outlets are unpriced and unlimited | **Owner** | [QrSubscriptionService.java:167](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrSubscriptionService.java); [BKD/FIXES.md ISSUE-020](file:///home/user/qr-code-bkd/FIXES.md) |
| S4 | **Admin "grant plan" resets the entitlement to start today.** `activatePaidPlan` sets `entitlementEnd = today + days`, so a vendor renewed through the manual admin path loses their remaining days. The webhook path, by contrast, extends from the current end. This matters because manual activation is the fallback path until Cashfree is tested | Code | [QrSubscriptionService.java:75-80](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrSubscriptionService.java) vs [:157-167](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrSubscriptionService.java) |
| S5 | **Paid flags with no product behind them.** PAYMENT_GATEWAY (Growth/Pro) only stores unused PhonePe credentials and has no UI. ANALYTICS (Pro) gates nothing. PRIORITY_SUPPORT (Pro) has no support channel. Either remove these from what is sold or build them. They are already removed from the UI bullets, except "Priority support" | **Owner** | [BKD/FIXES.md phase 2 B7a](file:///home/user/qr-code-bkd/FIXES.md); [TenantPaymentConfigService.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/payment/TenantPaymentConfigService.java) |
| S6 | SMS provider (MSG91, Gupshup or Twilio) with a DLT-registered template, to enable `SMS_ENABLED` (sign-up verification and self-serve password reset) and optionally `CUSTOMER_OTP_ENABLED` | **Owner**: provider account plus DLT registration. Then code: add a real `SmsSender` bean | [STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md); [.env.example](file:///home/user/qr-code-bkd/.env.example); [SmsConfig.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/otp/SmsConfig.java) |
| S7 | External uptime monitor on `https://<domain>/api/health`. "Nothing inside the stack pages anyone" | **Ops** (UptimeRobot, Better Stack or Healthchecks.io account) | [RUNBOOK.md](file:///home/user/qr-code-bkd/docs/RUNBOOK.md) |
| S8 | Full-stack backup/restore test. Only the database steps were tested | Ops/code (no input) | [STATUS "Can be built now"](file:///home/user/vikram52151/QR_ORDERING_STATUS.md) |
| S9 | Super-admin is not forced to change the `.env` password on first login | Code, or an ops procedure | [BKD/FIXES.md ISSUE-001, phase 4 B12b](file:///home/user/qr-code-bkd/FIXES.md) |
| S10 | DPDP Act 2023 basics beyond the checkout notice. The code has no data-retention or deletion job (grep for `retention|purge|erase|@Scheduled` returns nothing), no customer data-erasure route and no grievance contact. Customer name and mobile are stored per order indefinitely | **Owner/legal** (policy). Then code | grep over [BKD/src/main/java](file:///home/user/qr-code-bkd/src/main/java); [customer-order.html:221-229](file:///home/user/qr-code-ui/src/app/features/customer/customer-order.html) |
| S11 | No renewal reminders. With no email or SMS, nothing warns a vendor before the trial or plan lapses and their customer QR codes 404. Only the in-app days-left badge and banner exist | Email/SMS provider (S6, P-email). Then code | [BKD/FIXES.md phase 4 A1](file:///home/user/qr-code-bkd/FIXES.md); [PublicService.java:396-406](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/publicapi/PublicService.java) |
| S12 | Stale operator docs. README still describes Redis ("runs the UI, API, MySQL, and Redis", `redis-data` volume) although Redis was removed in ISSUE-033 and compose has no Redis | Code/docs | [BKD/README.md](file:///home/user/qr-code-bkd/README.md) vs [docker-compose.yml](file:///home/user/qr-code-bkd/docker-compose.yml); [BKD/FIXES.md ISSUE-033](file:///home/user/qr-code-bkd/FIXES.md) |

### ANDROID-SPECIFIC (blocker only if the APK ships at launch; vendors can use the web app)
| # | Item | Unblocked by | Source |
|---|---|---|---|
| A1 | Set the production API domain in `environment.apk-prod.ts` (currently the `REPLACE-WITH-YOUR-API-HOST` placeholder) | **Owner** (domain, from B2) | [environment.apk-prod.ts](file:///home/user/qr-code-ui/src/environments/environment.apk-prod.ts); [STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md) |
| A2 | Create the release keystore and `android/keystore.properties`. Without them the build is unsigned | **Owner** (keystore custody) | [ANDROID.md](file:///home/user/qr-code-ui/ANDROID.md) |
| A3 | Play Store listing, Data safety form, privacy policy URL, and device testing. Nothing in the repos covers a Play listing | **Owner** (Play Console account) plus B5 | absence in [ANDROID.md](file:///home/user/qr-code-ui/ANDROID.md) |
| A4 | Cashfree returns to the web origin after payment on Android, not into the app | Code (deep link), post-launch acceptable | [UI/FIXES.md phase 1 S1](file:///home/user/qr-code-ui/FIXES.md) |
| A5 | R8 minify is off, pending keep-rules and a device test | Code | [UI/FIXES.md phase 1 N3b](file:///home/user/qr-code-ui/FIXES.md) |

### POST-LAUNCH (documented as remaining, can be built later)
- **Product depth, from STATUS "Can be built now":**
  - Table sessions (one bill per party).
  - Per-outlet token numbers.
  - Assigning orders to a cook.
  - — [STATUS](file:///home/user/vikram52151/QR_ORDERING_STATUS.md)
- **Per-outlet reports** are not done. — [BKD/FIXES.md phase 5 B2](file:///home/user/qr-code-bkd/FIXES.md)
- **Rate limits** are held in memory per instance and reset on restart. This is acceptable for a single instance. Move them to the database or Redis before scaling out. — [BKD/FIXES.md ISSUE-014, phase 6 B13a](file:///home/user/qr-code-bkd/FIXES.md); [RUNBOOK "Known limits"](file:///home/user/qr-code-bkd/docs/RUNBOOK.md)
- **Metrics, tracing and in-stack alerting** are not done. — [BKD/FIXES.md phase 6 B14c](file:///home/user/qr-code-bkd/FIXES.md)
- **Staging build configuration** is not done. — [UI/FIXES.md phase 6 N9](file:///home/user/qr-code-ui/FIXES.md)
- **Needs a provider or account first:**
  - Email verification needs SES, SendGrid or similar.
  - Automatic UPI verification needs a gateway that collects money for vendors (Cashfree, Razorpay or PhonePe).
  - Direct printing without the print dialog needs the printer model and a native plugin.
  - — [STATUS "Needs something from you first"](file:///home/user/vikram52151/QR_ORDERING_STATUS.md)
- **Single platform time zone.** The whole platform uses one zone (`app.timezone`, Asia/Kolkata). — [BKD/FIXES.md ISSUE-007](file:///home/user/qr-code-bkd/FIXES.md)
- **UX follow-ups.**
  - Delete confirmation is a native `confirm()`. — [UI/FIXES.md ISSUE-026](file:///home/user/qr-code-ui/FIXES.md)
  - Kitchen staff may still land on the dashboard instead of the kitchen view. — [UI/FIXES.md ISSUE-003](file:///home/user/qr-code-ui/FIXES.md)
- **Competitive gaps from Q4:** GST billing, aggregators, inventory, multi-language, offline mode, WhatsApp and reports.

### Inferences
- Indian payment gateways, including Cashfree, typically require a live website with Terms, Privacy and Refund policy pages and a contact page before activating a production merchant account. This is general industry knowledge, not verified in this research. Google Play requires a privacy policy URL and a completed Data safety form for any app that handles personal data, and this app handles mobile numbers and logins. B5 and B6 therefore probably block B4(a) and A3 as well as being legal hygiene.
- Launch on the web app plus manual admin activation (B4b) is feasible with only B1, B2, B3, B5, B6 and B7 done.

### Gaps
- There is no evidence of any existing live vendors, so whether B8 matters is unknown.
- It is not documented whether Tech2Software is GST-registered, so the urgency of B9 cannot be fixed.
- No load or performance testing is recorded. The page-flow audit listed "load tests" as a gap ([page-flow-audit.md](file:///home/user/qr-code-ui/plan/page-flow-audit.md)), and no later doc says they were done.

---

## 6. Discrepancies — docs claim vs code (and stale docs)

### Takeaway
The current FIXES and STATUS docs are largely accurate against the code. The remaining mismatches are: the setup-wizard printer copy, printing that is ungated despite the "Growth and Pro" claim, paid feature flags with nothing behind them, a stale README (Redis), and stale planning docs (₹100 Starter, ₹149 per seat, a page-flow audit that predates the fixes).

### Cited Findings
- **Printer copy.** The landing page and plan bullets say slips are Growth/Pro, but the print buttons are not gated in the UI or server. — [landing.ts](file:///home/user/qr-code-ui/src/app/features/landing/landing.ts); [qr-plans.ts](file:///home/user/qr-code-ui/src/app/plan/qr-plans.ts); [orders.ts:174](file:///home/user/qr-code-ui/src/app/features/vendor/orders/orders.ts); [kitchen.ts:90](file:///home/user/qr-code-ui/src/app/features/vendor/kitchen/kitchen.ts)
- **Wizard copy.** ISSUE-019 says "the printer UI no longer claims a connection it does not have". That is true for Settings, but the setup wizard still shows "Connect a thermal printer … ✓ Connected". — [BKD/FIXES.md ISSUE-019](file:///home/user/qr-code-bkd/FIXES.md) vs [setup-wizard.html:140-175](file:///home/user/qr-code-ui/src/app/features/setup/setup-wizard.html)
- **Unused paid flags.** `PAYMENT_GATEWAY` is sold in Growth and Pro and stores PhonePe credentials that no code path uses. `ANALYTICS` exists only as a label. — [QrPlan.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrPlan.java); [TenantPaymentConfigService.java](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/payment/TenantPaymentConfigService.java)
- **Stale README.** It still describes Redis, which was removed. — [BKD/README.md](file:///home/user/qr-code-bkd/README.md) vs [BKD/FIXES.md ISSUE-033](file:///home/user/qr-code-bkd/FIXES.md)
- **Stale "Still open" notes.** BKD/FIXES.md ISSUE-002's first entry ("There is still no Cashfree integration") and ISSUE-015 ("Sequential vendor ids remain enumerable") were later superseded. Cashfree was added in the fourth pass and phase 1. Table codes replaced vendor IDs in phase 3, with the enumeration risk returning only while `PUBLIC_VENDOR_ID_LINKS=true`. — [BKD/FIXES.md](file:///home/user/qr-code-bkd/FIXES.md)
- **Stale planning docs.**
  - The design spec says "Starter ₹100/mo" and lists "Multiple subscription tiers beyond Starter" as out of scope. — [spec:9, §7](file:///home/user/qr-code-ui/docs/superpowers/specs/2026-06-17-qr-ordering-platform-design.md)
  - production-readiness.md says staff seats cost ₹149/month each. — [UI/plan/production-readiness.md](file:///home/user/qr-code-ui/plan/production-readiness.md)
  - page-flow-audit.md lists blockers that were since fixed: RBAC, outlet scope, opaque QR, idempotency, OTP and the admin guard. — [UI/plan/page-flow-audit.md](file:///home/user/qr-code-ui/plan/page-flow-audit.md)
- **Subscription copy vs code.** "Pay today and get 30 extra days" is labelled a "Limited launch offer", but the code applies it permanently to every payment, with no end date or first-payment-only rule. — [subscription.html:12](file:///home/user/qr-code-ui/src/app/features/subscription/subscription.html) vs [QrSubscriptionService.java:167](file:///home/user/qr-code-bkd/src/main/java/com/tech2software/qrorder/subscription/QrSubscriptionService.java)

### Inferences
- Any competitor comparison should use the numbers from `QrPlan.java`, not the older docs.

### Gaps
- None of the screens were run live in this research. Claims about rendered behaviour, such as the wizard's 403 for Starter, come from reading the code and are not runtime-verified.
