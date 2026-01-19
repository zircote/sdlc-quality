---
# Image generation provider
# Options: svg, dalle-3, gemini, manual
provider: svg

# SVG-specific settings (only used when provider: svg)
# Options: minimal, geometric, illustrated
svg_style: minimal

# Dark mode support
# false = light mode only, true = dark mode only, both = generate both variants
dark_mode: false

# Output settings
output_path: .github/social-preview.svg
dimensions: 1280x640
include_text: true
colors: auto

# README infographic settings
infographic_output: .github/readme-infographic.svg
infographic_style: hybrid

# Upload to repository (requires gh CLI or GITHUB_TOKEN)
upload_to_repo: false
---

# GitHub Social Plugin Configuration

This configuration was created by `/github-social:setup` on 2026-01-19.

## Current Settings

| Setting     | Value     | Description                            |
| ----------- | --------- | -------------------------------------- |
| Provider    | `svg`     | Claude generates SVG graphics directly |
| SVG Style   | `minimal` | Clean design with 3-5 shapes           |
| Dark Mode   | `false`   | Light mode only                        |
| Auto-upload | `false`   | Manual upload required                 |

## Provider: SVG (Selected)

Claude generates clean, minimal SVG graphics directly. No API key required.

**Advantages:**

- Free - no API costs
- Instant - no network calls
- Editable - modify in any vector editor
- Small file size - typically 10-50KB
- Professional - predictable, consistent results

## SVG Style: Minimal (Selected)

Clean, simple design emphasizing the project name with subtle geometric accents:

- Maximum 3-5 shapes
- Generous whitespace
- Professional appearance
- Fast to render

## Available Commands

Generate social preview image:

```
/github-social:social-preview
```

Enhance README with badges and infographic:

```
/github-social:readme-enhance
```

Generate optimized repository metadata:

```
/github-social:repo-metadata
```

Run all github-social skills:

```
/github-social:all
```

## Command Overrides

Override any setting via natural language:

```
Generate a social preview with geometric style
Create a dark mode social preview
```

## Modifying Settings

Edit this file directly or run `/github-social:setup` again to reconfigure.

## Notes

- SVG files can be converted to PNG using any image editor if needed
- GitHub accepts both SVG and PNG for social previews (1280x640 recommended)
- Consider adding this file to `.gitignore` if you want to keep config private
