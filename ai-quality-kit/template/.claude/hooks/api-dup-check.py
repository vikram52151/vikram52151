#!/usr/bin/env python3
"""api-dup-check.py - finds the same API built again and again for different regions (or outlets,
tenants, cities, statuses...) instead of one API that takes the region as a parameter.

What it flags
  1. Region copies: endpoints with the same HTTP method whose paths differ only by a region-like
     segment, e.g.  GET /api/india/orders  and  GET /api/us/orders
     (fix: one endpoint, GET /api/{region}/orders or GET /api/orders?region=IN).
  2. Near-identical siblings: endpoints whose paths differ by one literal segment and whose handler
     code is almost the same, e.g.  GET /orders/active  and  GET /orders/pending  with copied bodies
     (fix: GET /orders?status=active, one handler).
  3. Per-region classes and methods: OrderServiceIndia / OrderServiceUs, getIndiaOrders() /
     getUsOrders() (fix: one class or method; region differences in config or a strategy map).

Where it looks
  Spring (Java/Kotlin @RequestMapping/@GetMapping...), NestJS (@Controller/@Get...), Express-style
  routers (app.get('/x', ...), router.post(...)), frontend HTTP calls to '/api/...' URLs
  (this.http.get('/api/in/orders')), and OpenAPI/Swagger JSON files. Test files are skipped.

Scope and exit codes
  --base REV   only findings that touch files changed since REV (plus untracked files) fail the
               check; older findings are listed as "existing" for information.  exit 1 = new findings.
  --all        every finding fails the check.                                      exit 1 = findings.
  --files F..  only findings that touch these files fail (used right after an edit).
  --report-only  always exit 0.
  Internal errors never block: the script prints a note and exits 0.

Suppressing a finding (a human reviews it in the pull request)
  Put  api-dup-ok: <reason>  in a comment on or just above the endpoint, class or method,
  e.g.  // api-dup-ok: EU endpoint must stay separate for data-residency audit (ticket 123)

Settings (also readable from .claude/hooks/quality.conf through ai-gate.sh):
  --extra-words "mumbai delhi outlet7"   more region-like words for your domain
  --similarity 0.85                      how alike two handler bodies must be for rule 2
"""

import argparse
import difflib
import json
import os
import re
import subprocess
import sys

SKIP_DIRS = {
    ".git", "node_modules", "target", "build", "dist", "out", "coverage", "vendor", ".angular",
    ".gradle", ".idea", ".vscode", ".next", ".nuxt", "bin", "obj", "__pycache__", ".venv", "venv",
    "android", "ios", "www",
}
TEST_PATH_RE = re.compile(
    r"(^|/)(src/test|test|tests|__tests__|spec|e2e)/|(Test|Tests|IT|Spec)\.(java|kt)$|\.(spec|test)\.[cm]?[jt]sx?$"
)
SOURCE_EXT = (".java", ".kt", ".ts", ".tsx", ".js", ".mjs", ".cjs", ".jsx")
MAX_FILE_BYTES = 1_500_000

# Words that usually name a region, market, currency or locale. Extend with --extra-words.
DEFAULT_REGION_WORDS = """
india bharat in usa us america uk gb britain england eu europe asia apac emea amer latam mena gcc
uae ae sg singapore au australia nz ca canada de germany fr france jp japan cn china za africa
north south east west central northeast northwest southeast southwest northern southern eastern western
domestic international intl global local national regional
mumbai delhi newdelhi bangalore bengaluru chennai kolkata hyderabad pune ahmedabad jaipur lucknow
kochi surat indore nagpur chandigarh noida gurgaon gurugram
maharashtra karnataka tamilnadu kerala gujarat rajasthan telangana punjab bihar odisha goa
westbengal uttarpradesh madhyapradesh andhrapradesh haryana assam
inr usd eur gbp aed sgd aud cad jpy
""".split()
REGION_PATTERNS = [
    re.compile(r"^(zone|region|area|cluster|dc|shard|market|branch|outlet|store|city|state)[-_]?\d+$"),
    re.compile(r"^[a-z]{2}[-_][a-z]{2}$"),   # locale like en-in, en_us
    re.compile(r"^\d+$"),                    # hard-coded numeric ids in a path
]

