#!/usr/bin/env bash
# Auto-discovers every Gemfile.lock in the repo and audits each against the
# ruby-advisory-db. Shipped paths block the PR; test/demo/example/blind-spot
# paths (and allow-listed advisories) are report-only. Writes a findings table
# to the PR check's Summary page.
#
# Kept in a script file (not inline in the workflow) so the Actions log stays
# clean — the step only echoes "bash .github/scripts/bundler-audit.sh".
set -uo pipefail

bundler-audit update >/dev/null 2>&1 || true   # refresh ruby-advisory-db

# Advisories explicitly downgraded to report-only (surfaced, won't block), each
# with a justification. Keep this list short and reviewed:
#  - CVE-2026-35611 / GHSA-h27x-rffw-24p4: addressable ReDoS. addressable is a
#    TEST-only gem (pulled in by webmock), never shipped to SDK consumers.
REPORT_ONLY_IDS="CVE-2026-35611 GHSA-h27x-rffw-24p4"

shipped_failed=0
printf '## 🔒 bundler-audit\n\n' >> "$GITHUB_STEP_SUMMARY"
while IFS= read -r lock; do
  dir=$(dirname "$lock")
  # Classify the directory: test/demo/example/blind-spot dirs => report-only.
  case "$dir" in
    *demo*|*example*|*e2e*|*fixture*|*sample*|*test*|*spec*) dir_mode=report-only ;;
    *) dir_mode=blocking ;;
  esac
  if out=$(cd "$dir" && bundler-audit check 2>&1); then
    printf -- '- ✅ `%s` — no known advisories\n' "$dir" >> "$GITHUB_STEP_SUMMARY"
    continue
  fi
  # Simple, actionable table on the PR check's Summary page.
  {
    printf '\n### `%s`\n\n' "$dir"
    printf '| Gem | Version | Severity | Advisory | Status | What to do |\n'
    printf '|-----|---------|----------|----------|--------|------------|\n'
  } >> "$GITHUB_STEP_SUMMARY"
  # Per-finding status (report-only if its dir is report-only OR its advisory id
  # is allow-listed). awk exits 1 if any finding blocks.
  if ! printf '%s\n' "$out" | awk -v dir_mode="$dir_mode" -v allow=" $REPORT_ONLY_IDS " '
    function flush(){ if(name=="")return; adv=(cve!=""?cve:ghsa);
      ro=(dir_mode=="report-only");
      if(index(allow," " cve " ")>0 || index(allow," " ghsa " ")>0) ro=1;
      status=ro?"🟡 report-only":"🔴 blocking";
      printf("| %s | %s | %s | [%s](%s) | %s | %s |\n",name,ver,crit,adv,url,status,sol) >> ENVIRON["GITHUB_STEP_SUMMARY"];
      if(ro) printf("::warning::%s %s (%s %s, report-only) — %s\n",name,ver,crit,adv,sol);
      else { printf("::error::%s %s (%s %s) — %s\n",name,ver,crit,adv,sol); blocking++ }
      name=ver=cve=ghsa=crit=url=sol="" }
    /^Name:/{flush();name=$2}
    /^Version:/{ver=$2} /^CVE:/{cve=$2} /^GHSA:/{ghsa=$2}
    /^Criticality:/{crit=$2} /^URL:/{url=$2}
    /^Solution:/{s=$0;sub(/^Solution: /,"",s);sol=s}
    END{flush(); exit (blocking>0?1:0)}
  '; then shipped_failed=1; fi
done < <(find . -name Gemfile.lock -not -path '*/vendor/*' -not -path '*/.git/*' | sort)
if [ "$shipped_failed" = 1 ]; then
  printf '\n> ❌ **Fix the 🔴 blocking gems above** (apply the "What to do" version, e.g. `bundle update <gem>`) before this PR can merge.\n' >> "$GITHUB_STEP_SUMMARY"
fi
exit $shipped_failed
