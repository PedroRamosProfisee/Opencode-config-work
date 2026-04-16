import { tool } from "@opencode-ai/plugin";
import * as fs from "fs";
import * as path from "path";

function sanitizeKey(key: string): string {
  const sanitized = key.replace(/[^a-zA-Z0-9_-]/g, "-").slice(0, 50);
  if (!sanitized) {
    throw new Error("Key is empty after sanitization");
  }
  return sanitized;
}

export default tool({
  description:
    "Read and write cross-agent scratchpad entries for swarm runs. Enables agents to share findings, decisions, and context with downstream agents.",
  args: {
    action: tool.schema
      .string()
      .describe(
        "The action to perform. Must be one of: write, read, or list"
      ),
    runId: tool.schema
      .string()
      .describe(
        "The swarm run ID to scope the scratchpad. Use 'default' if no specific run ID is available"
      ),
    key: tool.schema
      .string()
      .describe(
        "The entry key (required for write and read actions, use empty string for list)"
      ),
    content: tool.schema
      .string()
      .describe(
        "The content to write (required for write action, use empty string for read/list)"
      ),
  },
  async execute({ action, runId, key, content }) {
    try {
      // Runtime validation for action
      const validActions = ["write", "read", "list"];
      if (!validActions.includes(action)) {
        return JSON.stringify({
          success: false,
          message: `Invalid action '${action}'. Must be one of: ${validActions.join(", ")}`,
        });
      }

      if (!runId) {
        return JSON.stringify({
          success: false,
          message: "runId is required",
        });
      }

      if (action === "write") {
        if (!key) {
          return JSON.stringify({
            success: false,
            message: "Key is required for write action",
          });
        }
        if (!content) {
          return JSON.stringify({
            success: false,
            message: "Content is required for write action",
          });
        }

        const sanitizedKey = sanitizeKey(key);
        const scratchpadDir = path.join(
          ".swarm",
          "runs",
          runId,
          "scratchpad"
        );
        const filePath = path.join(scratchpadDir, `${sanitizedKey}.md`);

        fs.mkdirSync(scratchpadDir, { recursive: true });
        fs.writeFileSync(filePath, content, "utf-8");

        return JSON.stringify({
          success: true,
          path: filePath,
          message: `Written to scratchpad: ${key}`,
        });
      }

      if (action === "read") {
        if (!key) {
          return JSON.stringify({
            success: false,
            message:
              "Key is required for read action. Use 'list' to see available entries.",
          });
        }

        const sanitizedKey = sanitizeKey(key);
        const filePath = path.join(
          ".swarm",
          "runs",
          runId,
          "scratchpad",
          `${sanitizedKey}.md`
        );

        if (!fs.existsSync(filePath)) {
          return JSON.stringify({
            success: false,
            message: `Scratchpad entry '${key}' not found`,
          });
        }

        const fileContent = fs.readFileSync(filePath, "utf-8");
        return JSON.stringify({
          success: true,
          key,
          content: fileContent,
        });
      }

      if (action === "list") {
        const scratchpadDir = path.join(
          ".swarm",
          "runs",
          runId,
          "scratchpad"
        );

        if (!fs.existsSync(scratchpadDir)) {
          return JSON.stringify({
            success: true,
            entries: [],
            message: "No scratchpad entries yet",
          });
        }

        const files = fs
          .readdirSync(scratchpadDir)
          .filter((f: string) => f.endsWith(".md"));

        const entries = files.map((file: string) => {
          const entryKey = file.replace(/\.md$/, "");
          const fullPath = path.join(scratchpadDir, file);
          const fileContent = fs.readFileSync(fullPath, "utf-8");
          const firstLine = fileContent.split("\n")[0] || "";
          return { key: entryKey, preview: firstLine.slice(0, 120) };
        });

        return JSON.stringify({ success: true, entries });
      }

      return JSON.stringify({ success: false, message: "Unknown action" });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Unknown error occurred";
      return JSON.stringify({
        success: false,
        message: `Scratchpad error: ${message}`,
      });
    }
  },
});