HTTP_METHODS = ("GET", "POST", "PUT", "DELETE", "PATCH")
SUPPRESS_RE = re.compile(r"api-dup-ok")


def is_test_path(rel):
    return bool(TEST_PATH_RE.search(rel.replace(os.sep, "/")))


class Ctx:
    def __init__(self, words, similarity):
        self.words = set(w.lower() for w in words)
        self.similarity = similarity

    def is_region(self, segment):
        s = segment.lower()
        if s in self.words:
            return True
        return any(p.match(s) for p in REGION_PATTERNS)


class Endpoint:
    def __init__(self, method, path, rel, line, body, suppressed, kind):
        self.method = method
        self.path = path
        self.rel = rel
        self.line = line
        self.body = body
        self.suppressed = suppressed
        self.kind = kind  # "server", "client" or "spec"

    @property
    def where(self):
        return "%s:%d" % (self.rel, self.line)


# ------------------------------------------------------------------ small parsing helpers

def strip_comments_keep_lines(text):
    """Blank out // and /* */ comments but keep line numbers and string contents."""
    out = []
    i, n = 0, len(text)
    quote = None
    while i < n:
        c = text[i]
        if quote:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(text[i + 1])
                i += 2
                continue
            if c == quote:
                quote = None
            i += 1
            continue
        if c in "\"'`":
            quote = c
            out.append(c)
            i += 1
            continue
        if text.startswith("//", i):
            j = text.find("\n", i)
            j = n if j == -1 else j
            out.append(" " * (j - i))
            i = j
            continue
        if text.startswith("/*", i):
            j = text.find("*/", i + 2)
            j = n if j == -1 else j + 2
            out.append("".join(ch if ch == "\n" else " " for ch in text[i:j]))
            i = j
            continue
        out.append(c)
        i += 1
    return "".join(out)


def match_close(text, start, open_ch, close_ch):
    """Index just past the bracket that closes text[start] (which must be open_ch)."""
    depth = 0
    quote = None
    i, n = start, len(text)
    while i < n:
        c = text[i]
        if quote:
            if c == "\\":
                i += 2
                continue
            if c == quote:
                quote = None
        elif c in "\"'`":
            quote = c
        elif c == open_ch:
            depth += 1
        elif c == close_ch:
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return n


def line_of(text, pos):
    return text.count("\n", 0, pos) + 1


def string_literals(s):
    return [m.group(2) for m in re.finditer(r"([\"'`])((?:\\.|(?!\1).)*)\1", s)]


def mapping_paths(args):
    """Paths from the inside of @XxxMapping(...) / @Get(...): value=, path= or positional strings."""
    if args is None:
        return [""]
    m = re.search(r"\b(value|path)\s*=\s*", args)
    if m:
        rest = args[m.end():]
        nxt = re.search(r",\s*\w+\s*=", rest)
        seg = rest[: nxt.start()] if nxt else rest
        lits = string_literals(seg)
    else:
        first_named = re.search(r"\w+\s*=", args)
        seg = args[: first_named.start()] if first_named else args
        lits = string_literals(seg)
    return lits or [""]


def join_paths(prefix, path):
    p = "/" + "/".join(x for x in (prefix + "/" + path).split("/") if x)
    return p if p != "" else "/"


def suppressed_near(raw_lines, line, body):
    lo = max(0, line - 4)
    window = "\n".join(raw_lines[lo:line])
    return bool(SUPPRESS_RE.search(window) or SUPPRESS_RE.search(body or ""))


# ------------------------------------------------------------------ extractors

