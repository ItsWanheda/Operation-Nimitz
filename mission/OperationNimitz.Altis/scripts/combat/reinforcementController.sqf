/*
    Operation Nimitz — dynamic reinforcement wave controller.

    Config source: ON_reinforcementDefinitions in config/assetConfig.sqf

    Row schema:
      [id, side, [classnameKey, ...], spawnMarker, [waypointMarker, ...],
       triggerType, triggerValue, initialDelaySeconds, maxWaves, waveIntervalSeconds]

    triggerType:
      ALERT_LEVEL   triggerValue: SUSPICIOUS / ALERTED / ENGAGED
      PHASE         triggerValue: a mission phase such as IN_FLIGHT
      PLAYER_RADIUS triggerValue: [markerName, radiusMetres]

    Each wave uses the shared force-package spawner and the exact manual
    classname keys supplied in the configuration. No classname is inferred.
*/

waitUntil {
    !isNil "ON_fnc_message"
    && { !isNil "ON_fnc_log" }
    && { !isNil "ON_fnc_spawnForcePackage" }
    && { missionNamespace getVariable ["ON_enemyAlertControllerReady", false] }
};

private _definitions = missionNamespace getVariable ["ON_reinforcementDefinitions", []];
private _status = createHashMap;
missionNamespace setVariable ["ON_reinforcementStatus", _status];
missionNamespace setVariable ["ON_reinforcementGroups", []];

ON_fnc_reinforcementAlertRank = {
    params [["_level", "QUIET", [""]]];
    switch (toUpper _level) do {
        case "SUSPICIOUS": { 1 };
        case "ALERTED": { 2 };
        case "ENGAGED": { 3 };
        default { 0 };
    }
};

