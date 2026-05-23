# docs/accessibility-guidelines.md - NataSaku Accessibility Guidelines

## Goal

NataSaku must be usable by people with different visual, motor, and cognitive needs.

Target:
- Android accessibility best practices.
- TalkBack-friendly UI.
- Touch target minimum 48dp.

## Core Requirements

1. Every interactive target minimum 48dp.
2. Every icon-only button has contentDescription.
3. Decorative icons use `contentDescription = null`.
4. Status must include text label, not only color.
5. Inputs must have visible labels.
6. Error messages must be close to related fields.
7. Charts/progress indicators must have text summary.
8. UI must support system font scaling.
9. Motion must be short and non-essential.
10. Dialogs must have clear title and action labels.

## Touch Targets

Minimum:
- 48dp width.
- 48dp height.

Applies to:
- Buttons.
- FAB.
- Icon buttons.
- Chips.
- Transaction rows.
- Settings rows.
- Dialog actions.
- Bottom sheet options.

## Screen Reader Labels

| Component | contentDescription |
|---|---|
| Back button | Kembali |
| Settings icon | Buka pengaturan |
| Add FAB | Catat pengeluaran |
| Edit transaction | Edit transaksi |
| Delete transaction | Hapus transaksi |
| Share file | Bagikan file |
| Open file | Buka file |
| Download PDF | Download PDF |
| Export CSV | Export CSV |

## Status Accessibility

Bad:
- Showing green/orange/red only.

Good:
- Green + “Aman”.
- Orange + “Waspada”.
- Red + “Melewati Batas”.

## Form Accessibility

Every field needs:
- Label.
- Keyboard type.
- Error state.
- Error message.

## Progress Accessibility

Progress bar must have text summary.

Example:
> Terpakai Rp420.000 dari Rp1.800.000.

For saving:
> Terkumpul Rp300.000 dari target Rp1.000.000.

## Text Scaling

Test with larger system font size.

Critical screens:
- Home Dashboard.
- Add Expense Bottom Sheet.
- Warning Dialog.
- Transaction History.
- Monthly Report.
- Settings.

## Accessibility QA Checklist

- [ ] All icon buttons have labels.
- [ ] All form fields have labels.
- [ ] All errors are text, not color only.
- [ ] All status indicators include labels.
- [ ] Touch targets are 48dp minimum.
- [ ] Home dashboard can be understood by TalkBack.
- [ ] Add Expense can be completed with screen reader.
- [ ] Dialog buttons are clear.
- [ ] Text scaling does not break main flows.
- [ ] Dark mode contrast is acceptable.
