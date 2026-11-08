/*
    OPERATION NIMITZ — MANUAL ASSET / CLASSNAME CONFIGURATION

    EDIT THIS FILE TO SELECT EVERY MOD ASSET USED BY THE MISSION.
    Paste exact classnames from the installed ARMA 3 Config Viewer / mod docs.
    Do not use display names. Empty strings are intentionally disabled.

    Deployment row:
      [id, type, classnameKey, marker, side, createCrew, missionVariable,
       driverVehicleVariable, requireUniqueMarker]

    type: "UNIT" or "VEHICLE"
    side: west / east / independent / civilian
    createCrew: true for vehicle-native crew; false for player aircraft and
                vehicles receiving a separately configured pilot/unit.
    missionVariable: optional missionNamespace reference such as "ON_carrier".
    driverVehicleVariable: optional missionNamespace vehicle reference for a
                           UNIT that should be seated in that vehicle's driver seat.
    requireUniqueMarker: true prevents another static deployment using that marker.

    Convoy row:
      [convoyId, [classnameKey, ...], [routeMarker, ...], side]
    Every convoy needs at least one unique route marker per vehicle.
*/

missionNamespace setVariable ["ON_assetClassnames", createHashMapFromArray [
    // PLAYABLE EDEN UNIT — match this to the player unit class selected in Eden.
    ["PLAYER_UNIT", ""],

    // CARRIER AND PRIMARY FLIGHT
    ["USS_NIMITZ", ""],
    ["PLAYER_F18F", ""],
    ["WINGMAN_F18F", ""],
    ["WINGMAN_PILOT", ""],

    // SUPPORT AIRCRAFT AND PILOTS
    ["AWACS_AIRCRAFT", ""],
    ["AWACS_PILOT", ""],
    ["TANKER_AIRCRAFT", ""],
    ["TANKER_PILOT", ""],
    ["DECK_CREW", ""],

    // FRIENDLY / USMC INFANTRY
    ["USMC_RIFLEMAN", ""],
    ["USMC_MEDIC", ""],
    ["USMC_AT", ""],
    ["USMC_MG", ""],
    ["USMC_CREW", ""],
    ["USMC_SNIPER", ""],

    // FRIENDLY / USMC GROUND AND STATIC ASSETS
    ["USMC_CAR", ""],
    ["USMC_APC", ""],
    ["USMC_IFV", ""],
    ["USMC_TANK", ""],
    ["USMC_AA", ""],
    ["USMC_ARTILLERY", ""],
    ["USMC_MORTAR", ""],
    ["USMC_STATIC_MG", ""],
    ["USMC_STATIC_AT", ""],
    ["USMC_STATIC_AA", ""],

    // FRIENDLY / USMC AIR ASSETS
    ["USMC_HELICOPTER", ""],
    ["USMC_AIRCRAFT", ""],

    // ENEMY / AFR INFANTRY
    ["AFR_RIFLEMAN", ""],
    ["AFR_MEDIC", ""],
    ["AFR_AT", ""],
    ["AFR_MG", ""],
    ["AFR_SNIPER", ""],
    ["AFR_CREW", ""],

    // ENEMY / AFR GROUND AND STATIC ASSETS
    ["AFR_CAR", ""],
    ["AFR_APC", ""],
    ["AFR_IFV", ""],
    ["AFR_TANK", ""],
    ["AFR_AA", ""],
    ["AFR_ARTILLERY", ""],
    ["AFR_MORTAR", ""],
    ["AFR_STATIC_MG", ""],
    ["AFR_STATIC_AT", ""],
    ["AFR_STATIC_AA", ""],

    // ENEMY / AFR AIR ASSETS
    ["AFR_HELICOPTER", ""],
    ["AFR_AIRCRAFT", ""],

    // CONVOY VEHICLES (CLASSNAMES ARE REFERENCED BY KEY BELOW)
    ["AFR_CONVOY_TRUCK", ""],
    ["AFR_CONVOY_ESCORT_CAR", ""],
    ["AFR_CONVOY_ESCORT_APC", ""],
    ["AFR_CONVOY_TANK", ""],

    // OPTIONAL CUSTOM SLOTS — rename keys or add as many as required.
    ["CUSTOM_UNIT_01", ""],
    ["CUSTOM_VEHICLE_01", ""],
    ["CUSTOM_AIRCRAFT_01", ""]
]];

