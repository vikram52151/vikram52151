# QR Ordering — gap walkthrough status

Last updated: 12 Oct 2026. Covers the two code repositories:

- [QR-Code-ui](https://github.com/vikram52151/QR-Code-ui) (Angular web app and Android APK)
- [QR-Code-bkd](https://github.com/vikram52151/QR-Code-bkd) (Spring Boot API)

The plan the phases come from: [QR Ordering Gap Walkthrough](https://claude.ai/artifact/7rrYBK72kkqaNu2qp4Lgdo).
Each repository's `FIXES.md` has the detailed write-up for every phase.

## Where the code is

| Branch | Contains | Merged into `master`? |
|---|---|---|
| `claude/pensive-planck-b0uqoz` | Phase 1 | No |
| `claude/magical-noether-ys2e87` | Phase 1 + phases 2–6 (built on top of phase 1) | No |

No pull requests are open yet. `master` in both repositories is still the pre-walkthrough code
(ui `33ef21a`, bkd `4b5e429`).

## Phases

| # | Phase | Status | QR-Code-ui | QR-Code-bkd |
|---|---|---|---|---|
| 1 | Stop money and release blockers | Done; two items need your input (see below) | `709c9a6` | `1d2d5bc` |
| 2 | Lock down access | Done | `ee7d5d4` | `a955075` |
| 3 | Table QR and customer trust | Done | `fd264c9` | `7b7a7c9` |
| 4 | Accounts and honest copy | Done | `fa94666` | `0b6ef06` |
| 5 | Kitchen and menu depth (incl. outlet scoping) | Done | `caf4099` | `1ce02c0` |
| 6 | Release gates | Done | `42be6f5` | `28947d4` |

### Test and CI results (branch `claude/magical-noether-ys2e87`)

| | Result |
|---|---|
| Backend tests | 107 pass, including every migration applied to a real MySQL 8.4 |
| Frontend unit tests | 68 pass |
| Frontend end-to-end tests (customer flow + accessibility scan) | 3 pass |
| Production npm audit | 0 vulnerabilities |
| Secret scan (gitleaks, full history, both repos) | No leaks |
| GitHub Actions CI | Passing on both repositories |

## What each phase delivered

- **Phase 1** — Paid renewals extend the plan; the plan changes only after a verified payment;
  the webhook checks the amount; Cashfree checkout wired in; Android release build hardened.
- **Phase 2** — Staff see only the pages and buttons their role may use; waiters and kitchen
  don't see revenue; plan features (printer, payment gateway, live tracking) enforced on the
  server; expired vendors can't create QR codes, outlets or staff.
- **Phase 3** — Random, revocable QR code per table ("New QR" cancels the old printout);
  privacy notice and consent; duplicate orders blocked; optional customer OTP; customers can send
  their UPI reference; owners can undo a payment.
- **Phase 4** — Password reset (SMS, or one-time passwords from the admin portal / the owner);
  new staff must set their own password; session-expired message and return to the same page;
  admin actions audited; landing page describes only real features and loads prices from the
  server.
- **Phase 5** — Kitchen display with late flags and a printable kitchen ticket; new-order sound
  and notification; portions and add-ons; veg/non-veg; item hours; menu photos; CSV import;
  customer self-cancel; menus and orders separated by outlet.
- **Phase 6** — CI with dependency and secret scanning; end-to-end tests; health check that
  tests the database and storage; backup and restore scripts; `docs/RUNBOOK.md` (backend repo).

### Problems found along the way and fixed

- **Database migrations never ran.** The backend lacked `spring-boot-starter-flyway`, which
  Spring Boot 4 needs; a fresh database would have stopped the API at startup.
- **Angular security advisories** (including an XSS) — upgraded to 21.2.25.
- **Brand green failed accessibility contrast** — darkened to `#147A3A` (changes the app's look
  slightly).
- **Customers could see a raw "SyntaxError" message** — they now see a plain message.

## Before you deploy

- **Old printed QR codes (`/order?v=<id>`) stop working.** Set `PUBLIC_VENDOR_ID_LINKS=true`
  only while reprinting them, then turn it off.
- SMS features are off until an SMS provider is connected: `SMS_ENABLED` (sign-up check,
  password reset) and `CUSTOMER_OTP_ENABLED` (customer OTP). Without SMS, owners are reset from
  the admin portal and staff by their owner.
- Set up the daily backup and an external uptime monitor as described in `docs/RUNBOOK.md`.

## Remaining work

### Can be built now (no input needed)

| Item | Notes |
|---|---|
| Table sessions | Group one party's orders at a table into a single bill; close the table |
| Per-outlet token numbers | Each outlet gets its own 001, 002… sequence (today: one per vendor) |
| Rate limits in the database | Today they are in memory: reset on restart, not shared between servers |
| Metrics | Request count, error rate, orders per minute for a monitoring tool |
| Assign orders to a cook | On the Kitchen screen |
| Staging build | A separate app build with its own settings |
| Full-stack backup/restore test | Run `scripts/backup.sh` and `scripts/restore.sh` against the whole Docker stack (only the database steps were tested) |

### Needs something from you first

| Item | What is needed |
|---|---|
| Android release build | Your production API domain (goes in `environment.apk-prod.ts`) |
| Test a real online payment | Cashfree sandbox keys, then one sandbox payment end to end |
| SMS sign-up check, SMS password reset, customer OTP | An SMS provider account (MSG91, Gupshup or Twilio) with a DLT-registered template |
| Email verification | An email provider (SES, SendGrid or similar) |
| Automatic UPI payment verification | A payment gateway account that collects money for vendors (Cashfree, Razorpay or PhonePe) |
| Printing straight to a printer (no print dialog) | Which printer model is used; likely needs a native Android plugin |
| Merge to `master` | Your go-ahead to open pull requests for `claude/magical-noether-ys2e87` |
