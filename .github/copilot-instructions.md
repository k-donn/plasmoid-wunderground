<!-- Copilot / AI agent instructions for plasmoid-wunderground -->
# Copilot Instructions — plasmoid-wunderground

Summary
- This is a KDE Plasma 6 applet (KPackage: Plasma/Applet) that displays Wunderground PWS data.
- UI lives in the QML folder: plasmoid/contents/ui. Business logic and API handling live in JavaScript under plasmoid/contents/code (notably `pws-api.js` and `utils.js`).
- Localization and translations are under `plasmoid/translate` and `plasmoid/locale`.

Big picture
- The widget is a self-contained Plasma applet (see [plasmoid/metadata.json](plasmoid/metadata.json#L1)).
- UI: QML components assemble views (main.qml, DetailsItem, ForecastItem, DayChartItem, SwitchPanel). Browse [plasmoid/contents/ui](plasmoid/contents/ui) for examples of layout and interaction patterns.
- Logic: `plasmoid/contents/code/pws-api.js` makes HTTP requests using XMLHttpRequest and normalizes responses via callback-style functions. `plasmoid/contents/code/utils.js` defines global enums (`UNITS_SYSTEM`, `PRES_UNITS`), mappings (icon maps, unit conversions), and helpers used across QML.

Developer guidance (actionable)
- When changing API requests, update `pws-api.js` and respect the existing callback signatures (err-first callbacks). Example: `_httpGet(url, cb) -> cb(err, res, status, raw)`.
- Modify unit mappings or conversion logic in `utils.js` (see `UNITS_SYSTEM`, `TEMP_UNITS`, `PRES_UNITS` and conversion helpers like `mbToInhg`).
- UI changes should be made in QML under `plasmoid/contents/ui` and its `lib/` subfolder for shared components (e.g. `StationSearcher.qml`, `StationMapSearcher.qml`). Use the pattern of small reusable QML items rather than monolithic files.
- Debugging: code uses `printDebug(...)` and Qt includes (`Qt.include("utils.js")`), so run-time testing should be done inside a Plasma/QML environment where `Qt` globals exist. There are no repository test harnesses — assume manual verification in Plasma.

Project-specific conventions & patterns
- Global helper loading: QML/JS files guard against static analysis by wrapping `Qt.include` in try/catch and providing a fallback `Utils` object when `Qt` is not available. When editing, preserve these guards to keep files runnable in static analyzers.
- Callback style: the JS modules use traditional Node-style error-first callbacks (not promises/async). Keep this style for consistency when adding new API methods.
- Icon mapping: `utils.js` contains two icon-theme maps (`iconThemeMapPredefined` and `iconThemeMapSymbolic`). Update both when adding new icon mappings.
- Units & sections: `pws-api.js` maps internal `UNITS_SYSTEM` values to API query codes via helpers `_unitsToQuery` and `_unitsToSection`. Change both helpers together to avoid mismatches.

Integration points & external dependencies
- External API: Wunderground endpoints are used via `Utils.getAPIHost()` + paths in `pws-api.js`. Search for `getAPIHost` in `utils.js` and use that to control host selection.
- KDE/Plasma runtime: the applet assumes Plasma 6 APIs (see `X-Plasma-API-Minimum-Version` in metadata.json). Changes that rely on newer Plasma APIs should update metadata accordingly.
- Translations: when adding strings, run the existing `*.po` workflow (translations are in `plasmoid/translate` and compiled into `plasmoid/locale` for packaging).

What to watch for (gotchas visible in code)
- Many QML properties are named `cfg_*` in configuration bindings; a known Plasma bug can emit `Setting initial properties failed: <COMPONENT> does not have a property called cfg_XXXX` — this is expected and not always fatal (see README Known Problems).
- Network error handling: `_httpGet` returns parsed JSON only when present; non-JSON responses may produce null `err` but still include `raw` text. Preserve this behavior in new handlers.
- Heavy files: `pws-api.js` and `utils.js` are long single-file modules. Prefer refactoring into small helpers only when you can run/validate the widget in Plasma.

Examples (where to change things)
- Add an API parameter or change JSON parsing: edit [plasmoid/contents/code/pws-api.js](plasmoid/contents/code/pws-api.js#L1).
- Change unit labels or conversions: edit [plasmoid/contents/code/utils.js](plasmoid/contents/code/utils.js#L1).
- Update UI layout or add a tab: edit [plasmoid/contents/ui/SwitchPanel.qml](plasmoid/contents/ui/SwitchPanel.qml#L1) or the specific item files under `ui/`.

Missing/unknown items for maintainers
- There are no automated test scripts or CI steps documented in the repository. If you maintain CI or local run instructions, add them to README.md or a `CONTRIBUTING.md` and update this file.

If something looks wrong
- Run small, focused changes and verify in Plasma (the codebase lacks unit tests). Ask the repo owner for recommended local dev commands (plasmoid packaging/installation steps) if you need them.

Next steps for the agent
- Prefer targeted edits (update a single helper and the UI component that consumes it). Ask the repo owner where they prefer packaging/build steps to be documented.

-- End
