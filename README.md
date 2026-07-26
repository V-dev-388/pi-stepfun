# pi-stepfun

[简体中文](./README.md) | [English](./README_EN.md)

[Pi Agent](https://pi.dev) 扩展，自动从 [StepFun 阶跃星辰](https://platform.stepfun.com) API 拉取所有可用模型并注册到 Pi。

## 支持的模型

| 模型 | 类型 | 推理 | 多模态 |
|------|------|------|--------|
| `step-3.7-flash` | Chat | ✅ | ✅ 图片 |
| `step-3.5-flash` | Chat | ✅ | - |
| `step-3.5-flash-2603` | Chat | ✅ | - |
| `step-router-v1` | Chat | ✅ | ✅ 图片 |
| `step-image-edit-2` | Image | - | ✅ |
| `stepaudio-2.5-chat` | Audio | - | - |
| `stepaudio-2.5-tts` | Audio | - | - |
| `stepaudio-2.5-asr` | Audio | - | - |
| `stepaudio-2.5-realtime` | Audio | - | - |

> StepFun 上线新模型后，扩展会在下次启动时自动拉取，无需手动更新。

## 安装

### 方式一：直接克隆

```bash
git clone https://github.com/V-dev-388/pi-stepfun.git ~/.pi/agent/extensions/stepfun
cd ~/.pi/agent/extensions/stepfun
```

### 方式二：软链接

```bash
mkdir -p ~/.pi/agent/extensions
ln -s ~/project/pi-stepfun ~/.pi/agent/extensions/stepfun
```

### 方式三：作为 Pi Package 安装

```bash
pi install git:github.com/V-dev-388/pi-stepfun
```

### 方式四：通过 npm 安装

```bash
pi install npm:@v_dev_338/pi-stepfun
```

## 配置 API Key

编辑 `src/index.ts`，把 `YOUR_STEPFUN_API_KEY` 替换为你的 StepFun API Key：

```typescript
const STEPFUN_API_KEY = "YOUR_STEPFUN_API_KEY";
```

或者在 `settings.json` 中通过环境变量引用：

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

## 使用

启动 Pi，扩展会自动加载并注册所有模型：

```bash
pi --model stepfun/step-3.7-flash
```

切换模型：

```
/model stepfun/step-3.5-flash
```

调整推理强度：

```bash
pi --thinking high --model stepfun/step-3.7-flash
```

支持 `off` / `minimal` / `low` / `medium` / `high` / `xhigh` / `max` 七档，全部映射到 StepFun 的 `low` / `medium` / `high` 三档。

## 手动刷新模型

```bash
pi update --models
```

## 原理

扩展在 Pi 启动时：

1. 调用 `GET https://api.stepfun.com/step_plan/v1/models` 获取全量模型列表
2. 根据模型 ID 前缀自动分类（推理/音频/图像/实时）并分配属性
3. 调用 `pi.registerProvider()` 注册到 Pi 的模型运行时

## 文件结构

```
pi-stepfun/
├── src/
│   └── index.ts              # Extension entry point
├── package.json              # Package metadata
├── README.md                 # Chinese documentation
└── README_EN.md              # English documentation
```

## License

MIT
