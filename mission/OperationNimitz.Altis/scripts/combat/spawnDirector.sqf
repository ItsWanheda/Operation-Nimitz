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

{
    _x params [
        ["_convoyId", "", [""]],
        ["_classKeys", [], [[]]],
        ["_routeMarkers", [], [[]]],
        ["_side", east]
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

    if (
        _convoyId isEqualTo ""
        || { !_classesValid }
        || { !_markersExist }
        || { !_markersUnique }
        || { !_routeUnused }
        || { !_routeLongEnough }
    ) then {
        [format [
            "Convoy '%1' skipped. Check classname keys, valid CfgVehicles classnames, and a unique existing route with at least one marker per vehicle.",
            _convoyId
        ]] call ON_fnc_log;
    } else {
        _usedRouteMarkers append _routeMarkers;
        private _convoyGroup = createGroup [_side, true];
        private _convoyVehicles = [];

        {
            private _className = _x;
            private _spawnMarker = _routeMarkers select _forEachIndex;
            private _vehicle = createVehicle [_className, getMarkerPos _spawnMarker, [], 0, "NONE"];

            if (!isNull _vehicle) then {
                _vehicle setDir (markerDir _spawnMarker);
                createVehicleCrew _vehicle;
                (crew _vehicle) joinSilent _convoyGroup;
                _vehicle setVariable ["ON_convoyId", _convoyId, true];
                _vehicle setVariable ["ON_assetClassKey", _classKeys select _forEachIndex, true];
                _vehicle setVariable ["ON_assetSpawnMarker", _spawnMarker, true];
                _convoyVehicles pushBack _vehicle;
                _spawnedAssets pushBack _vehicle;
            };
        } forEach _resolvedClasses;

        if ((count _convoyVehicles) isEqualTo (count _resolvedClasses)) then {
            {
                private _waypoint = _convoyGroup addWaypoint [getMarkerPos _x, 0];
                _waypoint setWaypointType "MOVE";
                _waypoint setWaypointSpeed "LIMITED";
                _waypoint setWaypointBehaviour "SAFE";
                _waypoint setWaypointCompletionRadius 20;
            } forEach (_routeMarkers select [1]);

            private _cycle = _convoyGroup addWaypoint [getMarkerPos (_routeMarkers select 0), 0];
            _cycle setWaypointType "CYCLE";
            _convoyGroup setBehaviour "SAFE";
            _convoyGroup setSpeedMode "LIMITED";
            _convoyGroup setVariable ["ON_convoyId", _convoyId, true];

            [format [
                "Convoy '%1' spawned with %2 vehicle(s). Route: %3.",
                _convoyId,
                count _convoyVehicles,
                _routeMarkers joinString ", "
            ]] call ON_fnc_recordEvent;
        } else {
            {
                deleteVehicle _x;
            } forEach _convoyVehicles;
            deleteGroup _convoyGroup;
            [format ["Convoy '%1' failed during vehicle creation; partial vehicles removed.", _convoyId]] call ON_fnc_log;
        };
    };
} forEach _convoys;

if (isNull (missionNamespace getVariable ["ON_atc", objNull])) then {
    missionNamespace setVariable ["ON_atc", missionNamespace getVariable ["ON_carrier", objNull]];
};

missionNamespace setVariable ["ON_spawnedAssets", _spawnedAssets];
[format ["Manual asset deployment finished. Created %1 object(s).", count _spawnedAssets]] call ON_fnc_recordEvent;
