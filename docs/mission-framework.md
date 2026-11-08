# Operation Nimitz — Mission Framework

**Status:** 0.2.0-dev mission-system foundation; not yet a playable/exported mission.  
**Mission folder:** mission/OperationNimitz.Altis  
**Active implementation branch:** feat/mission-system-foundation

This milestone extends the first SQF foundation with scripted contact progression, player-confirmed ROE, radio support endpoints, mission event journaling, sampled sortie telemetry, setup validation, and safer CAP/RTB gating.

## Implemented systems

- Mission bootstrap, shared phase validation, task helpers, diagnostic logging, and setup checks.
- Diary briefing and ready-room-to-aircraft progression.
- Phase-gated preflight, engine-start, taxi, and launch confirmation actions. Engine-start reporting requires the assigned aircraft engine to be running; launch reporting requires the aircraft to be airborne above 50 metres.
- AI wingman join-up order and sampled formation-distance monitoring when the pilot is already seated in an editor-placed aircraft. The group remains on hold fire.
- CAP station monitoring with configurable marker, radius, and on-station time.
- Optional editor-placed contact detection, player visual-identification confirmation, ROE-gated hostile declaration, and contact resolution.
- CAP/RTB progression waits for an active scripted contact to be resolved.
- Optional AWACS, tanker, carrier-control, and deck-crew status calls.
- Basic recovery gate requiring the assigned aircraft, grounded state, low speed, and proximity to the carrier.
- Debrief interaction with measured mission time, sampled airborne time, CAP time, sampled vehicle travel, maximum sampled altitude/speed, wingman state, contact state, and event count.
- Bounded in-memory event journal and RPT diagnostic logging.

## Required Eden setup

The repository still does not contain an Eden-generated mission.sqm. Create an Altis mission in Eden Editor, save it as OperationNimitz.Altis, and copy the SQF source from this folder into that mission directory. Add and verify all editor-placed objects before testing.

| Eden object | Variable name | Required | Notes |
|---|---|---:|---|
| Player unit | JOKER_1_1 | Yes | Assign player control in Eden. |
| Parked F/A-18E | ON_playerAircraft | Yes | Select the verified F/A-18E Super Hornet 2020 asset. |
| USS Nimitz object | ON_carrier | Yes | Must be the installed, verified carrier object. |
| CAP marker | ON_mrk_CAP | Yes | Place at the intended patrol station. |
| AI wingman pilot | ON_wingman | No | Assign the pilot unit, already seated in its aircraft. |
| AWACS support object/unit | ON_awacs | No | Optional; status-call reference only. |
| Tanker support object/unit | ON_tanker | No | Optional; status-call reference only. |
| Deck crew object/unit | ON_deckCrew | No | Optional; status-call reference only. |
| Scripted contact aircraft | ON_contactAircraft | No | Optional; select a verified AFR asset only after the mod is installed. |

Carrier control uses ON_carrier by default; an optional ON_atc object can override it.

### Contact hostility metadata

For a verified hostile contact, set the following in that object's Eden init field only after confirming its faction and role:

    this setVariable ["ON_isHostile", true, true];

Leave this unset or false for a non-hostile / unclassified contact. The player cannot use the hostile-declaration action until the contact is first detected, brought within the identification distance, and reported visually identified. Proximity alone never authorizes engagement.

## Sortie flow

1. The player reviews the diary briefing and walks to the assigned aircraft.
2. The player begins and completes the external preflight inspection.
3. The player boards the assigned aircraft and performs the actual installed-mod engine-start procedure. The startup report is gated on the engine being on.
4. The player performs the actual installed-mod taxi and launch procedure. The launch report is gated on the assigned aircraft being airborne above 50 metres.
5. The AI wingman controller issues a follow order only if the assigned pilot is already seated in an editor-placed aircraft.
6. The flight proceeds to the CAP marker and accumulates the configured on-station time while airborne and inside the radius.
7. If an optional scripted contact is configured, the mission detects it inside the configured mission-distance radius. The player must close to identification range and report visual identification. A hostile declaration is available only if the contact object is marked ON_isHostile=true.
8. The CAP timer may be satisfied while a contact is active, but RTB is held until contact state becomes RESOLVED.
9. The player returns in the assigned aircraft. The recovery monitor checks grounded state, speed below 25 km/h, and distance under 250 metres from the carrier object.
10. The player shuts down, exits the aircraft, and completes the debrief interaction on foot near the carrier.

## Scripted support calls

The mission provides status-call actions for AWACS, tanker, Nimitz control, and deck crew. Optional references are required for AWACS, tanker, and deck crew. Nimitz control defaults to the carrier object.

These are communications/status endpoints only. They do not spawn or fly support aircraft, implement a radar picture, direct AI sensors, refuel the player, animate deck crew, grant actual catapult clearance, or replace the selected mods' procedures.

## Configuration defaults

The defaults are initialized in scripts/core/initMission.sqf:

| Setting | Default | Meaning |
|---|---:|---|
| ON_capMarker | ON_mrk_CAP | CAP station marker. |
| ON_capRadius | 1200 m | Station boundary. |
| ON_capDuration | 120 s | Required accumulated on-station time. |
| ON_contactDetectionRange | 8000 m | Scripted mission-distance detection threshold. |
| ON_contactIdentificationRange | 2500 m | Player-confirmed identification range. |

The contact object is optional. When no ON_contactAircraft is assigned, contact handling is skipped and the CAP task can complete normally.

## Important implementation limits

- No mission.sqm is committed yet; a valid Eden scenario and exact editor assets are still required.
- Workshop aircraft, USMC, and carrier classnames have not been supplied or verified. No classnames are invented by this framework.
- The USS Nimitz Workshop listing's installability/compatibility status remains unresolved. Its advertised features are not treated as verified in-game capabilities.
- Player confirmation actions are not aircraft-system simulations.
- The contact detector is a distance gate, not radar, AWACS sensor fusion, or visual line-of-sight simulation.
- Hostile declaration depends on manually verified Eden metadata and player confirmation. No weapon is fired automatically.
- Wingman behavior is basic AI follow/formation control. There is no automatic aircraft spawning, pilot boarding, advanced BVR tactics, or carrier recovery logic.
- Recovery proximity is not proof of a successful arrested landing or hook/cable engagement.
- Telemetry uses periodic position samples and game time. It is not a calibrated flight-data recorder and does not measure fuel, stores, damage, or carrier-wire engagement.
- No ARMA 3 runtime test has been performed in this environment. Run the mission in-game and inspect the RPT before treating it as playable.

## Next dependency-gated work

1. Verify/install the Workshop dependencies and provide exact editor classnames for the F/A-18E, USMC units, carrier, support aircraft, and AFR contact assets.
2. Build and commit the Eden-generated mission.sqm from the verified editor setup.
3. Integrate actual aircraft startup, launch, tanker, carrier-control, and recovery features only where the installed mods expose documented and tested interactions.
4. Run the scripted sortie in ARMA 3, correct SQF/RPT errors, and test normal, missing-object, lost-wingman, destroyed-contact, and failed-recovery cases.