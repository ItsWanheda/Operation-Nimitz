# Operation Nimitz — Mission-Building Checklist

> **Document status:** Planning baseline  
> **Mission type:** ARMA 3, single-player, full-MILSIM naval aviation  
> **Theatre:** Altis  
> **Initial sortie:** Combat Air Patrol (CAP) from a carrier  
> **Player flight:** JOKER 1-1 / AI wingman: JOKER 1-2

This checklist is the working implementation plan for Operation Nimitz. It deliberately separates confirmed project decisions from assets, classnames, and procedures that still require verification in the actual ARMA 3 installation.

## Status key

- [ ] Not started
- [x] Completed and verified
- [!] Blocked or requires a decision
- **Pending confirmation** means do not build mission logic around the assumption yet.
- **In-game verified** means tested with the exact enabled mod set and recorded in the project.

Do not mark a dependency, classname, capability, or procedure complete merely because it appears in a Workshop description, video, screenshot, or another person's loadout. Verify it in the installed game.

---

## 1. Mission baseline and design decisions

### 1.1 Established concept

- [x] Project name: **Operation Nimitz**.
- [x] Game: **ARMA 3**.
- [x] Mission format: **single-player**.
- [x] Simulation level: **full MILSIM**, not cinematic or simplified.
- [x] Theatre: **Altis**.
- [x] Friendly squadron: **VFA-103 Jolly Rogers**.
- [x] Player aircraft: **F/A-18E Super Hornet** (single-seat E variant).
- [x] Player callsign: **JOKER 1-1**.
- [x] AI wingman callsign: **JOKER 1-2**.
- [x] Initial mission: **Combat Air Patrol (CAP)**.
- [x] Opposing force concept: **AFR / Altis Armed Forces**.
- [x] AI controls the wingman and supporting units; the player directly flies the lead aircraft.

### 1.2 Mission design decisions to document

- [ ] Write a one-paragraph operational situation: friendly force posture, why the carrier is operating near Altis, the CAP objective, and what event starts the mission.
- [ ] Define the patrol area, station altitude, speed guidance, time on station, weather, visibility, wind, and time of day.
- [ ] Define the operational boundaries and keep-out areas.
- [ ] Define rules of engagement (ROE), identification requirements, escalation authority, abort criteria, and weapons-release conditions.
- [ ] Define the hostile-contact outcome paths: identify and monitor, intercept, escort away, engage only when authorized, or disengage.
- [ ] Define success, partial success, failure, abort, and emergency-recovery outcomes.
- [ ] Decide whether the first sortie is a standalone mission or the first chapter in a persistent campaign.
- [ ] Keep briefing claims consistent with what the mission actually simulates. Do not imply dynamic systems that are only scripted messages.

---

## 2. Repository and project setup

