/*
    Operation Nimitz — tactical force package controller.

    Config source: ON_forcePackages in config/assetConfig.sqf

    Package schema:
      [id, side, [classnameKey, ...], spawnMarker, behavior,
       [waypointMarker, ...], activationMarker, activationRadius]

    Behaviors:
      GARRISON — spawn immediately and hold the assigned position.
      PATROL   — spawn immediately and cycle through ordered waypoint markers.
      QRF      — spawn only when the player enters activationRadius of
                 activationMarker, then move through the configured waypoints.

    This is an AI group/waypoint controller, not a full combat AI overhaul.
    Classnames and all map positions remain manually configured by the mission author.
*/

waitUntil { !isNil "ON_fnc_recordEvent" && { !isNil "ON_fnc_log" } };

private _classMap = missionNamespace getVariable ["ON_assetClassnames", createHashMap];
private _packages = missionNamespace getVariable ["ON_forcePackages", []];
private _activeGroups = [];
private _pendingQRF = [];

ON_fnc_spawnForcePackage = {
    params [
        ["_packageId", "", [""]],
        ["_side", east],
        ["_classKeys", [], [[]]],
        ["_spawnMarker", "", [""]],
        ["_behavior", "GARRISON", [""]],
        ["_waypointMarkers", [], [[]]]
    ];

    private _assetClassMap = missionNamespace getVariable ["ON_assetClassnames", createHashMap];
    private _classes = _classKeys apply { _assetClassMap getOrDefault [_x, ""] };

    if (_packageId isEqualTo "" || { _classes isEqualTo [] }) exitWith {
        [format ["Force package '%1' rejected: ID or unit list is empty.", _packageId]] call ON_fnc_log;
        grpNull
    };

    if !(_spawnMarker in allMapMarkers) exitWith {
        [format ["Force package '%1' rejected: spawn marker '%2' is missing.", _packageId, _spawnMarker]] call ON_fnc_log;
        grpNull
    };

    private _invalidClassIndex = _classes findIf {
        _x isEqualTo "" || { !isClass (configFile >> "CfgVehicles" >> _x) }
    };
    if (_invalidClassIndex >= 0) exitWith {
        [format ["Force package '%1' rejected: classname key '%2' is empty or invalid.", _packageId, _classKeys select _invalidClassIndex]] call ON_fnc_log;
        grpNull
    };

    if ((_waypointMarkers findIf { !(_x in allMapMarkers) }) >= 0) exitWith {
        [format ["Force package '%1' rejected: one or more waypoint markers are missing.", _packageId]] call ON_fnc_log;
        grpNull
    };

    if (_behavior isEqualTo "PATROL" && { (count _waypointMarkers) < 2 }) exitWith {
        [format ["Force package '%1' rejected: PATROL requires at least two waypoint markers.", _packageId]] call ON_fnc_log;
        grpNull
    };
    if (_behavior isEqualTo "QRF" && { (count _waypointMarkers) < 1 }) exitWith {
        [format ["Force package '%1' rejected: QRF requires at least one destination waypoint.", _packageId]] call ON_fnc_log;
        grpNull
    };

    private _group = createGroup [_side, true];
    private _origin = getMarkerPos _spawnMarker;
    private _heading = markerDir _spawnMarker;
    private _createdUnits = [];

    {
        private _row = _forEachIndex;
        private _column = _row mod 3;
        private _rank = floor (_row / 3);
        private _spawnPosition = [
            (_origin select 0) + ((_column - 1) * 3.5),
            (_origin select 1) + (_rank * 3.5),
            0
        ];
        private _unit = _group createUnit [_x, _spawnPosition, [], 0, "FORM"];

        if (!isNull _unit) then {
            _unit setDir _heading;
            _unit setVariable ["ON_forcePackageId", _packageId, true];
            _createdUnits pushBack _unit;
        };
    } forEach _classes;

    if ((count _createdUnits) isNotEqualTo (count _classes)) exitWith {
        { deleteVehicle _x; } forEach _createdUnits;
        deleteGroup _group;
        [format ["Force package '%1' failed to create every unit; partial group removed.", _packageId]] call ON_fnc_log;
        grpNull
    };

    _group setVariable ["ON_forcePackageId", _packageId, true];
    _group setBehaviour (if (_behavior isEqualTo "QRF") then { "AWARE" } else { "SAFE" });
    _group setCombatMode "YELLOW";
    _group setSpeedMode (if (_behavior isEqualTo "QRF") then { "NORMAL" } else { "LIMITED" });
    _group setFormation "WEDGE";

    switch (_behavior) do {
        case "GARRISON": {
            {
                _x doWatch (getMarkerPos _spawnMarker);
                _x setUnitPos "UP";
            } forEach _createdUnits;
        };

        case "PATROL": {
            {
                private _waypoint = _group addWaypoint [getMarkerPos _x, 0];
                _waypoint setWaypointType "MOVE";
                _waypoint setWaypointSpeed "LIMITED";
                _waypoint setWaypointBehaviour "SAFE";
                _waypoint setWaypointCompletionRadius 15;
            } forEach _waypointMarkers;

            private _cycle = _group addWaypoint [getMarkerPos (_waypointMarkers select 0), 0];
            _cycle setWaypointType "CYCLE";
        };

        case "QRF": {
            {
                private _waypoint = _group addWaypoint [getMarkerPos _x, 0];
                _waypoint setWaypointType "MOVE";
                _waypoint setWaypointSpeed "NORMAL";
                _waypoint setWaypointBehaviour "AWARE";
                _waypoint setWaypointCompletionRadius 15;
            } forEach _waypointMarkers;
        };
    };

    [format ["Force package '%1' spawned: %2 unit(s), behavior %3, marker %4.", _packageId, count _createdUnits, _behavior, _spawnMarker]] call ON_fnc_recordEvent;
    _group
};

