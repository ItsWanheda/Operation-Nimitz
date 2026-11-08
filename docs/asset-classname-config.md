# Manual Asset and Classname Configuration

All mod asset classnames are managed in one place:

`mission/OperationNimitz.Altis/config/assetConfig.sqf`

You do **not** need to edit the spawner to change a unit, vehicle, aircraft, carrier, or convoy asset. Enter the exact classname in the matching key and set the desired map marker in the deployment list.

## 1. Enter classnames

Open `config/assetConfig.sqf` and replace the empty string for each asset you want to use:

```sqf
["USS_NIMITZ", "YOUR_EXACT_CARRIER_CLASSNAME"],
["PLAYER_F18F", "YOUR_EXACT_F18F_CLASSNAME"],
["AFR_AA", "YOUR_EXACT_AA_CLASSNAME"],
["AFR_TANK", "YOUR_EXACT_TANK_CLASSNAME"],
["AFR_ARTILLERY", "YOUR_EXACT_ARTILLERY_CLASSNAME"]
```

The file contains separate keys for:

- Playable player unit (validated against the Eden player entity), USS Nimitz, player F/A-18F, wingman F/A-18F and wingman pilot.
- AWACS aircraft/pilot, tanker aircraft/pilot and deck crew.
- USMC infantry roles, cars, APCs, IFVs, tanks, AA, artillery, mortars, static weapons, helicopters and aircraft.
- AFR infantry roles, cars, APCs, IFVs, tanks, AA, artillery, mortars, static weapons, helicopters and aircraft.
- Convoy trucks, escort cars/APCs and convoy tanks.
- Custom slots that you can rename or extend.

The `PLAYER_UNIT` key is checked against the playable Eden unit; select the matching playable unit class in Eden because ARMA defines the player entity in `mission.sqm`. Use the **class name**, not the editor display name. Classnames are case-sensitive in practice and must exist in the installed `CfgVehicles` config. Blank values are disabled. The mission does not guess or silently substitute another mod asset.

## 2. Add the map markers

Create the marker names used by the deployment rows in Eden:

- `ON_SPAWN_CARRIER`: place at the carrier's exact water position.
- `ON_SPAWN_PLAYER_AIRCRAFT`: place on the carrier flight deck where the player aircraft should appear.
- `ON_SPAWN_WINGMAN_AIRCRAFT` and `ON_SPAWN_WINGMAN_PILOT`: wingman aircraft and pilot spawn references.
- Support aircraft and their pilot markers are named in the matching rows.
- Every individual friendly/enemy deployment row has its own marker.
- Every convoy route has its own ordered set of route markers.

Marker direction is used as the spawned object's heading. Put ground-vehicle route markers on roads. The carrier marker must be placed in water; the player aircraft marker must be positioned on the deck. These are spawn coordinates, not proof that a Workshop carrier supports scripted spawning or deck attachment.

## 3. Configure individual units and vehicles

The deployment row format is:

```sqf
[id, type, classnameKey, marker, side, createCrew,
 missionVariable, driverVehicleVariable, requireUniqueMarker]
```

Example:

```sqf
["AFR_TANK_02", "VEHICLE", "AFR_TANK", "ON_SPAWN_AFR_TANK_02",
 east, true, "", "", true],
["AFR_RIFLEMAN_03", "UNIT", "AFR_RIFLEMAN", "ON_SPAWN_AFR_RIFLEMAN_03",
 east, false, "", "", true]
```

- `UNIT` creates one infantry/man unit in the selected side's group.
- `VEHICLE` creates a vehicle, aircraft, carrier object or static weapon.
- `createCrew=true` asks the vehicle config to create its native crew. Use `false` for an empty aircraft or a vehicle that receives a separately configured pilot.
- `missionVariable` assigns the created object to a mission reference, for example `"ON_carrier"`, `"ON_playerAircraft"`, or `"ON_wingman"`.
- `driverVehicleVariable` moves a configured `UNIT` into the driver seat of an already spawned object reference. The vehicle row must appear first in the list.
- `requireUniqueMarker=true` rejects a marker already used by another unique deployment. Keep it true for enemy spawn positions.

