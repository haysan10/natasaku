# DO_NOT_BUILD.md - NataSaku Forbidden Scope

## Purpose

Dokumen ini berisi daftar fitur, dependency, dan keputusan teknis yang tidak boleh dibuat untuk NataSaku MVP.

Tujuannya adalah mencegah scope creep dan menjaga aplikasi tetap offline-first, lokal, sederhana, dan privat.

---

## Absolute Forbidden Features

Jangan buat fitur berikut:

1. Login.
2. Register account.
3. User account.
4. Backend server.
5. Cloud sync.
6. Bank integration.
7. E-wallet integration.
8. Payment gateway.
9. Subscription billing.
10. Ads.
11. Analytics SDK.
12. Remote config.
13. Online AI recommendation.
14. Social sharing of financial data.
15. Multi-user account.
16. Public profile.
17. Chat/community feature.
18. Online dashboard.
19. Web admin panel.
20. API service.

---

## Forbidden Dependencies

Jangan tambahkan dependency seperti:

- Firebase Auth.
- Firebase Firestore.
- Firebase Realtime Database.
- Firebase Analytics.
- Firebase Crashlytics unless explicitly approved later.
- Supabase.
- Appwrite.
- Retrofit for remote backend.
- Google Sign-In.
- Facebook Login.
- Stripe.
- PayPal.
- Midtrans.
- Bank API SDK.
- Ads SDK.
- Mixpanel.
- Amplitude.
- Segment.
- Remote config SDK.
- Cloud storage SDK.

Note:
- Local Android file sharing via intent is allowed.
- Local notification is allowed.
- Local PDF/CSV generation is allowed.

---

## Forbidden Android Permissions

Avoid adding:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Unless a future approved technical reason exists. MVP should not need internet permission.

Also avoid unnecessary sensitive permissions:

- Contacts.
- Location.
- Camera.
- Microphone.
- SMS.
- Call logs.
- Account access.

---

## Forbidden Product Decisions

Do not decide to:

1. Require user to sign in before using app.
2. Store financial data online.
3. Sync user data to server.
4. Connect to bank automatically.
5. Categorize spending from bank transactions.
6. Send report by email automatically.
7. Add monetization before MVP.
8. Add ads banner.
9. Add social comparison.
10. Shame user for spending.

---

## Forbidden UX Copy

Never use:

- Kamu boros.
- Budget gagal.
- Kamu salah.
- Tidak disiplin.
- Pengeluaranmu buruk.
- Keuanganmu kacau.
- Harusnya kamu tidak belanja.
- Budget kamu hancur.
- Kamu terlalu banyak jajan.
- Ini kesalahanmu.

Use instead:

- Jatah hari ini terlewati.
- Budget akan disesuaikan.
- Pengeluaran bulan ini lebih tinggi dari rencana.
- Kamu bisa menyesuaikan nominal agar lebih nyaman.
- Kita atur pelan-pelan.

---

## Forbidden Architecture Patterns

Do not:

1. Put all code in MainActivity.
2. Put all business logic in Composables.
3. Query Room directly from Composables.
4. Pass Room entities directly to UI.
5. Use `Double` or `Float` for money.
6. Create God ViewModel.
7. Hardcode calculation logic in multiple places.
8. Use online-first architecture.
9. Add repository methods for remote sync.
10. Add fake backend placeholders.

---

## Forbidden UI Patterns

Do not:

1. Make dashboard too crowded.
2. Use aggressive red full-screen warning.
3. Use bank-like corporate rigid visual style.
4. Use childish gamification.
5. Use tiny money text.
6. Show status by color only.
7. Hide important actions in unclear menus.
8. Make add expense require too many steps.
9. Use confusing financial jargon.
10. Show scary warnings for normal spending.

---

## Forbidden Data Behavior

Do not:

1. Delete user data silently.
2. Restore backup without confirmation.
3. Export data without user action.
4. Share files automatically.
5. Log financial amounts in production logs.
6. Store user notes in crash logs.
7. Use destructive database migration without explicit development-only note.
8. Lose money due to rounding.
9. Store currency amount as decimal floating point.
10. Mix data from different periods without clear relation.

---

## Allowed Alternatives

Instead of login:
- Store preferences locally with DataStore.

Instead of cloud sync:
- Provide local backup/restore JSON.

Instead of bank integration:
- Provide fast manual expense input.

Instead of analytics:
- Use manual QA checklist.

Instead of online recommendation:
- Generate local report insights from local data.

Instead of payment:
- No monetization in MVP.

---

## Scope Creep Warning

If an agent suggests any forbidden feature, respond with:

```text
This is outside NataSaku MVP scope. Keep the app offline-first and local-only. Do not add login, backend, cloud sync, bank integration, analytics, ads, payment, or online features. Use the local-first alternative documented in DO_NOT_BUILD.md.
```

---

## Final Rule

When uncertain, choose the simpler local-only solution.
