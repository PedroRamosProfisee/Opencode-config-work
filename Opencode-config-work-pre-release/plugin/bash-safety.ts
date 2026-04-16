import { tool } from "@opencode-ai/plugin";

const HIGH_RISK: { pattern: RegExp; description: string }[] = [
  { pattern: /rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?(-[a-zA-Z]*r[a-zA-Z]*\s+)?(\/|~|\.\s)/, description: "Recursive delete of root, home, or current directory" },
  { pattern: /:\(\)\{\s*:\|:\&\s*\};:/, description: "Fork bomb" },
  { pattern: /curl\s+.*\|\s*(ba)?sh/, description: "Pipe curl to shell (remote code execution)" },
  { pattern: /wget\s+.*\|\s*(ba)?sh/, description: "Pipe wget to shell (remote code execution)" },
  { pattern: />\s*\/dev\/sd[a-z]/, description: "Direct write to disk device" },
  { pattern: /\bdd\s+if=/, description: "Low-level disk copy (dd)" },
  { pattern: /\bmkfs\b/, description: "Format filesystem" },
  { pattern: /\bformat\s+[A-Z]:/, description: "Format drive (Windows)" },
  { pattern: /export\s+PATH\s*=\s*$/, description: "Nuke PATH variable" },
  { pattern: /unset\s+PATH/, description: "Unset PATH variable" },
  { pattern: /Remove-Item\s+.*-Recurse.*-Force.*[\/\\]$/, description: "PowerShell recursive force delete root" },
];

const MEDIUM_RISK: { pattern: RegExp; description: string }[] = [
  { pattern: /\bsudo\s+/, description: "Elevated privilege execution (sudo)" },
  { pattern: /history\s+(-c|-w|-d)/, description: "Shell history manipulation" },
  { pattern: /chmod\s+777/, description: "Overly permissive file permissions" },
  { pattern: /\beval\s+/, description: "Dynamic command evaluation" },
  { pattern: /Invoke-Expression/, description: "PowerShell dynamic execution" },
  { pattern: /git\s+push\s+.*--force/, description: "Force push (rewrites remote history)" },
  { pattern: /\b(cat|echo|type)\b.*\.(env|pem|key|secrets)/, description: "Exposing sensitive files" },
  { pattern: /Set-ExecutionPolicy\s+(Unrestricted|Bypass)/, description: "PowerShell execution policy bypass" },
  { pattern: /reg\s+delete/i, description: "Windows registry deletion" },
  { pattern: /\bchown\s+-R\s+.*\s+\//, description: "Recursive ownership change from root" },
];

const LOW_RISK: { pattern: RegExp; description: string }[] = [
  { pattern: /git\s+reset\s+--hard/, description: "Hard reset discards uncommitted changes" },
  { pattern: /npm\s+publish/, description: "Publishing npm package" },
  { pattern: /dotnet\s+nuget\s+push/, description: "Publishing NuGet package" },
  { pattern: /git\s+clean\s+-[a-zA-Z]*f/, description: "Force clean untracked files" },
  { pattern: /\bgit\s+stash\s+drop/, description: "Dropping stashed changes" },
];

export default tool({
  description: "Analyze a bash/shell command for dangerous patterns before execution. Returns risk level and specific issues found.",
  args: {
    command: tool.schema.string().describe("The bash/shell command to analyze for safety"),
  },
  async execute({ command }) {
    const issues: { risk: string; description: string }[] = [];

    for (const entry of HIGH_RISK) {
      if (entry.pattern.test(command)) {
        issues.push({ risk: "HIGH", description: entry.description });
      }
    }

    for (const entry of MEDIUM_RISK) {
      if (entry.pattern.test(command)) {
        issues.push({ risk: "MEDIUM", description: entry.description });
      }
    }

    for (const entry of LOW_RISK) {
      if (entry.pattern.test(command)) {
        issues.push({ risk: "LOW", description: entry.description });
      }
    }

    let highestRisk = "NONE";
    if (issues.some((i) => i.risk === "HIGH")) {
      highestRisk = "HIGH";
    } else if (issues.some((i) => i.risk === "MEDIUM")) {
      highestRisk = "MEDIUM";
    } else if (issues.some((i) => i.risk === "LOW")) {
      highestRisk = "LOW";
    }

    let recommendation: string;
    switch (highestRisk) {
      case "HIGH":
        recommendation = "BLOCK: Do not execute";
        break;
      case "MEDIUM":
        recommendation = "WARN: Explain risk to user and get confirmation";
        break;
      case "LOW":
        recommendation = "CAUTION: Proceed with note to user";
        break;
      default:
        recommendation = "OK: Command appears safe";
        break;
    }

    return JSON.stringify({
      safe: highestRisk !== "HIGH",
      risk: highestRisk,
      issues: issues.map((i) => i.description),
      recommendation,
    });
  },
});
