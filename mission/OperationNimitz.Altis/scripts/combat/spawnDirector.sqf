/*
    Operation Nimitz — generic manual-classname asset deployment director.

    Reads:
      ON_assetClassnames    hashmap: classname key -> exact CfgVehicles classname
      ON_assetDeployments   rows defined in config/assetConfig.sqf
      ON_convoyDefinitions  convoy rows using classname keys

    All deployed objects are created from the user's exact classnames.
    Blank classnames disable a row. No mod classname is guessed.
*/

if (missionNamespace getVariable ["ON_assetDirectorStarted", false]) exitWith {
    ["Asset director already ran; duplicate deployment prevented."] call ON_fnc_log;
};
missionNamespace setVariable ["ON_assetDirectorStarted", true];

private _classMap = missionNamespace getVariable ["ON_assetClassnames", createHashMap];
private _deployments = missionNamespace getVariable ["ON_assetDeployments", []];
private _spawnedAssets = [];
private _usedUniqueMarkers = [];

// The playable player entity is defined by Eden's mission.sqm, not spawned as an AI unit.
// This key lets the user keep its intended classname in the same manual asset config.
private _expectedPlayerClass = _classMap getOrDefault ["PLAYER_UNIT", ""];
if (_expectedPlayerClass isNotEqualTo "") then {
    if !(isClass (configFile >> "CfgVehicles" >> _expectedPlayerClass)) then {
        [format ["PLAYER_UNIT classname '%1' is not present in CfgVehicles.", _expectedPlayerClass]] call ON_fnc_log;
    } else {
        if ((typeOf player) isNotEqualTo _expectedPlayerClass) then {
            [format ["Playable Eden unit is '%1' but config PLAYER_UNIT expects '%2'. Set the player unit to the configured class in Eden.", typeOf player, _expectedPlayerClass]] call ON_fnc_log;
        } else {
            ["Playable player unit matches configured PLAYER_UNIT classname."] call ON_fnc_recordEvent;
        };
    };
};

// -----------------------------------------------------------------------------
// INDIVIDUAL UNITS, VEHICLES, AIRCRAFT, CARRIER, STATIC WEAPONS
// -----------------------------------------------------------------------------
{
    _x params [
        ["_id", "", [""]],
        ["_type", "", [""]],
        ["_classKey", "", [""]],
        ["_marker", "", [""]],
        ["_side", west],
        ["_createCrew", false, [false]],
        ["_missionVariable", "", [""]],
        ["_driverVehicleVariable", "", [""]],
        ["_requireUniqueMarker", true, [true]]
    ];

    private _className = _classMap getOrDefault [_classKey, ""];

    // An empty classname is an intentional opt-out; it is not an error.
    if (_className isNotEqualTo "") then {
        if !(_type in ["UNIT", "VEHICLE"]) then {
            [format ["Asset '%1' skipped: unsupported type '%2' (use UNIT or VEHICLE).", _id, _type]] call ON_fnc_log;
        } else {
            if !(_marker in allMapMarkers) then {
                [format ["Asset '%1' skipped: marker '%2' does not exist.", _id, _marker]] call ON_fnc_log;
            } else {
                if !(_className isEqualType "" && { isClass (configFile >> "CfgVehicles" >> _className) }) then {
                    [format ["Asset '%1' skipped: classname key '%2' resolves to invalid CfgVehicles classname '%3'.", _id, _classKey, _className]] call ON_fnc_log;
                } else {
                    if (_requireUniqueMarker && { _marker in _usedUniqueMarkers }) then {
                        [format ["Asset '%1' skipped: marker '%2' is already used by another unique deployment.", _id, _marker]] call ON_fnc_log;
                    } else {
                        if (_requireUniqueMarker) then {
                            _usedUniqueMarkers pushBack _marker;
                        };

                        private _position = getMarkerPos _marker;
                        private _direction = markerDir _marker;
                        private _asset = objNull;

                        if (_type isEqualTo "UNIT") then {
                            private _group = createGroup [_side, true];
                            _asset = _group createUnit [_className, _position, [], 0, "NONE"];
                            if (!isNull _asset) then {
                                _asset setDir _direction;
                            };
                        } else {
                            _asset = createVehicle [_className, _position, [], 0, "NONE"];
                            if (!isNull _asset) then {
                                _asset setDir _direction;

                                if (_createCrew) then {
                                    createVehicleCrew _asset;
                                    private _crewGroup = createGroup [_side, true];
                                    (crew _asset) joinSilent _crewGroup;
                                };
                            };
                        };

                        if (isNull _asset) then {
                            [format ["Asset '%1' could not be created. Check classname '%2' and marker '%3'.", _id, _className, _marker]] call ON_fnc_log;
                        } else {
                            _asset setVariable ["ON_assetId", _id, true];
                            _asset setVariable ["ON_assetClassKey", _classKey, true];
                            _asset setVariable ["ON_assetSpawnMarker", _marker, true];

                            if (_missionVariable isNotEqualTo "") then {
                                missionNamespace setVariable [_missionVariable, _asset];
                            };

                            if (_driverVehicleVariable isNotEqualTo "") then {
                                private _driverVehicle = missionNamespace getVariable [_driverVehicleVariable, objNull];
                                if (isNull _driverVehicle) then {
                                    [format ["Unit '%1' spawned, but driver vehicle reference '%2' is missing.", _id, _driverVehicleVariable]] call ON_fnc_log;
                                } else {
                                    _asset moveInDriver _driverVehicle;
                                };
                            };

                            _spawnedAssets pushBack _asset;
                            [format ["Spawned asset '%1' (%2) from classname key '%3' at '%4'.", _id, _className, _classKey, _marker]] call ON_fnc_recordEvent;
                        };
                    };
                };
            };
        };
    };
} forEach _deployments;