// Validate and launch immediate packages. QRF packages remain dormant until triggered.
{
    _x params [
        ["_id", "", [""]],
        ["_side", east],
        ["_classKeys", [], [[]]],
        ["_spawnMarker", "", [""]],
        ["_behavior", "GARRISON", [""]],
        ["_waypointMarkers", [], [[]]],
        ["_activationMarker", "", [""]],
        ["_activationRadius", 1500, [0]]
    ];

    if !(_behavior in ["GARRISON", "PATROL", "QRF"]) then {
        [format ["Force package '%1' skipped: unsupported behavior '%2'.", _id, _behavior]] call ON_fnc_log;
    } else {
        if (_behavior isEqualTo "QRF") then {
            if !(_activationMarker in allMapMarkers) then {
                [format ["QRF '%1' skipped: activation marker '%2' is missing.", _id, _activationMarker]] call ON_fnc_log;
            } else {
                _pendingQRF pushBack _x;
                [format ["QRF '%1' standing by. Activation radius: %2m around %3.", _id, _activationRadius, _activationMarker]] call ON_fnc_recordEvent;
            };
        } else {
            private _group = [
                _id, _side, _classKeys, _spawnMarker, _behavior, _waypointMarkers
            ] call ON_fnc_spawnForcePackage;
            if (!isNull _group) then { _activeGroups pushBack _group; };
        };
    };
} forEach _packages;

missionNamespace setVariable ["ON_forcePackageGroups", _activeGroups];
missionNamespace setVariable ["ON_pendingQRFCount", count _pendingQRF];

// QRF is a one-shot activation: once the player enters the configured radius,
// the group is spawned at its separate spawn marker and follows its route.
while {
    (missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "COMPLETE"
    && { _pendingQRF isNotEqualTo [] }
} do {
    private _playerPosition = getPosATL player;
    private _activatedIndexes = [];

    {
        _x params [
            ["_id", "", [""]],
            ["_side", east],
            ["_classKeys", [], [[]]],
            ["_spawnMarker", "", [""]],
            ["_behavior", "QRF", [""]],
            ["_waypointMarkers", [], [[]]],
            ["_activationMarker", "", [""]],
            ["_activationRadius", 1500, [0]]
        ];

        if (
            _activationMarker in allMapMarkers
            && { (_playerPosition distance2D (getMarkerPos _activationMarker)) <= _activationRadius }
        ) then {
            private _group = [
                _id, _side, _classKeys, _spawnMarker, "QRF", _waypointMarkers
            ] call ON_fnc_spawnForcePackage;

            if (!isNull _group) then {
                private _groups = missionNamespace getVariable ["ON_forcePackageGroups", []];
                _groups pushBack _group;
                missionNamespace setVariable ["ON_forcePackageGroups", _groups];
                [format ["QRF '%1' activated by player proximity.", _id]] call ON_fnc_message;
            };
            _activatedIndexes pushBack _forEachIndex;
        };
    } forEach _pendingQRF;

    for "_i" from ((count _activatedIndexes) - 1) to 0 step -1 do {
        _pendingQRF deleteAt (_activatedIndexes select _i);
    };

    missionNamespace setVariable ["ON_pendingQRFCount", count _pendingQRF];
    sleep 5;
};

["Tactical force package controller initialized."] call ON_fnc_recordEvent;
