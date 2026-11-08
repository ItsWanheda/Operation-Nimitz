/*
    Marker-driven AFR deployment director.

    Spawn definition:
      [role, spawnMarker, vehicleClassname, side]
    Roles: "AA", "ARMOR", "ARTILLERY"

    Convoy definition:
      [convoyId, [vehicleClassnames...], [orderedRouteMarkerNames...], side]

    Configure missionNamespace arrays in mission init.sqf BEFORE initMission.sqf.
    Every static enemy element needs its own spawn marker. Each convoy needs at
    least one distinct route marker per vehicle. Classnames are never guessed.
*/
waitUntil { !isNil "ON_fnc_recordEvent" };

if (missionNamespace getVariable ["ON_enemyDirectorStarted", false]) exitWith {
    ["Enemy deployment director already ran; duplicate spawn prevented."] call ON_fnc_log;
};
missionNamespace setVariable ["ON_enemyDirectorStarted", true];

private _spawned = [];
private _usedSpawnMarkers = [];
private _usedRouteMarkers = [];
private _definitions = missionNamespace getVariable ["ON_enemySpawnDefinitions", []];

{
    _x params [
        ["_role", "", [""]],
        ["_marker", "", [""]],
        ["_class", "", [""]],
        ["_side", east]
    ];

    if !(_role in ["AA", "ARMOR", "ARTILLERY"]) then {
        [format ["Rejected unknown enemy spawn role '%1'.", _role]] call ON_fnc_log;
    } else {
        if (_marker isEqualTo "" || { !(_marker in allMapMarkers) }) then {
            [format ["Enemy %1 spawn skipped; marker '%2' is missing.", _role, _marker]] call ON_fnc_log;
        } else {
            if (_marker in _usedSpawnMarkers) then {
                [format ["Enemy spawn skipped; marker '%1' is already assigned.", _marker]] call ON_fnc_log;
            } else {
                if (_class isEqualTo "" || { !isClass (configFile >> "CfgVehicles" >> _class) }) then {
                    [format ["Enemy %1 spawn skipped; classname '%2' is invalid or unset.", _role, _class]] call ON_fnc_log;
                } else {
                    _usedSpawnMarkers pushBack _marker;
                    private _vehicle = createVehicle [_class, getMarkerPos _marker, [], 0, "NONE"];
                    if (!isNull _vehicle) then {
                        _vehicle setDir (markerDir _marker);
                        createVehicleCrew _vehicle;
                        private _crewGroup = createGroup [_side, true];
                        (crew _vehicle) joinSilent _crewGroup;
                        _vehicle setVariable ["ON_enemyRole", _role, true];
                        _vehicle setVariable ["ON_spawnMarker", _marker, true];
                        _spawned pushBack _vehicle;
                        [format ["Spawned %1 asset '%2' at marker '%3'.", _role, _class, _marker]] call ON_fnc_recordEvent;
                    };
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
        ["_side", east]
    ];

    private _validRoute = _routeMarkers select { _x in allMapMarkers };
    private _routeIsUnique = (count (_validRoute arrayIntersect _validRoute)) isEqualTo (count _validRoute);
    private _routeAlreadyUsed = (_validRoute findIf { _x in _usedRouteMarkers }) >= 0;

    if (
        _convoyId isEqualTo ""
        || { _classes isEqualTo [] }
        || { (count _validRoute) < (count _classes) }
        || { !_routeIsUnique }
        || { _routeAlreadyUsed }
    ) then {
        [format ["Convoy '%1' skipped: provide a unique, valid route with at least one marker per vehicle.", _convoyId]] call ON_fnc_log;
    } else {
        _usedRouteMarkers append _validRoute;
        private _convoyVehicles = [];
        private _convoyGroup = createGroup [_side, true];

        {
            private _class = _x;
            private _spawnMarker = _validRoute select _forEachIndex;

            if (_class isEqualTo "" || { !isClass (configFile >> "CfgVehicles" >> _class) }) then {
                [format ["Convoy '%1' skipped invalid vehicle classname '%2'.", _convoyId, _class]] call ON_fnc_log;
            } else {
                private _vehicle = createVehicle [_class, getMarkerPos _spawnMarker, [], 0, "NONE"];
                if (!isNull _vehicle) then {
                    _vehicle setDir (markerDir _spawnMarker);
                    createVehicleCrew _vehicle;
                    (crew _vehicle) joinSilent _convoyGroup;
                    _vehicle setVariable ["ON_convoyId", _convoyId, true];
                    _vehicle setVariable ["ON_spawnMarker", _spawnMarker, true];
                    _convoyVehicles pushBack _vehicle;
                    _spawned pushBack _vehicle;
                };
            };
        } forEach _classes;

        if (_convoyVehicles isNotEqualTo []) then {
            {
                private _waypoint = _convoyGroup addWaypoint [getMarkerPos _x, 0];
                _waypoint setWaypointType "MOVE";
                _waypoint setWaypointSpeed "LIMITED";
                _waypoint setWaypointBehaviour "SAFE";
                _waypoint setWaypointCompletionRadius 20;
            } forEach (_validRoute select [1]);

            private _cycle = _convoyGroup addWaypoint [getMarkerPos (_validRoute select 0), 0];
            _cycle setWaypointType "CYCLE";
            _convoyGroup setBehaviour "SAFE";
            _convoyGroup setSpeedMode "LIMITED";
            _convoyGroup setVariable ["ON_convoyId", _convoyId, true];
            [format ["Convoy '%1' spawned with %2 vehicle(s), route markers: %3.", _convoyId, count _convoyVehicles, _validRoute joinString ", "]] call ON_fnc_recordEvent;
        } else {
            deleteGroup _convoyGroup;
            [format ["Convoy '%1' could not form a crewed group; verify vehicle crew configs.", _convoyId]] call ON_fnc_log;
        };
    };
} forEach _convoys;

missionNamespace setVariable ["ON_spawnedEnemyVehicles", _spawned];
[format ["Enemy deployment complete. Spawned %1 vehicle(s).", count _spawned]] call ON_fnc_recordEvent;