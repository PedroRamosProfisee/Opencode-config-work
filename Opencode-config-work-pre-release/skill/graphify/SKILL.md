---
name: graphify
description: Turn any folder of files (code, docs, papers, images) into a navigable knowledge graph with community detection, god nodes, and an honest audit trail. Load this skill when the user types /graphify or asks to build a knowledge graph from files.
---

# /graphify

Turn any folder of files into a navigable knowledge graph with community detection, an honest audit trail, and three outputs: interactive HTML, GraphRAG-ready JSON, and a plain-language `GRAPH_REPORT.md`.

Fully multimodal — accepts code, PDFs, markdown, screenshots, diagrams, whiteboard photos, even images in other languages. Claude vision extracts concepts from all of it and connects them into one graph.

## Usage

```
/graphify                                             # full pipeline on current directory
/graphify <path>                                      # full pipeline on specific path
/graphify <path> --mode deep                          # thorough extraction, richer INFERRED edges
/graphify <path> --update                             # incremental - re-extract only new/changed files
/graphify <path> --cluster-only                       # rerun clustering on existing graph
/graphify <path> --no-viz                             # skip visualization, just report + JSON
/graphify <path> --obsidian                           # also generate Obsidian vault (opt-in)
/graphify <path> --svg                                # also export graph.svg
/graphify <path> --graphml                            # export graph.graphml (Gephi, yEd)
/graphify <path> --neo4j                              # generate graphify-out/cypher.txt for Neo4j
/graphify <path> --neo4j-push bolt://localhost:7687   # push directly to Neo4j
/graphify <path> --mcp                                # start MCP stdio server for agent access
/graphify <path> --watch                              # watch folder, auto-rebuild on code changes
/graphify add <url>                                   # fetch URL, save to ./raw, update graph
/graphify add <url> --author "Name"                   # tag who wrote it
/graphify query "<question>"                          # BFS traversal - broad context
/graphify query "<question>" --dfs                    # DFS - trace a specific path
/graphify query "<question>" --budget 1500            # cap answer at N tokens
/graphify path "NodeA" "NodeB"                        # shortest path between two concepts
/graphify explain "ConceptName"                       # plain-language explanation of a node
```

## What graphify is for

Three things it does that reading files alone cannot:

1. **Persistent graph** — relationships stored in `graphify-out/graph.json` survive across sessions. Ask questions weeks later without re-reading everything.
2. **Honest audit trail** — every edge is tagged `EXTRACTED`, `INFERRED`, or `AMBIGUOUS`. You know what was found vs invented.
3. **Cross-document surprise** — community detection finds connections between concepts in different files you would never think to ask about directly.

Use it for:
- A codebase you're new to (understand architecture before touching anything)
- A reading list (papers + tweets + notes → one navigable graph)
- A research corpus (citation graph + concept graph in one)
- A personal `/raw` folder (drop everything in, let it grow, query it)

---

## What You Must Do When Invoked

If no path was given, use `.` (current directory). Do not ask the user for a path.

Follow these steps in order. Do not skip steps.

---

### Step 1 — Ensure graphify is installed

```bash
python3 -c "import graphify" 2>/dev/null || pip install graphifyy -q --break-system-packages 2>&1 | tail -3
```

If the import succeeds, print nothing and move straight to Step 2.

---

### Step 2 — Detect files

```bash
python3 -c "
import json
from graphify.detect import detect
from pathlib import Path
result = detect(Path('INPUT_PATH'))
print(json.dumps(result))
" > .graphify_detect.json
```

Replace `INPUT_PATH` with the actual path. Do NOT cat or print the JSON — read it silently and present a clean summary:

```
Corpus: X files · ~Y words
  code:     N files (.py .ts .go ...)
  docs:     N files (.md .txt ...)
  papers:   N files (.pdf ...)
  images:   N files
```

Then act on it:
- If `total_files` is 0: stop with "No supported files found in [path]."
- If `skipped_sensitive` is non-empty: mention file count skipped, not the file names.
- If `total_words` > 2,000,000 OR `total_files` > 200: show the warning and the top 5 subdirectories by file count, then ask which subfolder to run on. Wait for the user's answer before proceeding.
- Otherwise: proceed directly to Step 3.

---

### Step 3 — Extract entities and relationships

**Before starting:** note whether `--mode deep` was given. Pass `DEEP_MODE=true` to every subagent in Step B2 if it was.

Run Part A (AST) and Part B (semantic) **in parallel**. Dispatch all semantic subagents AND start AST extraction in the same message.

#### Part A — Structural extraction for code files