ANNOT_RE = re.compile(r"@(Get|Post|Put|Delete|Patch|Request)Mapping\b\s*(\()?")
CLASS_RE = re.compile(r"\b(class|interface|object)\s+([A-Za-z_]\w*)")
NEST_ANNOT_RE = re.compile(r"@(Get|Post|Put|Delete|Patch|All)\s*\(")
NEST_CTRL_RE = re.compile(r"@Controller\s*\(")
ROUTER_RE = re.compile(
    r"\b([A-Za-z_$][\w$]*)\s*\.\s*(get|post|put|delete|patch|all)\s*\(\s*([\"'`])(/[^\"'`]*)\3"
)
# HTTP client calls: any object calling a URL containing /api/, or an http/axios-style client calling
# a path that starts with / or with a base-URL variable (`${apiBase}/vendor/orders`).
CLIENT_RE = re.compile(
    r"(?:\b(http|httpClient|axios|api|apiClient|client|\$http)\s*)?\.\s*(get|post|put|delete|patch)\s*(?:<[^>()]*>)?"
    r"\s*\(\s*([\"'`])((?:\$\{[^}]*\})?/[^\"'`]*)\3"
)
ROUTER_OBJECTS = re.compile(r"^(app|router|server|api|fastify|routes?|\w*[Rr]outer|\w*[Aa]pp)$")


def spring_endpoints(rel, raw, text):
    eps = []
    raw_lines = raw.splitlines()
    classes = [(m.start(), m.group(2)) for m in CLASS_RE.finditer(text)]
    first_class = classes[0][0] if classes else len(text)
    prefix = ""
    annots = list(ANNOT_RE.finditer(text))
    for m in annots:
        args = None
        end = m.end()
        if m.group(2):
            close = match_close(text, m.end() - 1, "(", ")")
            args = text[m.end(): close - 1]
            end = close
        if m.start() < first_class and m.group(1) == "Request":
            prefix = (mapping_paths(args) or [""])[0]
            continue
        if m.group(1) == "Request":
            rm = re.findall(r"RequestMethod\.(\w+)", args or "")
            methods = [x.upper() for x in rm] or ["ANY"]
        else:
            methods = [m.group(1).upper()]
        # handler body: first '{' after the annotation (skipping the parameter list)
        brace = text.find("{", end)
        semi = text.find(";", end)
        body = ""
        if brace != -1 and (semi == -1 or brace < semi or text.rfind(")", end, brace) != -1):
            body = text[brace: match_close(text, brace, "{", "}")]
        line = line_of(text, m.start())
        sup = suppressed_near(raw_lines, line, body)
        for p in mapping_paths(args):
            for meth in methods:
                eps.append(Endpoint(meth, join_paths(prefix, p), rel, line, body, sup, "server"))
    return eps


def nest_endpoints(rel, raw, text):
    eps = []
    raw_lines = raw.splitlines()
    prefix = ""
    c = NEST_CTRL_RE.search(text)
    if c:
        close = match_close(text, c.end() - 1, "(", ")")
        lits = string_literals(text[c.end(): close - 1])
        prefix = lits[0] if lits else ""
    for m in NEST_ANNOT_RE.finditer(text):
        close = match_close(text, m.end() - 1, "(", ")")
        lits = string_literals(text[m.end(): close - 1]) or [""]
        brace = text.find("{", close)
        body = text[brace: match_close(text, brace, "{", "}")] if brace != -1 else ""
        line = line_of(text, m.start())
        sup = suppressed_near(raw_lines, line, body)
        meth = m.group(1).upper()
        meth = "ANY" if meth == "ALL" else meth
        for p in lits:
            eps.append(Endpoint(meth, join_paths(prefix, p), rel, line, body, sup, "server"))
    return eps


def router_endpoints(rel, raw, text):
    eps = []
    raw_lines = raw.splitlines()
    for m in ROUTER_RE.finditer(text):
        if not ROUTER_OBJECTS.match(m.group(1)):
            continue
        open_paren = text.find("(", m.start(2))
        call_end = match_close(text, open_paren, "(", ")")
        body = text[m.end(): call_end]
        line = line_of(text, m.start())
        meth = m.group(2).upper()
        meth = "ANY" if meth == "ALL" else meth
        eps.append(Endpoint(meth, join_paths("", m.group(4)), rel, line, body,
                            suppressed_near(raw_lines, line, body), "server"))
    return eps


