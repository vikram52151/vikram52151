// k6 smoke load test - a small, steady load that fails the run when latency or errors exceed
// the thresholds. k6 exits with a non-zero code when a threshold fails, which fails the CI job.
//
// Run locally:   k6 run -e BASE_URL=http://localhost:8080 perf/smoke.js
// In CI:         the load-smoke job in .github/workflows/quality-gates.yml (needs a running environment)
//
// Thresholds are this kit's starting conventions, not a standard. Set them from your own SLOs and run
// against an environment of fixed size, otherwise results are too noisy to gate on. Start with the job
// as non-required and make it required once a few runs show stable numbers.

import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 5,
  duration: '1m',
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'], // milliseconds
    http_req_failed: ['rate<0.01'], // under 1% errors
    checks: ['rate>0.99'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

// Replace with your most important read endpoints. Do not point a load test at production.
const PATHS = ['/actuator/health'];

export default function () {
  for (const path of PATHS) {
    const res = http.get(`${BASE_URL}${path}`, { timeout: '10s' });
    check(res, { [`${path} returns 200`]: (r) => r.status === 200 });
  }
  sleep(1);
}