/*
    EDIT / DUPLICATE THESE ROWS TO PLACE ASSETS.
    Markers must exist on the Altis map. Vehicle and aircraft markers should
    be placed at their exact intended spawn positions. Put the carrier marker
    at sea and the player aircraft marker on the flight deck.
*/
missionNamespace setVariable ["ON_assetDeployments", [
    // USS NIMITZ + PRIMARY FLIGHT
    ["USS_NIMITZ", "VEHICLE", "USS_NIMITZ", "ON_SPAWN_CARRIER", west, false, "ON_carrier", "", true],
    ["PLAYER_F18F", "VEHICLE", "PLAYER_F18F", "ON_SPAWN_PLAYER_AIRCRAFT", west, false, "ON_playerAircraft", "", true],
    ["WINGMAN_F18F", "VEHICLE", "WINGMAN_F18F", "ON_SPAWN_WINGMAN_AIRCRAFT", west, false, "ON_wingmanAircraft", "", true],
    ["WINGMAN_PILOT", "UNIT", "WINGMAN_PILOT", "ON_SPAWN_WINGMAN_PILOT", west, false, "ON_wingman", "ON_wingmanAircraft", true],

    // SUPPORT AIRCRAFT — optional; fill the classname keys and create the named markers.
    ["AWACS_AIRCRAFT", "VEHICLE", "AWACS_AIRCRAFT", "ON_SPAWN_AWACS_AIRCRAFT", west, false, "ON_awacs", "", true],
    ["AWACS_PILOT", "UNIT", "AWACS_PILOT", "ON_SPAWN_AWACS_PILOT", west, false, "ON_awacsPilot", "ON_awacs", true],
    ["TANKER_AIRCRAFT", "VEHICLE", "TANKER_AIRCRAFT", "ON_SPAWN_TANKER_AIRCRAFT", west, false, "ON_tanker", "", true],
    ["TANKER_PILOT", "UNIT", "TANKER_PILOT", "ON_SPAWN_TANKER_PILOT", west, false, "ON_tankerPilot", "ON_tanker", true],
    ["DECK_CREW", "UNIT", "DECK_CREW", "ON_SPAWN_DECK_CREW", west, false, "ON_deckCrew", "", true],

    // FRIENDLY / USMC — add one row per individual unit or vehicle.
    ["USMC_RIFLEMAN_01", "UNIT", "USMC_RIFLEMAN", "ON_SPAWN_USMC_RIFLEMAN_01", west, false, "", "", true],
    ["USMC_MEDIC_01", "UNIT", "USMC_MEDIC", "ON_SPAWN_USMC_MEDIC_01", west, false, "", "", true],
    ["USMC_AT_01", "UNIT", "USMC_AT", "ON_SPAWN_USMC_AT_01", west, false, "", "", true],
    ["USMC_MG_01", "UNIT", "USMC_MG", "ON_SPAWN_USMC_MG_01", west, false, "", "", true],
    ["USMC_CAR_01", "VEHICLE", "USMC_CAR", "ON_SPAWN_USMC_CAR_01", west, true, "", "", true],
    ["USMC_APC_01", "VEHICLE", "USMC_APC", "ON_SPAWN_USMC_APC_01", west, true, "", "", true],
    ["USMC_IFV_01", "VEHICLE", "USMC_IFV", "ON_SPAWN_USMC_IFV_01", west, true, "", "", true],
    ["USMC_TANK_01", "VEHICLE", "USMC_TANK", "ON_SPAWN_USMC_TANK_01", west, true, "", "", true],
    ["USMC_AA_01", "VEHICLE", "USMC_AA", "ON_SPAWN_USMC_AA_01", west, true, "", "", true],
    ["USMC_ARTILLERY_01", "VEHICLE", "USMC_ARTILLERY", "ON_SPAWN_USMC_ARTILLERY_01", west, true, "", "", true],
    ["USMC_MORTAR_01", "VEHICLE", "USMC_MORTAR", "ON_SPAWN_USMC_MORTAR_01", west, true, "", "", true],
    ["USMC_STATIC_MG_01", "VEHICLE", "USMC_STATIC_MG", "ON_SPAWN_USMC_STATIC_MG_01", west, true, "", "", true],
    ["USMC_STATIC_AT_01", "VEHICLE", "USMC_STATIC_AT", "ON_SPAWN_USMC_STATIC_AT_01", west, true, "", "", true],
    ["USMC_STATIC_AA_01", "VEHICLE", "USMC_STATIC_AA", "ON_SPAWN_USMC_STATIC_AA_01", west, true, "", "", true],
    ["USMC_HELICOPTER_01", "VEHICLE", "USMC_HELICOPTER", "ON_SPAWN_USMC_HELICOPTER_01", west, true, "", "", true],
    ["USMC_AIRCRAFT_01", "VEHICLE", "USMC_AIRCRAFT", "ON_SPAWN_USMC_AIRCRAFT_01", west, true, "", "", true],

    // ENEMY / AFR — every listed enemy gets its own marker and classname key.
    ["AFR_RIFLEMAN_01", "UNIT", "AFR_RIFLEMAN", "ON_SPAWN_AFR_RIFLEMAN_01", east, false, "", "", true],
    ["AFR_RIFLEMAN_02", "UNIT", "AFR_RIFLEMAN", "ON_SPAWN_AFR_RIFLEMAN_02", east, false, "", "", true],
    ["AFR_MEDIC_01", "UNIT", "AFR_MEDIC", "ON_SPAWN_AFR_MEDIC_01", east, false, "", "", true],
    ["AFR_AT_01", "UNIT", "AFR_AT", "ON_SPAWN_AFR_AT_01", east, false, "", "", true],
    ["AFR_MG_01", "UNIT", "AFR_MG", "ON_SPAWN_AFR_MG_01", east, false, "", "", true],
    ["AFR_SNIPER_01", "UNIT", "AFR_SNIPER", "ON_SPAWN_AFR_SNIPER_01", east, false, "", "", true],
    ["AFR_CAR_01", "VEHICLE", "AFR_CAR", "ON_SPAWN_AFR_CAR_01", east, true, "", "", true],
    ["AFR_APC_01", "VEHICLE", "AFR_APC", "ON_SPAWN_AFR_APC_01", east, true, "", "", true],
    ["AFR_IFV_01", "VEHICLE", "AFR_IFV", "ON_SPAWN_AFR_IFV_01", east, true, "", "", true],
    ["AFR_TANK_01", "VEHICLE", "AFR_TANK", "ON_SPAWN_AFR_TANK_01", east, true, "", "", true],
    ["AFR_AA_01", "VEHICLE", "AFR_AA", "ON_SPAWN_AFR_AA_01", east, true, "", "", true],
    ["AFR_ARTILLERY_01", "VEHICLE", "AFR_ARTILLERY", "ON_SPAWN_AFR_ARTILLERY_01", east, true, "", "", true],
    ["AFR_STATIC_MG_01", "VEHICLE", "AFR_STATIC_MG", "ON_SPAWN_AFR_STATIC_MG_01", east, true, "", "", true],
    ["AFR_STATIC_AT_01", "VEHICLE", "AFR_STATIC_AT", "ON_SPAWN_AFR_STATIC_AT_01", east, true, "", "", true],
    ["AFR_STATIC_AA_01", "VEHICLE", "AFR_STATIC_AA", "ON_SPAWN_AFR_STATIC_AA_01", east, true, "", "", true],
    ["AFR_MORTAR_01", "VEHICLE", "AFR_MORTAR", "ON_SPAWN_AFR_MORTAR_01", east, true, "", "", true],
    ["AFR_HELICOPTER_01", "VEHICLE", "AFR_HELICOPTER", "ON_SPAWN_AFR_HELICOPTER_01", east, true, "", "", true],
    ["AFR_AIRCRAFT_01", "VEHICLE", "AFR_AIRCRAFT", "ON_SPAWN_AFR_AIRCRAFT_01", east, true, "", "", true]

    // COPY A ROW, change its ID / classname key / marker / side, and add a comma
    // when you want more units, vehicles, aircraft, static weapons, or custom assets.
]];

