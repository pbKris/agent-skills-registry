# Skills Ask Mode — Implementation Notes

**Source:** `re-strategy.md` (Strategi Integrasi Skills Real Engineer)  
**Mode:** `ask` (native Kilo Code)  
**Folder:** `.kilo/skills-ask/`

---

## 1. Skill Assignment per re-strategy.md

### 1.1 Core Ask Skills (from agent-files.manifest & Table 2.1)

| Skill | Vendor | Source Path | Category | Invocation |
|-------|--------|-------------|----------|------------|
| `ask-matt` | matt | `matt/skills/ask-matt` | Navigation | `/ask-matt` (user-invoked, router) |
| `grill-me` | matt | `matt/skills/grill-me` | Engineering | `/grill-me` (user-invoked) |
| `handoff` | matt | `matt/skills/handoff` | Context Mgmt | `/handoff` (user-invoked) |
| `wait-what` | matt | `matt/skills/wait-what` | Context Mgmt | `/wait-what` (user-invoked) |

**Note:** Per Table 2.1 (Mapping Mode → Matt Skills), ask mode uses: `ask-matt` (router), `grill-me`, `handoff`, `wait-what` for "Navigasi & context mgmt".

---

## 2. Symlink Structure (Target)

```
.kilo/skills-ask/
├── ask-matt -> ../../vendor/matt/skills/ask-matt
├── grill-me -> ../../vendor/matt/skills/grill-me
├── handoff -> ../../vendor/matt/skills/handoff
└── wait-what -> ../../vendor/matt/skills/wait-what
```

**Total: 4 skills** (well within 15-skill limit per mode)

---

## 3. Agent-Files.Manifest Entries (Current)

Already present in `.kilo/agent-files.manifest` under `# ---- ask ----`:

```manifest
# ---- ask ----
ask     matt/skills/ask-matt
ask     matt/skills/grill-me
ask     matt/skills/handoff
ask     matt/skills/wait-what
```

---

## 4. Commands for Ask Mode

Create in `.kilo/commands/` (from commands table Section 8):

| Command File | Description | Skill Mapping |
|--------------|-------------|---------------|
| `ask-matt.md` | Router untuk repo Matt Pocock skills | matt/ask-matt |
| `grill-me.md` | Interactive grilling session (user-driven) | matt/grill-me |
| `handoff.md` | Context handoff between sessions/agents | matt/handoff |
| `wait-what.md` | Context recovery / session summary | matt/wait-what |
| `retro.md` | Suggest repo improvements (from commands table) | matt/retro (if exists) |

**Note:** `retro.md` appears in the commands table (Section 8) mapped to ask mode but is not in the ask section of agent-files.manifest. Verify if `matt/skills/retro` exists or if this is a standalone command.

---

## 5. Workflow Integration

### 5.1 Ask Mode Entry Points

1. **`/ask-matt` (Router)** — Primary entry point. Routes user to appropriate Matt skill based on question/context. Use when unsure which skill to use.

2. **`/grill-me`** — User-driven grilling session. Unlike `grill-with-docs` (system-designer, for spec creation), this is for general Q&A, learning, exploration.

3. **`/handoff`** — Save/restore context between sessions. Critical for multi-session work. Outputs context snapshot for next session.

4. **`/wait-what`** — "What was I doing?" Context recovery. Summarizes current state, recent decisions, next steps.

5. **`/retro`** — Repository improvement suggestions. Run periodically to identify tech debt, process improvements.

### 5.2 Ask Mode Characteristics

- **No vendor pendukung** — Pure Matt Pocock skills for navigation/context
- **Read-only friendly** — Most ask skills don't require write permissions
- **Session management** — `handoff` + `wait-what` enable seamless multi-session workflows
- **Router pattern** — `ask-matt` reduces decision fatigue for users

---

## 6. Conflict Guards (from re-strategy.md ADR-013)

### 6.1 Rejected Overlaps (Ask Context)

From the "ditolak" section of agent-files.manifest:

```manifest
# matt/grill-me               # sejenis grilling/grill-with-docs
# matt/ask-matt               # router repo matt penuh
```

