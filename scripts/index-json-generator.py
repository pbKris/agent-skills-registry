#!/usr/bin/env python3
import json, glob, os, re

root = "skills"
skills = []

for d in sorted(glob.glob(f"{root}/*/")):
    name = os.path.basename(os.path.normpath(d))
    skill_md = os.path.join(d, "SKILL.md")
    if not os.path.exists(skill_md):
        continue
    
    text = open(skill_md, encoding="utf-8").read()
    # ambil description dari frontmatter
    m = re.search(r'^description:\s*(.+)$', text, re.MULTILINE)
    desc = m.group(1).strip() if m else ""
    # potong biar ideal 120-250 char, Kilo max 1024
    desc = desc[:350]

    # list semua file yang mau di-publish (SKILL.md wajib)
    files = ["SKILL.md"]
    # kalau ada references/, assets/, scripts/ tambahin otomatis
    for extra in glob.glob(f"{d}/references/*"):
        if os.path.isfile(extra):
            files.append(os.path.relpath(extra, d))

    skills.append({
        "name": name,
        "description": desc,
        "files": files,
        "version": "1.0.0"
    })

with open(f"{root}/index.json", "w", encoding="utf-8") as out:
    json.dump({"skills": skills}, out, indent=2, ensure_ascii=False)
    out.write("\n")

print(f"Generated {root}/index.json with {len(skills)} skills")