/*
    TACTICAL FORCE PACKAGES — OPTIONAL GROUP-LEVEL AI SYSTEM

    Row format:
      [id, side, [unitClassnameKey, ...], spawnMarker, behavior,
       [waypointMarker, ...], activationMarker, activationRadius]

    GARRISON: spawns immediately and holds the position.
    PATROL: spawns immediately and cycles through 2+ waypoint markers.
    QRF: stays unspawned until the player enters activationRadius of the
         activationMarker; then spawns at spawnMarker and moves to its route.

    Every unit classname key and marker is still selected by you.
    Leave the list empty until you are ready to configure group packages.
*/
missionNamespace setVariable ["ON_forcePackages", [
    /*
    // Example: a four-person AFR garrison at a manually selected location.
    ["AFR_OUTPOST_NORTH", east,
        ["AFR_RIFLEMAN", "AFR_RIFLEMAN", "AFR_MG", "AFR_AT"],
        "ON_SPAWN_AFR_OUTPOST_NORTH", "GARRISON", [], "", 0],

    // Example: a mobile patrol that cycles through three separate map markers.
    ["AFR_PATROL_EAST", east,
        ["AFR_RIFLEMAN", "AFR_RIFLEMAN", "AFR_MG"],
        "ON_SPAWN_AFR_PATROL_EAST", "PATROL",
        ["ON_PATROL_EAST_01", "ON_PATROL_EAST_02", "ON_PATROL_EAST_03"], "", 0],

    // Example: QRF stays dormant until the player approaches the trigger area.
    ["AFR_QRF_CENTRAL", east,
        ["AFR_RIFLEMAN", "AFR_RIFLEMAN", "AFR_AT", "AFR_MG"],
        "ON_SPAWN_AFR_QRF_BASE", "QRF",
        ["ON_QRF_ROUTE_01", "ON_QRF_ROUTE_02"],
        "ON_QRF_ACTIVATION", 1800]
    */
]];