{
    private _definition = _x;
    _definition params [
        ["_id", "", [""]],
        ["_side", east],
        ["_classKeys", [], [[]]],
        ["_spawnMarker", "", [""]],
        ["_waypointMarkers", [], [[]]],
        ["_triggerType", "", [""]],
        ["_triggerValue", ""],
        ["_initialDelay", 0, [0]],
        ["_maxWaves", 1, [0]],
        ["_waveInterval", 60, [0]]
    ];

    if (
        _id isEqualTo ""
        || { _classKeys isEqualTo [] }
        || { !(_spawnMarker in allMapMarkers) }
        || { !(_triggerType in ["ALERT_LEVEL", "PHASE", "PLAYER_RADIUS"]) }
        || { _maxWaves < 1 }
    ) then {
        [format ["Reinforcement definition rejected due to invalid ID, class list, spawn marker, trigger, or wave count: %1.", _id]] call ON_fnc_log;
        _status set [_id, ["INVALID", 0, _maxWaves]];
    } else {
        if ((_waypointMarkers findIf { !(_x in allMapMarkers) }) >= 0) then {
            [format ["Reinforcement '%1' rejected: a route marker is missing.", _id]] call ON_fnc_log;
            _status set [_id, ["INVALID", 0, _maxWaves]];
        } else {
            if (
                _triggerType isEqualTo "PLAYER_RADIUS"
                && {
                    !(_triggerValue isEqualType [])
                    || { (count _triggerValue) < 2 }
                    || { !((_triggerValue select 0) in allMapMarkers) }
                    || { !((_triggerValue select 1) isEqualType 0) }
                    || { (_triggerValue select 1) <= 0 }
                }
            ) then {
                [format ["Reinforcement '%1' rejected: PLAYER_RADIUS requires [existingMarker, radius].", _id]] call ON_fnc_log;
                _status set [_id, ["INVALID", 0, _maxWaves]];
            } else {
                _status set [_id, ["STANDBY", 0, _maxWaves]];

                [_definition] spawn {
                    params ["_row"];
                    _row params [
                        ["_reinforcementId", "", [""]],
                        ["_reinforcementSide", east],
                        ["_reinforcementClassKeys", [], [[]]],
                        ["_reinforcementSpawnMarker", "", [""]],
                        ["_reinforcementWaypoints", [], [[]]],
                        ["_reinforcementTriggerType", "", [""]],
                        ["_reinforcementTriggerValue", ""],
                        ["_reinforcementInitialDelay", 0, [0]],
                        ["_reinforcementMaxWaves", 1, [0]],
                        ["_reinforcementWaveInterval", 60, [0]]
                    ];

                    private _triggered = false;
                    while {
                        !_triggered
                        && { (missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "COMPLETE" }
                    } do {
                        switch (_reinforcementTriggerType) do {
                            case "ALERT_LEVEL": {
                                private _requiredRank = [_reinforcementTriggerValue] call ON_fnc_reinforcementAlertRank;
                                private _currentRank = missionNamespace getVariable ["ON_enemyAlertRank", 0];
                                _triggered = _requiredRank > 0 && { _currentRank >= _requiredRank };
                            };
                            case "PHASE": {
                                _triggered = (missionNamespace getVariable ["ON_phase", ""]) isEqualTo _reinforcementTriggerValue;
                            };
                            case "PLAYER_RADIUS": {
                                private _triggerMarker = _reinforcementTriggerValue select 0;
                                private _triggerRadius = _reinforcementTriggerValue select 1;
                                _triggered = (
                                    _triggerMarker in allMapMarkers
                                    && { ((vehicle player) distance2D (getMarkerPos _triggerMarker)) <= _triggerRadius }
                                );
                            };
                        };
                        if (!_triggered) then { sleep 3; };
                    };

                    if (!_triggered) exitWith {
                        [format ["Reinforcement '%1' remained on standby until mission termination.", _reinforcementId]] call ON_fnc_log;
                    };

                    private _stateMap = missionNamespace getVariable ["ON_reinforcementStatus", createHashMap];
                    _stateMap set [_reinforcementId, ["DELAYING", 0, _reinforcementMaxWaves]];
                    ["NIMITZ", format ["Reinforcement request '%1' received. First wave estimated in %2 seconds.", _reinforcementId, _reinforcementInitialDelay]] call ON_fnc_message;
                    [format ["Reinforcement '%1' trigger satisfied; initial delay %2 seconds.", _reinforcementId, _reinforcementInitialDelay]] call ON_fnc_recordEvent;

                    sleep (_reinforcementInitialDelay max 0);

                    for "_wave" from 1 to _reinforcementMaxWaves do {
                        if ((missionNamespace getVariable ["ON_phase", ""]) isEqualTo "COMPLETE") exitWith {};

                        private _behavior = if (_reinforcementWaypoints isEqualTo []) then { "GARRISON" } else { "QRF" };
                        private _group = [
                            format ["%1_WAVE_%2", _reinforcementId, _wave],
                            _reinforcementSide,
                            _reinforcementClassKeys,
                            _reinforcementSpawnMarker,
                            _behavior,
                            _reinforcementWaypoints,
                            _wave
                        ] call ON_fnc_spawnForcePackage;

                        if (!isNull _group) then {
                            private _groups = missionNamespace getVariable ["ON_reinforcementGroups", []];
                            _groups pushBack _group;
                            missionNamespace setVariable ["ON_reinforcementGroups", _groups];

                            private _updated = _stateMap getOrDefault [_reinforcementId, ["ACTIVE", 0, _reinforcementMaxWaves]];
                            _updated set [0, "ACTIVE"];
                            _updated set [1, _wave];
                            _stateMap set [_reinforcementId, _updated];

                            ["NIMITZ", format ["Reinforcement '%1': wave %2/%3 deployed.", _reinforcementId, _wave, _reinforcementMaxWaves]] call ON_fnc_message;
                            [format ["Reinforcement '%1' wave %2/%3 spawned.", _reinforcementId, _wave, _reinforcementMaxWaves]] call ON_fnc_recordEvent;
                        } else {
                            [format ["Reinforcement '%1' wave %2 failed to spawn; check classname keys and markers.", _reinforcementId, _wave]] call ON_fnc_log;
                        };

                        if (_wave < _reinforcementMaxWaves) then {
                            sleep (_reinforcementWaveInterval max 1);
                        };
                    };

                    private _finalStatus = _stateMap getOrDefault [_reinforcementId, ["COMPLETE", 0, _reinforcementMaxWaves]];
                    _finalStatus set [0, "COMPLETE"];
                    _stateMap set [_reinforcementId, _finalStatus];
                    [format ["Reinforcement schedule '%1' completed.", _reinforcementId]] call ON_fnc_recordEvent;
                };
            };
        };
    };
} forEach _definitions;

["Dynamic reinforcement controller initialized."] call ON_fnc_recordEvent;
