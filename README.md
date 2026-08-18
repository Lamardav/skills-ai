# Skills AI

Один репозиторий, который поднимает мой полный стек Claude Code на любой машине —
маркетплейсы, плагины, MCP-серверы — и печатает краткую выжимку по стеку
в начале каждой сессии.

## Установка на новом ПК

```powershell
git clone <URL этого репозитория> skills-ai
cd skills-ai
.\install.ps1
```

macOS / Linux:

```bash
git clone <URL этого репозитория> skills-ai && cd skills-ai && ./install.sh
```

Скрипт идемпотентен — повторный запуск ничего не ломает, уже установленное
пропускается. После установки **перезапусти Claude Code**.

Обновление стека позже: `git pull` и снова `.\install.ps1`.

## Что ставится

Источник правды — [`manifest.json`](manifest.json). Правишь его, коммитишь,
на других машинах `git pull && .\install.ps1`.

| | |
|---|---|
| **Маркетплейсы** | `anthropics/claude-plugins-official`, `anthropics/skills`, `pitimon/claude-cybersecurity-skill`, плюс сам этот репозиторий |
| **Плагины** | superpowers, frontend-design, example-skills, document-skills, claude-api, academy-guide, discernment-nudge, cybersecurity-pro, skills-ai |
| **MCP** | `context7` (актуальная документация библиотек), `playwright` (управление браузером) |

## Плагин `skills-ai`

Сам репозиторий одновременно является маркетплейсом и плагином. Плагин даёт:

- **SessionStart-хук** — печатает [`BRIEF.md`](BRIEF.md) в начале каждой новой
  сессии (`startup` и `/clear`, но не после сжатия контекста);
- **`/skills-brief`** — показать выжимку вручную в любой момент.

Текст выжимки правится в `BRIEF.md` — код трогать не нужно. Claude Code держит
копию плагина в своём кэше, поэтому после правки примени её:

```powershell
.\install.ps1 -Refresh
```

(`claude plugin update` тут не поможет — он сравнивает версии и на неизменённой
`1.0.0` решит, что обновлять нечего. `-Refresh` снимает плагин и ставит заново.)

### Выключить автопоказ

Не удаляя плагин, задай переменную окружения:

```powershell
[Environment]::SetEnvironmentVariable('SKILLS_AI_BRIEF','off','User')
```

Либо отключить плагин целиком: `claude plugin disable skills-ai@skills-ai`.

## Структура

```
.claude-plugin/marketplace.json   репозиторий как маркетплейс
.claude-plugin/plugin.json        метаданные плагина
manifest.json                     что именно ставить (источник правды)
BRIEF.md                          текст выжимки
hooks/hooks.json                  регистрация SessionStart
hooks/run-hook.cmd                cmd/bash-полиглот (Windows + Unix)
hooks/session-start               сам скрипт вывода
commands/skills-brief.md          слэш-команда
install.ps1 / install.sh          бутстрап
```

`.gitattributes` форсирует `eol=lf`: `run-hook.cmd` — полиглот, и CRLF сломал бы
его bash-половину.

## Замечания

- `context7` работает без ключа с пониженным лимитом. Ключ — `npx ctx7 setup --claude`.
- `playwright` требует Node.js 18+; браузеры докачиваются при первом запуске.
- `document-skills` и `claude-api` дублируют скилы, встроенные в десктоп-приложение.
  Если мешают — `claude plugin disable document-skills@anthropic-agent-skills`.
- Личные настройки (`~/.claude/settings.json`), история и кэш плагинов
  в репозиторий не входят и между машинами не синхронизируются.