def client_calls(rel, raw, text):
    eps = []
    raw_lines = raw.splitlines()
    for m in CLIENT_RE.finditer(text):
        url = m.group(4)
        if "/api/" in url:
            url = url[url.find("/api/"):]
        elif not m.group(1):
            continue   # not an http-style client and not an /api/ URL: probably not an HTTP call
        url = re.sub(r"^\$\{[^}]*\}", "", url)
        url = re.sub(r"\$\{[^}]*\}", "{}", url).split("?")[0]
        line = line_of(text, m.start())
        # the enclosing statement is a good enough "body" for similarity
        lo = text.rfind("\n", 0, max(0, m.start() - 300))
        hi = text.find(";", m.end())
        body = text[max(0, lo): hi if hi != -1 else m.end() + 300]
        eps.append(Endpoint(m.group(2).upper(), join_paths("", url), rel, line, body,
                            suppressed_near(raw_lines, line, ""), "client"))
    return eps


def openapi_endpoints(rel, raw):
    eps = []
    try:
        doc = json.loads(raw)
    except ValueError:
        return eps
    paths = doc.get("paths") if isinstance(doc, dict) else None
    if not isinstance(paths, dict):
        return eps
    for p, ops in paths.items():
        if not isinstance(ops, dict):
            continue
        for meth, op in ops.items():
            if meth.upper() not in HTTP_METHODS or not isinstance(op, dict):
                continue
            core = {k: v for k, v in op.items() if k not in ("summary", "description", "operationId", "tags")}
            body = json.dumps(core, sort_keys=True)
            sup = bool(SUPPRESS_RE.search(json.dumps(op)))
            eps.append(Endpoint(meth.upper(), join_paths("", p), rel, 1, body, sup, "spec"))
    return eps


# ------------------------------------------------------------------ class / method names

CAMEL_RE = re.compile(r"[A-Z]+(?=[A-Z][a-z]|\d|\b)|[A-Z]?[a-z]+|[A-Z]+|\d+")
# Line-anchored and without nested open-ended quantifiers, so it cannot backtrack across a file.
JAVA_METHOD_RE = re.compile(
    r"^[ \t]*(?:@\w+(?:\([^()\n]*\))?[ \t]+)*"
    r"(?:(?:public|protected|private|static|final|synchronized|abstract|default|native)[ \t]+)*"
    r"(?:<[^>\n]*>[ \t]+)?([\w.$]+(?:<[^()\n=;{}]*>)?(?:\[\])*)[ \t]+([a-z]\w*)[ \t]*\(",
    re.M,
)
KOTLIN_FUN_RE = re.compile(r"\bfun\s+(?:<[^>]*>\s*)?([a-z]\w*)\s*\(")
TS_METHOD_RE = re.compile(
    r"^[ \t]*(?:(?:public|private|protected|static|async|readonly)[ \t]+)*([a-z]\w*)[ \t]*\([^)]*\)[ \t]*(?::[^{=;\n]+)?\{",
    re.M,
)
TS_FUNC_RE = re.compile(r"\b(?:function\s+([a-z]\w*)|(?:const|let)\s+([a-z]\w*)\s*=\s*(?:async\s*)?\()")
NOT_METHODS = {"if", "for", "while", "switch", "catch", "return", "function", "constructor", "super", "new", "this"}
NOT_TYPES = {"return", "new", "throw", "else", "case", "yield", "await", "import", "package", "assert"}


def split_camel(name):
    return [t.lower() for t in CAMEL_RE.findall(name)]


