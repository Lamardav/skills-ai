## 🧠 Skills AI — стек подключён

**Плагины:**
| Плагин | Что даёт |
|---|---|
| `superpowers` | Методология разработки: TDD, systematic-debugging, brainstorming, планы, code-review |
| `example-skills` | frontend-design, canvas-design, theme-factory, brand-guidelines, algorithmic-art, mcp-builder, webapp-testing, web-artifacts-builder, skill-creator, doc-coauthoring, internal-comms, slack-gif-creator |
| `cybersecurity-pro` | 22 домена ИБ: IR, DFIR, DevSecOps, SOC, compliance, cloud, AI/ML security |
| `skills-ai` | Этот дайджест + `/skills-brief` |

**MCP-серверы:** `context7` — свежая документация любых библиотек прямо в контекст · `playwright` — управление реальным браузером (клики, формы, скриншоты, тесты)

**Уже встроено в Claude Code, ставить не нужно:** работа с `.docx` / `.xlsx` / `.pptx` / `.pdf`, `dataviz`, `claude-api`, `skill-creator`, артефакты.

---

**Что срабатывает само, без команд:**
- **Скилы** — по смыслу запроса. Скажи «сделай отчёт в Word» → `docx`; «почини баг» → `systematic-debugging`; «построй график» → `dataviz`; «свёрстай интерфейс» → `frontend-design`; «проверь модель угроз» → `cybersecurity-pro`. В контексте висят только названия и описания; полный текст скила читается в момент срабатывания.
- **MCP** — когда задача этого требует: незнакомая библиотека → `context7`, «открой сайт / протестируй UI» → `playwright`.
- **Хуки** — этот дайджест печатается на старте каждой новой сессии.

**Что нужно звать вручную:** `/skills-brief` — показать это снова · `/code-review` — ревью изменений · `/security-review` — аудит ветки · `/simplify` — упростить код · `/plugin` — управление плагинами · `/mcp` — статус MCP · `/init` — создать CLAUDE.md · `/context` — что съедает контекст

**Обновить стек:** `git pull` + `.\install.ps1` в репозитории Skills AI. Поправил `BRIEF.md` — примени: `.\install.ps1 -Refresh`.
