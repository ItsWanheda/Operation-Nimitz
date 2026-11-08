# Operation Nimitz — Mission Framework Foundation

**Status:** 0.1.0-dev foundation; not yet a playable/exported mission.  
**Mission folder:** `mission/OperationNimitz.Altis`

This commit starts the actual SQF mission system. It provides a single-player mission bootstrap, shared phase/task/message functions, briefing, player-confirmed flight-deck progression, a CAP station timer, a basic carrier recovery gate, contact-state/ROE scaffolding, and a debrief action.

## What is implemented

- Mission metadata and SQF bootstrap.
- Mission phases: `BRIEFING`, `PREFLIGHT`, `STARTUP`, `IN_FLIGHT`, `RTB`, `DEBRIEF`, `COMPLETE`.
- Shared diagnostic logging, radio-style message, task creation, and task-state helpers.
- Diary briefing and initial briefing task.
- Aircraft actions that record the player's confirmation of preflight, startup, and launch progression.
- CAP station monitoring using a named Eden marker and configurable radius/on-station duration.
- Basic recovery detection using a carrier object reference, grounded state, speed, and proximity.
- A debrief interaction on the carrier.
- Contact state model with a strict `HOSTILE_CONFIRMED` gate; no enemy spawning or automatic engagement is implemented.

## Required Eden setup

The repository does not yet contain a valid `mission.sqm`. Create/open an Altis mission in Eden Editor, save it as `OperationNimitz.Altis`, then copy the SQF source from this folder into that mission directory. Export/commit the Eden-generated `mission.sqm` only after the actual mod assets and object classnames have been verified.

Assign these variable names in Eden's object attributes:

| Eden object | Variable name | Purpose |
|---|---|---|
| Player unit | `JOKER_1_1` | Player slot; assign player control in Eden |
| Player's parked F/A-18E | `ON_playerAircraft` | Aircraft used for flight progression actions |
| Carrier object | `ON_carrier` | Recovery proximity reference and debrief action |
| AI wingman aircraft/unit | `ON_wingman` | Reserved for future wingman AI controller |
| CAP marker | `ON_mrk_CAP` | Center of CAP station; create an Eden marker |

**Do not guess classnames.** Select the aircraft, carrier, and unit assets from the installed editor lists after confirming the Workshop mods load. The F/A-18E, USMC 2026, and USS Nimitz Workshop references are recorded in the root README/checklist. The USS Nimitz listing currently has availability/compatibility warnings, so the carrier remains a hard setup dependency to resolve.

## How the current flow works

1. Player starts in the ready-room location selected in Eden.
2. Player walks to the parked aircraft and uses **Report preflight inspection complete**.
3. After performing the actual mod-supported startup procedure, player uses **Report engine start and checks complete**.
4. After physically completing taxi and launch using the selected carrier/aircraft mod procedures, player uses **Report taxi and launch complete**.
5. The mission tracks entry into the CAP marker radius while airborne and requires 120 seconds on station (configurable).
6. The mission assigns RTB and monitors for a grounded aircraft within 250 metres of the carrier at less than 25 km/h.
7. A debrief interaction is added to the carrier object.

The flight-deck actions are **player-confirmation gates**, not simulated aircraft systems. The CAP/recovery checks are basic mission logic, not a radar, catapult, arresting-wire, or naval aviation systems simulation.

## Configuration

The defaults are set in `scripts/core/initMission.sqf`:

- `ON_capMarker`: marker name, default `ON_mrk_CAP`.
- `ON_capRadius`: CAP station radius, default 1200 metres.
- `ON_capDuration`: required on-station time, default 120 seconds.

The first build intentionally uses short on-screen messages rather than requiring a radio mod. AWACS/tanker/ATC assets, enemy aircraft, exact classnames, real aircraft startup controls, carrier catapult operation, arresting gear, and AI carrier recovery are not implemented until the relevant dependencies are verified.

## Known limitations / next implementation steps

- [ ] Build and validate an Eden `mission.sqm` after verifying the exact installed assets.
- [ ] Confirm the aircraft object/action behavior with the F/A-18E mod; make actions available at the intended ready-room/flight-deck positions.
- [ ] Implement a proper player/wingman join-up controller using verified unit references and AI behavior.
- [ ] Replace player-reported startup/taxi/launch gates with real mod-supported interactions where available.
- [ ] Validate the CAP marker and on-station condition in-game.
- [ ] Select and verify AFR contact assets and implement detection/identification without bypassing ROE.
- [ ] Verify USS Nimitz installability, catapult, hook, cable, and recovery features; do not infer them from the Workshop description.
- [ ] Expand debrief with measured mission events and aircraft state only when reliable data sources exist.
- [ ] Run the mission in ARMA 3 and inspect the RPT; this code has not yet been runtime-tested in the game.