def names_in(rel, raw, text):
    """(kind, name, line, suppressed) for classes and methods in a file."""
    out = []
    raw_lines = raw.splitlines()
    for m in CLASS_RE.finditer(text):
        ln = line_of(text, m.start())
        out.append(("class", m.group(2), ln, suppressed_near(raw_lines, ln, "")))
    if rel.endswith((".java",)):
        regexes = [JAVA_METHOD_RE]
    elif rel.endswith((".kt",)):
        regexes = [KOTLIN_FUN_RE]
    else:
        regexes = [TS_METHOD_RE, TS_FUNC_RE]
    for rx in regexes:
        for m in rx.finditer(text):
            if rx is JAVA_METHOD_RE:
                if m.group(1) in NOT_TYPES:
                    continue
                name = m.group(2)
            else:
                name = next((g for g in m.groups() if g), None)
            if not name or name in NOT_METHODS:
                continue
            ln = line_of(text, m.start())
            out.append(("method", name, ln, suppressed_near(raw_lines, ln, "")))
    return out


# ------------------------------------------------------------------ findings

def sort_where(items):
    def key(w):
        f, _, ln = w.rpartition(":")
        return (f, int(ln) if ln.isdigit() else 0)
    return sorted(items, key=key)


def norm_body(body, drop_words):
    b = re.sub(r"\s+", " ", body or "").strip()
    for w in drop_words:
        if w:
            b = re.sub(re.escape(w), "§", b, flags=re.I)
    return b[:4000]


def uses_value(value, body):
    """True when the handler hard-codes the value: "india", 'zone1', Status.ACTIVE, Region.IN..."""
    body = body or ""
    if re.search(r"[\"'`]%s[\"'`]" % re.escape(value), body, re.I):
        return True
    return len(value) >= 2 and bool(re.search(r"(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])" % re.escape(value.upper()), body)) \
        and value.upper() != value.lower()


def dispatches(value, body):
    """True when the handler calls a method named after the value: service.suspend(...)."""
    v = re.sub(r"[^A-Za-z0-9]", "", value)
    return bool(v) and bool(re.search(r"\.\s*%s\w*\s*\(" % re.escape(v), body or "", re.I))


def similar(a, b):
    return difflib.SequenceMatcher(None, a, b, autojunk=False).ratio()


def path_segments(path):
    segs = []
    for s in path.strip("/").split("/"):
        if not s:
            continue
        if (s.startswith("{") and s.endswith("}")) or s.startswith(":") or s == "{}" or s == "*":
            segs.append("{}")
        else:
            segs.append(s.lower())
    return segs


def find_route_findings(eps, ctx):
    findings = []
    seen_pairs = set()
    live = [e for e in eps if not e.suppressed]

    # rule 1: region copies
    groups = {}
    for e in live:
        segs = path_segments(e.path)
        key_segs = ["{region}" if (s != "{}" and ctx.is_region(s)) else s for s in segs]
        if "{region}" not in key_segs:
            continue
        key = (e.kind, e.method, "/" + "/".join(key_segs))
        groups.setdefault(key, []).append(e)
    for (kind, meth, shape), members in groups.items():
        literal = sorted(set(m.path for m in members))
        if len(literal) < 2:
            continue
        for a in members:
            for b in members:
                if a.path < b.path:
                    seen_pairs.add((a.where, b.where))
        what = "frontend calls" if kind == "client" else ("API spec paths" if kind == "spec" else "endpoints")
        findings.append({
            "rule": "region-copies",
            "title": "Same API repeated per region: %d %s %s differ only by a region-like segment" % (len(literal), meth, what),
            "locations": sort_where(set(m.where for m in members)),
            "detail": ", ".join(literal),
            "fix": "Use one %s %s and pass the region as a path variable or a query parameter "
                   "(?region=...). Keep region differences (prices, tax, timezone, features) in "
                   "configuration or a strategy map, not in copied code." % (meth, shape),
            "files": set(m.rel for m in members),
        })

    # rule 2: near-identical siblings differing by one literal segment
    buckets = {}
    for e in live:
        segs = path_segments(e.path)
        for i, s in enumerate(segs):
            if s == "{}":
                continue
            key = (e.kind, e.method, len(segs), i, tuple(segs[:i] + ["*"] + segs[i + 1:]))
            buckets.setdefault(key, []).append((s, e))
    for key, members in buckets.items():
        if len(set(s for s, _ in members)) < 2:
            continue
        for x in range(len(members)):
            for y in range(x + 1, len(members)):
                sa, a = members[x]
                sb, b = members[y]
                if sa == sb or a.where == b.where:
                    continue
                pair = tuple(sorted((a.where, b.where)))
                if pair in seen_pairs or (pair[1], pair[0]) in seen_pairs:
                    continue
                na, nb = norm_body(a.body, [sa, sb]), norm_body(b.body, [sa, sb])
                if not na or not nb:
                    continue
                # Flag only copies that hard-code their own path value ("active" -> Status.ACTIVE).
                # Generic copy-paste is left to CPD/jscpd; distinct actions that call their own method
                # (/suspend -> service.suspend(), /activate -> service.activate()) are fine.
                if not (uses_value(sa, a.body) and uses_value(sb, b.body)):
                    continue
                if dispatches(sa, a.body) and dispatches(sb, b.body):
                    continue
                score = similar(na, nb)
                if score < ctx.similarity:
                    continue
                seen_pairs.add(pair)
                raw_segs = [x for x in a.path.strip("/").split("/") if x]
                raw_segs[key[3]] = "{value}"
                shape = "/" + "/".join(raw_segs)
                findings.append({
                    "rule": "near-identical-siblings",
                    "title": "Two %s endpoints are %d%% the same and differ only by '%s' vs '%s'" % (
                        a.method, round(score * 100), sa, sb),
                    "locations": sort_where({a.where, b.where}),
                    "detail": "%s  vs  %s" % (a.path, b.path),
                    "fix": "Make one handler for %s %s (or a query parameter) and pass '%s'/'%s' as data. "
                           "Move shared logic into one service method." % (a.method, shape, sa, sb),
                    "files": {a.rel, b.rel},
                })
    return findings


