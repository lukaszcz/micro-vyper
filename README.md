# micro-vyper

Micro editor syntax highlighting for the Vyper smart contract language.

The syntax file supports `.vy` contracts and `.vyi` interface files. It uses
Micro colorscheme highlight groups such as `statement`, `type`,
`type.keyword`, `constant.string`, `constant.number`, `symbol.operator`, and
`comment` instead of hardcoded terminal colors.

## Installation

As a Micro plugin:

```sh
git clone https://github.com/lukaszcz/micro-vyper ~/.config/micro/plug/vyper
```

Then restart Micro.

For syntax-only installation:

```sh
mkdir -p ~/.config/micro/syntax
cp syntax/vyper.yaml ~/.config/micro/syntax/vyper.yaml
```

## Development Notes

The highlighter is based on Micro's YAML syntax format and current Vyper
language documentation. Vyper is Pythonic, so the syntax structure follows
Micro's Python highlighter where that maps cleanly, with Vyper-specific
decorators, built-ins, environment variables, types, pragmas, and module
keywords added.
