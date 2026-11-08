/*
    Operation Nimitz — operational command and radio report controller.

    Contextual addAction entries provide scripted status requests. These are
    mission communications helpers, not a simulated radio/voice network.
*/

waitUntil {
    !isNil "ON_fnc_message"
    && { !isNil "ON_fnc_recordEvent" }
    && { !isNil "ON_fnc_log" }
};

ON_fnc_commandRequest = {
    params [["_command", "", [""]]];

    private _phase = missionNamespace getVariable ["ON_phase", "UNKNOWN"];
    private _alert = missionNamespace getVariable ["ON_enemyAlertLevel", "QUIET"];
    private _knownEnemies = missionNamespace getVariable ["ON_enemyKnownUnitCount", 0];

    switch (toUpper _command) do {
        case "SITREP": {
            private _flightTime = missionNamespace getVariable ["ON_metricFlightSeconds", 0];
            private _casTime = missionNamespace getVariable ["ON_metricCasTime", 0];
            private _aircraft = missionNamespace getVariable ["ON_playerAircraft", objNull];
            private _aircraftStatus = if (isNull _aircraft) then { "UNAVAILABLE" } else { if (alive _aircraft) then { "OPERATIONAL" } else { "LOST" } };
            ["NIMITZ CONTROL", format [
                "SITREP: phase %1; aircraft %2; enemy alert %3; known hostile units %4; flight time %5 sec; CAS station time %6 sec.",
                _phase, _aircraftStatus, _alert, _knownEnemies, round _flightTime, round _casTime
            ]] call ON_fnc_message;
        };

        case "THREAT": {
            ["NIMITZ INTEL", format [
                "Threat report: alert level %1; %2 hostile unit(s) currently show AI knowledge of JOKER 1-1. This is not a radar picture.",
                _alert, _knownEnemies
            ]] call ON_fnc_message;
        };

        case "REINFORCEMENTS": {
            private _statusMap = missionNamespace getVariable ["ON_reinforcementStatus", createHashMap];
            private _pending = 0;
            private _active = 0;
            private _complete = 0;
            private _failed = 0;

            {
                private _state = (_statusMap get _x) param [0, "UNKNOWN"];
                switch (_state) do {
                    case "STANDBY": { _pending = _pending + 1; };
                    case "DELAYING": { _pending = _pending + 1; };
                    case "ACTIVE": { _active = _active + 1; };
                    case "COMPLETE": { _complete = _complete + 1; };
                    case "INVALID": { _failed = _failed + 1; };
                };
            } forEach (keys _statusMap);

            ["NIMITZ CONTROL", format [
                "Reinforcement schedule: %1 standby/delaying, %2 active, %3 complete, %4 invalid.",
                _pending, _active, _complete, _failed
            ]] call ON_fnc_message;
        };

        case "CONVOY": {
            private _records = missionNamespace getVariable ["ON_convoyRecords", []];
            if (_records isEqualTo []) then {
                ["NIMITZ CONTROL", "No configured convoy is currently available in the mission record."] call ON_fnc_message;
            } else {
                {
                    _x params ["_convoyId", "_vehicles", "_group", "_reactionMode", "_damageThreshold", "_checkpoints", "_pauseSeconds", "_speed", "_behaviour"];
                    private _alive = { alive _x } count _vehicles;
                    private _total = count _vehicles;
                    private _stateMap = missionNamespace getVariable ["ON_convoyStatus", createHashMap];
                    private _state = _stateMap getOrDefault [_convoyId, "MOVING"];
                    ["NIMITZ CONTROL", format [
                        "Convoy %1: %2/%3 vehicles operational; status %4; reaction %5.",
                        _convoyId, _alive, _total, _state, _reactionMode
                    ]] call ON_fnc_message;
                } forEach _records;
            };
        };

        case "TASKING": {
            private _instruction = switch (_phase) do {
                case "BRIEFING": { "Review the briefing and report to the assigned aircraft to begin preflight." };
                case "PREFLIGHT": { "Complete the external inspection and report preflight complete." };
                case "STARTUP": { "Board the aircraft, complete engine start and report checks complete." };
                case "TAXI": { "Request and follow the verified carrier taxi/launch procedure." };
                case "IN_FLIGHT": {
                    private _marker = missionNamespace getVariable ["ON_casAreaMarker", "ON_mrk_CAS"];
                    if (_marker in allMapMarkers) then {
                        format ["Proceed to CAS area marker %1. Current enemy alert is %2; apply ROE.", _marker, _alert]
                    } else {
                        "CAS tasking marker unavailable; mission setup requires correction."
                    }
                };
                case "RTB": { "Return to the assigned carrier and complete the configured recovery check." };
                case "DEBRIEF": { "Shut down, exit the aircraft, and proceed to the debrief station." };
                case "COMPLETE": { "Sortie complete. No further tasking." };
                default { "Current tasking is unavailable." };
            };
            ["NIMITZ CONTROL", format ["Mission update (%1): %2", _phase, _instruction]] call ON_fnc_message;
        };

        default {
            [format ["Rejected unknown command request '%1'.", _command]] call ON_fnc_log;
        };
    };

    [format ["Operational command request: %1.", toUpper _command]] call ON_fnc_recordEvent;
};

private _aircraft = missionNamespace getVariable ["ON_playerAircraft", objNull];
if (!isNull _aircraft) then {
    _aircraft addAction [
        "<t color='#B6FF00'>Radio: Request mission SITREP</t>",
        { ["SITREP"] call ON_fnc_commandRequest; },
        nil, 1.5, true, true, "",
        "vehicle _this isEqualTo _target"
    ];
    _aircraft addAction [
        "<t color='#B6FF00'>Radio: Request enemy threat report</t>",
        { ["THREAT"] call ON_fnc_commandRequest; },
        nil, 1.5, true, true, "",
        "vehicle _this isEqualTo _target"
    ];
    _aircraft addAction [
        "<t color='#B6FF00'>Radio: Request reinforcement status</t>",
        { ["REINFORCEMENTS"] call ON_fnc_commandRequest; },
        nil, 1.5, true, true, "",
        "vehicle _this isEqualTo _target"
    ];
    _aircraft addAction [
        "<t color='#B6FF00'>Radio: Request convoy status</t>",
        { ["CONVOY"] call ON_fnc_commandRequest; },
        nil, 1.5, true, true, "",
        "vehicle _this isEqualTo _target"
    ];
    _aircraft addAction [
        "<t color='#B6FF00'>Radio: Request updated tasking</t>",
        { ["TASKING"] call ON_fnc_commandRequest; },
        nil, 1.5, true, true, "",
        "vehicle _this isEqualTo _target"
    ];
} else {
    ["Operational command actions not installed: ON_playerAircraft is missing."] call ON_fnc_log;
};

["Operational command actions installed on the assigned aircraft."] call ON_fnc_recordEvent;
