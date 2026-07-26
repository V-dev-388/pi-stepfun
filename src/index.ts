/**
 * pi-stepfun — Pi Agent extension for StepFun 阶跃星辰
 *
 * Auto-fetches all available models from StepFun's /v1/models endpoint
 * and registers them as a provider in Pi at startup.
 *
 * Setup:
 *   1. Set your API key via environment variable STEPFUN_API_KEY
 *   2. Or replace the placeholder below with your key
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// =============================================================================
// API Key — prefer environment variable, fallback to placeholder
// =============================================================================

const STEPFUN_API_KEY = process.env.STEPFUN_API_KEY ?? "YOUR_STEPFUN_API_KEY";

if (STEPFUN_API_KEY === "YOUR_STEPFUN_API_KEY") {
	console.error("[pi-stepfun] Warning: STEPFUN_API_KEY env var not set. Using placeholder — API calls will fail.");
}

// =============================================================================
// Model Definitions
// =============================================================================

interface ModelDef {
	id: string;
	name: string;
	reasoning: boolean;
	input: string[];
	cost: { input: number; output: number; cacheRead: number; cacheWrite: number };
	contextWindow: number;
	maxTokens: number;
	thinkingLevelMap?: Record<string, string | null>;
}

/** Known chat/reasoning models with full property definitions */
const CHAT_MODELS: Record<string, ModelDef> = {
	"step-3.7-flash": {
		id: "step-3.7-flash",
		name: "Step 3.7 Flash",
		reasoning: true,
		input: ["text", "image"],
		cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
		contextWindow: 256000,
		maxTokens: 8192,
		thinkingLevelMap: {
			minimal: "low",
			low: "low",
			medium: "medium",
			high: "high",
			xhigh: "high",
			max: "high",
		},
	},
	"step-3.5-flash": {
		id: "step-3.5-flash",
		name: "Step 3.5 Flash",
		reasoning: true,
		input: ["text"],
		cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
		contextWindow: 128000,
		maxTokens: 8192,
		thinkingLevelMap: {
			minimal: "low",
			low: "low",
			medium: "medium",
			high: "high",
			xhigh: "high",
			max: "high",
		},
	},
	"step-3.5-flash-2603": {
		id: "step-3.5-flash-2603",
		name: "Step 3.5 Flash 2603",
		reasoning: true,
		input: ["text"],
		cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
		contextWindow: 128000,
		maxTokens: 8192,
		thinkingLevelMap: {
			minimal: "low",
			low: "low",
			medium: "medium",
			high: "high",
			xhigh: "high",
			max: "high",
		},
	},
	"step-router-v1": {
		id: "step-router-v1",
		name: "Step Router V1",
		reasoning: true,
		input: ["text", "image"],
		cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
		contextWindow: 128000,
		maxTokens: 8192,
		thinkingLevelMap: {
			minimal: "low",
			low: "low",
			medium: "medium",
			high: "high",
			xhigh: "high",
			max: "high",
		},
	},
};

/** Default properties for models fetched from the API but not in CHAT_MODELS */
const DEFAULT_MODEL_DEF: Omit<ModelDef, "id" | "name"> = {
	reasoning: false,
	input: ["text"],
	cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
	contextWindow: 128000,
	maxTokens: 4096,
};

// =============================================================================
// Model Classification
// =============================================================================

function classifyModel(modelId: string): ModelDef | null {
	if (CHAT_MODELS[modelId])
		return CHAT_MODELS[modelId];

	const def: ModelDef = {
		id: modelId,
		name: formatModelName(modelId),
		...DEFAULT_MODEL_DEF,
	};

	if (modelId.includes("realtime")) {
		def.input = ["text"];
	}
	else if (modelId.includes("stepaudio") || modelId.includes("tts") || modelId.includes("asr")) {
		def.input = ["text"];
	}
	else if (modelId.includes("step-image")) {
		def.input = ["text", "image"];
	}

	return def;
}

function formatModelName(modelId: string): string {
	return modelId
		.replace(/-/g, " ")
		.replace(/\b\w/g, (c) => c.toUpperCase());
}

// =============================================================================
// Extension Entry Point
// =============================================================================

export default async function stepfunExtension(pi: ExtensionAPI): Promise<void> {
	try {
		const response = await fetch("https://api.stepfun.com/step_plan/v1/models", {
			headers: {
				Authorization: `Bearer ${STEPFUN_API_KEY}`,
			},
		});

		if (!response.ok) {
			console.error(`[pi-stepfun] Failed to fetch models: ${response.status} ${response.statusText}`);
			return;
		}

		const data = (await response.json()) as { data: Array<{ id: string }> };
		const models: ModelDef[] = [];

		for (const m of data.data) {
			const def = classifyModel(m.id);
			if (def)
				models.push(def);
		}

		if (models.length === 0) {
			console.error("[pi-stepfun] No compatible models found");
			return;
		}

		pi.registerProvider("stepfun", {
			name: "StepFun 阶跃星辰",
			baseUrl: "https://api.stepfun.com/step_plan/v1",
			apiKey: STEPFUN_API_KEY,
			api: "openai-completions",
			compat: {
				supportsReasoningEffort: true,
				maxTokensField: "max_tokens",
				supportsDeveloperRole: false,
			},
			models: models.map(({ id, name, reasoning, input, cost, contextWindow, maxTokens, thinkingLevelMap }) => ({
				id,
				name,
				reasoning,
				input: input as ("text" | "image")[],
				cost,
				contextWindow,
				maxTokens,
				...(thinkingLevelMap ? { thinkingLevelMap } : {}),
			})),
		});

		console.error(`[pi-stepfun] Registered ${models.length} model(s): ${models.map((m) => m.id).join(", ")}`);
	} catch (error) {
		console.error("[pi-stepfun] Extension error:", error instanceof Error ? error.message : String(error));
	}
}
