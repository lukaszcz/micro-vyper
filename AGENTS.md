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
Key loop in `highlightEmptyRegion`:

```go
fullHighlights := make([]Group, len(line))
for _, p := range h.Def.rules.patterns {
    matches := findAllIndex(p.regex, line)
    for _, m := range matches {
        for i := m[0]; i < m[1]; i++ {
            fullHighlights[i] = p.group
        }
    }
}
```

### Decorator vs Standalone Keywords

Vyper keywords that appear as `@decorator` have different coloring needs than when they appear standalone. Some keywords have **dual usage** (both decorator and standalone), while others are **decorator-only**.

| Keyword | `@decorator` | Standalone | Standalone context |
|---------|-------------|------------|-------------------|
| `external` | ✅ | ❌ | — |
| `internal` | ✅ | ❌ | — |
| `deploy` | ✅ | ❌ | — |
| `abstract` | ✅ | ❌ | — |
| `override` | ✅ | ❌ | — |
| `raw_return` | ✅ | ❌ | — |
| `nonreentrant` | ✅ | ❌ | — |
| `view` | ✅ | ✅ | Interface mutability: `def foo(): view` |
| `pure` | ✅ | ✅ | Interface mutability: `def foo(): pure` |
| `payable` | ✅ | ✅ | Interface mutability: `def foo(): payable` |
| `nonpayable` | ✅ | ✅ | Interface mutability: `def foo(): nonpayable` |
| `reentrant` | ✅ | ✅ | Variable annotation: `foo: reentrant(public(uint256))` |
| `public` | ❌ | ✅ | Variable annotation: `foo: public(uint256)` |
| `constant` | ❌ | ✅ | Variable annotation: `FOO: constant(uint256)` |
| `immutable` | ❌ | ✅ | Variable annotation: `FOO: immutable(uint256)` |
| `transient` | ❌ | ✅ | Variable annotation: `FOO: transient(uint256)` |
| `indexed` | ❌ | ✅ | Event arg: `sender: indexed(address)` |

**Current solution**: Place `type.keyword` (standalone-only keywords) **before** the `preproc` decorator rule. This way:
- `@view` → `type.keyword` colors `view`, then `preproc` overwrites the full `@view` span → consistent preproc color
- standalone `view` → only `type.keyword` matches → correct type.keyword color
- `@external` → only `preproc` matches (not in `type.keyword`) → consistent preproc color

## Validating Changes

### 1. Install and test in Micro

```sh
just install
```

Then open the example file in Micro:

```sh
micro examples/example.vy
```

Verify:
- `@external`, `@deploy`, `@payable`, `@view` — entire decorator (including `@`) should be one consistent color (preproc)
- `public(uint256)`, `indexed(address)` — should be type.keyword color
- `view` standalone in interface defs — should be type.keyword color
- No keyword inherits the wrong group (e.g., `external` should never look like a `type.keyword`)

### 2. Cross-reference with Vyper grammar

The canonical Vyper grammar is in the Vyper repository:
https://github.com/vyperlang/vyper/blob/master/vyper/ast/grammar.lark

Key rules to check:
- `decorator: "@" NAME [ "(" [arguments] ")" ]` — decorators are `@NAME`
- `variable_annotation: ("public" | "reentrant" | "immutable" | "transient") "(" ...` — standalone variable annotations
- `mutability: NAME` in `interface_function` — standalone mutability in interfaces
- `indexed_event_arg: NAME ":" "indexed" "(" type ")"` — indexed in events

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

### 4. Adding new keywords

When adding Vyper keywords to the syntax file:
1. Check the grammar to determine if the keyword is decorator-only, standalone-only, or dual-use
2. If decorator-only: add to the `preproc` decorator regex only
3. If standalone-only: add to `type.keyword` only
4. If dual-use: add to **both** `type.keyword` and the `preproc` decorator regex, keeping `type.keyword` before `preproc`
5. Test both usages in Micro

## Syntax File Format

Micro's YAML syntax format reference:
- Patterns: `- group: "regex"` — simple pattern rules
- Regions: `- group: start/end/skip/rules` — multiline regions (strings, comments)
- Available highlight groups: `statement`, `type`, `type.keyword`, `preproc`, `identifier`, `identifier.class`, `identifier.function`, `constant`, `constant.bool`, `constant.number`, `constant.string`, `symbol.operator`, `symbol.brackets`, `comment`, `todo`
