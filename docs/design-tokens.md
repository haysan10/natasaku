# docs/design-tokens.md - NataSaku Design Tokens

## Visual Direction

NataSaku should feel:

- Clean.
- Calm.
- Friendly.
- Professional.
- Modern.
- Not corporate-bank rigid.
- Not childish.

Use:

- Material Design 3.
- Card-based layout.
- Large rounded corners.
- Soft tonal surfaces.
- Clean whitespace.
- Clear typography.
- Simple rounded icons.
- Teal/mint primary color.
- Off-white background.
- Dark mode support.

## Light Mode Colors

| Token | Name | Hex | Usage |
|---|---|---|---|
| primary | Nata Teal | `#0F9F8C` | Main CTA, FAB, selected states |
| primaryDark | Deep Teal | `#08786A` | Pressed state, strong accent |
| primarySoft | Mint Surface | `#DDF7F1` | Soft cards, selected chip background |
| secondaryMint | Calm Mint | `#7EDDC8` | Illustration accent |
| background | Soft Ivory | `#FAFBF7` | App background |
| surface | Clean White | `#FFFFFF` | Cards, sheets |
| surfaceVariant | Mist Gray | `#F1F5F3` | Section background |
| textPrimary | Charcoal | `#1D2523` | Main text |
| textSecondary | Slate Green Gray | `#66736F` | Secondary text |
| border | Soft Border | `#DDE7E3` | Borders/dividers |
| success | Aman Green | `#2EAD6B` | Safe status |
| warning | Waspada Orange | `#F59E3D` | Warning status |
| error | Soft Red | `#E85D5D` | Overbudget |
| errorSoft | Red Surface | `#FDECEC` | Error dialog/card background |
| info | Calm Blue | `#4A90E2` | Information |

## Dark Mode Colors

| Token | Hex | Usage |
|---|---|---|
| background | `#0F1514` | App background |
| surface | `#17201E` | Cards |
| surfaceVariant | `#20302D` | Elevated areas |
| primary | `#7EE5D3` | Main CTA/accent |
| primaryContainer | `#114D45` | Soft primary container |
| textPrimary | `#EEF7F4` | Main text |
| textSecondary | `#A8BBB5` | Secondary text |
| border | `#2E403B` | Border/divider |
| success | `#7DDC9D` | Safe |
| warning | `#F4B96A` | Warning |
| error | `#FF8A8A` | Overbudget |

## Typography

Recommended font:

- Android system default / Roboto.

Scale:

| Style | Size | Weight | Usage |
|---|---:|---|---|
| Display Small | 32sp | Bold | Main money amount |
| Headline Medium | 28sp | Bold | Onboarding headline |
| Headline Small | 24sp | Bold | Screen title |
| Title Large | 22sp | SemiBold | Section title |
| Title Medium | 16sp | SemiBold | Card title |
| Body Large | 16sp | Regular | Main body |
| Body Medium | 14sp | Regular | Subtitle/helper |
| Label Large | 14sp | SemiBold | Buttons |
| Label Medium | 12sp | Medium | Chips/captions |

## Spacing

Use 4dp/8dp grid.

| Token | Value |
|---|---:|
| screenPadding | 20dp |
| sectionSpacing | 24dp |
| cardPadding | 16-20dp |
| compactGap | 8dp |
| normalGap | 12dp |
| fieldGap | 16dp |
| largeGap | 24dp |
| pageBottomPadding | 32dp |

## Shape

| Token | Value | Usage |
|---|---:|---|
| small | 12dp | Small chips/input |
| medium | 16dp | Buttons |
| large | 24dp | Cards |
| extraLarge | 28dp | Bottom sheets/dialogs |

## Status Colors

Statuses must use color + text label.

- SAFE: label `Aman`, green accent.
- WARNING: label `Waspada`, orange accent.
- OVER_BUDGET: label `Melewati Batas`, soft red accent.

## Icon Style

Use:

- Rounded line icons.
- 20-24dp common size.
- 40-48dp circular icon container.
- Simple category icons.

## Dark Mode Direction

Rules:

- No pure black.
- No overly saturated red.
- Use charcoal/green surfaces.
- Primary mint should remain readable.
- Keep cards distinct from background.
- Use border if shadow is weak.

## Design QA Checklist

- [ ] Uses Material 3.
- [ ] Uses theme tokens.
- [ ] No random colors.
- [ ] Main amount is readable.
- [ ] Touch targets are large enough.
- [ ] Cards have consistent radius.
- [ ] UI has enough whitespace.
- [ ] Status not shown by color only.
- [ ] Dark mode readable.
- [ ] Dashboard is not crowded.