```bash
python3 -c "
import sys, json
from graphify.extract import collect_files, extract
from pathlib import Path
import json

code_files = []
detect = json.loads(Path('.graphify_detect.json').read_text())
for f in detect.get('files', {}).get('code', []):
    code_files.extend(collect_files(Path(f)) if Path(f).is_dir() else [Path(f)])

if code_files:
    result = extract(code_files)
    Path('.graphify_ast.json').write_text(json.dumps(result, indent=2))
    print(f'AST: {len(result[\"nodes\"])} nodes, {len(result[\"edges\"])} edges')
else:
    Path('.graphify_ast.json').write_text(json.dumps({'nodes':[],'edges':[],'input_tokens':0,'output_tokens':0}))
    print('No code files - skipping AST extraction')
"
```

#### Part B — Semantic extraction (parallel subagents)

**Fast path:** If detection found zero docs, papers, and images (code-only corpus), skip Part B entirely and go straight to Part C.

**MANDATORY: Use the Agent/Task tool here. Reading files one-by-one is forbidden — it is 5-10x slower.**

Before dispatching subagents, print a timing estimate:
- Load `total_words` and file counts from `.graphify_detect.json`
- Estimate agents needed: `ceil(uncached_non_code_files / 22)`
- Estimate time: ~45s per agent batch
- Print: `"Semantic extraction: ~N files → X agents, estimated ~Ys"`

**Step B0 — Check extraction cache**

```bash
python3 -c "
import json
from graphify.cache import check_semantic_cache
from pathlib import Path

detect = json.loads(Path('.graphify_detect.json').read_text())
all_files = [f for files in detect['files'].values() for f in files]

cached_nodes, cached_edges, cached_hyperedges, uncached = check_semantic_cache(all_files)

if cached_nodes or cached_edges or cached_hyperedges:
    Path('.graphify_cached.json').write_text(json.dumps({'nodes': cached_nodes, 'edges': cached_edges, 'hyperedges': cached_hyperedges}))
Path('.graphify_uncached.txt').write_text('\n'.join(uncached))
print(f'Cache: {len(all_files)-len(uncached)} files hit, {len(uncached)} files need extraction')
"
```

Only dispatch subagents for files in `.graphify_uncached.txt`. If all files are cached, skip to Part C.

**Step B1 — Split into chunks**

Load files from `.graphify_uncached.txt`. Split into chunks of 20–25 files. Each image file gets its own chunk.

**Step B2 — Dispatch ALL subagents in a single message**

Call the Agent/Task tool multiple times IN THE SAME RESPONSE — one call per chunk. This is the only way they run in parallel.

Each subagent receives this exact prompt (substitute `FILE_LIST`, `CHUNK_NUM`, `TOTAL_CHUNKS`, `DEEP_MODE`):

```
You are a graphify extraction subagent. Read the files listed and extract a knowledge graph fragment.
Output ONLY valid JSON matching the schema below - no explanation, no markdown fences, no preamble.

Files (chunk CHUNK_NUM of TOTAL_CHUNKS):
FILE_LIST

Rules:
- EXTRACTED: relationship explicit in source (import, call, citation, "see §3.2")
- INFERRED: reasonable inference (shared data structure, implied dependency)
- AMBIGUOUS: uncertain - flag for review, do not omit

Code files: focus on semantic edges AST cannot find (call relationships, shared data, arch patterns).
  Do not re-extract imports - AST already has those.
Doc/paper files: extract named concepts, entities, citations. Also extract rationale — sections that
  explain WHY a decision was made, trade-offs chosen, or design intent. These become nodes with
  `rationale_for` edges pointing to the concept they explain.
Image files: use vision to understand what the image IS - do not just OCR.
  UI screenshot: layout patterns, design decisions, key elements, purpose.
  Chart: metric, trend/insight, data source.
  Tweet/post: claim as node, author, concepts mentioned.
  Diagram: components and connections.
  Research figure: what it demonstrates, method, result.
  Handwritten/whiteboard: ideas and arrows, mark uncertain readings AMBIGUOUS.

DEEP_MODE (if --mode deep was given): be aggressive with INFERRED edges - indirect deps,
  shared assumptions, latent couplings. Mark uncertain ones AMBIGUOUS instead of omitting.

Semantic similarity: if two concepts solve the same problem without any structural link, add a
  `semantically_similar_to` edge marked INFERRED with a confidence_score (0.6-0.95). Only add
  these when the similarity is genuinely non-obvious and cross-cutting.

Hyperedges: if 3+ nodes clearly participate together in a shared concept/flow/pattern that pairwise
  edges cannot express, add a hyperedge to the top-level `hyperedges` array. Max 3 per chunk.

confidence_score is REQUIRED on every edge - never omit it, never use 0.5 as a default:
- EXTRACTED edges: confidence_score = 1.0 always
- INFERRED edges: reason individually. Direct evidence: 0.8-0.9. Reasonable inference: 0.6-0.7.
  Weak/speculative: 0.4-0.5.
- AMBIGUOUS edges: 0.1-0.3

Output exactly this JSON (no other text):
{"nodes":[{"id":"filestem_entityname","label":"Human Readable Name","file_type":"code|document|paper|image","source_file":"relative/path","source_location":null,"source_url":null,"captured_at":null,"author":null,"contributor":null}],"edges":[{"source":"node_id","target":"node_id","relation":"calls|implements|references|cites|conceptually_related_to|shares_data_with|semantically_similar_to|rationale_for","confidence":"EXTRACTED|INFERRED|AMBIGUOUS","confidence_score":1.0,"source_file":"relative/path","source_location":null,"weight":1.0}],"hyperedges":[{"id":"snake_case_id","label":"Human Readable Label","nodes":["node_id1","node_id2","node_id3"],"relation":"participate_in|implement|form","confidence":"EXTRACTED|INFERRED","confidence_score":0.75,"source_file":"relative/path"}],"input_tokens":0,"output_tokens":0}
```

