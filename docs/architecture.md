# Architecture

## Environment

The primary terminal environment is:

```text
Windows 11
└── WezTerm
    └── MSYS2 UCRT64
        └── Bash
````

## Ownership boundaries

Windows owns:

* WezTerm
* Git
* .NET SDK
* Windows fonts
* GUI applications

MSYS2 UCRT64 owns:

* Bash
* Unix command-line tools
* UCRT64-native command-line applications
* Terminal configuration deployment

Neovim configuration is maintained in a separate repository.
