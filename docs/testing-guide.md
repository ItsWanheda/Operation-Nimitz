# Operation Nimitz — Eden Setup and Test Guide

This guide covers the 0.3.0-dev SQF mission framework and the manual classname deployment system.

## Before opening the mission

1. Install and verify the F/A-18F Super Hornet 2020, USMC 2026, and intended USS Nimitz Workshop assets.
2. Confirm the carrier Workshop item's current installability and compatibility in your ARMA 3 launcher.
3. Open `mission/OperationNimitz.Altis/config/assetConfig.sqf` and enter your exact classnames.
4. Create every map marker referenced by the configured deployment rows.
5. Copy the mission folder into an Eden-created Altis mission named `OperationNimitz.Altis`.
6. Preview the mission and inspect the RPT for missing markers, invalid classnames or failed spawns.

## Manual asset configuration

All assets are configured in `config/assetConfig.sqf`. It contains classname keys for the carrier, F/A-18F aircraft, pilots, support aircraft, USMC and AFR infantry, cars, APCs, IFVs, tanks, AA, artillery, mortars, static weapons, helicopters, aircraft and convoy vehicles.

The deployment list controls where each configured classname appears. Use `UNIT` for infantry and `VEHICLE` for vehicles, aircraft, carriers and static weapons. Set `createCrew` according to whether the vehicle should create its own native crew. You can assign mission references such as `ON_carrier`, `ON_playerAircraft`, `ON_wingman`, `ON_awacs`, `ON_tanker` and `ON_deckCrew`.

Every enemy deployment row should have its own marker and keep `requireUniqueMarker=true`. Convoys use separately named ordered route markers and classname keys. For the exact row format, examples and instructions for adding unlimited custom rows, see [Manual Asset and Classname Configuration](asset-classname-config.md).

## First-preview checklist

- Confirm the mission loads without an SQF compile error.
- Confirm the RPT reports configured asset spawns and no invalid classnames or missing markers.
- Confirm the USS Nimitz object appears at its sea marker and the player F/A-18F appears at its flight-deck marker.
- Confirm the wingman aircraft and pilot are created and the pilot is seated in the configured aircraft.
- Confirm optional AWACS, tanker and deck-crew references resolve when configured.
- Confirm every infantry/vehicle deployment appears at its intended marker and on the intended side.
- Confirm each enemy spawn is at a unique marker.
- Confirm all convoy vehicles start at their assigned route markers and follow the ordered route.
- Confirm the diary contains Mission, Situation, Rules of Engagement, and Communications.
- Complete preflight, startup, taxi and launch using the actual aircraft-mod procedures.
- Verify the CAS timer accumulates only while airborne inside the configured area.
- Verify ROE/contact actions follow the configured hostile metadata.
- Verify CAS does not transition to RTB until the player reports the target area clear.
- Return to the carrier and verify the basic grounded/speed/distance recovery gate.
- Exit the aircraft and complete the debrief on foot near the carrier.

## Optional support-call checks

Assign verified `ON_awacs`, `ON_tanker`, and `ON_deckCrew` assets. `ON_atc` defaults to `ON_carrier`. Request each status call and verify missing/dead references are reported as unavailable rather than silently treated as operational.

## Diagnostics

Mission diagnostics are written to the ARMA 3 RPT with the prefix:

    [OperationNimitz]

Check the RPT for undefined variables, missing assets, invalid classnames, failed object creation, SQF syntax errors, invalid task states, and script termination messages. The in-memory event journal is capped at 100 entries and is summarized by the debrief.

## Test scenarios still required

- Empty classname field, invalid classname and missing marker.
- Duplicate enemy spawn marker and duplicate convoy route marker.
- Wrong asset type entered into a UNIT row or VEHICLE row.
- Crew-enabled and empty vehicles; faction-correct crew verification.
- Wingman pilot missing, pilot unable to enter aircraft, and aircraft missing.
- Carrier spawn in water, aircraft spawn on deck, and object placement collisions.
- Multiple convoys with independent route markers.
- Full end-to-end sortie with the actual F/A-18F and USS Nimitz mods loaded.

No in-game tests have been run by this repository automation.