**Step B3 — Collect, cache, and merge**

Wait for all subagents. For each result:
- Valid JSON with `nodes` and `edges`: include it and save to cache
- Failed or invalid JSON: print a warning and skip — do not abort
- If more than half the chunks failed: stop and tell the user

```bash
python3 -c "
import json
from graphify.cache import save_semantic_cache
from pathlib import Path

new = json.loads(Path('.graphify_semantic_new.json').read_text()) if Path('.graphify_semantic_new.json').exists() else {'nodes':[],'edges':[],'hyperedges':[]}
saved = save_semantic_cache(new.get('nodes', []), new.get('edges', []), new.get('hyperedges', []))
print(f'Cached {saved} files')
"
```

Merge cached + new results into `.graphify_semantic.json`:

```bash
python3 -c "
import json
from pathlib import Path

cached = json.loads(Path('.graphify_cached.json').read_text()) if Path('.graphify_cached.json').exists() else {'nodes':[],'edges':[],'hyperedges':[]}
new = json.loads(Path('.graphify_semantic_new.json').read_text()) if Path('.graphify_semantic_new.json').exists() else {'nodes':[],'edges':[],'hyperedges':[]}

all_nodes = cached['nodes'] + new.get('nodes', [])
all_edges = cached['edges'] + new.get('edges', [])
all_hyperedges = cached.get('hyperedges', []) + new.get('hyperedges', [])
seen = set()
deduped = []
for n in all_nodes:
    if n['id'] not in seen:
        seen.add(n['id'])
        deduped.append(n)

merged = {
    'nodes': deduped,
    'edges': all_edges,
    'hyperedges': all_hyperedges,
    'input_tokens': new.get('input_tokens', 0),
    'output_tokens': new.get('output_tokens', 0),
}
Path('.graphify_semantic.json').write_text(json.dumps(merged, indent=2))
print(f'Extraction complete - {len(deduped)} nodes, {len(all_edges)} edges ({len(cached[\"nodes\"])} from cache, {len(new.get(\"nodes\",[]))} new)')
"
rm -f .graphify_cached.json .graphify_uncached.txt .graphify_semantic_new.json
```

#### Part C — Merge AST + semantic into final extraction

```bash
python3 -c "
import sys, json
from pathlib import Path

ast = json.loads(Path('.graphify_ast.json').read_text())
sem = json.loads(Path('.graphify_semantic.json').read_text())

seen = {n['id'] for n in ast['nodes']}
merged_nodes = list(ast['nodes'])
for n in sem['nodes']:
    if n['id'] not in seen:
        merged_nodes.append(n)
        seen.add(n['id'])

merged = {
    'nodes': merged_nodes,
    'edges': ast['edges'] + sem['edges'],
    'hyperedges': sem.get('hyperedges', []),
    'input_tokens': sem.get('input_tokens', 0),
    'output_tokens': sem.get('output_tokens', 0),
}
Path('.graphify_extract.json').write_text(json.dumps(merged, indent=2))
print(f'Merged: {len(merged_nodes)} nodes, {len(merged[\"edges\"])} edges ({len(ast[\"nodes\"])} AST + {len(sem[\"nodes\"])} semantic)')
"
```

---

