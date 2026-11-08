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

- USS Nimitz, player F/A-18F, wingman F/A-18F and wingman pilot.
- AWACS aircraft/pilot, tanker aircraft/pilot and deck crew.
- USMC infantry roles, cars, APCs, IFVs, tanks, AA, artillery, mortars, static weapons, helicopters and aircraft.
- AFR infantry roles, cars, APCs, IFVs, tanks, AA, artillery, mortars, static weapons, helicopters and aircraft.
- Convoy trucks, escort cars/APCs and convoy tanks.
- Custom slots that you can rename or extend.

Use the **class name**, not the editor display name. Classnames are case-sensitive in practice and must exist in the installed `CfgVehicles` config. Blank values are disabled. The mission does not guess or silently substitute another mod asset.

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

## 4. Configure convoys and routes

Convoy rows use classname **keys**, not raw classnames:

```sqf
[
    "AFR_BRAVO",
    ["AFR_CONVOY_TRUCK", "AFR_CONVOY_ESCORT_APC", "AFR_CONVOY_TRUCK"],
    ["ON_ROUTE_B_01", "ON_ROUTE_B_02", "ON_ROUTE_B_03"],
    east
]
```

Create at least one route marker per convoy vehicle. Each vehicle starts at its corresponding route marker; the convoy then follows the remaining route markers in order and cycles back to the first marker. A route must contain existing marker names, must not repeat a marker, and must not reuse another convoy's route. Every referenced classname key must resolve to a valid class.

## 5. Add custom mod assets

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

## 6. Startup and validation

`mission/init.sqf` loads `config/assetConfig.sqf` before the core mission system. The asset director runs before mandatory setup validation, so configured carrier and player-aircraft references are available to the framework.

The director logs missing markers, invalid classnames and failed spawns to the ARMA 3 RPT with the `[OperationNimitz]` prefix. Empty classname fields intentionally skip their deployment. A valid config entry only proves that the classname exists in the loaded config; it does not prove the mod behaves correctly in-game.

**Still required:** test all classnames in the installed mod set, check crew/faction behavior, validate exact spawn positions, and run the full sortie in ARMA 3. No runtime validation is claimed by this repository update.
