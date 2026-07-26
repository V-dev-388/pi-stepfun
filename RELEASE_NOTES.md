# Release Notes

## 1.0.0 - 2026-07-26

### Added
- Auto-discovery of all StepFun models via `GET https://api.stepfun.com/step_plan/v1/models`
- Model classification by prefix: chat/reasoning, audio, image, realtime
- Provider registration via `pi.registerProvider()`
- Thinking level mapping: `off` / `minimal` / `low` / `medium` / `high` / `xhigh` / `max` -> StepFun `low` / `medium` / `high`
- Bilingual documentation: Chinese (`README.md`) and English (`README_EN.md`)
- Pi Package manifest in `package.json` (`pi.extensions`)
- npm package metadata for publishing as `@V-dev-388/pi-stepfun`

### Installation

```bash
# Git
pi install git:github.com/V-dev-388/pi-stepfun

# npm
pi install npm:@V-dev-388/pi-stepfun
```

### Notes
- Requires `STEPFUN_API_KEY` environment variable or manual config in `src/index.ts`
- Compatible with `@earendil-works/pi-coding-agent` `*` peer dependency
- Licensed under MIT