### Step 4 — Build graph, cluster, analyze, generate outputs

```bash
mkdir -p graphify-out
python3 -c "
import sys, json
from graphify.build import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate
from graphify.export import to_json
from pathlib import Path

extraction = json.loads(Path('.graphify_extract.json').read_text())
detection  = json.loads(Path('.graphify_detect.json').read_text())

G = build_from_json(extraction)
communities = cluster(G)
cohesion = score_all(G, communities)
tokens = {'input': extraction.get('input_tokens', 0), 'output': extraction.get('output_tokens', 0)}
gods = god_nodes(G)
surprises = surprising_connections(G, communities)
labels = {cid: 'Community ' + str(cid) for cid in communities}
questions = suggest_questions(G, communities, labels)

report = generate(G, communities, cohesion, labels, gods, surprises, detection, tokens, 'INPUT_PATH', suggested_questions=questions)
Path('graphify-out/GRAPH_REPORT.md').write_text(report)
to_json(G, communities, 'graphify-out/graph.json')

analysis = {
    'communities': {str(k): v for k, v in communities.items()},
    'cohesion': {str(k): v for k, v in cohesion.items()},
    'gods': gods,
    'surprises': surprises,
    'questions': questions,
}
Path('.graphify_analysis.json').write_text(json.dumps(analysis, indent=2))
if G.number_of_nodes() == 0:
    print('ERROR: Graph is empty - extraction produced no nodes.')
    raise SystemExit(1)
print(f'Graph: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges, {len(communities)} communities')
"
```

Replace `INPUT_PATH` with the actual path. If this step prints `ERROR: Graph is empty`, stop and tell the user — do not proceed.

---

### Step 5 — Label communities

Read `.graphify_analysis.json`. For each community key, look at its node labels and write a 2–5 word plain-language name (e.g. "Attention Mechanism", "Training Pipeline", "Data Loading").

Then regenerate the report:

```bash
python3 -c "
import sys, json
from graphify.build import build_from_json
from graphify.cluster import score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate
from pathlib import Path

extraction = json.loads(Path('.graphify_extract.json').read_text())
detection  = json.loads(Path('.graphify_detect.json').read_text())
analysis   = json.loads(Path('.graphify_analysis.json').read_text())

G = build_from_json(extraction)
communities = {int(k): v for k, v in analysis['communities'].items()}
cohesion = {int(k): v for k, v in analysis['cohesion'].items()}
tokens = {'input': extraction.get('input_tokens', 0), 'output': extraction.get('output_tokens', 0)}

# Replace with the labels you chose above
labels = LABELS_DICT

questions = suggest_questions(G, communities, labels)
report = generate(G, communities, cohesion, labels, analysis['gods'], analysis['surprises'], detection, tokens, 'INPUT_PATH', suggested_questions=questions)
Path('graphify-out/GRAPH_REPORT.md').write_text(report)
Path('.graphify_labels.json').write_text(json.dumps({str(k): v for k, v in labels.items()}))
print('Report updated with community labels')
"
```

Replace `LABELS_DICT` with the actual dict (e.g. `{0: "Attention Mechanism", 1: "Training Pipeline"}`). Replace `INPUT_PATH` with the actual path.

---

### Step 6 — Generate HTML visualization

**Always generate HTML** (unless `--no-viz` was given). **Obsidian vault only if `--obsidian` was explicitly given.**

If `--obsidian` was given:

```bash
python3 -c "
import sys, json
from graphify.build import build_from_json
from graphify.export import to_obsidian, to_canvas
from pathlib import Path

extraction = json.loads(Path('.graphify_extract.json').read_text())
analysis   = json.loads(Path('.graphify_analysis.json').read_text())
labels_raw = json.loads(Path('.graphify_labels.json').read_text()) if Path('.graphify_labels.json').exists() else {}

G = build_from_json(extraction)
communities = {int(k): v for k, v in analysis['communities'].items()}
cohesion = {int(k): v for k, v in analysis['cohesion'].items()}
labels = {int(k): v for k, v in labels_raw.items()}

n = to_obsidian(G, communities, 'graphify-out/obsidian', community_labels=labels or None, cohesion=cohesion)
to_canvas(G, communities, 'graphify-out/obsidian/graph.canvas', community_labels=labels or None)
print(f'Obsidian vault: {n} notes in graphify-out/obsidian/')
"
```

Generate the HTML graph (always, unless `--no-viz`):