To add more infantry, tanks, cars, APCs, AA systems, artillery pieces or other assets, copy a row, give it a new ID, set its classname key and marker, and choose its side. Add new classname keys to the hashmap at the top of the file. You can create as many rows and custom keys as the scenario requires.

### Example: distribute AA units across the map

Give every AA deployment its own Eden marker. For example, create four markers at four different positions on Altis:

- `ON_SPAWN_AFR_AA_NORTH`
- `ON_SPAWN_AFR_AA_SOUTH`
- `ON_SPAWN_AFR_AA_EAST`
- `ON_SPAWN_AFR_AA_WEST`

Then add one deployment row per AA vehicle:

```sqf
["AFR_AA_NORTH", "VEHICLE", "AFR_AA", "ON_SPAWN_AFR_AA_NORTH", east, true, "", "", true],
["AFR_AA_SOUTH", "VEHICLE", "AFR_AA", "ON_SPAWN_AFR_AA_SOUTH", east, true, "", "", true],
["AFR_AA_EAST",  "VEHICLE", "AFR_AA", "ON_SPAWN_AFR_AA_EAST",  east, true, "", "", true],
["AFR_AA_WEST",  "VEHICLE", "AFR_AA", "ON_SPAWN_AFR_AA_WEST",  east, true, "", "", true]
```

All four vehicles use the same manually selected AA classname key, but each spawns at its own marker. Repeat this pattern for tanks, artillery, APCs, infantry, aircraft, or any other asset category. You can also assign a different classname key to each row when you want different models.

**Important:** the final `true` enables the unique-marker check. Keep it enabled for individually positioned deployments so accidentally reusing a marker is caught during mission startup.

## 4. Configure advanced convoys and routes

Convoy rows use classname **keys**, not raw classnames. The original four-column format remains valid:

```sqf
[
    "AFR_BRAVO",
    ["AFR_CONVOY_TRUCK", "AFR_CONVOY_ESCORT_APC", "AFR_CONVOY_TRUCK"],
    ["ON_ROUTE_B_01", "ON_ROUTE_B_02", "ON_ROUTE_B_03"],
    east
]
```

The extended format adds optional convoy behavior:

```sqf
[
    "AFR_BRAVO",
    ["AFR_CONVOY_TRUCK", "AFR_CONVOY_ESCORT_APC"],
    ["ON_ROUTE_B_01", "ON_ROUTE_B_02", "ON_ROUTE_B_03"],
    east,
    1,
    ["ON_ROUTE_B_02"],
    20,
    "HALT_ON_LOSS",
    0.6,
    "LIMITED",
    "SAFE"
]
```

The optional fields, in order, are:

- `escortCount`: number of final vehicles in classname order tagged as `ESCORT`. Earlier vehicles are tagged `TRANSPORT`. Set this to zero when no vehicle should be designated as escort.
- `checkpointMarkers`: existing route markers that should pause the convoy.
- `checkpointPauseSeconds`: deterministic pause duration at each configured checkpoint.
- `reactionMode`: `CONTINUE`, `HALT_ON_DAMAGE`, or `HALT_ON_LOSS`.
- `damageThreshold`: damage value from 0.0 to 1.0 used by `HALT_ON_DAMAGE`.
- `speedMode`: `LIMITED`, `NORMAL`, or `FULL` (the values accepted by this controller).
- `behaviour`: `SAFE`, `AWARE`, `COMBAT`, or `STEALTH`.

Create at least one route marker per convoy vehicle. Each vehicle starts at its corresponding marker; the group follows the remaining route markers in order and cycles back to the first marker. Checkpoint markers must also be included in the convoy route. Route markers must exist, must not repeat, and must not be reused by another convoy.