**Resolution in re-strategy.md:**
- `grill-me` **KEPT** in ask mode — different purpose: user-driven Q&A vs `grill-with-docs` (system-designer, spec creation workflow)
- `ask-matt` **KEPT** in ask mode — router for Matt's skill ecosystem, not full repo router

**Key distinction:**
| Skill | Mode | Purpose |
|-------|------|---------|
| `grill-with-docs` | system-designer | Structured interview → domain model → spec artifacts |
| `grill-me` | ask | Ad-hoc Q&A, learning, exploration, no artifact output |
| `ask-matt` | ask | "Which Matt skill should I use?" router |

---

## 7. Symlinks-Agent-Files.sh Handling

The script handles ask mode correctly:

```bash
# In symlinks-agent-files.sh:
for m in skills skills-system-designer skills-plan skills-code skills-debug skills-ask; do
  rm -rf "$m"; mkdir -p "$m"
done

# ask mode processing:
dest=skills-ask  # when mode == ask
```

No special handling needed — all 4 skills are standard vendor/matt skills.

---

## 8. Rules for Ask Mode

No dedicated `rules-ask/` folder in current architecture. Ask mode inherits:
- `.kilo/rules/` (global)
- No mode-specific rules defined

**Recommendation:** If ask-specific guidelines needed (e.g., "always use ask-matt first for navigation"), create `.kilo/rules-ask/ask-philosophy.md`.

---

## 9. Implementation Checklist

| # | Task | Status |
|---|------|--------|
| 1 | Verify all 4 skills exist in `vendor/matt/skills/` | ⏳ |
| 2 | Run `.kilo/symlinks-agent-files.sh` to generate skills-ask/ symlinks | ⏳ |
| 3 | Create 4-5 command files in `.kilo/commands/` for ask skills | ⏳ |
| 4 | Verify ask mode loads 4 skills (within 15 limit) | ⏳ |
| 5 | Test `/ask-matt` router functionality | ⏳ |
| 6 | Test `/handoff` + `/wait-what` session continuity | ⏳ |

---

## 10. Quick Reference

```
ASK MODE SKILLS (4 total - ALL MATT)
├── matt/ask-matt       # Router: "Which skill should I use?"
├── matt/grill-me       # Ad-hoc Q&A, learning, exploration
├── matt/handoff        # Context save/restore between sessions
└── matt/wait-what      # Context recovery: "What was I doing?"

COMMANDS (4-5)
├── /ask-matt           # Router entry point
├── /grill-me           # Interactive grilling
├── /handoff            # Session handoff
├── /wait-what          # Context recovery
└── /retro              # Repo improvement suggestions (verify skill exists)

VENDOR OWNERSHIP (Ask)
└── matt: 100% — Navigation, context management, Q&A workflow
```

---

## 11. Usage Patterns

### 11.1 New User / New Repo
```
/ask-matt "Saya baru di repo ini, mau belajar workflow-nya"
→ Routes to: /setup-matt-pocock-skills (once) → /grill-me for Q&A
```

### 11.2 Multi-Session Work
```
Session 1: /handoff → saves context to .kilo/handoff-<timestamp>.md
Session 2: /wait-what → reads latest handoff, summarizes state
```

### 11.3 Skill Discovery
```
/ask-matt "Mau bikin spec tapi lupa command-nya"
→ Routes to: /grill-with-docs (system-designer mode)
```

### 11.4 Periodic Health Check
```
/retro → Analyzes repo, suggests improvements (tech debt, process, skills)
```

---

## 12. Notes for Implementation

1. **Pure Matt ecosystem** — Ask mode is the only mode with single-vendor (Matt) skills. Simplifies maintenance.

2. **Router is key** — `ask-matt` should be the default entry point for users unfamiliar with the skill system.

3. **Session continuity** — `handoff` + `wait-what` are differentiators for multi-session workflows. Ensure they work reliably.

4. **grill-me vs grill-with-docs** — Clear separation:
   - `grill-me` (ask): Conversational, no artifacts, learning/exploration
   - `grill-with-docs` (system-designer): Structured, produces GLOSSARY/ADR/SPEC

5. **retro command** — Verify if `matt/skills/retro` exists in vendor. If not, `retro.md` may be a standalone shell command not backed by a skill.

6. **No write permissions needed** — Ask skills are primarily read/analysis, making ask mode safe for any user.