# pi-stepfun

[简体中文](./README.md) | [English](./README_EN.md)

[Pi Agent](https://pi.dev) extension that auto-fetches all available models from [StepFun](https://platform.stepfun.com) API and registers them in Pi.

## Supported Models

| Model | Type | Reasoning | Multimodal |
|------|------|------|--------|
| `step-3.7-flash` | Chat | ✅ | ✅ Image |
| `step-3.5-flash` | Chat | ✅ | - |
| `step-3.5-flash-2603` | Chat | ✅ | - |
| `step-router-v1` | Chat | ✅ | ✅ Image |
| `step-image-edit-2` | Image | - | ✅ |
| `stepaudio-2.5-chat` | Audio | - | - |
| `stepaudio-2.5-tts` | Audio | - | - |
| `stepaudio-2.5-asr` | Audio | - | - |
| `stepaudio-2.5-realtime` | Audio | - | - |

> After StepFun releases new models, the extension will auto-fetch them on next startup. No manual update needed.

## Install

### Method 1: Clone

```bash
git clone https://github.com/V-dev-388/pi-stepfun.git ~/.pi/agent/extensions/stepfun
cd ~/.pi/agent/extensions/stepfun
```

### Method 2: Symlink

```bash
mkdir -p ~/.pi/agent/extensions
ln -s ~/project/pi-stepfun ~/.pi/agent/extensions/stepfun
```

## Configure API Key

Edit `src/index.ts` and replace `YOUR_STEPFUN_API_KEY` with your StepFun API Key:

```typescript
const STEPFUN_API_KEY = "YOUR_STEPFUN_API_KEY";
```

Or use an environment variable in `settings.json`:

```json
{
  "defaultProvider": "stepfun",
  "defaultModel": "step-3.7-flash"
}
```

```bash
export STEPFUN_API_KEY="your-key"
pi
```

## Usage

Start Pi; the extension will auto-load and register all models:

```bash
pi --model stepfun/step-3.7-flash
```

Switch models:

```
/model stepfun/step-3.5-flash
```

Adjust reasoning strength:

```bash
pi --thinking high --model stepfun/step-3.7-flash
```

Supports `off` / `minimal` / `low` / `medium` / `high` / `xhigh` / `max`, mapped to StepFun's `low` / `medium` / `high`.

## Manually Refresh Models

```bash
pi update --models
```

## How It Works

On Pi startup, the extension:

1. Calls `GET https://api.stepfun.com/step_plan/v1/models` to fetch the full model list
2. Classifies models by ID prefix and assigns properties
3. Calls `pi.registerProvider()` to register with Pi's model runtime

## File Structure

```
pi-stepfun/
├── src/
│   └── index.ts          # Extension entry point
├── package.json          # Package metadata
└── README.md             # Documentation
```

## License

MIT