```bash
python3 -c "
import sys, json
from graphify.build import build_from_json
from graphify.export import to_html
from pathlib import Path

extraction = json.loads(Path('.graphify_extract.json').read_text())
analysis   = json.loads(Path('.graphify_analysis.json').read_text())
labels_raw = json.loads(Path('.graphify_labels.json').read_text()) if Path('.graphify_labels.json').exists() else {}

G = build_from_json(extraction)
communities = {int(k): v for k, v in analysis['communities'].items()}
labels = {int(k): v for k, v in labels_raw.items()}

if G.number_of_nodes() > 5000:
    print(f'Graph has {G.number_of_nodes()} nodes - too large for HTML viz. Use Obsidian vault instead.')
else:
    to_html(G, communities, 'graphify-out/graph.html', community_labels=labels or None)
    print('graph.html written - open in any browser, no server needed')
"
```

---

### Step 7 — Optional exports (only run if the matching flag was given)

**`--neo4j`** — Generate Cypher file:
```bash
python3 -c "
import json
from graphify.build import build_from_json
from graphify.export import to_cypher
from pathlib import Path
G = build_from_json(json.loads(Path('.graphify_extract.json').read_text()))
to_cypher(G, 'graphify-out/cypher.txt')
print('cypher.txt written - import with: cypher-shell < graphify-out/cypher.txt')
"
```

**`--neo4j-push <uri>`** — Push directly to Neo4j (ask user for credentials if not provided):
```bash
python3 -c "
import json
from graphify.build import build_from_json
from graphify.export import push_to_neo4j
from pathlib import Path
G = build_from_json(json.loads(Path('.graphify_extract.json').read_text()))
analysis = json.loads(Path('.graphify_analysis.json').read_text())
communities = {int(k): v for k, v in analysis['communities'].items()}
result = push_to_neo4j(G, uri='NEO4J_URI', user='NEO4J_USER', password='NEO4J_PASSWORD', communities=communities)
print(f'Pushed to Neo4j: {result[\"nodes\"]} nodes, {result[\"edges\"]} edges')
"
```

**`--svg`**:
```bash
python3 -c "
import json
from graphify.build import build_from_json
from graphify.export import to_svg
from pathlib import Path
extraction = json.loads(Path('.graphify_extract.json').read_text())
analysis = json.loads(Path('.graphify_analysis.json').read_text())
labels_raw = json.loads(Path('.graphify_labels.json').read_text()) if Path('.graphify_labels.json').exists() else {}
G = build_from_json(extraction)
communities = {int(k): v for k, v in analysis['communities'].items()}
labels = {int(k): v for k, v in labels_raw.items()}
to_svg(G, communities, 'graphify-out/graph.svg', community_labels=labels or None)
print('graph.svg written')
"
```

**`--graphml`**:
```bash
python3 -c "
import json
from graphify.build import build_from_json
from graphify.export import to_graphml
from pathlib import Path
G = build_from_json(json.loads(Path('.graphify_extract.json').read_text()))
analysis = json.loads(Path('.graphify_analysis.json').read_text())
communities = {int(k): v for k, v in analysis['communities'].items()}
to_graphml(G, communities, 'graphify-out/graph.graphml')
print('graph.graphml written - open in Gephi, yEd, or any GraphML tool')
"
```

**`--mcp`** — Start MCP stdio server:
```bash
python3 -m graphify.serve graphify-out/graph.json
```
This exposes tools: `query_graph`, `get_node`, `get_neighbors`, `get_community`, `god_nodes`, `graph_stats`, `shortest_path`.

---

### Step 8 — Token reduction benchmark (only if `total_words` > 5000)

```bash
python3 -c "
import json
from graphify.benchmark import run_benchmark, print_benchmark
from pathlib import Path
detection = json.loads(Path('.graphify_detect.json').read_text())
result = run_benchmark('graphify-out/graph.json', corpus_words=detection['total_words'])
print_benchmark(result)
"
```

Print the output directly in chat. If `total_words <= 5000`, skip silently.

---

### Step 9 — Save manifest, update cost tracker, clean up, and report

