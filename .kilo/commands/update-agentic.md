# Update Skills Workflow Pipeline

## Trigger
- Manual execution via `/update-skills` command
- Automatic trigger on skill directory changes

## Pipeline Stages

### 1. Validation Stage
- Validate all skill directories have required `SKILL.md`
- Check `SKILL.md` frontmatter schema compliance
- Verify skill references exist (scripts, references, etc.)

### 2. Index Generation Stage
- Run `scripts/index-json-generator.py` to regenerate `skills/index.json`
- Validate generated JSON against schema
- Update `SKILLS-CATALOG.md` with latest skill list

### 3. Quality Checks Stage
- Lint all markdown files in skills/
- Check for broken internal links
- Validate code examples in skills compile/run

### 4. Documentation Sync Stage
- Update `README.md` skill count and categories
- Sync any cross-references between skills
- Regenerate table of contents if needed

### 5. Commit & Tag Stage
- Stage all changes: `skills/index.json`, `SKILLS-CATALOG.md`, `README.md`
- Create commit with message: `chore: update skills index and catalog`
- Tag release if version changed: `skills/v<version>`

### 6. Post-Update Actions
- Notify dependent repositories (if webhook configured)
- Update CDN cache (see `docs/note-propagasi-cdn.md`)
- Log update timestamp in `skills/.last-update`

## Error Handling
- On validation failure: stop pipeline, report errors
- On index generation failure: rollback changes, alert maintainer
- On commit failure: retry with force push if needed

## Manual Override
```bash
# Skip validation (emergency only)
/update-skills --skip-validation

# Force regenerate index only
/update-skills --index-only

# Dry run (no commits)
/update-skills --dry-run
```