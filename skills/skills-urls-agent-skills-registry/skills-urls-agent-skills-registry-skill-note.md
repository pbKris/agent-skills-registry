Berdasarkan docs Kilo, `skills.urls` itu solusi buat kamu yang mau bikin 1 repo `agent-skills-registry` sebagai central source, tanpa `ln -s` atau `cp -R` manual.

### Cara kerja di docs

Di `kilo.jsonc` kamu bisa deklarasi:

```jsonc
{
  "skills": {
    "paths": ["/path/to/shared/skills", "~/my-skills"],
    "urls": ["https://example.com/.well-known/skills/"]
  }
}
```

> The `skills.paths` key accepts absolute paths... The `skills.urls` key accepts URLs to remote skill directories that serve an `index.json` manifest.

> The remote server must serve an `index.json` file at the URL path

Isinya:

```json
{
  "skills": [
    { "name": "skill-name", "files": ["SKILL.md", "references/file.md"] }
  ]
}
```


Fix di docs terbaru diperjelas:

> correct URL format (`https://example.com/.well-known/skills/`) and added documentation explaining the required `index.json` manifest structure with `name`, `description`, and `files` fields. Files are downloaded from `{url}/{skill-name}/{file}` paths

Flow-nya:
> By pointing `skills.urls` in `kilo.jsonc` to the parent folder containing `index.json`... Kilo will: Fetch the remote `index.json` manifest. Download and namespace each listed skill into its own cache subfolder under `~/.cache/kilo/skills/<plugin-name>/`.

Prioritas: remote URL itu paling rendah:

> Kilo discovers skills from... additional local paths via `skills.paths` in `kilo.jsonc`, and **remote URLs** via `skills.urls` in `kilo.jsonc` (lowest priority).

Dan remote = untrusted, jadi ``!`command` `` di `SKILL.md` **tidak akan dieksekusi**. Ini beda sama `~/.kilo/skills/` yang trusted.

### Solusi `agent-skills-registry` repo

**1. Struktur repo yang Kilo pahami**

Paling simpel pakai `raw.githubusercontent.com`:

```
agent-skills-registry/
└── skills/
    ├── index.json
    ├── my-frontend/
    │ └── SKILL.md # name: my-frontend
    ├── api-design/
    │ └── SKILL.md
    └── typescript-patterns/
        ├── SKILL.md
        └── references/
            └── patterns.md
```

`index.json` versi minimal yang valid buat Kilo:

```json
{
  "skills": [
    {
      "name": "my-frontend",
      "description": "Frontend design guidelines",
      "files": ["SKILL.md"]
    },
    {
      "name": "typescript-patterns",
      "description": "TS patterns for Code mode",
      "version": "1.0.1",
      "files": ["SKILL.md", "references/patterns.md"]
    }
  ]
}
```

Field `version` opsional tapi penting:
> Kilo re-fetches automatically whenever a skill's version changes

**2. Config di Kilo**

Di global config `~/.config/kilo/kilo.jsonc` biar trusted:

```jsonc
{
  "skills": {
    "urls": [
      "https://raw.githubusercontent.com/username/agent-skills-registry/main/skills"
    ]
  }
}
```

Contoh real dari komunitas:
> `"urls": ["https://raw.githubusercontent.com/xhighhongo41/agent-skills/main/skills"]` — OpenCode reads `index.json` from that directory

> `{ "skills": { "urls": ["https://raw.githubusercontent.com/vivantel/kms/master/plugins/kms/skills"] } }`

**PENTING:** URL harus ke folder yang berisi `index.json`, bukan ke file `index.json` itu sendiri, dan harus pakai trailing `/` tidak? Docs pakai trailing `/`. Dan file diambil dari `{url}/{skill-name}/{file}` jadi pastikan folder skill namanya sama persis dengan `name:`.

Ini memvalidasi poin ke-3 kamu kemarin:
> `name` field **must match** parent directory name.

**3. Gimana handle `skills-code/` dan `skills-plan/` per mode?**

Docs resmi `skills.urls` tidak support mode-specific secara native. Mode-specific hanya didokumentasikan untuk path lokal `skills-{mode-slug}`:

> `mkdir -p ~/.kilocode/skills-code/typescript-patterns`... The directory naming pattern is `skills-{mode-slug}` where `{mode-slug}` matches the mode's identifier

Solusi praktis dengan registry:

**Opsi A - tetap generic:** Bikin semua skill generic di registry, tapi di `description` tulis `Use in code mode only`. Agent LLM akan pick berdasarkan description, bukan folder.

**Opsi B - registry terpisah per mode (yang kamu mau):**
```
skills/
  index.json // generic
skills-code/
  index.json
skills-plan/
  index.json
```

Lalu di `kilo.jsonc`:

```jsonc
{
  "skills": {
    "urls": [
      "https://raw.githubusercontent.com/username/agent-skills-registry/main/skills",
      "https://raw.githubusercontent.com/username/agent-skills-registry/main/skills-code",
      "https://raw.githubusercontent.com/username/agent-skills-registry/main/skills-plan"
    ]
  }
}
```

Kilo akan merge semua. Kamu tetap butuh script lokal kalau mau symlink ke `~/.kilo/skills-code/` biar mode-specific beneran ter-filter, tapi untuk distribusi tim, `urls` sudah cukup.

**4. Script generator `index.json`**

Biar gak manual:

```bash
#!/bin/bash
cd skills
echo '{ "skills": [' > index.json
first=1
for d in */; do
  name=$(basename $d)
  desc=$(grep -m1 "description:" $d/SKILL.md | sed 's/description: //')
  [ $first -eq 0 ] && echo "," >> index.json
  first=0
  echo " {\"name\": \"$name\", \"description\": \"$desc\", \"files\": [\"SKILL.md\"]}" >> index.json
done
echo '] }' >> index.json
```

Push ke `main`, bump `version` di entry yang berubah, Kilo akan auto re-fetch cache.

Verifikasi: buka Kilo, tanya `What skills do you have available?` — itu cara resmi docs buat cek skill ke-load.