```bash
python3 -c "
import json
from pathlib import Path
from datetime import datetime, timezone
from graphify.detect import save_manifest

detect = json.loads(Path('.graphify_detect.json').read_text())
save_manifest(detect['files'])

extract = json.loads(Path('.graphify_extract.json').read_text())
input_tok = extract.get('input_tokens', 0)
output_tok = extract.get('output_tokens', 0)

cost_path = Path('graphify-out/cost.json')
cost = json.loads(cost_path.read_text()) if cost_path.exists() else {'runs': [], 'total_input_tokens': 0, 'total_output_tokens': 0}
cost['runs'].append({'date': datetime.now(timezone.utc).isoformat(), 'input_tokens': input_tok, 'output_tokens': output_tok, 'files': detect.get('total_files', 0)})
cost['total_input_tokens'] += input_tok
cost['total_output_tokens'] += output_tok
cost_path.write_text(json.dumps(cost, indent=2))

print(f'This run: {input_tok:,} input tokens, {output_tok:,} output tokens')
print(f'All time: {cost[\"total_input_tokens\"]:,} input, {cost[\"total_output_tokens\"]:,} output ({len(cost[\"runs\"])} runs)')
"
rm -f .graphify_detect.json .graphify_extract.json .graphify_ast.json .graphify_semantic.json .graphify_analysis.json .graphify_labels.json
rm -f graphify-out/.needs_update 2>/dev/null || true
```

Tell the user (omit the obsidian line unless `--obsidian` was given):

```
Graph complete. Outputs in PATH_TO_DIR/graphify-out/

  graph.html            - interactive graph, open in browser
  GRAPH_REPORT.md       - audit report
  graph.json            - raw graph data
  obsidian/             - Obsidian vault (only if --obsidian was given)
```

Then paste these three sections from `GRAPH_REPORT.md` directly into chat (not the full report):
- God Nodes
- Surprising Connections
- Suggested Questions

Then pick the single most interesting suggested question — the one that crosses the most community boundaries — and offer to trace it:

> "The most interesting question this graph can answer: **[question]**. Want me to trace it?"

If the user says yes, run `/graphify query "[question]"` and walk through the answer using the graph structure. Keep going as long as they want to explore. Each answer should end with a natural follow-up.

---

## For --update (incremental re-extraction)

Only re-extracts changed files since the last run.

```bash
python3 -c "
import sys, json
from graphify.detect import detect_incremental, save_manifest
from pathlib import Path

result = detect_incremental(Path('INPUT_PATH'))
Path('.graphify_incremental.json').write_text(json.dumps(result))
new_total = result.get('new_total', 0)
if new_total == 0:
    print('No files changed since last run. Nothing to update.')
    raise SystemExit(0)
print(f'{new_total} new/changed file(s) to re-extract.')
"
```

Check if all changed files are code-only:
```bash
python3 -c "
import json
from pathlib import Path
result = json.loads(open('.graphify_incremental.json').read()) if Path('.graphify_incremental.json').exists() else {}
code_exts = {'.py','.ts','.js','.go','.rs','.java','.cpp','.c','.rb','.swift','.kt','.cs','.scala','.php','.cc','.cxx','.hpp','.h','.kts'}
all_changed = [f for files in result.get('new_files', {}).values() for f in files]
code_only = all(Path(f).suffix.lower() in code_exts for f in all_changed)
print('code_only:', code_only)
"
```

- If `code_only` is True: print `[graphify update] Code-only changes — skipping semantic extraction (no LLM needed)`, run only Step 3A on the changed files, then proceed to merge and Steps 4–8.
- If `code_only` is False: run the full Steps 3A–3C pipeline as normal.

Before merging, back up the existing graph: `cp graphify-out/graph.json .graphify_old.json`

After merging, show the graph diff:
```bash
python3 -c "
import json
from graphify.analyze import graph_diff
from graphify.build import build_from_json
from networkx.readwrite import json_graph
from pathlib import Path

old_data = json.loads(Path('.graphify_old.json').read_text()) if Path('.graphify_old.json').exists() else None
G_new = build_from_json(json.loads(Path('.graphify_extract.json').read_text()))

if old_data:
    import networkx as nx
    G_old = json_graph.node_link_graph(old_data, edges='links')
    diff = graph_diff(G_old, G_new)
    print(diff['summary'])
    if diff['new_nodes']:
        print('New nodes:', ', '.join(n['label'] for n in diff['new_nodes'][:5]))
    if diff['new_edges']:
        print('New edges:', len(diff['new_edges']))
"
rm -f .graphify_old.json
```

---

## For --cluster-only

Skip Steps 1–3. Load existing graph and re-run clustering:

```bash
python3 -c "
import sys, json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections
from graphify.report import generate
from graphify.export import to_json
from networkx.readwrite import json_graph
from pathlib import Path

data = json.loads(Path('graphify-out/graph.json').read_text())
G = json_graph.node_link_graph(data, edges='links')
detection = {'total_files': 0, 'total_words': 99999, 'needs_graph': True, 'warning': None, 'files': {'code': [], 'document': [], 'paper': []}}
tokens = {'input': 0, 'output': 0}

communities = cluster(G)
cohesion = score_all(G, communities)
gods = god_nodes(G)
surprises = surprising_connections(G, communities)
labels = {cid: 'Community ' + str(cid) for cid in communities}

report = generate(G, communities, cohesion, labels, gods, surprises, detection, tokens, '.')
Path('graphify-out/GRAPH_REPORT.md').write_text(report)
to_json(G, communities, 'graphify-out/graph.json')
Path('.graphify_analysis.json').write_text(json.dumps({'communities': {str(k): v for k, v in communities.items()}, 'cohesion': {str(k): v for k, v in cohesion.items()}, 'gods': gods, 'surprises': surprises}))
print(f'Re-clustered: {len(communities)} communities')
"
```

