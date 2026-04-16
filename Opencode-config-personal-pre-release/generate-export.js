#!/usr/bin/env node
/**
 * generate-export.js
 * Regenerates the OpenCode export manifest from local folders.
 * 
 * Usage: node generate-export.js
 * 
 * Scans local folders and outputs:
 *   - data/agents.json
 *   - data/skills.json
 *   - data/mcp-env-annex.json
 *   - docs/agent-flow.md
 *   - docs/dupe-cleanup.md
 */

const fs = require('fs');
const path = require('path');

// === CONFIG ===
const CONFIG = {
  repoRoot: process.cwd(),
  opencodePath: 'C:\\Users\\ramos\\.config\\opencode',
  globalSkillsPath: 'C:\\Users\\ramos\\.agents\\skills',
  archivePath: 'C:\\Users\\ramos\\.config\\opencode\\.archive\\2026-04-11-token-reduction\\agents',
  activeAgents: [
    'bug-fix-coordinator', 'cc-implementor', 'cc-planner', 'cc-reviewer', 'cc-tester',
    'cheap-cloud-implementor', 'cost-tracking', 'docs-coordinator',
    'fb-implementor', 'fb-validator',
    'fc-implementor', 'fc-planner', 'fc-reviewer', 'fc-tester',
    'free-cloud-implementor-basic', 'free-cloud-implementor',
    'ideation-coordinator', 'media-interpreter', 'migration-coordinator',
    'mm-handoff-writer', 'mm-investigator', 'mm-planner', 'mm-researcher',
    'mm-reviewer', 'mm-router', 'mm-scene-tester', 'mm-test-writer',
    'multimodel-architect', 'qa-coordinator', 'security-coordinator',
    'test-writer', 'uiux-coordinator'
  ],
  archivedAgents: [
    'swarm-implementor', 'swarm-manager', 'swarm-planner',
    'swarm-reviewer', 'swarm-tester'
  ],
  notHooked: ['debug', 'local-implementor'],
  opencodeSkills: [
    'antivibe', 'context', 'context7', 'graphify',
    'ori-memory', 'smart-router-skill', 'task-management'
  ],
  globalSkills: [
    'caveman', 'caveman-commit', 'caveman-compress',
    'caveman-help', 'caveman-review', 'find-skills', 'ui-ux-pro-max'
  ],
  mcpEnv: {
    Godot: { GODOT_EXECUTABLE: 'C:\\Users\\ramos\\tools\\godot\\Godot_v4.6.1-stable_mono_win64.exe' },
    Codesight: { CMD: 'npx codesight --mcp' },
    Ori: { ORI_VAULT: 'C:\\Users\\ramos\\.ori-memory', ORI_BRIDGE: 'C:\\tmp\\ori-bridge\\dist\\index.js', VAULT_MOUNT: 'C:\\Users\\ramos\\.ori-memory' }
  }
};

// === HELPERS ===
function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function writeJson(filePath, data) {
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
}

function writeMd(filePath, content) {
  fs.writeFileSync(filePath, content, 'utf8');
}

// === MAIN ===
function main() {
  console.log('Regenerating OpenCode export...\n');

  const dataDir = path.join(CONFIG.repoRoot, 'data');
  const docsDir = path.join(CONFIG.repoRoot, 'docs');
  ensureDir(dataDir);
  ensureDir(docsDir);

  // 1) Generate agents.json
  const active = CONFIG.activeAgents.map(name => ({
    name,
    path: CONFIG.opencodePath + '\\agents\\' + name + '.md',
    status: 'active',
    origin: 'opencode'
  }));
  
  const archived = CONFIG.archivedAgents.map(name => ({
    name,
    archivedPath: CONFIG.archivePath + '\\' + name + '.md',
    note: 'Archived duplicate to prune active surface'
  }));
  
  const notHooked = CONFIG.notHooked.map(name => ({
    name,
    reason: name === 'debug' ? 'Auxiliary utility not integrated into MM-router flow' : 'Local helper not wired to pipeline stages'
  }));

  writeJson(path.join(dataDir, 'agents.json'), { active, archived, not_hooked: notHooked });
  console.log('Generated: data/agents.json');

  // 2) Generate skills.json
  const skills = [
    ...CONFIG.opencodeSkills.map(name => ({
      name,
      origin: 'opencode',
      path: CONFIG.opencodePath + '\\skills\\' + name,
      notes: getSkillNotes(name)
    })),
    ...CONFIG.globalSkills.map(name => ({
      name,
      origin: 'global',
      path: CONFIG.globalSkillsPath + '\\' + name,
      notes: getSkillNotes(name)
    }))
  ];
  
  writeJson(path.join(dataDir, 'skills.json'), skills);
  console.log('Generated: data/skills.json');

  // 3) Generate mcp-env-annex.json
  writeJson(path.join(dataDir, 'mcp-env-annex.json'), CONFIG.mcpEnv);
  console.log('Generated: data/mcp-env-annex.json');

  // 4) Generate agent-flow.md
  const agentFlow = '# Agent flow hierarchy rooted at MM-router\n\n' +
    'This document defines the canonical agent flow MM-router orchestrates.\n\n' +
    'MM-Router Phase 1: Research\n' +
    '- Hooked: mm-researcher\n' +
    'Phase 2: Investigate\n' +
    '- Hooked: mm-investigator\n' +
    'Phase 3: Handoff\n' +
    '- Hooked: multimodel-architect, mm-handoff-writer\n' +
    'Phase 4: Review\n' +
    '- Hooked: mm-reviewer\n' +
    'Phase 5: Implement\n' +
    '- Hooked: cc-implementor, fc-implementor, fb-implementor\n' +
    'Phase 6: Test\n' +
    '- Hooked: mm-scene-tester or mm-tester\n\n' +
    'Not-hooked: debug, local-implementor\n';
  writeMd(path.join(docsDir, 'agent-flow.md'), agentFlow);
  console.log('Generated: docs/agent-flow.md');

  // 5) Generate dupe-cleanup.md
  const dupeCleanup = '# Dupe-cleanup plan\n\n' +
    '- Prune active duplicates to single canonical source\n' +
    '- Preserve history in archived folder\n' +
    '- 32 active, 5 archived\n';
  writeMd(path.join(docsDir, 'dupe-cleanup.md'), dupeCleanup);
  console.log('Generated: docs/dupe-cleanup.md');

  console.log('\nExport regenerated. Commit changes.');
}

function getSkillNotes(name) {
  const notes = {
    antivibe: 'Anti-vibecoding learning framework',
    context: 'Context management',
    context7: 'Documentation-oriented context',
    graphify: 'Knowledge graph from code/docs',
    'ori-memory': 'Ori-memory MCP tools',
    'smart-router-skill': 'Smart routing behavior',
    'task-management': 'Task management toolkit',
    caveman: 'Ultra-efficient communication',
    'caveman-commit': 'Compact commit messages',
    'caveman-compress': 'Memory compression',
    'caveman-help': 'Caveman quick reference',
    'caveman-review': 'Ultra-compressed code review',
    'find-skills': 'Skill discovery',
    'ui-ux-pro-max': 'UI/UX design intelligence'
  };
  return notes[name] || '';
}

main();