// -----------------------------------------------------------------------------
// CONVOYS — CLASSNAME KEYS ARE RESOLVED THROUGH THE SAME MANUAL CONFIG HASHMAP
// -----------------------------------------------------------------------------
private _convoys = missionNamespace getVariable ["ON_convoyDefinitions", []];
private _usedRouteMarkers = [];
private _convoyRecords = [];

{
    _x params [
        ["_convoyId", "", [""]],
        ["_classKeys", [], [[]]],
        ["_routeMarkers", [], [[]]],
        ["_side", east],
        ["_escortCount", 0, [0]],
        ["_checkpointMarkers", [], [[]]],
        ["_checkpointPauseSeconds", 0, [0]],
        ["_reactionMode", "CONTINUE", [""]],
        ["_damageThreshold", 0.5, [0]],
        ["_speedMode", "LIMITED", [""]],
        ["_behaviour", "SAFE", [""]]
    ];

    private _resolvedClasses = _classKeys apply { _classMap getOrDefault [_x, ""] };
    private _markersExist = (_routeMarkers findIf { !(_x in allMapMarkers) }) isEqualTo -1;
    private _markersUnique = (count (_routeMarkers arrayIntersect _routeMarkers)) isEqualTo (count _routeMarkers);
    private _routeUnused = (_routeMarkers findIf { _x in _usedRouteMarkers }) isEqualTo -1;
    private _classesValid = (count _resolvedClasses) > 0 && {
        (_resolvedClasses findIf {
            _x isEqualTo "" || { !isClass (configFile >> "CfgVehicles" >> _x) }
        }) isEqualTo -1
    };
    private _routeLongEnough = (count _routeMarkers) >= (count _resolvedClasses);
    private _escortValid = _escortCount >= 0 && { _escortCount <= count _resolvedClasses };
    private _checkpointsValid = (_checkpointMarkers findIf { !(_x in _routeMarkers) }) isEqualTo -1;
    private _reactionValid = _reactionMode in ["CONTINUE", "HALT_ON_DAMAGE", "HALT_ON_LOSS"];
    private _speedValid = _speedMode in ["LIMITED", "NORMAL", "FULL"];
    private _behaviourValid = _behaviour in ["SAFE", "AWARE", "COMBAT", "STEALTH"];
    private _thresholdValid = _damageThreshold >= 0 && { _damageThreshold <= 1 };
    private _pauseValid = _checkpointPauseSeconds >= 0;

    if (
        _convoyId isEqualTo ""
        || { !_classesValid }
        || { !_markersExist }
        || { !_markersUnique }
        || { !_routeUnused }
        || { !_routeLongEnough }
        || { !_escortValid }
        || { !_checkpointsValid }
        || { !_reactionValid }
        || { !_speedValid }
        || { !_behaviourValid }
        || { !_thresholdValid }
        || { !_pauseValid }
    ) then {
        [format [
            "Convoy '%1' skipped. Check classname keys, route/spawn markers, escort count, checkpoint subset, reaction mode, speed/behaviour, and damage threshold.",
            _convoyId
        ]] call ON_fnc_log;
    } else {
        _usedRouteMarkers append _routeMarkers;
        private _convoyGroup = createGroup [_side, true];
        private _convoyVehicles = [];
        private _escortStartIndex = (count _resolvedClasses) - _escortCount;

        {
            private _className = _x;
            private _vehicleIndex = _forEachIndex;
            private _spawnMarker = _routeMarkers select _vehicleIndex;
            private _vehicle = createVehicle [_className, getMarkerPos _spawnMarker, [], 0, "NONE"];

            if (!isNull _vehicle) then {
                _vehicle setDir (markerDir _spawnMarker);
                createVehicleCrew _vehicle;
                private _vehicleCrew = crew _vehicle;

                if (_vehicleCrew isEqualTo []) then {
                    deleteVehicle _vehicle;
                    [format ["Convoy '%1' vehicle at marker '%2' has no crew. Verify that the selected classname is crewable.", _convoyId, _spawnMarker]] call ON_fnc_log;
                } else {
                    _vehicleCrew joinSilent _convoyGroup;
                    _vehicle setVariable ["ON_convoyId", _convoyId, true];
                    _vehicle setVariable ["ON_assetClassKey", _classKeys select _vehicleIndex, true];
                    _vehicle setVariable ["ON_assetSpawnMarker", _spawnMarker, true];
                    _vehicle setVariable [
                        "ON_convoyRole",
                        if (_escortCount > 0 && { _vehicleIndex >= _escortStartIndex }) then { "ESCORT" } else { "TRANSPORT" },
                        true
                    ];
                    _convoyVehicles pushBack _vehicle;
                    _spawnedAssets pushBack _vehicle;
                };
            };
        } forEach _resolvedClasses;

        if ((count _convoyVehicles) isEqualTo (count _resolvedClasses)) then {
            _convoyGroup setVariable ["ON_convoyId", _convoyId, true];
            _convoyGroup setFormation (if (_escortCount > 0) then { "COLUMN" } else { "FILE" });
            _convoyGroup setBehaviour _behaviour;
            _convoyGroup setCombatMode "YELLOW";
            _convoyGroup setSpeedMode _speedMode;

            {
                private _routeMarker = _x;
                private _waypoint = _convoyGroup addWaypoint [getMarkerPos _routeMarker, 0];
                _waypoint setWaypointType "MOVE";
                _waypoint setWaypointSpeed _speedMode;
                _waypoint setWaypointBehaviour _behaviour;
                _waypoint setWaypointCompletionRadius 20;

                if (_routeMarker in _checkpointMarkers && { _checkpointPauseSeconds > 0 }) then {
                    _waypoint setWaypointTimeout [
                        _checkpointPauseSeconds,
                        _checkpointPauseSeconds,
                        _checkpointPauseSeconds
                    ];
                };
            } forEach (_routeMarkers select [1]);

            private _cycle = _convoyGroup addWaypoint [getMarkerPos (_routeMarkers select 0), 0];
            _cycle setWaypointType "CYCLE";

            _convoyRecords pushBack [
                _convoyId,
                _convoyVehicles,
                _convoyGroup,
                _reactionMode,
                _damageThreshold,
                _checkpointMarkers,
                _checkpointPauseSeconds,
                _speedMode,
                _behaviour
            ];

            private _escortVehicles = { (_x getVariable ["ON_convoyRole", ""]) isEqualTo "ESCORT" } count _convoyVehicles;
            [format [
                "Convoy '%1' spawned with %2 vehicle(s), %3 escort(s). Route: %4. Checkpoints: %5. Reaction: %6.",
                _convoyId,
                count _convoyVehicles,
                _escortVehicles,
                _routeMarkers joinString ", ",
                _checkpointMarkers joinString ", ",
                _reactionMode
            ]] call ON_fnc_recordEvent;
        } else {
            {
                deleteVehicle _x;
            } forEach (units _convoyGroup);
            {
                deleteVehicle _x;
            } forEach _convoyVehicles;
            deleteGroup _convoyGroup;
            [format ["Convoy '%1' failed during vehicle/crew creation; partial convoy removed.", _convoyId]] call ON_fnc_log;
        };
    };
} forEach _convoys;

missionNamespace setVariable ["ON_convoyRecords", _convoyRecords];
missionNamespace setVariable ["ON_convoyDirectorReady", true];

if (isNull (missionNamespace getVariable ["ON_atc", objNull])) then {
    missionNamespace setVariable ["ON_atc", missionNamespace getVariable ["ON_carrier", objNull]];
};

missionNamespace setVariable ["ON_spawnedAssets", _spawnedAssets];
[format ["Manual asset deployment finished. Created %1 object(s).", count _spawnedAssets]] call ON_fnc_recordEvent;