def find_name_findings(names, ctx):
    findings = []
    groups = {}
    for rel, kind, name, line, sup in names:
        if sup:
            continue
        toks = split_camel(name)
        region = [t for t in toks if ctx.is_region(t)]
        if not region or len(toks) < 2:
            continue
        rest = tuple(t for t in toks if not ctx.is_region(t))
        if not rest:
            continue
        scope = "" if kind == "class" else rel   # methods: compare within the same file
        groups.setdefault((kind, scope, rest), []).append((rel, name, line))
    for (kind, scope, rest), members in groups.items():
        distinct = sorted(set(n for _, n, _ in members))
        if len(distinct) < 2:
            continue
        locs = sort_where(set("%s:%d" % (r, l) for r, _, l in members))
        base = "".join(t.capitalize() for t in rest)
        if kind == "method":
            base = base[0].lower() + base[1:]
        findings.append({
            "rule": "region-named-%s" % ("classes" if kind == "class" else "methods"),
            "title": "One %s per region: %s" % (kind, ", ".join(distinct)),
            "locations": locs,
            "detail": "",
            "fix": "Replace them with one %s (e.g. %s) that takes the region as a parameter; keep "
                   "per-region values in configuration or a Map<Region, Strategy>." % (kind, base),
            "files": set(r for r, _, _ in members),
        })
    return findings


# ------------------------------------------------------------------ main

def changed_files(root, base):
    try:
        diff = subprocess.run(["git", "diff", "--name-only", base, "--"], cwd=root,
                              capture_output=True, text=True, timeout=60)
        untracked = subprocess.run(["git", "ls-files", "--others", "--exclude-standard"], cwd=root,
                                   capture_output=True, text=True, timeout=60)
    except (OSError, subprocess.SubprocessError):
        return None
    if diff.returncode != 0:
        return None
    return set(x for x in (diff.stdout + "\n" + untracked.stdout).splitlines() if x)


def iter_files(root):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
        for f in filenames:
            full = os.path.join(dirpath, f)
            rel = os.path.relpath(full, root).replace(os.sep, "/")
            yield rel, full


