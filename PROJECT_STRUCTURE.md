# NataSaku Repository Structure

Struktur folder repositori NataSaku setelah pembersihan dan restrukturisasi untuk persiapan rilis final:

```text
natasaku/
├── natasaku_flutter/        ← Sumber kode utama Flutter (satu-satunya target build)
│   ├── lib/                 ← Sumber kode Dart (app, core, data, features, shared)
│   ├── android/             ← Host native Android (build gradle kts, manifest)
│   ├── ios/                 ← Host native iOS
│   ├── test/                ← Unit & widget testing suite
│   ├── assets/              ← Branding assets (splash, logo)
│   ├── pubspec.yaml         ← Dependensi Flutter
│   └── pubspec.lock
├── docs/                    ← Seluruh dokumentasi produk & spesifikasi teknis
├── .github/                 ← CI/CD Workflows
├── _archive/                ← AI scaffolding graveyard (arsip tools development)
│   └── ai-scaffolding/
├── _releases/               ← Binari rilis APK (tidak berada di build path)
├── .gitignore
├── LICENSE                  ← MIT License
├── README.md                ← Petunjuk instalasi & penggunaan
├── CONTRIBUTING.md          ← Kontribusi pengembangan
├── CODE_OF_CONDUCT.md
├── SECURITY.md
└── PROJECT_STRUCTURE.md     ← File spesifikasi struktur ini
```
