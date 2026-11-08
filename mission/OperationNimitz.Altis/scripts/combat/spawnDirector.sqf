/*
    Marker-driven AFR deployment director.

    Spawn definition format:
      [role, spawnMarker, vehicleClassname, side]
    Roles: "AA", "ARMOR", "ARTILLERY"

    Convoy definition format:
      [convoyId, [vehicleClassnames...], [routeMarkerNames...], side]

    Example configuration belongs in mission init.sqf BEFORE initMission.sqf:
      missionNamespace setVariable ["ON_enemySpawnDefinitions", [
        ["AA", "ON_SPAWN_AA_NORTH", "VERIFIED_AA_CLASS", east],
        ["ARMOR", "ON_SPAWN_ARMOR_WEST", "VERIFIED_TANK_CLASS", east],
        ["ARTILLERY", "ON_SPAWN_ARTY_HILL", "VERIFIED_ARTY_CLASS", east]
      ]];
      missionNamespace setVariable ["ON_convoyDefinitions", [
        ["ALPHA", ["VERIFIED_TRUCK_CLASS", "VERIFIED_ESCORT_CLASS"],
          ["ON_ROUTE_CONVOY_ALPHA_01", "ON_ROUTE_CONVOY_ALPHA_02",
           "ON_ROUTE_CONVOY_ALPHA_03"], east]
      ]];

    No classnames are assumed. Empty configuration means no enemies are spawned.
*/
waitUntil { !isNil "ON_fnc_recordEvent" };

if (missionNamespace getVariable ["ON_enemyDirectorStarted", false]) exitWith {
    ["Enemy deployment director already ran; duplicate spawn prevented."] call ON_fnc_log;
};
missionNamespace setVariable ["ON_enemyDirectorStarted", true];

private _spawned = [];
private _definitions = missionNamespace getVariable ["ON_enemySpawnDefinitions", []];

{
    _x params [
        ["_role", "", [""]],
        ["_marker", "", [""]],
        ["_class", "", [""]],
        ["_side", east, [sideUnknown, east, west, independent, civilian]]
    ];

    if !(_role in ["AA", "ARMOR", "ARTILLERY"]) then {
        [format ["Rejected unknown enemy spawn role '%1'.", _role]] call ON_fnc_log;
    } else {
        if (_marker isEqualTo "" || { !(_marker in allMapMarkers) }) then {
            [format ["Enemy %1 spawn skipped; marker '%2' is missing.", _role, _marker]] call ON_fnc_log;
        } else {
            if (_class isEqualTo "" || { !isClass (configFile >> "CfgVehicles" >> _class) }) then {
                [format ["Enemy %1 spawn skipped; vehicle classname '%2' is invalid or unset.", _role, _class]] call ON_fnc_log;
            } else {
                private _position = getMarkerPos _marker;
                private _vehicle = createVehicle [_class, _position, [], 0, "NONE"];
                if (!isNull _vehicle) then {
                    _vehicle setDir (markerDir _marker);
                    createVehicleCrew _vehicle;
                    _vehicle setVariable ["ON_enemyRole", _role, true];
                    _vehicle setVariable ["ON_spawnMarker", _marker, true];
                    _spawned pushBack _vehicle;
                    [format ["Spawned %1 asset '%2' at marker '%3'.", _role, _class, _marker]] call ON_fnc_recordEvent;
                };
            };
        };
    };
} forEach _definitions;

private _convoys = missionNamespace getVariable ["ON_convoyDefinitions", []];
{
    _x params [
        ["_convoyId", "", [""]],
        ["_classes", [], [[]]],
        ["_routeMarkers", [], [[]]],
        ["_side", east, [sideUnknown, east, west, independent, civilian]]
    ];

    private _validRoute = _routeMarkers select { _x in allMapMarkers };
    if (_convoyId isEqualTo "" || { _classes isEqualTo [] } || { _validRoute isEqualTo [] }) then {
        [format ["Convoy '%1' skipped: ID, vehicle list, or valid route markers are missing.", _convoyId]] call ON_fnc_log;
    } else {
        private _convoyVehicles = [];
        private _convoyGroup = grpNull;

        {
            private _class = _x;
            private _spawnMarker = _validRoute select 0;
            if (_class isEqualTo "" || { !isClass (configFile >> "CfgVehicles" >> _class) }) then {
                [format ["Convoy '%1' skipped invalid vehicle classname '%2'.", _convoyId, _class]] call ON_fnc_log;
            } else {
                private _spawnPosition = getMarkerPos _spawnMarker;
                private _vehicle = createVehicle [_class, _spawnPosition, [], 0, "NONE"];
                if (!isNull _vehicle) then {
                    _vehicle setDir (markerDir _spawnMarker);
                    createVehicleCrew _vehicle;
                    private _crew = crew _vehicle;
                    if (_crew isNotEqualTo []) then {
                        if (isNull _convoyGroup) then {
                            _convoyGroup = group (_crew select 0);
                        } else {
                            {
                                [_x] joinSilent _convoyGroup;
                            } forEach _crew;
                        };
                    };
                    _vehicle setVariable ["ON_convoyId", _convoyId, true];
                    _vehicle setVariable ["ON_spawnMarker", _spawnMarker, true];
                    _convoyVehicles pushBack _vehicle;
                    _spawned pushBack _vehicle;
                };
            };
        } forEach _classes;

        if (!isNull _convoyGroup && { _convoyVehicles isNotEqualTo [] }) then {
            {
                private _waypoint = _convoyGroup addWaypoint [getMarkerPos _x, 0];
                _waypoint setWaypointType "MOVE";
                _waypoint setWaypointSpeed "LIMITED";
                _waypoint setWaypointBehaviour "SAFE";
                _waypoint setWaypointCompletionRadius 20;
            } forEach _validRoute;
            private _cycle = _convoyGroup addWaypoint [getMarkerPos (_validRoute select 0), 0];
            _cycle setWaypointType "CYCLE";
            _convoyGroup setBehaviour "SAFE";
            _convoyGroup setSpeedMode "LIMITED";
            _convoyGroup setVariable ["ON_convoyId", _convoyId, true];
            [format ["Convoy '%1' spawned with %2 vehicle(s), route markers: %3.", _convoyId, count _convoyVehicles, _validRoute joinString ", "]] call ON_fnc_recordEvent;
        } else {
            [format ["Convoy '%1' could not form a crewed group; verify vehicle crew configs.", _convoyId]] call ON_fnc_log;
        };
    };
} forEach _convoys;

missionNamespace setVariable ["ON_spawnedEnemyVehicles", _spawned];
[format ["Enemy deployment complete. Spawned %1 vehicle(s).", count _spawned]] call ON_fnc_recordEvent;