def scan(root, ctx):
    eps, names = [], []
    server_lines = set()
    for rel, full in iter_files(root):
        low = rel.lower()
        is_spec = low.endswith(".json") and re.search(r"(openapi|swagger)[^/]*\.json$", low)
        if not (low.endswith(SOURCE_EXT) or is_spec):
            continue
        if is_test_path(rel) or low.endswith(".d.ts") or ".min." in low:
            continue
        try:
            if os.path.getsize(full) > MAX_FILE_BYTES:
                continue
            with open(full, encoding="utf-8", errors="replace") as fh:
                raw = fh.read()
        except OSError:
            continue
        if is_spec:
            eps.extend(openapi_endpoints(rel, raw))
            continue
        text = strip_comments_keep_lines(raw)
        if low.endswith((".java", ".kt")):
            if "Mapping" in text:
                eps.extend(spring_endpoints(rel, raw, text))
        else:
            if "@Controller" in text:
                eps.extend(nest_endpoints(rel, raw, text))
            routes = router_endpoints(rel, raw, text)
            eps.extend(routes)
            server_lines.update(e.where for e in routes)
            if "/api/" in text or "http" in text or "axios" in text:
                eps.extend(c for c in client_calls(rel, raw, text) if c.where not in server_lines)
        for kind, name, line, sup in names_in(rel, raw, text):
            names.append((rel, kind, name, line, sup))
    return eps, names


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--root", default=".")
    ap.add_argument("--base", help="git revision; only findings touching files changed since it fail")
    ap.add_argument("--all", action="store_true", help="every finding fails")
    ap.add_argument("--files", nargs="*", help="only findings touching these files fail")
    ap.add_argument("--extra-words", default="", help="extra region-like words, space separated")
    ap.add_argument("--similarity", type=float, default=0.85)
    ap.add_argument("--report-only", action="store_true")
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()

    root = os.path.abspath(a.root)
    words = DEFAULT_REGION_WORDS + [w for w in re.split(r"[\s,]+", a.extra_words) if w]
    ctx = Ctx(words, a.similarity)

    eps, names = scan(root, ctx)
    findings = find_route_findings(eps, ctx) + find_name_findings(names, ctx)

    scope = None   # None = everything counts
    scope_label = "all files"
    if a.files:
        scope = set()
        for f in a.files:
            p = os.path.relpath(os.path.abspath(f), root).replace(os.sep, "/")
            scope.add(p)
        scope_label = "the edited file(s)"
    elif a.base and not a.all:
        scope = changed_files(root, a.base)
        scope_label = "files changed since %s" % a.base[:12]
        if scope is None:
            print("api-dup-check: could not read git changes; checking all files.", file=sys.stderr)
            scope_label = "all files"

    new = [f for f in findings if scope is None or f["files"] & scope]
    old = [f for f in findings if f not in new]

    if a.json:
        def clean(f):
            return {k: (sorted(v) if isinstance(v, set) else v) for k, v in f.items()}
        print(json.dumps({"endpoints": len(eps), "new": [clean(f) for f in new],
                          "existing": [clean(f) for f in old]}, indent=2))
    else:
        print("API duplication check: %d endpoints/calls scanned; failing scope: %s." % (len(eps), scope_label))
        if not findings:
            print("No per-region copies or near-identical endpoints found.")
        for label, group in (("NEW", new), ("existing (not in this change)", old)):
            if not group:
                continue
            print("\n%s findings: %d" % (label, len(group)))
            for f in group:
                print("- [%s] %s" % (f["rule"], f["title"]))
                if f["detail"]:
                    print("    paths: %s" % f["detail"])
                print("    at:    %s" % ", ".join(f["locations"][:8]))
                print("    fix:   %s" % f["fix"])
        if new:
            print("\nIf a separate endpoint is genuinely required (legal, data residency, contract), a human "
                  "adds the comment 'api-dup-ok: <reason>' next to it; reviewers check the reason in the PR. "
                  "AI agents: fix the design or ask the human; do not add the comment yourself.")

    if a.report_only:
        return 0
    return 1 if new else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:  # never block on a bug in this script
        print("api-dup-check: skipped because of an internal error: %r" % (exc,), file=sys.stderr)
        sys.exit(0)