Then run Steps 5–9 as normal.

---

## For /graphify query

First verify the graph exists:
```bash
python3 -c "
from pathlib import Path
if not Path('graphify-out/graph.json').exists():
    print('ERROR: No graph found. Run /graphify <path> first.')
    raise SystemExit(1)
"
```

Load `graphify-out/graph.json`, then:

1. Find the 1–3 nodes whose label best matches key terms in the question.
2. Run BFS (default) or DFS (`--dfs`) traversal from each starting node.
3. Answer using **only** what the graph contains. Quote `source_location` when citing facts.
4. If the graph lacks enough information, say so — do not hallucinate edges.

```bash
python3 -c "
import sys, json
from networkx.readwrite import json_graph
from pathlib import Path

data = json.loads(Path('graphify-out/graph.json').read_text())
G = json_graph.node_link_graph(data, edges='links')

question = 'QUESTION'
mode = 'MODE'  # 'bfs' or 'dfs'
terms = [t.lower() for t in question.split() if len(t) > 3]

scored = sorted([(sum(1 for t in terms if t in G.nodes[n].get('label','').lower()), n) for n in G.nodes()], reverse=True)
start_nodes = [nid for _, nid in scored[:3] if _ > 0]

if not start_nodes:
    print('No matching nodes found for query terms:', terms)
    sys.exit(0)

subgraph_nodes = set()
subgraph_edges = []

if mode == 'dfs':
    visited = set()
    stack = [(n, 0) for n in reversed(start_nodes)]
    while stack:
        node, depth = stack.pop()
        if node in visited or depth > 6:
            continue
        visited.add(node)
        subgraph_nodes.add(node)
        for neighbor in G.neighbors(node):
            if neighbor not in visited:
                stack.append((neighbor, depth + 1))
                subgraph_edges.append((node, neighbor))
else:
    frontier = set(start_nodes)
    subgraph_nodes = set(start_nodes)
    for _ in range(3):
        next_frontier = set()
        for n in frontier:
            for neighbor in G.neighbors(n):
                if neighbor not in subgraph_nodes:
                    next_frontier.add(neighbor)
                    subgraph_edges.append((n, neighbor))
        subgraph_nodes.update(next_frontier)
        frontier = next_frontier

token_budget = BUDGET
char_budget = token_budget * 4
ranked_nodes = sorted(subgraph_nodes, key=lambda nid: sum(1 for t in terms if t in G.nodes[nid].get('label','').lower()), reverse=True)

lines = [f'Traversal: {mode.upper()} | Start: {[G.nodes[n].get(\"label\",n) for n in start_nodes]} | {len(subgraph_nodes)} nodes']
for nid in ranked_nodes:
    d = G.nodes[nid]
    lines.append(f'  NODE {d.get(\"label\", nid)} [src={d.get(\"source_file\",\"\")} loc={d.get(\"source_location\",\"\")}]')
for u, v in subgraph_edges:
    if u in subgraph_nodes and v in subgraph_nodes:
        d = G.edges[u, v]
        lines.append(f'  EDGE {G.nodes[u].get(\"label\",u)} --{d.get(\"relation\",\"\")} [{d.get(\"confidence\",\"\")}]--> {G.nodes[v].get(\"label\",v)}')

output = '\n'.join(lines)
if len(output) > char_budget:
    output = output[:char_budget] + f'\n... (truncated at ~{token_budget} token budget - use --budget N for more)'
print(output)
"
```

Replace `QUESTION`, `MODE` (`bfs` or `dfs`), and `BUDGET` (default `2000`).

After answering, save the result back to the graph:
```bash
python3 -c "
from graphify.ingest import save_query_result
from pathlib import Path
save_query_result(question='QUESTION', answer='ANSWER', memory_dir=Path('graphify-out/memory'), query_type='query', source_nodes=SOURCE_NODES)
"
```

---

## For /graphify path

Find shortest path between two named concepts.

