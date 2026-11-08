/*
    Operation Nimitz — enemy intelligence and alert controller.

    Sources:
      1. ARMA AI knowledge (knowsAbout) from living units on ON_enemySide.
      2. Optional manually configured map zones in ON_enemyAlertZones.

    This is not radar, line-of-sight, radio interception, or sensor fusion.
    Zone triggers are proximity-based and are configured by the mission author.
*/

waitUntil {
    !isNil "ON_fnc_message"
    && { !isNil "ON_fnc_recordEvent" }
    && { !isNil "ON_fnc_log" }
};

private _settings = missionNamespace getVariable ["ON_enemyAlertSettings", createHashMap];
private _enabled = _settings getOrDefault ["enabled", true];
private _enemySide = missionNamespace getVariable ["ON_enemySide", east];
private _suspiciousThreshold = _settings getOrDefault ["suspiciousKnowledge", 1.5];
private _alertedThreshold = _settings getOrDefault ["alertedKnowledge", 2.5];
private _engagedThreshold = _settings getOrDefault ["engagedKnowledge", 3.5];
private _scanInterval = (_settings getOrDefault ["scanInterval", 5]) max 1;

private _thresholdsValid = (
    _suspiciousThreshold isEqualType 0
    && { _alertedThreshold isEqualType 0 }
    && { _engagedThreshold isEqualType 0 }
    && { _suspiciousThreshold >= 0 }
    && { _suspiciousThreshold < _alertedThreshold }
    && { _alertedThreshold < _engagedThreshold }
    && { _engagedThreshold <= 4 }
);

if (!_thresholdsValid) then {
    ["Invalid enemy knowledge thresholds. Defaults 1.5 / 2.5 / 3.5 restored."] call ON_fnc_log;
    _suspiciousThreshold = 1.5;
    _alertedThreshold = 2.5;
    _engagedThreshold = 3.5;
};
private _zones = missionNamespace getVariable ["ON_enemyAlertZones", []];

ON_fnc_alertRank = {
    params [["_level", "QUIET", [""]]];
    switch (toUpper _level) do {
        case "SUSPICIOUS": { 1 };
        case "ALERTED": { 2 };
        case "ENGAGED": { 3 };
        default { 0 };
    }
};

ON_fnc_alertName = {
    params [["_rank", 0, [0]]];
    switch (_rank) do {
        case 1: { "SUSPICIOUS" };
        case 2: { "ALERTED" };
        case 3: { "ENGAGED" };
        default { "QUIET" };
    }
};

missionNamespace setVariable ["ON_enemyAlertLevel", "QUIET"];
missionNamespace setVariable ["ON_enemyAlertRank", 0];
missionNamespace setVariable ["ON_enemyKnownUnitCount", 0];
missionNamespace setVariable ["ON_enemyAlertControllerReady", true];

if (!_enabled) exitWith {
    ["Enemy alert controller disabled by configuration."] call ON_fnc_recordEvent;
};

{
    _x params [
        ["_zoneId", "", [""]],
        ["_marker", "", [""]],
        ["_radius", 0, [0]],
        ["_level", "SUSPICIOUS", [""]]
    ];

    if (
        _zoneId isEqualTo ""
        || { !(_marker in allMapMarkers) }
        || { _radius <= 0 }
        || { !((toUpper _level) in ["SUSPICIOUS", "ALERTED", "ENGAGED"]) }
    ) then {
        [format ["Enemy alert zone rejected: invalid ID, marker, radius, or level (%1).", _zoneId]] call ON_fnc_log;
    };
} forEach _zones;

["Enemy intelligence monitor online; AI knowledge and configured proximity zones are active."] call ON_fnc_recordEvent;

while { (missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "COMPLETE" } do {
    private _observedRank = missionNamespace getVariable ["ON_enemyAlertRank", 0];
    private _knownUnits = allUnits select {
        alive _x
        && { side group _x isEqualTo _enemySide }
    };
    private _knownCount = 0;

    {
        private _knowledge = _x knowsAbout player;
        if (_knowledge >= _suspiciousThreshold) then {
            _knownCount = _knownCount + 1;
        };

        if (_knowledge >= _engagedThreshold) then {
            _observedRank = _observedRank max 3;
        } else {
            if (_knowledge >= _alertedThreshold) then {
                _observedRank = _observedRank max 2;
            } else {
                if (_knowledge >= _suspiciousThreshold) then {
                    _observedRank = _observedRank max 1;
                };
            };
        };
    } forEach _knownUnits;

    private _playerPosition = getPosATL (vehicle player);
    {
        _x params [
            ["_zoneId", "", [""]],
            ["_marker", "", [""]],
            ["_radius", 0, [0]],
            ["_level", "SUSPICIOUS", [""]]
        ];

        if (
            _marker in allMapMarkers
            && { _radius > 0 }
            && { (_playerPosition distance2D (getMarkerPos _marker)) <= _radius }
        ) then {
            _observedRank = _observedRank max ([_level] call ON_fnc_alertRank);
            missionNamespace setVariable ["ON_lastEnemyAlertZone", _zoneId];
        };
    } forEach _zones;

    missionNamespace setVariable ["ON_enemyKnownUnitCount", _knownCount];

    private _currentRank = missionNamespace getVariable ["ON_enemyAlertRank", 0];
    if (_observedRank > _currentRank) then {
        private _newLevel = [_observedRank] call ON_fnc_alertName;
        missionNamespace setVariable ["ON_enemyAlertRank", _observedRank];
        missionNamespace setVariable ["ON_enemyAlertLevel", _newLevel];
        missionNamespace setVariable ["ON_enemyAlertChangedAt", time];

        private _report = switch (_observedRank) do {
            case 1: {
                "Enemy elements may have detected activity in the area. Maintain situational awareness."
            };
            case 2: {
                "Enemy forces are alerted. Expect increased resistance and possible reinforcements."
            };
            case 3: {
                "Enemy forces have a confirmed picture of our presence. Threat level is ENGAGED."
            };
            default { "Enemy alert state updated." };
        };

        ["NIMITZ INTEL", _report] call ON_fnc_message;
        [format ["Enemy alert escalated to %1 (known hostile units: %2).", _newLevel, _knownCount]] call ON_fnc_recordEvent;
    };

    sleep _scanInterval;
};

["Enemy intelligence monitor stopped."] call ON_fnc_log;
