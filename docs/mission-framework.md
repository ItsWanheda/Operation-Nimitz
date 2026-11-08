# Operation Nimitz — Mission Framework

**Status:** 0.6.0-dev mission-system expansion; not yet a playable/exported mission.  
**Mission folder:** mission/OperationNimitz.Altis  
**Active implementation branch:** feat/mission-system-foundation

This milestone provides the mission flow and a generic classname-driven deployment system. Mod assets are selected manually in one configuration file; mission scripts do not assume or invent Workshop classnames.

## Implemented systems

- Mission bootstrap, shared phase validation, task helpers, diagnostic logging, and setup checks.
- Central manual classname map (including the playable player-unit classname check) and marker-driven spawner for individual units, vehicles, aircraft, carriers and static weapons.
- Optional native vehicle crew creation and separately configured pilot seating.
- Marker-unique deployment checks for individual assets.
- Tactical force packages for manually configured infantry groups: immediate garrisons, waypoint patrols, and proximity-triggered QRF groups.
- Enemy intelligence and alert escalation based on ARMA AI `knowsAbout` values plus optional manually placed proximity alert zones.
- Dynamic reinforcement schedules triggered by alert level, mission phase, or player/aircraft proximity; delayed and repeated waves use the shared classname-driven spawner.
- Operational command requests for mission SITREP, threat state, reinforcement state, convoy state, and phase-based tasking.
- Advanced convoy configuration with transport/escort role tags, timed route checkpoints, configurable speed/behaviour, and continue/halt-on-damage/halt-on-loss reactions.
- Convoy spawning through classname keys and ordered, unique route-marker lists.
- Diary briefing and ready-room-to-aircraft progression.
- Phase-gated preflight, engine-start, taxi, and launch confirmation actions.
- AI wingman follow/hold-fire behavior when a pilot is seated in the configured aircraft.
- CAS area monitoring with configurable marker, radius, and on-station time.
- Optional editor-placed contact detection, player visual-identification confirmation, ROE-gated hostile declaration, and contact resolution.
- Optional AWACS, tanker, carrier-control, and deck-crew status calls.
- Basic recovery gate requiring the assigned aircraft, grounded state, low speed, and proximity to the carrier.
- Debrief interaction, sampled sortie telemetry and bounded event journal.

## Manual classname configuration

Edit **`mission/OperationNimitz.Altis/config/assetConfig.sqf`**.

The hashmap provides separate keys for:

- USS Nimitz, player F/A-18F, wingman F/A-18F, wingman pilot.
- AWACS aircraft/pilot, tanker aircraft/pilot, deck crew.
- USMC and AFR infantry roles.
- Cars, APCs, IFVs, tanks, AA, artillery, mortars, static weapons, helicopters and aircraft.
- Convoy trucks, escort vehicles and optional custom mod assets.

Enter the exact classname into the desired key. Then add one row to `ON_assetDeployments` with its type, classname key, marker, side, crew behavior, optional mission reference and unique-marker setting. Empty classname keys disable their rows.

For group-level infantry behavior, configure `ON_forcePackages` in the same file. Each package lists its own unit classname keys, spawn marker, behavior, and optional waypoint/activation markers. `GARRISON` holds a position, `PATROL` cycles through at least two route markers, and `QRF` remains unspawned until the player enters its configured activation radius. See the commented examples in `assetConfig.sqf`.

The director supports:
- `UNIT`: one infantry/man unit.
- `VEHICLE`: any valid `CfgVehicles` object class, including ground vehicles, aircraft, carrier objects and static weapons.
- `createCrew`: creates the vehicle's configured native crew.
- `driverVehicleVariable`: optionally seats a separately configured unit in a previously spawned vehicle's driver seat.
- `missionVariable`: exposes the spawned object through a missionNamespace reference used by the framework.

Convoy definitions reference classname keys and ordered route marker names. Each convoy requires at least as many unique route markers as vehicles. Optional fields configure escort tags, checkpoint pauses, speed/behaviour and damage/loss reactions. Static enemy spawn rows should use a unique marker for every element.

Enemy alert settings and optional alert zones are configured through `ON_enemyAlertSettings` and `ON_enemyAlertZones`. Reinforcement schedules are configured through `ON_reinforcementDefinitions`; they are empty by default. See the manual configuration guide for the exact row schemas and trigger types.

See [Manual Asset and Classname Configuration](asset-classname-config.md) for the complete schema and examples.

## Required setup and current limits

The repository still does not contain an Eden-generated `mission.sqm`. The mission must be opened in Eden, configured and tested with the installed mods.

The deployment director validates that a classname exists in `CfgVehicles`. It cannot establish that a Workshop asset is compatible, correctly factioned, crewable, correctly simulated, or suitable for a specific marker. Those details require in-game verification.

The USS Nimitz Workshop listing's installability/compatibility status remains unresolved. Its advertised features are not treated as verified in-game capabilities. Carrier spawning at a marker is not a simulated catapult, deck attachment or arresting-wire system.

Other current limits:
- Player confirmation actions are not aircraft-system simulations.
- The contact detector is a distance gate, not radar, AWACS sensor fusion, or visual line-of-sight simulation.
- Enemy alert escalation samples engine AI knowledge (`knowsAbout`) and optional proximity zones. It does not simulate radar coverage, communications interception, alert decay, or sensor fusion.
- Reinforcement triggers use configured mission phase, alert state, or player proximity; there is no simulated enemy command network or tactical pathfinding guarantee.
- Operational command entries are contextual `addAction`/systemChat reports, not a radio-frequency, voice, or crew communications simulation.
- Hostile declaration depends on manually verified metadata and player confirmation.
- Wingman behavior is basic AI follow/formation control.
- Force packages use standard group waypoints and basic AI behavior; they do not provide advanced tactical coordination, suppression doctrine, dynamic threat assessment, or guaranteed pathfinding.
- QRF activation is based on player proximity to a configured marker, not enemy radio detection or a simulated command network.
- Convoy escort roles are configuration tags within a shared convoy group. Checkpoints use waypoint timeouts, and selectable damage/loss reactions can halt the convoy; this does not provide advanced escort tactics, ambush behavior, infantry dismounts, or threat-aware rerouting.
- Recovery proximity is not proof of arrested landing or hook/cable engagement.
- No ARMA 3 runtime test has been performed in this environment.

## Next steps

1. Fill the manual classname map with exact classnames from the installed mods.
2. Add the matching spawn and route markers in Eden.
3. Verify each asset, crew faction, spawn position and convoy route in preview.
4. Generate and commit the Eden mission.sqm.
5. Integrate only those carrier/aircraft procedures exposed and validated by the installed mods.
6. Run the complete sortie and fix RPT/runtime errors.