```bash
python3 -c "
import json, sys
import networkx as nx
from networkx.readwrite import json_graph
from pathlib import Path

data = json.loads(Path('graphify-out/graph.json').read_text())
G = json_graph.node_link_graph(data, edges='links')

def find_node(term):
    term = term.lower()
    scored = sorted([(sum(1 for w in term.split() if w in G.nodes[n].get('label','').lower()), n) for n in G.nodes()], reverse=True)
    return scored[0][1] if scored and scored[0][0] > 0 else None

src = find_node('NODE_A')
tgt = find_node('NODE_B')

if not src or not tgt:
    print('Could not find nodes matching the provided names')
    sys.exit(0)

try:
    path = nx.shortest_path(G, src, tgt)
    print(f'Shortest path ({len(path)-1} hops):')
    for i, nid in enumerate(path):
        label = G.nodes[nid].get('label', nid)
        if i < len(path) - 1:
            edge = G.edges[nid, path[i+1]]
            print(f'  {label} --{edge.get(\"relation\",\"\")} [{edge.get(\"confidence\",\"\")}]-->')
        else:
            print(f'  {label}')
except nx.NetworkXNoPath:
    print('No path found between those nodes')
"
```

Explain the path in plain language — what each hop means, why it's significant. Then save:
```bash
python3 -c "
from graphify.ingest import save_query_result
from pathlib import Path
save_query_result(question='Path from NODE_A to NODE_B', answer='ANSWER', memory_dir=Path('graphify-out/memory'), query_type='path_query', source_nodes=PATH_NODES)
"
```

---

## For /graphify explain

Explain a single node and everything connected to it.

```bash
python3 -c "
import json, sys
import networkx as nx
from networkx.readwrite import json_graph
from pathlib import Path

data = json.loads(Path('graphify-out/graph.json').read_text())
G = json_graph.node_link_graph(data, edges='links')

term = 'NODE_NAME'
scored = sorted([(sum(1 for w in term.lower().split() if w in G.nodes[n].get('label','').lower()), n) for n in G.nodes()], reverse=True)
if not scored or scored[0][0] == 0:
    print(f'No node matching {term!r}')
    sys.exit(0)

nid = scored[0][1]
d = G.nodes[nid]
print(f'NODE: {d.get(\"label\", nid)}')
print(f'  source: {d.get(\"source_file\",\"unknown\")}')
print(f'  type: {d.get(\"file_type\",\"unknown\")}')
print(f'  degree: {G.degree(nid)}')
print()
print('CONNECTIONS:')
for neighbor in G.neighbors(nid):
    edge = G.edges[nid, neighbor]
    print(f'  --{edge.get(\"relation\",\"\")} [{edge.get(\"confidence\",\"\")}]--> {G.nodes[neighbor].get(\"label\", neighbor)} ({G.nodes[neighbor].get(\"source_file\",\"\")})')
"
```

Write a 3–5 sentence explanation using only what the graph contains. Then save:
```bash
python3 -c "
from graphify.ingest import save_query_result
from pathlib import Path
save_query_result(question='Explain NODE_NAME', answer='ANSWER', memory_dir=Path('graphify-out/memory'), query_type='explain', source_nodes=['NODE_NAME'])
"
```

---

## For /graphify add

Fetch a URL and add it to the corpus, then update the graph.

```bash
python3 -c "
import sys
from graphify.ingest import ingest
from pathlib import Path

try:
    out = ingest('URL', Path('./raw'), author='AUTHOR', contributor='CONTRIBUTOR')
    print(f'Saved to {out}')
except (ValueError, RuntimeError) as e:
    print(f'error: {e}', file=sys.stderr)
    sys.exit(1)
"
```

Supported URL types (auto-detected): Twitter/X → `.md` with tweet text and author; arXiv → abstract + metadata as `.md`; PDF → downloaded as `.pdf`; Images → downloaded for vision extraction; Any webpage → converted to markdown.

After a successful save, automatically run the `--update` pipeline on `./raw`.

---

## For --watch

```bash
python3 -m graphify.watch INPUT_PATH --debounce 3
```

- **Code file changes:** re-runs AST extraction + rebuild + cluster immediately (no LLM).
- **Docs/papers/images:** writes a flag and prints a notification to run `/graphify --update`.

Press Ctrl+C to stop.

---

## Honesty Rules

- Never invent an edge. If unsure, use AMBIGUOUS.
- Never skip the corpus-size check warning.
- Always show token cost in the report.
- Never hide cohesion scores — show the raw number.
- Never run HTML viz on a graph with more than 5,000 nodes without warning the user.
- Answer queries using only what the graph contains. Do not hallucinate edges.
