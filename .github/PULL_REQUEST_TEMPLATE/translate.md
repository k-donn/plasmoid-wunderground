---
name: Translation
about: Add/correct/extend a translation for this widget.
title: Add/update translation for [LOCALE_CODE eg. es_MX]
labels: translation
assignees: k-donn
---

**Instructions**

1. Copy [`template.pot`](./plasmoid/translate/template.pot) to `[LOCALE_CODE eg. es_MX].pot` and populate with your translations.

2. Then, run the `merge.sh` script in the `translate` folder which updates `ReadMe.md` in that folder and `metadata.desktop`.

3. Test your translations by running the `build.sh` script, and use the `plasmoidlocaletest` script with the locale as an argument to run the plasmoid with the new locale. 

4. Commit these changes into the PR!
