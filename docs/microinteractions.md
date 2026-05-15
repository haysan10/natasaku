# docs/microinteractions.md - NataSaku Microinteractions

## Purpose

Microinteractions should make NataSaku feel calm, responsive, and friendly without becoming distracting.

## Motion Principles

1. Subtle.
2. Fast.
3. Helpful.
4. Non-essential.
5. Accessible.
6. No excessive bounce.
7. No flashy animation.
8. No long blocking animation.

Recommended duration:
- 150ms for small feedback.
- 200-300ms for screen/content transition.
- 300ms max for most UI animations.

## Splash

Animation:
- Logo fade in.
- Slight scale from 0.96 to 1.0.

Avoid:
- Long splash.
- Loading spinner for online action.

## Onboarding

Animation:
- Horizontal pager slide.
- Dots indicator smooth transition.

## Setup Flow

Interactions:
- Step progress animates when moving forward.
- Form fields show gentle error transition.
- Total income/fixed expense updates with subtle number transition.

## Home Dashboard

Daily allowance card:
- Amount can crossfade/update when transaction changes.
- Progress bar animates from previous value to new value.
- Status chip crossfades between Aman/Waspada/Melewati Batas.

## Add Expense Bottom Sheet

Animation:
- Bottom sheet slides up.
- Nominal field autofocus.
- Save button shows brief loading if needed.

After save:
- Bottom sheet closes.
- Snackbar appears: “Pengeluaran berhasil dicatat.”

## Warning Overbudget Dialog

Animation:
- Fade in.
- Slight scale from 0.98 to 1.0.

Avoid:
- Aggressive shaking.
- Alarm sound.
- Strong red flash.

## Leftover Allocation Dialog

Interaction:
- Option card press state.
- Selected option briefly highlights.
- Confirmation snackbar: “Sisa jatah berhasil dialokasikan.”

## Transaction History

Interactions:
- Search updates list smoothly.
- Filter chips animate selected state.
- Delete uses confirmation dialog.
- After delete, row disappears with simple fade/slide if available.

## Saving Screen

Animation:
- Progress bar animates to current value.
- New allocation appears in history with subtle fade.

## Monthly Report

Animation:
- Summary cards can appear with subtle stagger.
- Export button shows loading state.
- Export success uses check icon scale/fade.

## Reduced Motion

If reduced motion is supported:
- Disable non-essential transitions.
- Keep state changes instant or minimal.
- Do not remove feedback entirely.

## Feedback Rules

| Action | Feedback |
|---|---|
| Save expense | Snackbar + dashboard update |
| Delete transaction | Confirmation + list update |
| Export file | Loading + success screen |
| Backup | Loading + success |
| Restore | Confirmation + success/error |
| Invalid input | Inline error |
| Overbudget | Dialog |
| Leftover allocated | Snackbar |