/*
    ENEMY INTELLIGENCE / ALERT CONFIGURATION.

    AI knowledge thresholds are sampled from living units on ON_enemySide.
    This uses the engine's knowsAbout value; it is not radar or sensor fusion.
    Optional zones use [id, marker, radiusMetres, minimumAlertLevel].
    Leave zones empty until you have placed the markers in Eden.
*/
missionNamespace setVariable ["ON_enemyAlertSettings", createHashMapFromArray [
    ["enabled", true],
    ["suspiciousKnowledge", 1.5],
    ["alertedKnowledge", 2.5],
    ["engagedKnowledge", 3.5],
    ["scanInterval", 5]
]];

missionNamespace setVariable ["ON_enemyAlertZones", [
    /*
    ["AFR_NORTH_PERIMETER", "ON_ALERT_NORTH", 1200, "SUSPICIOUS"],
    ["AFR_COMMAND_AREA", "ON_ALERT_COMMAND", 900, "ALERTED"],
    ["AFR_INNER_DEFENSE", "ON_ALERT_INNER", 500, "ENGAGED"]
    */
]];

/*
    DYNAMIC REINFORCEMENTS.

    Row format:
      [id, side, [unitClassnameKey, ...], spawnMarker, [waypointMarker, ...],
       triggerType, triggerValue, initialDelaySeconds, maxWaves, waveIntervalSeconds]

    ALERT_LEVEL: triggerValue is SUSPICIOUS / ALERTED / ENGAGED.
    PHASE: triggerValue is a mission phase such as IN_FLIGHT.
    PLAYER_RADIUS: triggerValue is [existingMarker, radiusMetres].

    Empty waypoint list creates a garrison wave. One or more route markers
    creates a moving QRF-style wave. Every wave is spawned at an offset from
    the previous wave so multiple waves do not occupy the same coordinates.
    Keep this list empty until you configure the exact classnames and markers.
*/
missionNamespace setVariable ["ON_reinforcementDefinitions", [
    /*
    ["AFR_ALERT_REACTION", east,
        ["AFR_RIFLEMAN", "AFR_RIFLEMAN", "AFR_AT", "AFR_MG"],
        "ON_SPAWN_AFR_REINFORCEMENT",
        ["ON_AFR_REINFORCEMENT_ROUTE_01", "ON_AFR_REINFORCEMENT_ROUTE_02"],
        "ALERT_LEVEL", "ALERTED", 90, 2, 180],

    ["AFR_CAS_RESPONSE", east,
        ["AFR_RIFLEMAN", "AFR_RIFLEMAN", "AFR_MG"],
        "ON_SPAWN_AFR_CAS_RESPONSE", [],
        "PHASE", "IN_FLIGHT", 120, 1, 60]
    */
]];

/*
    ADVANCED CONVOY CONFIGURATION.

    Backward-compatible core fields:
      [id, [vehicleClassnameKey, ...], [routeMarker, ...], side]

    Optional fields:
      escortCount, [checkpointMarker, ...], checkpointPauseSeconds,
      reactionMode, damageThreshold, speedMode, behaviour

    The last escortCount vehicles in classname order are tagged ESCORT;
    preceding vehicles are tagged TRANSPORT. All vehicles share the configured
    route. Checkpoint markers must also appear in routeMarkers.
    reactionMode: CONTINUE / HALT_ON_DAMAGE / HALT_ON_LOSS.
    speedMode: LIMITED / NORMAL / FULL / (or another valid engine speed mode).
    behaviour: SAFE / AWARE / COMBAT / STEALTH.
*/
missionNamespace setVariable ["ON_convoyDefinitions", [
    ["AFR_ALPHA",
        ["AFR_CONVOY_TRUCK", "AFR_CONVOY_ESCORT_CAR"],
        ["ON_ROUTE_A_01", "ON_ROUTE_A_02", "ON_ROUTE_A_03"],
        east,
        1,
        ["ON_ROUTE_A_02"],
        15,
        "HALT_ON_LOSS",
        0.6,
        "LIMITED",
        "SAFE"
    ]
]];

// Mission-wide hostile side used by CAS target-area checks.
missionNamespace setVariable ["ON_enemySide", east];
