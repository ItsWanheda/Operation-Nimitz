/*
    Operation Nimitz - mission initialization and shared functions.
    Single-player baseline. No third-party framework is assumed.
*/
waitUntil { time > 0 && { !isNull player } };

missionNamespace setVariable ["ON_version", "0.1.0-dev"];
missionNamespace setVariable ["ON_phase", "BRIEFING"];
missionNamespace setVariable ["ON_missionResult", "UNSET"];
missionNamespace setVariable ["ON_contactStatus", "NONE"];
missionNamespace setVariable ["ON_capMarker", "ON_mrk_CAP"];
missionNamespace setVariable ["ON_capRadius", 1200];
missionNamespace setVariable ["ON_capDuration", 120];
missionNamespace setVariable ["ON_carrier", missionNamespace getVariable ["ON_carrier", objNull]];
missionNamespace setVariable ["ON_playerAircraft", missionNamespace getVariable ["ON_playerAircraft", objNull]];
missionNamespace setVariable ["ON_wingman", missionNamespace getVariable ["ON_wingman", objNull]];

ON_fnc_log = {
    params [["_message", "", [""]]];
    diag_log format ["[OperationNimitz][%1] %2", missionNamespace getVariable ["ON_phase", "UNKNOWN"], _message];
};

ON_fnc_message = {
    params [
        ["_callsign", "NIMITZ", [""]],
        ["_message", "", [""]]
    ];
    systemChat format ["%1: %2", _callsign, _message];
    [format ["Radio message from %1: %2", _callsign, _message]] call ON_fnc_log;
};

ON_fnc_setPhase = {
    params [["_newPhase", "", [""]]];
    private _oldPhase = missionNamespace getVariable ["ON_phase", "UNKNOWN"];
    private _allowedTransitions = [
        ["BRIEFING", "PREFLIGHT"],
        ["PREFLIGHT", "STARTUP"],
        ["STARTUP", "TAXI"],
        ["TAXI", "IN_FLIGHT"],
        ["IN_FLIGHT", "RTB"],
        ["RTB", "DEBRIEF"],
        ["DEBRIEF", "COMPLETE"]
    ];
    if !([_oldPhase, _newPhase] in _allowedTransitions) exitWith {
        [format ["Rejected invalid phase transition: %1 -> %2", _oldPhase, _newPhase]] call ON_fnc_log;
    };
    missionNamespace setVariable ["ON_phase", _newPhase];
    [format ["Phase transition: %1 -> %2", _oldPhase, _newPhase]] call ON_fnc_log;
};

ON_fnc_createTask = {
    params [
        ["_taskId", "", [""]],
        ["_title", "", [""]],
        ["_description", "", [""]],
        ["_destination", objNull]
    ];
    if (_taskId isEqualTo "") exitWith { ["Rejected task with empty ID."] call ON_fnc_log; };
    [
        player,
        _taskId,
        [_description, _title, _title],
        _destination,
        "ASSIGNED",
        1,
        true,
        "default"
    ] call BIS_fnc_taskCreate;
    [format ["Created task %1: %2", _taskId, _title]] call ON_fnc_log;
};

ON_fnc_setTaskState = {
    params [
        ["_taskId", "", [""]],
        ["_state", "ASSIGNED", [""]]
    ];
    if (_taskId isEqualTo "") exitWith {};
    [_taskId, _state] call BIS_fnc_taskSetState;
    [format ["Task %1 set to %2", _taskId, _state]] call ON_fnc_log;
};

ON_fnc_endMission = {
    params [["_result", "ABORTED", [""]]];
    missionNamespace setVariable ["ON_missionResult", _result];
    ["COMPLETE"] call ON_fnc_setPhase;
    [format ["Sortie concluded: %1", _result]] call ON_fnc_log;
    ["JOKER 1-1", format ["Sortie concluded. Result: %1. Debrief available.", _result]] call ON_fnc_message;
};

[] execVM "scripts\\briefing\\initBriefing.sqf";
[] execVM "scripts\\flight\\flightFlow.sqf";
[] execVM "scripts\\combat\\contactFramework.sqf";

["Mission framework initialized. Verify all required editor objects before preview."] call ON_fnc_log;
