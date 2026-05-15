# prompts/review-code.md

## Target

Antigravity

## Use When

Gunakan prompt ini untuk meminta Antigravity melakukan review kode setelah satu track atau beberapa perubahan selesai.

## Prompt

```text
Review implementasi NataSaku saat ini.

Sebelum review, baca:

1. README.md
2. DO_NOT_BUILD.md
3. PROJECT_STRUCTURE.md
4. IMPLEMENTATION_ORDER.md
5. MVP_CHECKLIST.md
6. conductor/index.md
7. conductor/product.md
8. conductor/product-guidelines.md
9. conductor/tech-stack.md
10. conductor/workflow.md
11. conductor/tracks.md
12. docs/README.md
13. docs/testing-checklist.md
14. docs/release-checklist.md
15. docs/accessibility-guidelines.md
16. docs/copywriting.md

Review fokus pada:

1. Product scope:
   - Apakah fitur sesuai MVP?
   - Apakah ada scope creep?
   - Apakah ada fitur terlarang?

2. Architecture:
   - Apakah layer presentation/domain/data terpisah?
   - Apakah business logic finansial berada di domain?
   - Apakah Composable hanya mengurus UI?
   - Apakah Room entity tidak bocor ke UI?
   - Apakah repository dan use case digunakan dengan benar?

3. Offline-first:
   - Apakah app tetap local-only?
   - Apakah ada dependency atau permission internet yang tidak perlu?
   - Apakah ada backend/cloud/login/bank integration?

4. Money and calculation:
   - Apakah uang menggunakan Long?
   - Apakah tidak ada Double/Float untuk currency?
   - Apakah rumus budget sesuai docs/calculation-rules.md?
   - Apakah edge case calculation ditangani?

5. UI/UX:
   - Apakah UI mengikuti Material Design 3?
   - Apakah theme token digunakan?
   - Apakah dashboard tidak terlalu penuh?
   - Apakah Add Expense cukup cepat?
   - Apakah dark mode aman?

6. Copywriting:
   - Apakah copy bahasa Indonesia?
   - Apakah tone ramah dan tidak menghakimi?
   - Apakah tidak ada kata seperti “kamu boros”, “budget gagal”, “kamu salah”, atau “tidak disiplin”?

7. Accessibility:
   - Apakah touch target minimal 48dp?
   - Apakah icon-only button punya contentDescription?
   - Apakah status tidak hanya bergantung pada warna?
   - Apakah input punya label?
   - Apakah progress punya text summary?

8. Testing:
   - Apakah unit test ada untuk calculation penting?
   - Apakah DAO/ViewModel/UI test ada atau TODO jelas?
   - Apakah test relevan dijalankan?

Do not modify code during this review unless explicitly asked. This is a review-only task.

Output format:

Review Summary:
- ...

Pass:
- ...

Issues:
1. Severity: Critical / High / Medium / Low
   Area:
   File:
   Problem:
   Why it matters:
   Recommended fix:

Forbidden Feature Check:
- Login:
- Backend:
- Cloud sync:
- Bank integration:
- Analytics:
- Ads:
- Online-only feature:

Architecture Check:
- ...

Testing Gaps:
- ...

Required Fixes Before Continuing:
- ...

Suggested Improvements:
- ...
```
```
