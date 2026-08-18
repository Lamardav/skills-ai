## 🧠 Skills AI — стек подключён

**Плагины:**
| Плагин | Что даёт |
|---|---|
| `superpowers` | Методология разработки: TDD, systematic-debugging, brainstorming, планы, code-review |
| `frontend-design` | Вкус во фронтенде: вёрстка, компоненты, визуальная отладка |
| `example-skills` | canvas-design, algorithmic-art, mcp-builder, webapp-testing, skill-creator, theme-factory, brand-guidelines, doc-coauthoring, internal-comms, slack-gif-creator, web-artifacts-builder |
| `document-skills` | Чтение и генерация `.docx` / `.xlsx` / `.pptx` / `.pdf` |
| `claude-api` | Справочник по Claude API/SDK: модели, цены, tool use, кэширование |
| `cybersecurity-pro` | 22 домена ИБ: IR, DFIR, DevSecOps, SOC, compliance, cloud, AI/ML security |
| `academy-guide` | Подсказки по курсам Claude Academy |
| `discernment-nudge` | Напоминание проверять факты в спорных местах |
| `skills-ai` | Этот дайджест + `/skills-brief` |

**MCP-серверы (2):** `context7` — свежая документация любых библиотек прямо в контекст · `playwright` — управление реальным браузером (клики, формы, скриншоты, тесты)

---

**Что срабатывает само, без команд:**
- **Скилы** — по смыслу запроса. Скажи «сделай отчёт в Word» → `docx`; «почини баг» → `systematic-debugging`; «построй график» → `dataviz`; «проверь модель угроз» → `cybersecurity-pro`. В контексте висят только названия и описания; полный текст скила читается в момент срабатывания.
- **MCP** — когда задача этого требует: незнакомая библиотека → `context7`, «открой сайт / протестируй UI» → `playwright`.
- **Хуки** — этот дайджест печатается на старте каждой новой сессии.

**Что нужно звать вручную:** `/skills-brief` — показать это снова · `/code-review` — ревью изменений · `/security-review` — аудит ветки · `/simplify` — упростить код · `/plugin` — управление плагинами · `/mcp` — статус MCP · `/init` — создать CLAUDE.md · `/context` — что съедает контекст

**Обновить стек:** `git pull` + `.\install.ps1` в репозитории Skills AI. Поправил `BRIEF.md` — примени: `.\install.ps1 -Refresh`.
