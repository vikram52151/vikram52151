# Compliance, launch and go-to-market requirements for Tech2Software QR Ordering (India, as of 12 Oct 2026)

Research notes for the report writer. All web research was done on 12 Oct 2026. Most primary sites (cashfree.com, pib.gov.in, meity, developers.facebook.com, law-firm sites) **could not be fetched**: the sandbox egress proxy refused the connections (`connect_rejected`). Findings therefore rely on search-engine extracts of those pages and on secondary explainers. Where a primary page appeared only as a search snippet, this is noted. Every legal point below should be confirmed by a CA (for GST) and a lawyer (for DPDP, consumer and payments) before launch.

Legend used in Inferences: **[LEGAL]** = a statutory or regulatory requirement (or very likely one); **[PLATFORM]** = required by a vendor or platform contract (Cashfree, Google, Meta, telecom operators), not by law; **[BEST PRACTICE]** = recommended but not mandatory.

Product facts used (from `our_product_readiness_and_features.md` in this folder):
- Prices are ₹199, ₹299 and ₹459 a month, with yearly and two-year options. The largest single charge is the Pro two-year plan at ₹8,262.
- There is no GST, no invoice code and no auto-renew.
- Diner name and mobile number are collected with a consent checkbox. The notice says the data is "processed by Tech2Software". Data is kept indefinitely, and there is no deletion route or grievance contact.
- The SMS OTP feature is built but switched off. No provider is connected.
- The server builds UPI intent links to the vendor's own VPA, and Tech2Software never holds funds.
- The product stores PhonePe PG credentials, but nothing uses them.
- The Android app is built with Capacitor at targetSdk 36 and is not yet published.
- There are no Terms, Privacy or Refund pages and no support contact.

---

## 1. GST: registration, rate, inclusive vs exclusive pricing, invoicing

### Takeaway
GST registration is **not mandatory until aggregate turnover exceeds ₹20 lakh a year** (₹10 lakh in special-category states). This holds even for inter-state sales, because Notification 10/2017-Integrated Tax exempts small inter-state service suppliers. Voluntary registration is allowed and is commercially useful because vendors can then claim input tax credit. SaaS is taxed at 18%. E-invoicing applies only above ₹5 crore turnover, so it is irrelevant at launch. Competitors in this category usually quote prices "+ GST". India's dark-patterns rules penalise tax or fees that first appear at checkout, so whichever convention is chosen must be stated on the pricing page.

