# Batch 04 — Stitch edit prompts (Tenant & Tenancy Management)

The six Batch 04 screens already exist in the Stitch project
"Resido Mobile Design System" (16–21). The edits below fix scope and
consistency issues found in review. The Stitch MCP `edit_screens` call
timed out (2026-10-13) without applying changes, so apply each prompt in
the Stitch UI by selecting the screen and pasting its prompt.

Shared facts to keep consistent across screens:
- Suresh Kumar · +91 98470 23411 · Palm Grove Enclave, Unit 101,
  Ground Floor, 3 BHK · Panampilly Nagar, Kochi – 682036 · ₹24,000/month ·
  ₹72,000 deposit · 01 Oct 2023 – 31 Aug 2024.

---

## 16. Tenant List

Make small content refinements only. Keep the existing layout, colors, typography, cards, chips, bottom navigation and spacing exactly as they are. Do not redesign.
1. App bar: change the title "16. Tenant List" to "Tenants" (keep the small "Resido Kerala" eyebrow, same style as the Property List screen).
2. Remove identity-verification indicators: the small "verified" icons next to tenant names and the "KYC Done" and "Draft" badges. Keep the tenancy status badges (Active, Due 4d Ago, Unassigned, Completed).
3. Palm Grove Enclave units are 3 BHK: change "Ground Floor · 2BHK Heritage Wing" and "Ground Floor · 2BHK Garden Facing" to "Ground Floor · 3 BHK".
4. Former tenant card (Firoz Khan): change the "Ledger History" action label to "Profile".
5. Empty state body text: "Add your first tenant to keep their contact details in one place and link them to a unit in your portfolio."
Keep all names, phone numbers, ₹ rents, search, filter chips, the "Demo Empty" toggle and the "+ Add Tenant" button.

## 17. Add Tenant

Make small content refinements only. Keep the existing layout, colors, typography, cards and buttons. Do not redesign.
1. App bar title: "Add Tenant" (remove the "17." prefix).
2. Remove the "Tenant Photo / ID Badge" upload block entirely.
3. Phone field: label "Mobile Number *" (required), keep the 🇮🇳 +91 prefix and numeric keypad; helper text "Used to call or WhatsApp the tenant".
4. Email field helper text: "Optional — used to share rent receipts". Remove the mention of digital tenancy agreements and GST e-invoices.
5. Remove the "+ ID Verified" quick tag.
6. Success toast: title "Tenant saved", subtitle "You can now assign them to a unit".
Keep Full Name *, Email (Optional), Profile Notes with counter, quick tags, "What happens next?", Save Tenant and Cancel.

## 18. Tenant Details

Make small content refinements only. Keep the existing layout, colors, typography and cards. Do not redesign.
1. App bar title: "Tenant Details" (remove the "18." prefix).
2. Remove the "KYC Verified" badge, the "Verified" label next to the mobile number and the verified icon next to the name.
3. Email: "suresh.kumar@example.in". Landlord memo: "Senior consultant at an Infopark IT firm. Permanent residence in Thrissur. Prefers UPI payment on the 1st of every month."
4. Remove the "Assign Another Unit" row, the "Share Tenant Record — Export ledger & police verification summary" row and the "Resido Secure Vault · Encrypted Kerala Rental Records" footer.
Keep Call, WhatsApp, Edit Profile, the Current Tenancy card with "View Tenancy Details", the unassigned-state demo with "+ Assign to Unit", and "Archive Tenant Profile".

## 19. Edit Tenant

Make small content refinements only. Keep the existing layout, colors, typography and buttons. Do not redesign.
1. App bar title: "Edit Tenant" (remove the "19." prefix).
2. Remove the "Verified ID" badge on the Full Name field.
3. Phone label: "Mobile Number *" (required), matching Add Tenant.
4. Linked tenancy card: "Palm Grove Enclave • Unit 101" and "Panampilly Nagar, Kochi • ₹24,000/mo".
5. Notes text: "Senior consultant at an Infopark IT firm. Permanent residence in Thrissur. Prefers UPI payment on the 1st of every month." Prefill email "suresh.kumar@example.in" and mobile "98470 23411".
6. Success toast: title "Changes saved", no other claims.
Keep the Tenancy Details link, Save Changes, Cancel and the Danger Zone.

## 20. Assign Tenant

Make small content refinements only. Keep the existing layout, steps, colors, typography and buttons. Do not redesign.
1. App bar title: "Assign Tenant" (remove the "20." prefix).
2. Remove the "VERIFIED KYC" label and the "Kerala ID Attached" text from the tenant card.
3. Security Deposit: remove the "Auto-calculate" toggle; the landlord types the amount. Helper text: "Refundable · entered by landlord".
4. Replace the stamp-registration / Travancore-Cochin guidelines note with: "End date is optional for open-ended tenancies."
Keep the property and vacant-unit selection (Units 201 and 202), Agreed Monthly Rent in ₹, rent due day, term presets, start and end dates, notes, the Assignment Summary, "Create Tenancy" and "Cancel & Discard".

## 21. Tenancy Details

Make small content refinements only. Keep the existing layout, colors, typography and cards. Do not redesign.
1. App bar title: "Tenancy Details" (remove the "21." prefix).
2. Tenant row: phone "+91 98470 23411"; make the row tappable with a chevron and the label "View Tenant Details".
3. Property row: "Palm Grove Enclave · Unit 101 (Ground Floor)", "Panampilly Nagar, Kochi · PIN 682036".
4. Financial terms: remove the "INR Escrow" badge and the word "Escrow"; show "Security Deposit ₹72,000 · 3 months". Remove the "Stamp Paper ₹200 e-Stamp Reg" item.
5. Remove the inline "Editing Tenancy Terms" form and the "Edit Terms" / "Edit Tenancy Terms" buttons.
6. End Tenancy: keep the button. Simplify its confirmation text to "End tenancy for Unit 101? Unit 101 will be marked vacant. Suresh Kumar stays in your tenant directory." with "Confirm" and "Keep Tenancy Active". Remove mentions of check-out protocol, move-out inspection and deposit settlement.
Keep the lease period progress, rent due day, notice period and utilities section.
