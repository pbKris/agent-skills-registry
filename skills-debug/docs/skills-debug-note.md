# Skills Debug Mode — Implementation Notes

**Source:** `re-strategy.md` (Strategi Integrasi Skills Real Engineer)  
**Mode:** `debug` (native Kilo Code)  
**Folder:** `.kilo/skills-debug/`

---

## 1. Skill Assignment per re-strategy.md

### 1.1 Core Debug Skills (from agent-files.manifest)

| Skill | Vendor | Source Path | Category | Invocation |
|-------|--------|-------------|----------|------------|
| `gotth-stack` | pbk | `pbk/skills/gotth-stack` | Workflow | Auto-invoked via implement / manual |
| `gotth-code-reviewer` | pbk | `pbk/skills/gotth-code-reviewer` | Code Review | `/gotth-code-reviewer` (user-invoked) |
| `golang-troubleshooting` | samber | `samber/skills/golang-troubleshooting` | Go Depth | Model-invoked (di dalam implement/debug) |
| `golang-safety` | samber | `samber/skills/golang-safety` | Go Depth | Model-invoked (di dalam implement/debug) |
| `golang-security` | samber | `samber/skills/golang-security` | Go Depth | Model-invoked (di dalam implement/debug) |

### 1.2 Additional Debug-Related Skills (from commands & workflow)

| Skill | Vendor | Source Path | Category | Invocation | Mode |
|-------|--------|-------------|----------|------------|------|
| `diagnosing-bugs` | matt | `matt/skills/engineering/diagnosing-bugs` | Engineering | `/diagnosing-bugs` (user-invoked) | debug |

**Note:** `diagnosing-bugs` appears in the commands table for debug mode but is not listed in the debug section of agent-files.manifest. It should be added to the manifest under `debug` mode for consistency.

---

## 2. Symlink Structure (Target)

```
.kilo/skills-debug/
├── gotth-stack -> ../../vendor/pbk/skills/gotth-stack
├── gotth-code-reviewer -> ../../vendor/pbk/skills/gotth-code-reviewer
├── golang-troubleshooting -> ../../vendor/samber/skills/golang-troubleshooting
├── golang-safety -> ../../vendor/samber/skills/golang-safety
└── golang-security -> ../../vendor/samber/skills/golang-security
```

**Total: 5 skills** (within 15-skill limit per mode)

---

## 3. Agent-Files.Manifest Entries (Required)

Add to `.kilo/agent-files.manifest` under `# ---- debug ----` section:

```manifest
# ---- debug ----
debug   pbk/skills/gotth-stack
debug   pbk/skills/gotth-code-reviewer
debug   samber/skills/golang-troubleshooting
debug   samber/skills/golang-safety
debug   samber/skills/golang-security
# ADD: matt skill for bug diagnosis workflow
debug   matt/skills/engineering/diagnosing-bugs
```

---

## 4. Commands for Debug Mode

Create in `.kilo/commands/`:

| Command File | Description | Skill Mapping |
|--------------|-------------|---------------|
| `diagnosing-bugs.md` | 6-fase bug diagnosis loop | matt/diagnosing-bugs |
| `gotth-code-reviewer.md` | GOTTH stack code review | pbk/gotth-code-reviewer |
| `golang-troubleshooting.md` | Go troubleshooting patterns | samber/golang-troubleshooting |
| `golang-safety.md` | Go safety practices | samber/golang-safety |
| `golang-security.md` | Go security hardening | samber/golang-security |

---

## 5. Workflow Integration

### 5.1 Debug Mode Entry Points

1. **User-invoked:** `/diagnosing-bugs` → starts 6-phase bug diagnosis loop (Matt)
2. **User-invoked:** `/gotth-code-reviewer` → GOTTH stack review (pbk)
3. **Model-invoked (during implement/debug):** Samber Go depth skills auto-triggered based on context:
   - `golang-troubleshooting` → when debugging runtime issues
   - `golang-safety` → when reviewing unsafe patterns
   - `golang-security` → when reviewing security-sensitive code

