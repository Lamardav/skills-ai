---
description: Show the Skills AI digest — what is installed, what fires automatically, key commands
---

Read `${CLAUDE_PLUGIN_ROOT}/BRIEF.md` and render its contents verbatim to the user.

If the user passed an argument, first render the digest, then answer their question
about the stack using the digest plus anything you can read from
`${CLAUDE_PLUGIN_ROOT}/manifest.json`.

Argument: $ARGUMENTS
