# Operation Nimitz — Eden Setup and Test Guide

This guide covers the current 0.2.0-dev SQF framework. It does not replace the dependency/classname verification checklist.

## Before opening the mission

1. Install and confirm the F/A-18E Super Hornet 2020 dependency.
2. Confirm whether the USS Nimitz Workshop item can currently be installed and loaded. Do not substitute an unverified carrier.
3. Confirm the USMC 2026 and any chosen AFR/support assets load in the editor.
4. Create an Altis mission named OperationNimitz.Altis and copy the repository's mission-folder scripts into it.
5. Place the player, assigned F/A-18E, carrier, and CAP marker. Use the exact variable names in mission-framework.md.
6. Place the AI wingman pilot inside its assigned aircraft before previewing. Assign ON_wingman to the pilot unit, not the aircraft.
7. Optional: place a verified contact asset and assign ON_contactAircraft. Mark it hostile only after confirming the asset's faction and intended role.

## First-preview checklist

- Confirm the mission loads without an SQF compile error.
- Confirm the diary contains Mission, Situation, Rules of Engagement, and Communications.
- Confirm the setup log reports all mandatory editor references present.
- Walk to the parked aircraft and start the preflight action.
- Complete the external preflight and report it complete.
- Board the assigned aircraft and verify that engine-start reporting is unavailable with the engine off.
- Start the engine using the actual aircraft-mod procedure and verify that the startup report becomes available.
- Perform the actual carrier taxi/launch procedure. Verify the launch report is unavailable while grounded and available only after becoming airborne above 50 metres.
- Verify wingman follow/hold-fire behavior if the AI pilot was configured.
- Enter the CAP marker while airborne and verify station time accumulates.
- If a contact is configured, verify it is detected only within the scripted distance threshold; confirm visual identification is unavailable outside the configured identification range.
- Verify that an unmarked contact cannot be declared hostile. For a verified hostile test object, set ON_isHostile=true in its Eden init field and confirm the declaration action appears only after identification.
- Verify that CAP does not transition to RTB while contact state is UNKNOWN, IDENTIFIED, or HOSTILE_CONFIRMED.
- Resolve the contact, complete the CAP timer, and return to the carrier in the assigned aircraft.
- Verify recovery requires the assigned aircraft to be grounded, below 25 km/h, and within 250 metres of the carrier object.
- Exit the aircraft and complete the debrief on foot near the carrier.
- Confirm the debrief contains only the measured data listed in the framework documentation.

## Optional support-call checks

Assign ON_awacs, ON_tanker, and ON_deckCrew to verified editor objects/units. ON_atc is optional because it defaults to ON_carrier. Request each status call and verify that missing/dead references are reported as unavailable rather than silently treated as operational.

## Diagnostics

Mission diagnostics are written to the ARMA 3 RPT with the prefix:

    [OperationNimitz]

Check the RPT after each preview for undefined variables, missing objects, SQF syntax errors, invalid task states, and script termination messages. The in-memory event journal is capped at 100 entries and is summarized by the debrief.

## Test scenarios still required

- Missing mandatory aircraft, carrier, and CAP marker references.
- Missing optional support objects and missing optional contact object.
- Wingman not mounted, wingman destroyed, and wingman unable to join.
- Contact detected, classified non-hostile, confirmed hostile, destroyed before identification, and lost outside the detection radius.
- CAP timer reset when leaving the station and held RTB while a contact remains unresolved.
- Aircraft destroyed before recovery and recovery attempted in an unassigned vehicle.
- Full end-to-end sortie with the actual F/A-18E and USS Nimitz mods loaded.

No in-game tests have been run by this repository automation.