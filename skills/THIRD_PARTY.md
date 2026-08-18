# Third-party skills

`skills/grill-me` and `skills/grilling` are vendored from
<https://github.com/mattpocock/skills> at commit `9c9f36ccd3995266cd675468af71639c8dde1ec5`,
paths `skills/productivity/grill-me` and `skills/productivity/grilling`.

Only these two are vendored rather than installing the whole
`mattpocock-skills` plugin, which carries ~35 skills. `grill-me` is a
thin wrapper that calls `grilling`, so both are required; neither has
any further dependency. The upstream `agents/openai.yaml` files are
omitted -- they configure the Codex/OpenAI harness, not Claude Code.

To refresh them, re-copy from upstream and update the commit above.

---

MIT License

Copyright (c) 2026 Matt Pocock

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
