# Agent Instructions

This is a Micro editor syntax highlighting plugin for the Vyper smart contract language.

## Repository Structure

- `syntax/vyper.yaml` — Main syntax definition (Micro YAML format)
- `vyper.lua` — Micro plugin entry point
- `help/vyper.md` — Help text shown inside Micro
- `examples/example.vy` — Sample Vyper contract for testing highlighting

## Key Constraints

### Micro's Highlighting Engine

Micro applies pattern rules **sequentially**, and **later rules overwrite earlier ones per-character**. This means rule ordering matters critically:

- If rule A colors characters 5–12 and rule B (listed after A) also matches characters 8–12, the final color for 8–12 comes from rule B.
- To prevent a later rule from overwriting part of an earlier match, either remove the keyword from the later rule, or reorder so the earlier-match rule comes first (allowing the broader rule to overwrite it back).

Verified by reading Micro's source:
https://github.com/micro-editor/micro/blob/master/pkg/highlight/highlighter.go

## Validating Changes

### 1. Install and test in Micro

```sh
just install
```

Then open the example file in Micro:

```sh
micro examples/example.vy
```

### 2. Cross-reference with Vyper grammar

The canonical Vyper grammar is in the Vyper repository:
https://github.com/vyperlang/vyper/blob/master/vyper/ast/grammar.lark

Additional Vyper sources for keyword validation:
- Function visibility enum: https://github.com/vyperlang/vyper/blob/master/vyper/semantics/analysis/base.py (EXTERNAL, INTERNAL, DEPLOY)
- State mutability enum: same file (PURE, VIEW, NONPAYABLE, PAYABLE)
- Decorator parsing: https://github.com/vyperlang/vyper/blob/master/vyper/semantics/types/function.py (`_parse_decorators` function)
- Variable annotation parsing: https://github.com/vyperlang/vyper/blob/master/vyper/ast/nodes.py ( VariableDecl class)
- Reserved keywords: https://github.com/vyperlang/vyper/blob/master/vyper/ast/identifiers.py (`RESERVED_KEYWORDS`)

### 3. Vyper documentation

When the web proxy allows, check:
- https://docs.vyperlang.org/en/latest/structure-of-a-contract.html
- https://docs.vyperlang.org/en/latest/interfaces.html (for standalone mutability keywords)
- https://docs.vyperlang.org/en/latest/abstract-modules.html (for `@abstract` and `@override`)

Otherwise, fetch RST sources directly from GitHub:
- https://raw.githubusercontent.com/vyperlang/vyper/master/docs/structure-of-a-contract.rst
- https://raw.githubusercontent.com/vyperlang/vyper/master/docs/interfaces.rst
- https://raw.githubusercontent.com/vyperlang/vyper/master/docs/abstract-modules.rst

## Syntax File Format

Micro's YAML syntax format reference:
- Patterns: `- group: "regex"` — simple pattern rules
- Regions: `- group: start/end/skip/rules` — multiline regions (strings, comments)
- Available highlight groups: `statement`, `type`, `type.keyword`, `preproc`, `identifier`, `identifier.class`, `identifier.function`, `constant`, `constant.bool`, `constant.number`, `constant.string`, `symbol.operator`, `symbol.brackets`, `comment`, `todo`
