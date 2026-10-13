# FIXES and traceability log

One line per requirement, bug fix or behaviour change, newest first. It lets anyone answer
"which test proves this requirement?" and "why did this code change?" without digging through history.

- **Requirement / issue**: the issue ID or a short quote of the requirement.
- **Change**: one short sentence.
- **Commit**: SHA once committed (write `uncommitted` until then, and update it after committing).
- **Test(s)**: the test class and method or spec name that would fail if the change were reverted.
  For bug fixes, the test that failed before the fix.

| Date | Requirement / issue | Change | Commit | Test(s) |
|---|---|---|---|---|
| 2026-01-01 | EXAMPLE-12: order total ignores discount | Apply discount before tax in `OrderService.total()` | abc1234 | `OrderServiceTest#totalAppliesDiscountBeforeTax` |