### Cited Findings
- **Registration threshold.** Registration is required once aggregate turnover exceeds ₹40 lakh for goods or ₹20 lakh for services, with lower limits in special-category states. — [Kintsugi India GST guide 2026](https://trykintsugi.com/sales-tax-guides/apac/india)
- **Inter-state services exemption.** Notification 10/2017-Integrated Tax exempts persons making inter-state taxable supplies of services from compulsory registration up to ₹20 lakh aggregate turnover a year (₹10 lakh in special-category states). Before this notification, every inter-state supplier had to register regardless of turnover. Sources give the date as 13 Oct 2017; GSTZen gives 15 Nov 2017. — [GSTZen](https://gstzen.in/a/integrated-tax-notification-102017-seeks-to-exempt-persons-making-inter-state-supplies-of-taxable-services-from-registration-under-section-232.html); [TaxHeal](https://taxheal.com/notification-no-102017-integrated-tax.html)
  - **Conflict:** a startup-guide source says registration is "mandatory regardless of size for inter-state supply". That rule applies to goods. For services it is overridden by Notification 10/2017. — [Corrida Legal](https://corridalegal.com/gst-registration-for-startups-a-simple-explanation/)
- **Voluntary registration.** Businesses below the threshold may register voluntarily. Registration lets them issue tax invoices so that GST-registered B2B buyers can claim ITC, and lets them claim ITC on their own inputs (software, rent, professional fees). It also brings return-filing obligations. — [Corrida Legal](https://corridalegal.com/gst-registration-for-startups-a-simple-explanation/); [Treelife](https://treelife.in/?p=7971)
- **Composition scheme.** Composition dealers cannot issue tax invoices or claim ITC, so the scheme is a poor fit for B2B-facing startups. — [Corrida Legal](https://corridalegal.com/gst-registration-for-startups-a-simple-explanation/)
- **Rate.** SaaS and IT services are in the 18% slab under the "GST 2.0" reform effective 22 Sep 2025. Several sources tie this to SAC heading 9983. — [Kintsugi](https://trykintsugi.com/sales-tax-guides/apac/india); [PayPro Global](https://payproglobal.com/?p=4517)
- **E-invoicing threshold.** E-invoicing is mandatory for businesses with turnover above ₹5 crore from 1 Aug 2023. The earlier threshold was ₹10 crore. — [Tax2win](https://tax2win.in/guide/e-invoicing-gst). An older July 2023 Lok Sabha answer still cites ₹10 crore and predates the change. — [eparlib](https://eparlib.sansad.in/bitstream/123456789/2503351/1/AU678.pdf)
- **Competitor price display:**
  - Petpooja POS tiers are listed "plus 18% GST". — [SoftwareSuggest](https://www.softwaresuggest.com/petpooja/pricing)
  - Petpooja Invoice is listed at ₹5,000 a year before GST, or ₹5,900 with GST. — [Techjockey](https://www.techjockey.com/detail/petpooja-invoice)
  - G9 Smart Menu is listed at ₹4,000 excluding GST, or ₹4,720 including GST. — [Techjockey](https://www.techjockey.com/detail/g9-smart-menu)
  - Payment gateways quote fees as "2% + 18% GST". — [Razorpay](https://razorpay.com/blog/razorpay-payment-gateway-pricing-explained/)
- **Drip pricing.** The CCPA's Guidelines for Prevention and Regulation of Dark Patterns, 2023 list "drip pricing" among 13 prohibited patterns. Drip pricing means a headline price that rises at checkout without earlier disclosure. — [Mondaq](https://www.mondaq.com/india/dodd-frank-consumer-protection-act/1379670/understanding-dark-patterns-guidelines-for-consumer-protection)
  - In Aug 2026 the CCPA fined Zepto (₹7 lakh), IndiGo and BookMyShow for dark patterns. Zepto's fine was for fees added late in checkout. — [Business Standard](https://www.business-standard.com/industry/news/ccpa-fines-indigo-zepto-bookmyshow-dark-patterns-quick-commerce-penalty-126080600580_1.html); [Outlook Business](https://www.outlookbusiness.com/news/inside-indias-dark-pattern-crackdown-why-zepto-bookmyshow-and-others-are-under-ccpa-scanner)

### Inferences
- **[LEGAL] When registration becomes compulsory.** ₹20 lakh a year is about ₹1.67 lakh a month. That equals roughly 837 Starter, 557 Growth or 363 Pro monthly subscriptions. Below that level, registration is optional, and an unregistered supplier **must not charge or show GST** on its bills. Once registered, GST must be charged at 18% on every subscription.
- **Turnover counts every service.** "Aggregate turnover" is PAN-wide. If Tech2Software already earns other service income (for example software development), that income counts toward the ₹20 lakh. Whether Tech2Software is already registered is unknown, and the CA should check this first.
- **[BEST PRACTICE] Register voluntarily if selling to GST-registered restaurants.** Many restaurants are GST-registered and could claim ITC. Small stalls usually are not, so for them GST is a pure cost.
- **[LEGAL] Pricing display.** Choose one of two options and show it on the landing page, the plan cards and checkout:
  - **(a) "₹199 + 18% GST"**, which matches B2B norms; or
  - **(b) GST-inclusive "₹199 incl. GST"**, which means a net of ₹168.64.
  - Either way, the tax must be visible before the checkout step to avoid a drip-pricing complaint. The current UI shows no tax wording. Before registration the correct label is simply "₹199 (no GST charged)", or no tax line at all.
- **[LEGAL] Invoices once registered.** Every subscription payment then needs a tax invoice: GSTIN, invoice number, date, buyer details (and buyer GSTIN if B2B), SAC, taxable value, CGST+SGST or IGST split by place of supply, and amount. These contents come from general knowledge of CGST Rule 46 and were not sourced in this research, so verify them with the CA. Monthly or quarterly GSTR-1/3B filing follows. E-invoicing (IRN) is not needed below ₹5 crore.
- **[BEST PRACTICE] Receipts before registration.** Issue a payment receipt (a "bill of supply"-style document is unnecessary if unregistered) so vendors have proof of payment.
- **OIDAR.** The OIDAR special regime targets cross-border supplies to unregistered recipients in India. A domestic Indian supplier of SaaS is taxed under normal GST rules. This is general knowledge and was not sourced here. Confirm it with the CA.

### Gaps
- The exact six-digit SAC (commonly cited as 998314 for IT design and development, or 997331 for software licensing/SaaS) could not be confirmed against CBIC.
- No official page was found on whether Cashfree or Razorpay require a GSTIN for merchant onboarding. Cashfree's KYC FAQ (section 6) does not list GSTIN as mandatory, but this is unconfirmed.
- No rule was found that requires B2B service prices to be shown GST-inclusive. The Legal Metrology "MRP inclusive of all taxes" rule applies to packaged goods.
- The CBIC primary site could not be fetched.

---

## 2. DPDP Act 2023 and DPDP Rules 2025: timelines, role, obligations, penalties

### Takeaway
The DPDP Rules were notified on **13/14 Nov 2025**. Board provisions took effect immediately, consent-manager provisions start at about 12 months (~13/14 Nov 2026), and the **main fiduciary obligations start at about 18 months (~13/14 May 2027)**. These obligations cover notice, consent, security, breach reporting, retention and rights. For diner data, the **restaurant is the data fiduciary and Tech2Software is a data processor**, which requires a written processing contract. For vendor-owner and staff account data, and for any use of diner data for its own purposes, Tech2Software is a fiduciary. Maximum penalties reach ₹250 crore for security-safeguard failures. Until May 2027 the IT Act SPDI Rules 2011 continue to apply.

### Cited Findings
- **Notification and phases:**
  - The Rules were notified 14 Nov 2025 (some sources say 13 Nov). Implementation is phased over 12–18 months. — [Deccan Herald](https://www.deccanherald.com/amp/story/india%2Fcentre-notifies-dpdp-rules-implementation-planned-in-phases-spread-over-12-18-months-3798465); [SCC Online](https://www.scconline.com/blog/post/2025/12/26/digital-personal-data-protection-rules-2025-key-highlights/); [Hogan Lovells](https://www.hoganlovells.com/en/publications/indias-digital-personal-data-protection-act-2023-brought-into-force-)
  - Rules 1, 2 and 17–21 (Data Protection Board) took effect immediately. Consent-manager registration starts at 1 year (~14 Nov 2026). Notice, verifiable consent, security safeguards and breach reporting apply after 18 months (~13/14 May 2027). — [SCC Online](https://www.scconline.com/blog/post/2025/12/26/digital-personal-data-protection-rules-2025-key-highlights/); [DPDPA.com timeline](https://www.dpdpa.com/blogs/DPDPA_Implementation_Timeline.html)
  - **Conflict:** one Mondaq piece suggests Rule 4 (consent managers) is already in force. — [Mondaq](https://www.mondaq.com/india/privacy-protection/1708830/dpdp-act-compliance-mandate)
  - **Conflict:** one source says Section 8 (fiduciary duties) comes into force on 13 May 2027. — [Treelife](https://treelife.in/legal/data-fiduciary-vs-data-processor-redrafting-your-b2b-vendor-dpas/)
  - The SPDI Rules 2011 remain in force for 18 more months. — [SCC Online](https://www.scconline.com/blog/post/2025/12/26/digital-personal-data-protection-rules-2025-key-highlights/)
- **Notice (Rule 3).** The notice must give, in clear and plain language:
  - an itemised description of the personal data;
  - the specific purpose; and
  - the goods or services enabled.
  - Draft-stage guidance also listed the fiduciary's contact details and how to withdraw consent and exercise rights. — [Lawrbit](https://www.lawrbit.com/?p=8234); [KPMG final rules guidance](https://assets.kpmg.com/content/dam/kpmgsites/in/pdf/2025/11/dpdp-rules-2025-guidance-to-dpdp-act-implementation.pdf); [IIT BHU summary](https://iitbhu.ac.in/contents/institute/cf/cis/doc/dpdp_act_rules_summary.pdf)
- **Breach (Rule 7).** The fiduciary must notify the Board and affected individuals "without delay", then send a detailed report to the Board within 72 hours of becoming aware. The notice to individuals covers the nature, timing, impact and safeguards. — [Seclore](https://www.seclore.com/fundamentals/dpdp-rules-2025-compliance-guide/); [Mondaq](https://www.mondaq.com/india/data-protection/1708164/digital-personal-data-protection-rules-2025-notified)
- **Security safeguards.** These include contractual security obligations on data processors. — [Mondaq](https://www.mondaq.com/india/data-protection/1708164/digital-personal-data-protection-rules-2025-notified)
- **Log retention.** Fiduciaries must keep personal data, associated traffic data and processing logs for at least one year from the date of processing, for purposes such as state security (Rule 6(1)(e) and Rule 8(3)). — [DSCI FAQ on retention and erasure](https://www.dsci.in/files/content/documents/2025/faq-on-data-retention-and-data-erasure-v2.pdf)
- **Third Schedule erasure.** The fixed three-years-of-inactivity erasure rule applies only to listed classes, such as e-commerce entities with at least 2 crore registered users. The 48-hour pre-erasure notice appeared in the draft, and survival into the final text is unconfirmed. — [DPDP Wiki – Third Schedule](https://dpdp.myndsolution.com/wiki/rules/schedule-3-class-of-data-fiduciaries-purposes-time-period/); [Sabrang (draft)](https://sabrangindia.in/draft-dpdp-rules-2025-seeds-of-both-surveillance-and-freedom/)
- **Grievances.** Fiduciaries must set up grievance redressal with a 90-day resolution window. This comes from a single source and is unverified. — [Lawrbit](https://www.lawrbit.com/?p=8234)
- **Processor vs fiduciary:**
  - Section 8(2) allows processing by a processor only under a valid contract. Bare terms-of-service or MSAs that say nothing about personal data are a gap. — [Tsaaro](https://tsaaro.com/blogs/processor-contracts-under-dpdp-drafting-a-data-processing-agreement-that-survives-regulatory-scrutiny); [LawSikho](https://lawsikho.com/blog/data-processing-agreement-india-dpdp-act-template-clauses-compliance-guide-2026/)
  - A restaurant using a POS or CRM platform is usually the fiduciary and the SaaS vendor the processor. The test is who controls purpose. A vendor that uses client data beyond its instructions becomes a fiduciary for that use. Fiduciary accountability under Section 8(1) cannot be contracted away. — [Treelife](https://treelife.in/legal/data-fiduciary-vs-data-processor-redrafting-your-b2b-vendor-dpas/); [Mondaq vendor-data piece](https://www.mondaq.com/how-should-companies-handle-data-shared-with-vendors-under-the-dpdp-act/1846690)
  - Typical processing-agreement terms are security safeguards, immediate breach notice to the fiduciary, help with data-principal requests, sub-processor approval, retention and erasure. — [Treelife](https://treelife.in/legal/data-fiduciary-vs-data-processor-redrafting-your-b2b-vendor-dpas/)
- **Penalties.** The maximum is ₹250 crore for failing to take reasonable security safeguards that leads to a breach. The Board's penalty powers bite from May 2027. — [Seclore](https://www.seclore.com/fundamentals/dpdp-rules-2025-compliance-guide/); [DPDPA.com](https://www.dpdpa.com/blogs/DPDPA_Implementation_Timeline.html)

### Inferences
- **Roles:**
  - **Diner name and mobile:** the restaurant decides why the data is collected (to identify and call the customer), so the restaurant is the fiduciary and Tech2Software the processor. The existing notice wording ("go to <business> … processed by Tech2Software … not sold or used for marketing") already fits this model.
  - **Owner and staff logins, and billing data:** Tech2Software is the fiduciary.
  - If Tech2Software ever uses diner numbers for its own marketing or analytics across restaurants, it becomes a fiduciary for that use.
- **[LEGAL, from May 2027; BEST PRACTICE now] Before launch:**
  1. Add a **Data Processing Addendum** to the vendor Terms. It should cover processing only on the vendor's instructions, security, breach notice to the vendor, help with erasure and access requests, sub-processors (hosting, SMS or WhatsApp provider), deletion on termination and confidentiality.
  2. Expand the checkout notice to an **itemised notice**: data items, purpose, retention period, how to withdraw or erase, and a contact. Link it to a Privacy Policy and keep the unticked consent checkbox.
  3. Set a **retention period** for diner name and mobile, for example 12 months after the order, then anonymise. Keep the one-year processing-log minimum in mind.
  4. Publish a **grievance and contact person** (email and phone) in the Privacy Policy.
  5. Write a **breach runbook**: notify affected vendors at once, then the Board and individuals "without delay", with a detailed report within 72 hours. As processor, Tech2Software's job is to notify the restaurant immediately.
- **[LEGAL now] IT Act SPDI Rules.** A privacy policy published by a body corporate handling personal information is expected under SPDI Rules 2011, rule 4. This is general knowledge and was not sourced here. Name and phone number are not "sensitive" under SPDI, but the policy page is still standard.
- **Diner OTP.** If the optional diner OTP is switched on, the phone number goes to an SMS or WhatsApp provider. That provider is a sub-processor and must be named in the processing addendum and Privacy Policy.
- **Not applicable at this scale.** Penalties scale with harm and size, and the Third Schedule erasure classes and "Significant Data Fiduciary" duties do not apply to a small SaaS. A data breach caused by weak security is the main risk.

### Gaps
- The gazette text (G.S.R. number; Rule 3, 6, 8 and 14 wording) could not be fetched from MeitY, so the final notice list, the 48-hour erasure notice and the 90-day grievance window are unverified.
- Whether the date is 13 or 14 Nov 2025 differs across sources by one day.
- No source discusses how a SaaS that mixes processor and fiduciary roles should word a single combined notice.
- Lawyer review is recommended.

---

## 3. SMS/OTP in India: TRAI DLT, OTP SMS prices, WhatsApp authentication alternative

### Takeaway
Every commercial SMS in India must go through TRAI DLT. Tech2Software registers as a **Principal Entity** on an operator DLT portal (about ₹5,900 including GST, 2–7 working days, per one vendor source), registers a 6-character header, and registers consent and content templates such as "Your verification code is {#var#}". OTP SMS costs about **₹0.13–0.25 per message** through Indian providers (MSG91, Gupshup, Kaleyra) and about ₹0.45 through Twilio. WhatsApp authentication messages cost about **₹0.115–0.145** plus a 10–25% provider markup, and Meta now bills Indian accounts in INR.

### Cited Findings
- **DLT registration steps:**
  - Register on an operator DLT portal (for example Jio TrueConnect at trueconnect.jio.com, or Airtel, Vi, BSNL or Tata).
  - Businesses register as "Enterprise" (Principal Entity). Bulk-SMS providers register as "Telemarketer".
  - Documents: business PAN, a GST or TAN certificate, and a letter of authorisation.
  - The portal issues a 19-digit entity ID.
  - Alpha headers (6 characters) are used for transactional and service traffic, and numeric headers for promotional traffic.
  - Consent templates come first, then content templates with `{#var#}` variables.
  - — [Plivo DLT guide](https://plivo.com/blog/trai-dlt-regulations-for-sms); [Social Beat DLT playbook](https://www.socialbeat.in/wp-content/themes/socialbeat/home/images/marketing-salesforce/TRAI-DLT-Registration-Playbook.pdf); [Infobip](https://www.infobip.com/docs/essentials/dlt-registration); [Route Mobile](https://routemobile.com/wp-content/uploads/2021/08/DLT-TLV-Implementation.pdf)
- **DLT fees and timing.** Entity approval takes 2–7 working days and costs about ₹5,900 including GST. Headers and templates are usually free, and fees vary by operator. This is a single vendor blog. — [Avancezone](https://avancezone.com/dlt-registration-for-bulk-sms)
- **OTP SMS prices:**
  - Authgear's Aug 2026 review puts MSG91 at ₹0.18–0.25 per India SMS on prepaid slabs, and about ₹0.20 per OTP. — [Authgear](https://www.authgear.com/post/best-otp-service-providers/)
  - Message Central (a competitor blog, May 2026) puts MSG91 at about ₹0.15 (about ₹0.13 at volume), Gupshup at about ₹0.17, Kaleyra at about ₹0.18 and Twilio India at about ₹0.45 including forex. It says setup fees and sender-ID delays can move the all-in cost by 30–50%. — [Message Central](https://www.messagecentral.com/blog/sms-otp-pricing-india)
- **WhatsApp authentication pricing:**
  - About ₹0.115 per authentication message in India (about $0.0014). It is charged even inside the service window. — [Whautomate](https://whautomate.com/whatsapp-business-api-pricing-india); [Hyperleap calculator](https://hyperleap.ai/whatsapp-pricing-calculator-india); [Fyno](https://www.fyno.io/blog/how-to-save-big-on-sms-costs-with-whatsapp-in-india-updated-clst1n275005yxv47ioyo7mff/)
  - **Conflict:** AiSensy (June 2026) lists about ₹0.145 for authentication and ₹1.09 for marketing. — [AiSensy](https://m.aisensy.com/blog/whatsapp-business-pricing/)
  - Meta started INR billing for eligible Indian customers on 1 Jan 2026. Non-INR WhatsApp Business accounts must migrate by 31 Dec 2026, or messages stop on 1 Jan 2027. — [Meta pricing docs](https://developers.facebook.com/documentation/business-messaging/whatsapp/pricing.md)
  - Provider (BSP) markup adds roughly 10–25% or more. Volume tiers exist. — [Fyno](https://www.fyno.io/blog/how-to-save-big-on-sms-costs-with-whatsapp-in-india-updated-clst1n275005yxv47ioyo7mff/); [ChatMaxima](https://chatmaxima.com/blog/whatsapp-business-api-pricing-2026-complete-guide/)

### Inferences
- **[PLATFORM/LEGAL – TRAI TCCCPR] DLT before any SMS.** No SMS can be sent without DLT entity, header and template registration, typically done through the chosen provider's dashboard. Allow about 1–2 weeks. The PAN and GST/TAN documents tie this to Section 1: an unregistered business can use TAN or other proof, but should check with the provider.
- **[BEST PRACTICE] Unit economics.** Keep diner OTP **off by default**:
  - At ₹0.20 per OTP, a stall doing 100 orders a day spends about ₹600 a month on OTPs. That is more than the ₹199 Starter subscription.
  - Use SMS only for vendor sign-up verification and password reset, which is low volume: about ₹0.20 × a few messages per vendor.
  - If diner OTP is offered, make it per-restaurant opt-in or a paid add-on, or verify only on suspected fraud.
- **[BEST PRACTICE] WhatsApp as a cheaper channel.** WhatsApp authentication (about ₹0.12–0.15 plus markup) is comparable to or slightly cheaper than SMS. Indian users trust it, and it needs no DLT registration, but it needs Meta business verification and an approved authentication template. An SMS fallback is still needed for numbers without WhatsApp.

### Gaps
- MSG91, Gupshup, Twilio and Meta pricing pages could not be fetched directly, so all per-message prices come from third-party comparisons and need a fresh quote.
- The DLT fee is from one vendor blog. The Jio, Airtel and Vi portal fees were not verified.
- No primary source was found for the exact current Meta India authentication rate.

---

## 4. Payments: gateway fees, RBI e-mandate rules, PA licensing risk, UPI 0.4% MDR from 15 Oct 2026

### Takeaway
- **Gateway fees.** Cashfree and Razorpay charge about **2% (Cashfree 1.95–2.0%) plus 18% GST** on the fee, with no setup or annual fee. Their standard pricing charges this platform fee on UPI too.
- **Auto-renew.** Adding auto-renew would fall under the RBI e-mandate framework, consolidated in April 2026. Debits **up to ₹15,000 need no extra authentication** after the first, with **pre-debit notice at least 24 hours before**. Every Tech2Software price, up to ₹8,262, is under this cap.
- **PA licensing.** Generating UPI intent links to the vendor's own VPA without handling funds is outside the Payment Aggregator definition, which turns on handling funds. Legal sign-off is still advisable.
- **UPI 0.4% MDR from 15 Oct 2026.** The new MDR applies only to P2M UPI payments **above ₹2,000**. Small merchants receiving up to ₹1 lakh a month through UPI QR are exempt, so most Tech2Software vendors' typical orders are unaffected.

### Cited Findings
- **Cashfree fees and onboarding:**
  - Domestic cards, net banking and wallets cost 1.95–2.0% as a platform fee. UPI is listed at "Standard Pricing: 2.0% platform fee", with an anniversary offer of 1.95%. There is no setup or integration fee and no annual maintenance on the standard plan. — [Cashfree charges page (search extract)](https://www.cashfree.com/en/payment-gateway-charges/)
  - **Conflict:** a third-party guide says UPI is "0% for most merchants". — [Xflowpay](https://www.xflowpay.com/blog/cashfree-payment-gateway-charges)
  - The anniversary offer was for sign-ups from 18 Sep 2025 to 30 Apr 2026. One comparison site says it ran to 31 Jul 2026. Conditions were monthly GTV up to ₹1 crore and UPI at least 40% of GTV. Both windows have likely expired. — [Cashfree AE page](https://www.cashfree.com/ae/payment-gateway-charges/); [rfp.wiki](https://www.rfp.wiki/payments-fraud/payment-gateways/checkout-com/cashfree-payments)
  - 18% GST applies on every fee. — [Xflowpay](https://www.xflowpay.com/blog/cashfree-payment-gateway-charges)
  - Activation typically takes 24 working hours after documents are submitted. KYC uses Aadhaar OTP, CKYC or DigiLocker, and video KYC applies if the address check fails. — [Cashfree onboarding FAQ](https://www.cashfree.com/docs/help/onboarding-related/onboarding-faqs)
- **Razorpay fees and autopay:**
  - Most domestic methods, including UPI, cost 2% plus 18% GST. There is no setup or annual fee. UPI MDR is 0% by government rule, but Razorpay charges a 2% platform fee for its gateway services. — [Razorpay pricing explainer](https://razorpay.com/blog/razorpay-payment-gateway-pricing-explained/)
  - UPI Autopay is available through Subscriptions (plans, then a subscription per customer) or Recurring Payments. Mandate registration uses a ₹1 authorisation. — [Razorpay UPI recurring docs](https://razorpay.com/docs/payments/recurring-payments/upi.md); [Razorpay Subscriptions](https://razorpay.com/subscriptions/)
- **RBI e-mandate rules:**
  - The 2019 framework requires AFA on the first transaction. The AFA-free limit for later transactions was raised from ₹5,000 to ₹15,000 in June 2022. — [RBI notification 12341](https://www.rbi.org.in/Scripts/NotificationUser.aspx?Id=12341)
  - The NPCI RuPay AutoPay circular requires pre-debit notification at least 24 hours before the charge. — [NPCI circular](https://www.npci.org.in/PDF/npci/rupay/2022/Circular-RuPay-AutoPay-AFA-Limit-enhancement-and-compliance.pdf)
  - The limit is ₹1 lakh for mutual funds, insurance premiums and credit-card bills. — [RBI notification 12570](https://www.rbi.org.in/Scripts/NotificationUser.aspx?Id=12570)
  - On 21 Apr 2026 RBI notified a consolidated "Digital Payments – E-mandate Framework, 2026". It keeps the ₹15,000 AFA-free limit and the 24-hour pre-debit notice. This comes from a secondary summary, and the RBI text was not fetched. — [SCC Online](https://www.scconline.com/blog/post/2026/04/24/rbi-issues-digital-payments-e-mandate-framework-2026/)
- **Payment Aggregator licensing:**
  - RBI's Master Direction on Regulation of Payment Aggregators (15 Sep 2025, RBI/DPSS/2025-26/141) replaces the 2020/2021 PA-PG guidelines. — [RBI notification 12896](https://www.rbi.org.in/Scripts/NotificationUser.aspx?Id=12896); [AffairsCloud](https://affairscloud.com/rbi-rolls-out-comprehensive-framework-for-pas-pgs-to-boost-digital-payment-ecosystem/)
  - A Payment Gateway is defined as an entity that provides technology to route and facilitate payment processing **without handling funds**. Non-bank PAs need authorisation because they handle funds, along with ₹25 crore net worth by year 3 and an escrow account. — [PhonePe Business explainer](https://business.phonepe.com/articles/what-is-a-payment-aggregator-meaning-pg-difference-and-rbi-rules-explained); [Enterslice](https://enterslice.com/learning/rbi-payment-aggregators-and-payment-gateways-audit/)
- **UPI MDR from 15 Oct 2026:**
  - NPCI announced the framework on 15 Sep 2026, effective 15 Oct 2026. — [UNI India](https://www.uniindia.com/business-economy/business-upi-mdr-merchant-deals/180767); [Deccan Chronicle](https://www.deccanchronicle.com/business/npci-announces-04-merchant-charge-on-upi-payments-above-2000-1987634)
  - The rate is 0.4% on P2M UPI payments above ₹2,000. P2P transfers and P2M payments of ₹2,000 or less stay free. — [Adgully](https://www.adgully.com/post/20605/india-to-impose-04-merchant-fee-on-larger-upi-transactions-from-october-15); [Moneylife](https://www.moneylife.in/article/upi-charges-on-transactions-over-2000-from-15th-october-what-new-mdr-framework-means-for-consumers-and-merchants/81663.html)
  - **Small-merchant exemption:** small merchants under the P2PM framework, defined as receiving up to ₹1 lakh a month via UPI QR directly into their bank accounts, keep zero MDR. — [Morung Express](https://morungexpress.com/npci-reveals-mdr-on-upi-payments-above-rs-2000-from-oct-15-small-merchants-continue-to-benefit)
  - Merchants bear the fee and may not pass it on to customers. — [Indian Pay Calculator](https://www.indianpaycalculator.in/govt-news/upi-mdr-rate-card-october-15-2026-shop-cannot-charge-you); [Free Press Journal](https://www.freepressjournal.in/business/upi-payments-above-rs-2000-face-04-mdr-know-who-will-actually-pay)
  - Railways, fuel, telecom and insurance pay a flat ₹5. RuPay credit-card UPI follows card rules. — [CA Jatin Karda](https://cajatinkarda.in/articles/upi-mdr-charges-october-2026); [Fintechspecs](https://fintechspecs.com/blog/india-upi-mdr-october-15-2026-merchant-fee-explained/)
  - **Conflict on the ₹300 cap:** some outlets say ₹300 caps every qualifying payment. Moneylife and Onmanorama say the cap applies to payments of ₹75,000 and above. — [Khaleej Times](https://www.khaleejtimes.com/asia/india-charge-some-merchants-up-to-rs300-upi-transactions-over-rs2000); [Onmanorama](https://www.onmanorama.com/news/india/2026/09/15/centre-imposes-0-4-mdr-on-upi-merchant-payments-above-rs-2-000.amp.html)
  - A Supreme Court challenge is reported as pending. A LocalCircles survey found 83% of merchants unwilling to absorb the fee. — [Whalesbook](https://www.whalesbook.com/news/English/bankingfinance/UPI-Fee-Update-New-04percent-MDR-Rules-for-Merchants-Starting-Oct-15/6ac504205aacb956d08e0fd1); [Startup Fortune](https://startupfortune.com/upi-will-charge-merchants-a-04-fee-on-big-payments-from-october-15/)

### Inferences
- **Gateway cost per payment.** At about 2% plus GST (2.36% effective), a ₹199 payment costs about ₹4.70 and a ₹459 payment about ₹10.83. Cashfree's anniversary pricing has probably lapsed, so ask for a quote. Confirm whether UPI carries the platform fee for Tech2Software's account, since sources conflict.
- **[PLATFORM] Gateway activation prerequisites.** Cashfree activation needs a live website with legal pages (see Section 6) and business KYC.
- **[LEGAL, if auto-renew is added] E-mandate rules.** Mandate registration needs AFA. The issuer, through the gateway, sends a pre-debit notice at least 24 hours before each debit. The customer must be able to cancel. All plan prices are well under ₹15,000, so renewals need no per-debit AFA. Use Cashfree Subscriptions or Razorpay Subscriptions/UPI Autopay rather than building this in-house.
- **[LEGAL, inference] PA risk is low for the current model.** Tech2Software only generates a `upi://pay` deep link with the vendor's VPA and amount. Money moves from the customer's bank to the vendor's bank through the customer's UPI app, and no funds pass through Tech2Software's account. This falls outside the PA definition, which hinges on handling funds.
  - **Becomes regulated if** Tech2Software collects diner payments into its own account and settles to vendors, which would be PA activity needing RBI authorisation. The safe route then is a licensed PA's marketplace or split product (for example Cashfree Easy Split or Razorpay Route), or each vendor's own gateway credentials.
  - **PhonePe credentials:** storing each vendor's own PhonePe PG credentials (the PAYMENT_GATEWAY flag) keeps the vendor as the merchant of record, which is the right pattern. Get a one-time legal opinion.
- **[BEST PRACTICE] UPI MDR effect on Tech2Software's vendors.** Most stall and café orders are under ₹2,000, and many small vendors receive under ₹1 lakh a month through UPI QR, so most are likely unaffected.
  - A busy restaurant with bills over ₹2,000 that receives payment to a merchant VPA through an acquiring PSP could pay 0.4% (₹8 on ₹2,000) and cannot add a surcharge.
  - This is a sales talking point ("we take 0% commission and don't touch your money"). It also argues against building a gateway-collection feature that would add 2% on top.
  - **Caveat:** the fee applies through acquirers. A personal VPA used for P2M by tiny vendors may fall outside it or be reclassified. Check the NPCI circular for the definitions.

### Gaps
- The NPCI circular, Cashfree's live pricing page, and Cashfree Subscriptions or recurring pricing could not be read directly.
- Settlement cycles (T+1/T+2 and instant-settlement fees) were not found for either gateway.
- The RBI 2026 e-mandate framework text was not read.
- The PA Master Direction's exact carve-out wording for technology providers was not quoted in any result.

---

## 5. Google Play publishing requirements (2026)

### Takeaway
Publishing needs:
- a Play Console account (one-time **US$25**);
- an **organisation account with a D-U-N-S number** if published as a business, which avoids the closed-testing gate; a new **personal** account must run a **closed test with ≥12 opted-in testers for 14 continuous days** before production access;
- a privacy policy URL;
- a completed **Data safety** form;
- **in-app and web-link account deletion** (the app creates owner and staff accounts);
- **targetSdk 36 (Android 16)** for new apps and updates from **31 Aug 2026**. An extension to 1 Nov 2026 is available, and the APK already targets 36.

### Cited Findings
- **Testing gate.** New personal developer accounts must run a closed test with at least 12 testers opted in continuously for the past 14 days before applying for production access. This applies to personal accounts created after 13 Nov 2023, and organisation accounts are exempt. The requirement was earlier 20 testers. — [Play Console Help 14151465](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en); [Android Authority](https://androidauthority.com/google-play-app-testing-requirement-3510580)
  - Third-party guides claim the clock resets if testers drop below 12 (unofficial). — [Choicely](https://www.choicely.com/blog/google-play-12-tester-rule)
- **Target API.** New apps and updates must target Android 16 (API 36) from 31 Aug 2026, and an extension to 1 Nov 2026 can be requested. Existing apps must target API 35 or higher to stay visible to new users on newer devices. — [Play Console Help 11926878](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-419); [Android Developers target-sdk](https://developer.android.com/google/play/requirements/target-sdk?hl=de)
  - With API 36, large screens (600dp and up) can no longer lock orientation or aspect ratio, and the edge-to-edge opt-out is gone. — [DEV Community](https://dev.to/mr_manushukla/android-target-api-36-is-due-aug-31-2026-api-37-is-next-the-play-store-migration-checklist-2f9i)
- **Account deletion.** Apps that allow account creation must provide an in-app path to delete the account and associated data, plus a web link for deletion requests, entered in the Data safety form. Deactivation is not enough. Incomplete answers block new apps and updates. — [Play Console Help 13327111](https://support.google.com/googleplay/android-developer/answer/13327111); [Android Developers Blog, Apr 2023](https://android-developers.googleblog.com/2023/04/giving-people-more-control-over-their-data.html?hl=en)
- **Fee and D-U-N-S.** Registration is a one-time US$25 fee. Organisation accounts need a D-U-N-S number, which is free but can take up to about 30 days (an expedited paid option exists). The legal name must match the D-U-N-S record. — [Capgo guide](https://capgo.app/blog/how-to-create-apple-developer-and-google-play-developer-accounts/); [TMS Outsource](https://tms-outsource.com/blog/posts/google-play-developer-account-requirements/)

### Inferences
- **[PLATFORM] Pre-publish checklist for the Capacitor vendor app:**
  1. **Account type.** Choose an organisation account (start the D-U-N-S request now, since it takes up to 30 days). A personal account means recruiting 12 testers, for example friendly vendors and their staff, for 14 days.
  2. **Privacy policy URL** on the public website. Play requires one for apps handling personal data. This is general Play policy knowledge, not fetched here.
  3. **Data safety form.** Declare phone number, name, email (owner sign-up), user IDs, and purchase history if applicable. State that data is encrypted in transit and how deletion works.
  4. **Account deletion.** Add an in-app "Delete my account" for owners, plus a public web page or form. The backend needs a real delete or anonymise job (none exists today, per readiness S10).
  5. **targetSdk 36** is already set. Test edge-to-edge and orientation on a tablet.
  6. Release keystore and Play App Signing; production API host.
  7. Content rating questionnaire, app access instructions for reviewers (a demo vendor login) and store listing assets.
- **[PLATFORM] Payments policy.** The subscription is bought for a business service, and checkout happens through Cashfree on the web. This needs a Play Payments policy check, since apps selling digital content or services in-app generally must use Play Billing, and B2B and "reader" exceptions vary. This research did not cover it. Confirm before exposing a "Buy plan" button inside the APK. One option is to keep purchasing on the web only.

### Gaps
- The Play Payments (billing) policy for B2B SaaS subscriptions bought in-app was not researched.
- The privacy-policy and Data safety help pages were not fetched directly.
- The US$25 fee comes from third-party guides, not a Google page.

---

## 6. Legal pages: Terms, Privacy, Refund/Cancellation, consumer-protection e-commerce rules, grievance contact

### Takeaway
**Cashfree activation requires** a live site with Terms and Conditions, About Us, Contact Us (an email and at least one phone number), Privacy Policy and the registered business name. Refund and shipping policies are "conditional" in the current FAQ, but older Cashfree help pages list a refund policy as standard, so publish one. The Consumer Protection (E-Commerce) Rules 2020 require a grievance officer and contact details for e-commerce entities. Their application to a B2B SaaS is unsettled, but compliance costs little. Dark-patterns rules (drip pricing) apply to pricing display.

### Cited Findings
- **Cashfree website requirements:**
  - Mandatory: Terms and conditions, About us, Contact us, Privacy policy and the registered business name. Conditional on business model: refund or return policy, shipping and delivery, product or services, and pricing. Non-compliant sites can be deactivated later. — [Cashfree onboarding FAQ](https://www.cashfree.com/docs/help/onboarding-related/onboarding-faqs)
  - An older help page lists a refund policy section as standard and asks for a valid email and phone number on the contact page. — [Cashfree help 65](https://cashfree.com/help/65/need-make-changes-website-make-complaint-account-activation); [Cashfree help 107](https://cashfree.com/help/107/terms-conditions-for-activating-payment-gateway)
- **E-Commerce Rules 2020.** E-commerce entities must set up grievance redressal, appoint a grievance officer and display customer-care and grievance-officer contact details. — [Trilegal](https://trilegal.com/knowledge-repository/consumer-protection-e-commerce-rules-2020/); [IndiaLaw](https://www.indialaw.in/guides/civil/consumer-protection-e-commerce-rules/)
  - **B2B applicability is contested.** The Act generally does not govern purchases for commercial operations, but buyers acting for "self-employment" may still be consumers. The Rules lack clarity for B2B and digital services. — [Mondaq](https://www.mondaq.com/india/dodd-frank-consumer-protection-act/995148/the-consumer-protection-e-commerce-rules-2020); [Naik Naik](https://naiknaik.com/2021/07/29/consumer-protection-e-commerce-rules-2020-part-ii/)
  - The 48-hour acknowledgement and one-month redress timelines are recalled from the Rules but were not confirmed in fetched text.
- **Dark-patterns guidelines** apply to platforms, advertisers and sellers. The prohibited patterns include drip pricing and "basket sneaking". — [Mondaq](https://www.mondaq.com/india/dodd-frank-consumer-protection-act/1379670/understanding-dark-patterns-guidelines-for-consumer-protection)

### Inferences
- **[PLATFORM – Cashfree; LEGAL/BEST PRACTICE – DPDP, SPDI, Consumer] Pages to publish before switching on payments:**
  1. **Terms of Service** for vendors. Include plans, trial, the bonus-days rule, no auto-renew, suspension on expiry (the customer QR stops working), acceptable use, limitation of liability, governing law and jurisdiction, and the **Data Processing Addendum** from Section 2. Say clearly that UPI payments go directly to the vendor and Tech2Software does not verify or hold them.
  2. **Privacy Policy** covering both vendor-account data (Tech2Software as fiduciary) and diner data (as processor for the restaurant). Include data items, purposes, sub-processors (hosting, Cashfree, SMS or WhatsApp provider), retention, rights and erasure, and a grievance or contact person.
  3. **Refund and Cancellation Policy.** State the refund window (for example none after the trial, or a pro-rata rule), cancellation (no auto-renew, so nothing to cancel), and failed or duplicate payment handling with a timeline.
  4. **Contact Us / About Us** with the registered business name, address, email and phone.
  5. **Grievance officer.** A named person with an email, satisfying the E-Commerce Rules (if applicable) and DPDP.
  6. **Pricing page.** Show GST treatment up front (Section 1).
- **[BEST PRACTICE]** Link all pages from the landing footer, sign-up and checkout, and link the Privacy Policy from the diner checkout notice. Use a lawyer-reviewed template. Generated templates are a starting point only.
- The diner pays the restaurant, not Tech2Software, so diner-side consumer law (menu prices, food) stays with the restaurant.

### Gaps
- The text of the E-Commerce Rules (Rule 4 grievance timelines) and Cashfree's exact refund-policy content expectations were not fetched.
- Whether Razorpay's requirements differ was not checked. They are believed similar.

---

## 7. Go-to-market benchmarks for Indian small restaurants and stalls

### Takeaway
Incumbents rely on high-touch help, and the available evidence on how they acquire customers is thin:
- Petpooja advertises support in **18+ Indian languages**, 24x7 phone, chat and email support, and free on-call and in-person training, and reportedly runs a reseller programme paying **10% recurring commission**.
- DotPe grew through anchor-brand and mall deployments, with staff helping diners at launch.
- Low-cost QR-menu tools compete on flat fees and **zero commission** against aggregators' 18–30%.
- Free trials are common (about 70% of restaurant software offers one), and 14–30 days is typical.
- Opt-in, no-card trials convert at about **5–18%** depending on the benchmark.
- No published CAC figures were found for this segment.

### Cited Findings
- **Petpooja:**
  - Reseller programme: "10% ongoing commission on every referred client while they actively use Petpooja", plus a partner track for consultants and resellers. This comes from directory listings, not Petpooja's own site. — [Bitscale directory](https://bitscale.ai/directory/petpooja); [Elioplus](https://elioplus.com/profiles/vendors/31298/petpooja-prayohsa-food-services-pvtltd)
  - Scale: 55,000+ outlets in one source, 100,000+ clients in another, across 140+ cities. — [Bitscale](https://bitscale.ai/directory/petpooja); [Builtin](https://builtin.com/company/petpooja)
  - Support: help in 18+ Indian languages, free on-call and in-person staff training, and on-ground help from POS experts. A review site says 24x7 email, phone and chat. — [Petpooja Support](https://www.petpooja.com/support); [Techjockey reviews](https://www.techjockey.com/reviews/petpooja-pos)
- **DotPe:**
  - Shared mall QR codes, with floor managers guiding diners. — [Restaurant India](https://www.restaurantindia.in/news/phoenix-marketcity-bengaluru-adopts-contactless-dining-and-take-away-team-up-with-dotpe.n19401)
  - McDonald's India (North and East) tie-up, with store managers helping diners. — [Entrepreneur India](https://india.entrepreneur.com/news-and-trends/dotpe-collaborates-with-mcdonalds-india-north-east-to/354700)
  - Self-reported 10,000+ restaurant integrations, and 5M merchants on its WhatsApp "Digital Showroom" within 6 months. Backed by PayU and Google. — [IBS Intelligence](https://ibsintelligence.com/ibsi-news/dotpe-raises-27-5-mn-from-payu-google-and-info-edge-ventures); [TechCrunch](https://techcrunch.com/2022/05/31/temasek-in-talks-to-invest-in-google-backed-dotpe/)
- **Low-cost QR competitors (positioning and trials):**
  - AhaarScan: ₹399 a month or ₹2,999 a year, with zero per-order commission. — [Software Advice](https://www.softwareadvice.com.au/software/560297/Ahaar-Scan)
  - RestroQT: free tier (50 bills, 10 guests), paid from ₹499 a month. — [Capterra India](https://www.capterra.in/software/1105317/RestroQT)
  - Biller.app: ₹749, free trial, English only, email or help-desk support. — [Capterra AU](https://www.capterra.com.au/software/1110754/Biller-app)
  - Scanmyfood: first 30 days free with no card (vendor's own claim). — [Scanmyfood pricing](https://scan-and-serve-magic.lovable.app/pricing)
  - About 70% of restaurant-management tools offer a free trial. — [SoftwareSuggest](https://www.softwaresuggest.com/petpooja)
  - Swiggy and Zomato commissions are about 18–30%. — [Restaurant India](https://www.restaurantindia.in/article/best-online-ordering-platform-providers-in-india.13734)
- **Reseller models seen:** SynexPOS (India) recruits resellers with recurring payouts, a demo environment and training, and requires partners to provide local first-line support. The rate is undisclosed. — [Elioplus – Synexlabs](https://elioplus.com/profiles/vendors/226032/synexlabs)
- **Trial conversion benchmarks:**
  - First Page Sage (via secondary summaries): opt-in, no-card trials convert about 18.2%, and opt-out, card-required trials about 48.8%. — [Shno](https://www.shno.co/marketing-statistics/free-trial-conversion-statistics); [Userpilot](https://userpilot.com/blog/free-trial-conversion-rate/)
  - ChartMogul/ProductLed (Jan 2026, 200 B2B products): no-card trials convert 4–6% at the median and 10–15% at the 75th percentile. — [Userpilot](https://userpilot.com/blog/free-trial-conversion-rate/)
  - Flint: median trial-to-paid 18.5%, top performers 35–45%. — [Flint](https://www.flint.com/blog/b2b-saas-free-trial-conversion-rate-statistics)

### Inferences
- **[BEST PRACTICE] Channels for a ₹199–459 a month product.** The price is too low to fund field sales per vendor. The likely mix:
  - **WhatsApp-first** demos and support: share a 60-second video and a demo QR.
  - **Local agents or resellers on recurring commission.** Petpooja's reported 10% is a reference point. A higher first-year share (20–30%) is plausible to motivate agents at this low price, but no source confirms it.
  - Partnering with existing local service providers: menu printers, POS or printer dealers, CA firms and UPI soundbox field agents.
  - Instagram and YouTube Shorts in Hindi and regional languages.
  - Cluster selling in food courts and markets, where one install creates social proof.
  - Lead with the "0% commission, money goes straight to your UPI" message.
- **[BEST PRACTICE] Support expectations.** Incumbents set the bar at multilingual support (at least Hindi plus the launch region's language), phone or WhatsApp, and assisted onboarding: menu upload done for the vendor, plus QR printing. The current product is English-only with no support channel (readiness B6). A WhatsApp Business number with Hindi support and a "we'll set up your menu from a photo" service is the minimum.
- **Trial.** 14 days with no card fits the market (30 days is also seen). Budget for about 5–18% trial-to-paid, and improve it with day-1 assisted setup, a day-10 WhatsApp nudge, and reminders before expiry. Today nothing reminds vendors, and their QR codes 404 at expiry.
- **Pricing.** The pricing anomaly in the readiness notes (a 30-day bonus on every payment) should be fixed before resellers are paid commission on it.

### Gaps
- No published CAC, payback or field-sales cost figures for Indian restaurant SaaS were found.
- No confirmed reseller commission rates were found beyond the Petpooja directory claim.
- No India-specific trial-conversion data for restaurant tools was found.
- DotPe's current (2025–26) acquisition model, and PhonePe/Paytm soundbox-agent partnerships for SaaS distribution, were not found.

### Consolidated checklist (inference, built from Sections 1–7)
**Before production launch (blocking):**
1. Ask a CA to confirm GST status. If not registered and under ₹20 lakh, show prices without GST and issue receipts. If registered or registering, add 18% GST, decide inclusive or exclusive, show it on all pricing surfaces, and build tax invoices. [LEGAL]
2. Publish Terms (with a Data Processing Addendum), Privacy Policy, Refund/Cancellation, Contact/About with business name, address, email and phone, and a named grievance contact. [PLATFORM: Cashfree; LEGAL/BEST PRACTICE]
3. Complete Cashfree KYC, then run one sandbox payment and one live ₹1-style test payment. Get current fee quotes, and confirm whether UPI carries the 2% platform fee. [PLATFORM]
4. Update the diner consent notice to an itemised form linked to the Privacy Policy. Set a retention period and a delete or anonymise job. Write a breach runbook. [BEST PRACTICE now; LEGAL from May 2027]
5. Set up a support channel: WhatsApp Business plus phone, in Hindi and English. [BEST PRACTICE]
6. Get a legal opinion confirming the UPI-intent model is not PA activity. [BEST PRACTICE]

**Before the Play Store release:**
7. Create an organisation Play account (D-U-N-S) or run a 12-tester, 14-day closed test.
8. Complete the Data safety form, privacy URL, in-app and web account deletion, and targetSdk 36 testing.
9. Check the Play billing policy for in-app plan purchase.

**Before enabling SMS or WhatsApp OTP:**
10. Complete DLT entity, header and templates, choose a provider at about ₹0.15–0.25 per SMS, or set up WhatsApp authentication at about ₹0.12–0.15 plus markup. Keep diner OTP off by default because of cost.

**After launch:**
11. Monitor the UPI MDR rollout (15 Oct 2026) and the Supreme Court challenge, and prepare vendor FAQ messaging.
12. If adding auto-renew, use the gateway's subscription or UPI Autopay product (₹15,000 AFA-free cap, 24-hour pre-debit notice).
13. Reach full DPDP compliance by May 2027.
14. Track the ₹20 lakh GST threshold monthly.
15. Measure trial-to-paid conversion and reseller economics.