Escort assignment is a role tag and convoy formation setting; it does not create independent escort tactics, threat detection, or guaranteed protective positioning. Checkpoint waits use waypoint timeouts. Damage/loss reactions are monitored by the convoy controller and can halt the remaining group according to the selected mode.

## 5. Configure enemy alert zones

The alert system monitors the ARMA AI `knowsAbout` value for living units on the configured hostile side. It escalates through:

- `QUIET`: no configured threshold has been reached.
- `SUSPICIOUS`: one or more hostile AI units have partial knowledge, or the player enters a configured zone.
- `ALERTED`: hostile knowledge or a zone has reached the alert threshold.
- `ENGAGED`: hostile knowledge or a zone has reached the highest threshold.

Adjust the `ON_enemyAlertSettings` hashmap in `assetConfig.sqf` to set knowledge thresholds, scan interval, and enable/disable state. Alert detection uses the shared `ON_enemySide` setting at the bottom of the same file. Optional zone rows use:

```sqf
[id, marker, radiusMetres, minimumAlertLevel]
```

Example (commented out in the default configuration):

```sqf
["AFR_NORTH_PERIMETER", "ON_ALERT_NORTH", 1200, "SUSPICIOUS"]
```

Place each marker in Eden before enabling its row. Alert states only escalate during the sortie; this simple controller does not model alert decay, a radar picture, radio interception, or sensor fusion.

## 6. Configure dynamic reinforcement waves

Reinforcement rows use:

```sqf
[id, side, [classnameKey, ...], spawnMarker, [waypointMarker, ...],
 triggerType, triggerValue, initialDelaySeconds, maxWaves, waveIntervalSeconds]
```

Supported triggers:

- `ALERT_LEVEL`: start when the enemy alert reaches `SUSPICIOUS`, `ALERTED`, or `ENGAGED`.
- `PHASE`: start when the mission enters a named phase such as `IN_FLIGHT`.
- `PLAYER_RADIUS`: start when the player/assigned aircraft enters `[marker, radiusMetres]`.

An empty waypoint list creates a garrison wave. One or more waypoint markers create a moving QRF-style wave. Each later wave is offset from the previous wave's spawn area. The controller attempts to spawn up to `maxWaves`, waiting for `waveIntervalSeconds` between waves. It uses the same manually configured classname keys as the force-package system. No reinforcement definitions are active by default; uncomment and configure only after placing all markers and checking classnames.

## 7. Operational command requests

The assigned aircraft receives contextual radio-style actions for:

- Mission SITREP (phase, aircraft state, flight/CAS time and alert level).
- Enemy threat report (alert level and AI-known hostile count).
- Reinforcement schedule state.
- Convoy vehicle health and reaction state.
- Current phase-based tasking.

These are scripted `addAction` reports using systemChat. They are not a simulated radio network, voice comms, or real AWACS radar data.

## 8. Add custom mod assets

Add a new key to `ON_assetClassnames`:

```sqf
["MY_MODDED_RECON_VEHICLE", "exact_classname_from_config_viewer"]
```

Then add a deployment row:

```sqf
["RECON_VEHICLE_01", "VEHICLE", "MY_MODDED_RECON_VEHICLE",
 "ON_SPAWN_RECON_VEHICLE_01", east, true, "", "", true]
```

The same process works for a man unit by changing the row type to `UNIT`. This keeps mod-specific classnames out of the mission logic.

## 9. Startup and validation

`mission/OperationNimitz.Altis/init.sqf` loads `config/assetConfig.sqf` before the core mission system. The asset director runs before mandatory setup validation, so configured carrier and player-aircraft references are available to the framework.

The director logs missing markers, invalid classnames and failed spawns to the ARMA 3 RPT with the `[OperationNimitz]` prefix. Empty classname fields intentionally skip their deployment. A valid config entry only proves that the classname exists in the loaded config; it does not prove the mod behaves correctly in-game.

**Still required:** test all classnames in the installed mod set, check crew/faction behavior, validate exact spawn positions, and run the full sortie in ARMA 3. No runtime validation is claimed by this repository update.