- [x] Repository created: [ItsWanheda/Operation-Nimitz](https://github.com/ItsWanheda/Operation-Nimitz).
- [x] Default branch: `main`.
- [x] Planning work belongs on `docs/mission-building-checklist`; do not commit mission work directly to `main`.
- [ ] Keep mission source, documentation, and any distributable package clearly separated.
- [ ] Agree on a mission naming convention, version format, and release-note format.
- [ ] Record the exact ARMA 3 version/build used for development and testing.
- [ ] Record the mod list, Workshop IDs, versions/update dates, and required load order for each test run.
- [ ] Keep a copy of the known-good mod preset/export with the release notes or project documentation.
- [ ] Do not commit game installations, Steam Workshop downloads, generated logs, caches, or large binary assets unless there is a deliberate licensing and repository-size decision.
- [ ] Use relative mission paths and avoid references to local absolute paths such as a particular Windows user directory.
- [ ] Keep secrets, personal data, and machine-specific configuration out of the repository.
- [ ] Check mod licenses and redistribution permissions before including third-party files in a release.
- [ ] Use focused commits and review each diff before pushing.

### Suggested mission source layout

This is a proposed organization, not a requirement to create empty files immediately. Add files when their functionality is implemented.

```text
Operation-Nimitz/
├── README.md
├── docs/
│   └── mission-building-checklist.md
└── mission/
    └── OperationNimitz.Altis/
        ├── mission.sqm
        ├── description.ext
        ├── init.sqf
        ├── initPlayerLocal.sqf
        ├── initServer.sqf
        └── scripts/
            ├── init/
            ├── briefing/
            ├── flight/
            ├── carrier/
            ├── ai/
            ├── comms/
            ├── tasks/
            ├── combat/
            └── debrief/
```

Create only the directories and files needed by the chosen implementation. Confirm the mission folder naming and multiplayer/single-player initialization behavior against the installed ARMA 3 tools before relying on any particular execution path.

---

## 3. ARMA 3 and Eden Editor prerequisites

- [ ] Confirm ARMA 3 launches cleanly with the intended mod preset.
- [ ] Confirm the installed game build and Eden Editor version.
- [ ] Confirm Altis is available and loads without missing-content warnings.
- [ ] Confirm Eden Editor can create, save, close, and reopen a minimal Altis test mission.
- [ ] Confirm the mission can be previewed locally and that the player slot behaves as expected.
- [ ] Confirm the intended game difficulty, difficulty options, AI skill settings, view distance, and HUD settings.
- [ ] Decide whether any optional frameworks or utility mods are genuinely required. **Do not silently introduce dependencies** such as ACE, CBA, or other frameworks without a documented need and compatibility test.
- [ ] Confirm how scripts will be tested and how RPT/diagnostic output will be collected on the development machine.
- [ ] Create a disposable test mission for discovering assets and testing carrier/aircraft behavior before integrating those experiments into the main mission.
- [ ] Confirm that a clean restart reproduces the same initial mission state.

### Editor and script validation

- [ ] Learn and record the exact Eden workflow used to place, group, name, synchronize, and export mission objects.
- [ ] Give important mission entities stable editor variable names; avoid relying on automatically generated names.
- [ ] Validate script paths and capitalization on the target operating system.
- [ ] Check the RPT after mission start, after each major phase, and after mission end.
- [ ] Treat script errors and missing-resource warnings as test failures until understood.

---

## 4. Workshop dependencies and asset verification

### 4.1 Known Workshop references

| Asset | Workshop ID | Current status | Required verification |
|---|---:|---|---|
| F/A-18E Super Hornet 2020 | [2131302796](https://steamcommunity.com/sharedfiles/filedetails/?id=2131302796) | Identified by project owner; **not yet confirmed in-game** | Installed version, prerequisites, exact E-variant vehicle classname, cockpit/startup behavior, flight model, pylons, weapons, animations, sounds, and carrier compatibility |
| USMC 2026 | [3752331810](https://steamcommunity.com/sharedfiles/filedetails/?id=3752331810) | Identified by project owner; **not yet confirmed in-game** | Installed version, prerequisites, required units, factions, equipment, exact classnames, and compatibility with the selected mission mod set |
| USS Nimitz carrier | [643530417](https://steamcommunity.com/sharedfiles/filedetails/?id=643530417) — USS Nimitz (Rory / TeTeTe3) | Identified; **installation and compatibility not verified** | Verify availability/installability, CBA_A3 dependency, carrier object classname, deck features, launch/recovery support, and compatibility with the F/A-18E mod |

**Important:** The Workshop item is now identified, but it is not yet a verified mission dependency. The Steam listing currently displays a removed-from-community notice and an ARMA 3 incompatibility warning. Its description identifies the carrier as a static, non-pilotable structure and advertises a walkable deck, four steam catapults, arresting gear, IFLOLS, hangar, elevators, and a briefing room. Treat those as **publisher-described features, not in-game test results**. The listing also names **CBA_A3** as a required item. Confirm that the item can be installed and loaded with the current game/mod set before depending on it.

### 4.2 Dependency verification checklist

For every required mod:

- [ ] Open the actual Workshop item and verify its title, author, item ID, current description, and update state.
- [ ] Subscribe/install the mod and allow Steam to complete the download.
- [ ] Read the mod's stated requirements and identify every required dependency.
- [ ] Check whether dependencies are bundled, optional, or separately required.
- [ ] Launch ARMA 3 with the complete intended mod preset and check for load errors.
- [ ] Record the installed mod version/build or the best available update identifier.
- [ ] Open Eden Editor and confirm the required assets appear in the expected editor categories.
- [ ] Place each required asset in a disposable test mission, preview it, and verify that it initializes.
- [ ] Record exact classnames from a reliable in-game/config inspection method; do not guess them from display names.
- [ ] Verify whether the asset is usable by the player, AI, or both.
- [ ] Test the actual functions the mission will use instead of relying on Workshop marketing text.
- [ ] Record known limitations, conflicts, missing textures, missing sounds, and performance costs.
- [ ] Re-run the tests after significant mod updates or changes to the mod preset.

### 4.3 Aircraft-specific verification

- [ ] Verify that the installed asset is specifically the **F/A-18E**, not the F/A-18F two-seat variant.
- [ ] Record the exact aircraft classname only after in-game verification.
- [ ] Confirm the cockpit is usable in the player seat and check required interaction/action controls.
- [ ] Verify startup, engine state, avionics, lights, canopy, control surfaces, and landing gear behavior actually available in this mod.
- [ ] Verify flight handling, fuel consumption, damage behavior, and AI flight behavior.
- [ ] Inspect available pylons and compatible stores.
- [ ] Verify each intended loadout in the editor and in flight; do not assume real-world compatibility equals mod implementation.
- [ ] Confirm whether external fuel tanks, missiles, bombs, or other stores are modeled and functional before including them in a briefing.
- [ ] Verify arrestor-hook behavior and any carrier-specific aircraft configuration.
- [ ] Verify whether catapult launch requires a script, an object interaction, a mod feature, or a manual procedure.

### 4.4 Carrier-specific verification

Once the USS Nimitz asset is selected:

- [ ] Confirm the carrier object classname and required dependencies.
- [ ] Place the carrier in a test mission and verify it appears at the intended Altis location.
- [ ] Verify deck geometry, walkable surfaces, collision, access points, and spawn positions.
- [ ] Verify the ready-room / briefing space or decide how it will be represented.
- [ ] Verify elevator behavior and aircraft movement between hangar and flight deck, if supported.
- [ ] Verify aircraft parking spots, deck crew, tie-down/arming workflow, and visual signals, if supported.
- [ ] Verify catapult locations, aircraft alignment, launch mechanics, and launch reliability.
- [ ] Verify arresting gear, arrestor-cable behavior, landing-area geometry, and recovery reliability.
- [ ] Verify carrier movement, speed, heading, wake, and position persistence as required by the scenario.
- [ ] Test AI navigation around the deck; do not assume AI can taxi safely on a carrier.
- [ ] Record which features are native to the carrier mod, supplied by another dependency, scripted by this mission, or not available.
- [ ] If a required function is unsupported, choose and document a realistic alternative before mission implementation proceeds.

---

## 5. Single-player roles and mission entities

### 5.1 Player and flight

- [ ] Place the player as **JOKER 1-1** in the verified F/A-18E.
- [ ] Create **JOKER 1-2** as an AI-controlled wingman.
- [ ] Decide and document wingman skill, formation, spacing, speed, altitude, radio behavior, and lost-wingman behavior.
- [ ] Define how the player gives wingman orders and what happens if the AI cannot comply.
- [ ] Ensure the wingman remains useful but does not steal control from or unexpectedly override the player.
- [ ] Define how the mission handles wingman damage, fuel shortage, separation, or loss.

### 5.2 Supporting roles

| Role | Intended responsibility | Implementation status |
|---|---|---|
| AWACS | Air picture updates, contact reports, tasking and handoff | Planned; platform, asset, radio system, and detection simulation pending |
| Tanker | Refueling support or divert option if included | Planned; aircraft, station, boom/basket compatibility, and interaction pending |
| ATC / carrier control | Deck clearance, launch/recovery sequencing, pattern instructions | Planned; may be mission-scripted communications; procedure and mod support pending |
| Deck crew | Aircraft preparation, safety cues, launch/recovery atmosphere | Planned; exact assets and functional capabilities pending |
| AFR forces | Hostile contacts and threat response | Planned; exact units, aircraft, equipment, and classnames pending |
| Other friendly units | Context, rescue, logistics, or defensive support if needed | Optional; define only where they serve a mission purpose |

- [ ] Decide which roles require a physical AI unit and which can be represented by scripted radio communications.
- [ ] Name critical AI units and groups consistently.
- [ ] Define fallback behavior if an optional AI unit dies, is unavailable, or fails to spawn.
- [ ] Avoid spawning decorative or ambient AI that do not contribute to gameplay or atmosphere.

---

## 6. Ready room, briefing, and flight planning

- [ ] Start the player in the ready-room area, not already seated in the aircraft.
- [ ] Verify the player can navigate from the starting position to the flight deck without getting stuck or falling through geometry.
- [ ] Provide a briefing board or equivalent readable briefing presentation.
- [ ] Include mission date/time, weather, carrier position/heading, friendly situation, threat estimate, and mission objective.
- [ ] Include a map with the carrier, CAP station, boundaries, navigation points, and known friendly locations.
- [ ] Include a flight plan with route order, altitude/speed guidance, expected timing, and recovery plan.
- [ ] Include the aircraft identity, assigned callsign, wingman, and verified loadout.
- [ ] Include comms plan: who speaks, expected callouts, and how the player receives information.
- [ ] Include ROE, lost-communications plan, bingo/fuel decision, divert/emergency options, and abort conditions.
- [ ] Include threat information only when supported by mission intelligence; label uncertainty clearly.
- [ ] Ensure briefing information matches the actual mission configuration and triggers.

---

## 7. Carrier flight-deck setup and aircraft preparation

- [ ] Establish and test the carrier position, orientation, speed, and heading.
- [ ] Confirm the flight deck is clear enough for the planned player and AI aircraft.
- [ ] Place the player aircraft and wingman at verified parking/start positions.
- [ ] Verify aircraft orientation, spacing, collision clearance, and access for the player.
- [ ] Place only verified deck crew and support equipment.
- [ ] Ensure deck crew do not block the player's route, aircraft movement, catapult path, or recovery area.
- [ ] Add clear visual cues for the player to find their aircraft and proceed through the sequence.
- [ ] Confirm the aircraft begins in the intended cold-and-dark or other selected state, using only supported mod behavior.
- [ ] Verify fuel, ammunition, stores, countermeasures, and damage state at mission start.
- [ ] Provide a preflight checklist or kneeboard-style reference that matches the mod's actual functions.
- [ ] Make any simulated checks explicit as simulated; do not label a scripted message as a functional aircraft systems check.

---

## 8. Preflight, startup, taxi, and catapult launch

**Procedure note:** Exact startup controls, engine sequence, taxi behavior, catapult workflow, launch bars, and deck signals are aircraft-/carrier-mod dependent. Treat every step below as a mission requirement to verify, not as a claim that a particular mod implements the procedure.

### 8.1 Preflight

- [ ] Verify the player can reach and enter the aircraft through the supported interaction.
- [ ] Confirm the mod's actual method for checking aircraft condition and configuration.
- [ ] Provide a checklist for exterior/visual inspection, flight controls, fuel, stores, canopy, and required equipment where supported.
- [ ] Confirm the mission records a preflight-complete state only after the required player actions or checks.
- [ ] Prevent launch while required safety/mission steps remain incomplete, unless an explicit emergency bypass is designed.

### 8.2 Startup

- [ ] Verify cold-and-dark state is supported and consistent at mission start.
- [ ] Identify the actual startup/engine controls and sequence from the mod documentation or in-game testing.
- [ ] Test engine start, avionics, displays, lights, canopy, and other systems that the mod exposes.
- [ ] Confirm a failed or interrupted startup does not soft-lock mission progression.
- [ ] Define what the AI wingman does during the player's startup.

### 8.3 Taxi and deck movement

- [ ] Verify whether the player aircraft can taxi reliably on the selected carrier deck.
- [ ] Define the taxi route, holding point, marshal point, and launch position using actual deck geometry.
- [ ] Check clearance from deck crew, parked aircraft, island structure, elevators, and deck edges.
- [ ] Determine whether the AI wingman can taxi or must be staged at a safe location and join later.
- [ ] Use explicit clearance/hold messages and state checks rather than assuming the player has reached a position.
- [ ] Provide a safe abort/hold path if taxi or alignment fails.

### 8.4 Catapult and launch

- [ ] Verify the carrier mod's actual catapult activation method and prerequisites.
- [ ] Verify the aircraft's required launch configuration and any mod-specific launch interaction.
- [ ] Confirm the player is correctly aligned and the launch area is clear.
- [ ] Ensure launch clearance is given only after the required checks are complete.
- [ ] Test launch behavior repeatedly at the selected carrier speed, heading, weather, and aircraft load.
- [ ] Confirm the aircraft does not collide with the deck, crew, or carrier structures.
- [ ] Define an alternate safe launch method only if the native launch feature is unreliable; document it as a mission workaround.
- [ ] Verify how and when JOKER 1-2 joins the player after launch.

---

## 9. AI wingman, AWACS, tanker, and ATC support

### 9.1 AI wingman

- [ ] Establish a reliable join-up after launch.
- [ ] Define formation and station-keeping behavior for transit and CAP.
- [ ] Test altitude, speed, waypoint, formation, and combat behavior under the chosen AI skill settings.
- [ ] Define radio acknowledgements for join-up, station, contact, engagement authorization, disengagement, and RTB.
- [ ] Add a recovery path for wingman separation or stuck AI.
- [ ] Ensure the player can continue the mission if the wingman is lost or disabled.

### 9.2 AWACS

- [ ] Decide whether AWACS is an actual in-world asset, a scripted controller, or a combination.
- [ ] Verify the selected asset and its detection/communication capabilities before depending on them.
- [ ] Define a contact report format: bearing, range or approximate distance, altitude, heading, identification status, and timestamp where available.
- [ ] Ensure contact reports are driven by mission state or actual detection logic, not arbitrary messages presented as sensor truth.
- [ ] Space messages so they do not overlap or overwhelm cockpit tasks.
- [ ] Provide a clear player acknowledgement or response mechanism where required.

### 9.3 Tanker

- [ ] Decide whether aerial refueling is required for the first CAP sortie or deferred to a later phase.
- [ ] Identify and verify the tanker asset and compatible refueling method.
- [ ] Confirm aircraft/tanker compatibility and whether refueling is truly functional in the selected mods.
- [ ] Test rendezvous, station behavior, interaction, fuel transfer, and disconnect.
- [ ] If no compatible working refueling system is available, provide a documented fuel plan or omit tanker support from the first sortie.

### 9.4 ATC and deck control

- [ ] Decide whether ATC is represented by a real unit, a script, or a combination.
- [ ] Define concise and consistent launch, departure, recovery, and emergency communications.
- [ ] Verify any radio mod or interaction dependency before using it.
- [ ] Provide a reliable fallback for scripted text/audio if the preferred radio system is unavailable.
- [ ] Prevent contradictory or duplicated instructions from triggers and scripts.

---

## 10. CAP tasking and hostile-contact flow

### 10.1 CAP station

- [ ] Define CAP station coordinates, altitude band, speed guidance, heading, and patrol area.
- [ ] Define the station-entry condition and how the player knows they are on station.
- [ ] Decide whether patrol is a timed orbit, a player-managed area, or a scripted route.
- [ ] Ensure the player can leave station for an authorized intercept and return to the patrol area.
- [ ] Define fuel thresholds and time-on-station behavior.

### 10.2 Contact and identification

- [ ] Define how an unknown contact is created or detected.
- [ ] Keep contact location, direction, altitude, speed, identity, and intent consistent across all reports.
- [ ] Distinguish unknown, suspected hostile, confirmed hostile, friendly, and neutral entities.
- [ ] Provide a reasonable identification window before escalation.
- [ ] Ensure AWACS, wingman, and mission messages agree on the contact state.
- [ ] Avoid revealing information the player has not reasonably received.

### 10.3 Intercept and engagement

- [ ] Define intercept tasking, intercept geometry, safe separation, and return-to-station criteria.
- [ ] Define when the player may shadow, escort, warn, disengage, or engage.
- [ ] Require positive identification and explicit ROE conditions before any scripted engagement authorization.
- [ ] Ensure AI wingman engagement rules match the player's authorization and mission ROE.
- [ ] Avoid forcing the AI to attack an unverified or neutral contact.
- [ ] Test contact disappearance, route changes, destruction, retreat, and failure-to-intercept paths.
- [ ] Provide a clear task update when the contact is resolved or the situation changes.

### 10.4 Mission state and edge cases

- [ ] Define a single authoritative state for each contact and mission phase.
- [ ] Prevent duplicate contact spawns or repeated trigger activations.
- [ ] Handle player death/ejection, aircraft damage, wingman loss, mission abort, and timeout.
- [ ] Ensure the mission cannot report success while a mandatory objective remains unresolved.
- [ ] Ensure optional objectives do not block completion indefinitely.

---

## 11. RTB, carrier recovery, and post-flight debrief

### 11.1 Return to base (RTB)

- [ ] Define the RTB trigger conditions and who authorizes the return.
- [ ] Provide a route from CAP station to carrier recovery area.
- [ ] Provide fuel state, expected recovery time, weather, wind, carrier position, and recovery instructions.
- [ ] Handle early RTB due to damage, low fuel, weather, or mission abort.
- [ ] Confirm the carrier remains in a suitable and reachable recovery configuration.

### 11.2 Carrier recovery

- [ ] Verify the selected carrier mod's actual landing area, arresting gear, and hook/cable interaction.
- [ ] Define marshal/holding, approach, final, wave-off, bolter, and emergency outcomes only to the extent supported by the selected mod and mission design.
- [ ] Test recovery in the player aircraft using the intended loadout and fuel state.
- [ ] Test day/night and weather conditions selected for the mission.
- [ ] Check the player can safely wave off and re-enter the pattern.
- [ ] Define a safe alternate recovery or mission-abort outcome if arrested recovery fails.
- [ ] Verify the AI wingman's recovery behavior separately; do not assume it can land on the carrier.
- [ ] Ensure recovery messages are clear and do not conflict with active mission triggers.

### 11.3 Shutdown and debrief

- [ ] Define the post-landing taxi/parking sequence only if supported by the carrier and aircraft mods.
- [ ] Confirm a safe shutdown/end-of-sortie condition.
- [ ] Generate a debrief with mission result, objectives, contact timeline, fuel/ammunition state if available, aircraft/wingman status, and notable events.
- [ ] Distinguish measured game data from values estimated or simulated by scripts.
- [ ] Record aborts, damage, losses, emergency events, and incomplete objectives accurately.
- [ ] End with a clear mission-complete or mission-failed state.
- [ ] Test that the player can read the debrief and return to the menu without script errors.

---

## 12. Modular SQF architecture

The architecture below is a design guide. Validate command availability, locality, scheduling behavior, and multiplayer-related execution semantics against ARMA 3 scripting documentation and the actual single-player test environment. Even in single-player, clean initialization and predictable ownership prevent avoidable bugs.

### 12.1 Responsibilities

- [ ] Keep mission initialization small; delegate work to focused modules.
- [ ] Separate briefing, flight operations, carrier logic, AI control, communications, task flow, contact handling, and debrief.
- [ ] Define a clear initialization order and document dependencies between modules.
- [ ] Keep mission state in a small, documented set of variables rather than scattering unrelated globals.
- [ ] Use stable names for important entities and validate that expected objects exist before using them.
- [ ] Keep display text and radio content separate from mission-state logic where practical.
- [ ] Centralize configuration values such as callsigns, patrol coordinates, timeouts, fuel thresholds, and task identifiers.
- [ ] Use functions with clear input/output responsibilities and consistent naming.
- [ ] Avoid long-running unscheduled code; use appropriate scheduled execution and bounded waits.
- [ ] Give wait conditions timeouts and failure handling so a missing unit or trigger cannot hang the mission forever.
- [ ] Avoid duplicate event-handler registration and duplicate spawn/initialization calls.
- [ ] Handle object deletion, null references, destroyed units, and missing optional assets safely.
- [ ] Ensure any scripted loop can terminate when the relevant mission phase ends.
- [ ] Keep debug logging useful, consistently prefixed, and easy to disable for release.
- [ ] Do not add an external framework unless there is a documented requirement and the dependency has been verified.

### 12.2 Suggested module ownership

| Module | Responsibility |
|---|---|
| `init` | Validate prerequisites and initialize the mission once |
| `briefing` | Situation, objectives, map markers, flight plan, ROE |
| `flight` | Preflight flags, startup progression, taxi and launch state |
| `carrier` | Carrier references, deck positions, launch/recovery integration |
| `ai` | Wingman and supporting AI setup, orders, recovery behavior |
| `comms` | Radio/text messages, callout queue, acknowledgements |
| `tasks` | Create, update, complete, fail, or cancel objectives |
| `combat` | Contact state, identification, ROE gates, intercept outcome |
| `debrief` | Aggregate mission result and present the final report |

- [ ] Ensure each module has one clear owner for the state it changes.
- [ ] Prevent circular dependencies between modules.
- [ ] Make initialization idempotent where feasible: rerunning a setup path should not create duplicate units, tasks, or handlers.
- [ ] Keep test-only helpers out of the release mission or guard them behind an explicit debug setting.

---

## 13. Triggers, tasks, and radio communications

### 13.1 Trigger and phase design

- [ ] Use named, documented triggers or scripted conditions for mission-phase transitions.
- [ ] Define explicit phase states, for example: briefing, preflight, startup, taxi, launch, join-up, CAP, intercept, RTB, recovery, debrief.
- [ ] Define exactly which event advances each phase.
- [ ] Ensure each phase transition can occur only once unless a repeat is intentional.
- [ ] Add timeouts and player-visible recovery instructions for phases that can fail.
- [ ] Ensure triggers do not depend on fragile positional assumptions without validation.
- [ ] Test trigger boundaries and conditions at least once from both sides of each boundary.

### 13.2 Tasks and objectives

- [ ] Create a briefing task before the player leaves the ready room.
- [ ] Add flight preparation and launch objectives appropriate to the full-MILSIM flow.
- [ ] Add CAP station tasking and any contact/intercept task dynamically as the sortie progresses.
- [ ] Update task states in a consistent order and provide concise player feedback.
- [ ] Define optional objectives separately from mandatory objectives.
- [ ] Ensure tasks have meaningful completion, failure, cancellation, and timeout behavior.

### 13.3 Radio and message design

- [ ] Define a comms plan and callsign list.
- [ ] Use consistent terminology and message formatting.
- [ ] Ensure message sequencing does not overlap important player actions.
- [ ] Use short, actionable instructions; avoid excessive atmospheric chatter.
- [ ] Give time-sensitive messages a priority over ambient messages.
- [ ] Ensure every critical instruction has a fallback if audio or a radio dependency is unavailable.
- [ ] Verify audio files, paths, licensing, and in-game volume if custom audio is included.
- [ ] Ensure scripted messages reflect actual mission state and do not falsely imply live radar, weather, fuel, or carrier-system integration.

---

## 14. Single-player test plan and debugging

Run tests in small increments. Do not build the complete sortie before the carrier, aircraft, and startup/launch foundations are reliable.

### 14.1 Smoke tests

- [ ] Mission loads from the editor with the intended mod preset.
- [ ] Player spawns in the ready room and can reach the aircraft.
- [ ] Required aircraft, carrier, and units exist.
- [ ] No missing-addon, missing-class, or missing-resource errors appear.
- [ ] Mission initializes once and does not duplicate units or tasks.
- [ ] Mission can be restarted and replayed without stale state.

### 14.2 Functional tests

- [ ] Preflight and startup sequence can be completed.
- [ ] Interrupted or failed startup is handled safely.
- [ ] Taxi and catapult launch are repeatable.
- [ ] Wingman can join and hold the intended formation.
- [ ] CAP station detection and objective progression work.
- [ ] AWACS/contact messages match mission state.
- [ ] Intercept and ROE branches work as designed.
- [ ] RTB, recovery, wave-off/bolter or fallback paths work.
- [ ] Debrief data matches the events that occurred.
- [ ] Player death, ejection, aircraft loss, wingman loss, timeout, and abort paths do not leave the mission in a broken state.

### 14.3 Debugging workflow

- [ ] Check the ARMA 3 RPT after every test run.
- [ ] Fix undefined variables, missing functions, malformed script paths, and missing assets before adding more features.
- [ ] Add temporary diagnostic logging around phase transitions and external mod interactions.
- [ ] Log important entity references and validate missing objects before use.
- [ ] Reproduce errors in the smallest possible test mission.
- [ ] Test with optional mods disabled when investigating a suspected dependency conflict.
- [ ] Remove or disable noisy debug output before release.
- [ ] Keep a short test log with build/mod preset, steps performed, expected result, actual result, and unresolved issues.

### 14.4 Performance and stability

- [ ] Avoid excessive polling loops and overly frequent status checks.
- [ ] Prefer event-driven state changes when practical.
- [ ] Bound AI groups and ambient objects to what the scenario needs.
- [ ] Avoid unnecessary spawned effects, sounds, and repeated marker updates.
- [ ] Test with the expected view distance and AI count.
- [ ] Check for gradual FPS degradation during a full-length sortie.
- [ ] Confirm the mission does not leak repeated scripts, event handlers, markers, or spawned objects.
- [ ] Test several full mission runs, not only the first few minutes.

---

## 15. Implementation order

Work through the phases in order. A later phase should not be treated as complete while a required earlier dependency is unverified.

| Phase | Work | Exit gate |
|---|---|---|
| 0 — Repository and brief | Define mission baseline, source layout, naming, and test records | Requirements are written and scope is stable |
| 1 — Mod and asset verification | Verify aircraft and USMC mods; identify/select the carrier; record classnames and capabilities | All required assets load and pass isolated tests; unsupported features are documented |
| 2 — Carrier and player foundation | Place carrier, player start, ready room route, aircraft, and wingman | Player can move to and enter the correct F/A-18E; no critical geometry/spawn issues |
| 3 — Flight-deck procedures | Implement and test preflight, startup, taxi, launch, and join-up | Full launch sequence is repeatable or a documented alternative is approved |
| 4 — Mission framework | Implement initialization, phase state, tasks, triggers, communications, and briefing | Mission phases advance once and recover cleanly from expected failures |
| 5 — CAP and supporting AI | Implement wingman, CAP station, AWACS/ATC messages, and tanker only if verified | Patrol and support flow works in single-player |
| 6 — Contact scenario | Add AFR contact, identification, ROE, intercept, and outcomes | Contact branches are consistent, fair, and ROE-compliant |
| 7 — Recovery and debrief | Implement RTB, carrier recovery, shutdown, and final report | Successful recovery and defined fallback paths work |
| 8 — Hardening | Run regression, performance, clean-restart, and full-sortie tests | No known critical errors; release criteria are met |
| 9 — Release | Package mission, document exact dependencies and limitations, tag/version release | Another user can install the stated mod set and complete the mission |

### Suggested implementation discipline

- [ ] Complete and record the exit gate for each phase before expanding scope.
- [ ] Keep one known-good playable baseline at all times.
- [ ] Prefer a small test mission when validating mod-specific behavior.
- [ ] Do not combine asset discovery, mission logic changes, and unrelated refactoring in one commit.
- [ ] Update the checklist when a decision changes or a test disproves an assumption.

---

## 16. Acceptance criteria

The first sortie is ready for release only when all mandatory criteria below pass.

### Mission and setup

- [ ] A clean ARMA 3 installation with the documented game build and required mod preset can load the mission without missing dependencies.
- [ ] The README and release notes identify the correct Workshop items and clearly disclose any optional dependencies.
- [ ] The USS Nimitz asset is identified and its required features have been verified; or the mission explicitly documents a tested alternative.
- [ ] The player starts in the intended ready-room flow and can reach the flight deck.

### Aircraft and flight operations

- [ ] The player's aircraft is verified to be the F/A-18E variant, not the F/A-18F.
- [ ] Aircraft classname, loadout, and required functions are verified in-game.
- [ ] Preflight, startup, taxi, and launch are repeatable and do not depend on unverified features.
- [ ] JOKER 1-2 can join and support the player, or a documented fallback is provided.
- [ ] The player receives accurate and consistent briefing, flight, and support communications.

### CAP and mission logic

- [ ] The CAP station and tasking work reliably.
- [ ] Hostile contacts are identifiable through the designed mission flow.
- [ ] ROE prevents unauthorized scripted engagement.
- [ ] Contact outcomes and objective status remain consistent across all tested branches.
- [ ] Mission abort, timeout, aircraft loss, and wingman loss have defined outcomes.

### Recovery and quality

- [ ] RTB and carrier recovery work reliably, with tested wave-off/alternate handling where supported.
- [ ] Debrief accurately represents mission events.
- [ ] The RPT contains no unresolved critical script errors or missing required assets.
- [ ] Performance remains acceptable for a complete sortie on the target setup.
- [ ] The mission can be restarted and completed in repeated test runs.
- [ ] Release notes list exact mod requirements, known limitations, test environment, and mission version.

### Final release sign-off

- [ ] All mandatory criteria above are checked and evidence/test notes are recorded.
- [ ] Any remaining non-blocking limitations are documented honestly.
- [ ] The packaged mission is tested from a clean mission copy, not only the working editor session.
- [ ] The release commit/tag and corresponding documentation match the tested build.

---

## 17. Open verification register

Keep this list current. Resolve each item with evidence from the actual installed environment.

| Item | Current status | Evidence required before closing |
|---|---|---|
| F/A-18E Super Hornet 2020 exact vehicle classname | **Pending confirmation** | In-game/config inspection on the installed version |
| F/A-18E startup, avionics, hook, catapult, and loadout capabilities | **Pending confirmation** | Repeatable tests in a disposable mission |
| USMC 2026 required unit/faction classnames | **Pending confirmation** | In-game editor/config inspection |
| USS Nimitz Workshop item | Identified: [643530417](https://steamcommunity.com/sharedfiles/filedetails/?id=643530417); Steam currently displays removed/incompatible notices | Confirm installability and successful load in the current ARMA 3 build |
| USS Nimitz dependency | Listing names CBA_A3 as required | Install and test with CBA_A3 enabled |
| USS Nimitz deck, elevator, catapult, and arresting-gear functions | Advertised by Workshop description; **not in-game verified** | Isolated carrier test mission; validate each feature with the selected F/A-18E mod |
| AI taxi and carrier recovery capability | **Pending confirmation** | Repeatable AI tests; do not assume player functionality implies AI support |
| AWACS aircraft/system and detection behavior | **Pending confirmation** | Select asset/system and validate actual contact behavior |
| Tanker and refueling compatibility | **Pending confirmation** | Verify compatible assets and functional fuel transfer |
| ATC/radio implementation | **Pending design and confirmation** | Choose native/scripted approach and test its dependencies |
| AFR aircraft, ground units, and exact classnames | **Pending confirmation** | Identify installed assets and verify in Eden/in-game |
| Mod-specific carrier launch and recovery SOP | **Pending confirmation** | Use selected mods' documentation and tested behavior |

**Completion rule:** Update this register as soon as an item is verified, rejected, or replaced. Record the source/version and test result; do not silently convert an assumption into a confirmed fact.