### 5.2 GOTTH Stack in Debug

The `gotth-stack` skill provides:
- Git convention enforcement
- Change manifest integration
- Consistent workflow for bug fix commits

Auto-invoked when `implement` runs in code mode, but available explicitly in debug for standalone bug fix sessions.

---

## 6. Conflict Guards (from re-strategy.md ADR-013)

### 6.1 Samber Go Depth Skills — Coexistence Rules

| Skill | Coexists With | Reason |
|-------|---------------|--------|
| `golang-troubleshooting` | All | Unique concern: debugging methodology |
| `golang-safety` | `spf13/fileflow-pathologize` | Different concern: general safety vs file ops cross-OS |
| `golang-security` | All | Unique concern: security hardening |

### 6.2 Rejected Overlaps (Debug Context)

- `matt/diagnosing-bugs` ≈ `samber/golang-troubleshooting` — **Both kept**: Matt provides workflow (6-phase loop), Samber provides Go-specific troubleshooting patterns. Complementary, not overlapping.

---

## 7. Symlinks-Agent-Files.sh Handling

The script already handles debug mode correctly:

```bash
# In symlinks-agent-files.sh:
for m in skills skills-system-designer skills-plan skills-code skills-debug skills-ask; do
  rm -rf "$m"; mkdir -p "$m"
done

# debug mode processing:
dest=skills-debug  # when mode == debug
```

No special handling needed for pbk/go wrapper in debug mode (not used in debug).

---

## 8. Rules for Debug Mode

No dedicated `rules-debug/` folder in current architecture. Debug mode inherits:
- `.kilo/rules/` (global)
- `.kilo/rules-code/code-philosophy.md` (if code-philosophy applies to debugging)

**Recommendation:** Create `.kilo/rules-debug/debug-philosophy.md` if debug-specific guidelines needed (e.g., "reproduce first, fix minimal, verify fix").

---

## 9. Implementation Checklist

| # | Task | Status |
|---|------|--------|
| 1 | Add `debug matt/skills/engineering/diagnosing-bugs` to agent-files.manifest | ⏳ |
| 2 | Run `.kilo/symlinks-agent-files.sh` to generate skills-debug/ symlinks | ⏳ |
| 3 | Create 5 command files in `.kilo/commands/` for debug skills | ⏳ |
| 4 | Verify debug mode loads 5 skills (within 15 limit) | ⏳ |
| 5 | Test `/diagnosing-bugs` workflow in debug mode | ⏳ |

---

## 10. Quick Reference

```
DEBUG MODE SKILLS (5 total)
├── pbk/gotth-stack              # Workflow + git convention + change manifest
├── pbk/gotth-code-reviewer      # GOTTH code review (user-invoked)
├── samber/golang-troubleshooting # Go debugging patterns (model-invoked)
├── samber/golang-safety         # Go safety patterns (model-invoked)
└── samber/golang-security       # Go security patterns (model-invoked)

COMMANDS (5)
├── /diagnosing-bugs             # Matt 6-phase bug diagnosis
├── /gotth-code-reviewer         # GOTTH review
├── /golang-troubleshooting      # Samber troubleshooting
├── /golang-safety               # Samber safety
└── /golang-security             # Samber security

VENDOR OWNERSHIP (Debug)
├── pbk: GOTTH stack, code reviewer, git convention
└── samber: Go troubleshooting, safety, security (depth skills)
```

---

## 11. Notes for Implementation

1. **Matt's diagnosing-bugs** is the primary workflow entry point for debug mode — user starts here
2. **Samber skills** are guardrails that activate contextually during debugging (not standalone workflows)
3. **GOTTH stack** provides commit hygiene for bug fixes (git-convention, change-manifest)
4. **No spf13 skills** in debug mode — spf13 concerns (architecture, release, CLI) not relevant to debugging
5. **No jetbrains/use-modern-go** in debug — syntax checking happens in code mode via global skill