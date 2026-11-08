/*
    Operation Nimitz - mission initialization and shared functions.
    Single-player baseline. No third-party framework is assumed.
*/
waitUntil { time > 0 && { !isNull player } };

missionNamespace setVariable ["ON_version", "0.6.0-dev"];
missionNamespace setVariable ["ON_phase", "BRIEFING"];
missionNamespace setVariable ["ON_missionResult", "UNSET"];
missionNamespace setVariable ["ON_terminalPhase", "BRIEFING"];
missionNamespace setVariable ["ON_missionStartTime", time];
missionNamespace setVariable ["ON_contactStatus", "NONE"];
missionNamespace setVariable ["ON_contactDetectionRange", 8000];
missionNamespace setVariable ["ON_contactIdentificationRange", 2500];
missionNamespace setVariable ["ON_capMarker", "ON_mrk_CAP"];
missionNamespace setVariable ["ON_casAreaMarker", missionNamespace getVariable ["ON_casAreaMarker", "ON_mrk_CAS"]];
missionNamespace setVariable ["ON_casTargetMarker", missionNamespace getVariable ["ON_casTargetMarker", "ON_mrk_CAS_TARGET"]];
missionNamespace setVariable ["ON_casAreaRadius", missionNamespace getVariable ["ON_casAreaRadius", 2500]];
missionNamespace setVariable ["ON_casTargetRadius", missionNamespace getVariable ["ON_casTargetRadius", 500]];
missionNamespace setVariable ["ON_casTimeRequired", missionNamespace getVariable ["ON_casTimeRequired", 60]];
missionNamespace setVariable ["ON_enemySide", missionNamespace getVariable ["ON_enemySide", east]];
missionNamespace setVariable ["ON_assetClassnames", missionNamespace getVariable ["ON_assetClassnames", createHashMap]];
missionNamespace setVariable ["ON_assetDeployments", missionNamespace getVariable ["ON_assetDeployments", []]];
missionNamespace setVariable ["ON_convoyDefinitions", missionNamespace getVariable ["ON_convoyDefinitions", []]];
missionNamespace setVariable ["ON_forcePackages", missionNamespace getVariable ["ON_forcePackages", []]];
missionNamespace setVariable ["ON_enemyAlertSettings", missionNamespace getVariable ["ON_enemyAlertSettings", createHashMap]];
missionNamespace setVariable ["ON_enemyAlertZones", missionNamespace getVariable ["ON_enemyAlertZones", []]];
missionNamespace setVariable ["ON_reinforcementDefinitions", missionNamespace getVariable ["ON_reinforcementDefinitions", []]];
missionNamespace setVariable ["ON_reinforcementStatus", createHashMap];
missionNamespace setVariable ["ON_reinforcementGroups", []];
missionNamespace setVariable ["ON_enemyAlertControllerReady", false];
missionNamespace setVariable ["ON_enemyAlertLevel", "QUIET"];
missionNamespace setVariable ["ON_enemyAlertRank", 0];
missionNamespace setVariable ["ON_enemyKnownUnitCount", 0];
missionNamespace setVariable ["ON_convoyRecords", []];
missionNamespace setVariable ["ON_convoyStatus", createHashMap];
missionNamespace setVariable ["ON_convoyDirectorReady", false];
missionNamespace setVariable ["ON_metricCasTime", 0];
missionNamespace setVariable ["ON_capRadius", 1200];
missionNamespace setVariable ["ON_capDuration", 120];
missionNamespace setVariable ["ON_capTimeSeconds", 0];
missionNamespace setVariable ["ON_carrier", missionNamespace getVariable ["ON_carrier", objNull]];
missionNamespace setVariable ["ON_playerAircraft", missionNamespace getVariable ["ON_playerAircraft", objNull]];
missionNamespace setVariable ["ON_wingman", missionNamespace getVariable ["ON_wingman", objNull]];
missionNamespace setVariable ["ON_awacs", missionNamespace getVariable ["ON_awacs", objNull]];
missionNamespace setVariable ["ON_tanker", missionNamespace getVariable ["ON_tanker", objNull]];
missionNamespace setVariable ["ON_atc", missionNamespace getVariable ["ON_atc", missionNamespace getVariable ["ON_carrier", objNull]]];
missionNamespace setVariable ["ON_deckCrew", missionNamespace getVariable ["ON_deckCrew", objNull]];
missionNamespace setVariable ["ON_contactAircraft", missionNamespace getVariable ["ON_contactAircraft", objNull]];
missionNamespace setVariable ["ON_eventLog", []];
missionNamespace setVariable ["ON_taskIds", []];
missionNamespace setVariable ["ON_setupErrors", []];
missionNamespace setVariable ["ON_wingmanStatus", "WAITING"];
missionNamespace setVariable ["ON_metricMissionSeconds", 0];
missionNamespace setVariable ["ON_metricFlightSeconds", 0];
missionNamespace setVariable ["ON_metricVehicleDistance", 0];
missionNamespace setVariable ["ON_metricMaxAltitude", 0];
missionNamespace setVariable ["ON_metricMaxSpeed", 0];
missionNamespace setVariable ["ON_metricCapTime", 0];
missionNamespace setVariable ["ON_metricRecoveryTime", -1];

ON_fnc_log = {
    params [["_message", "", [""]]];
    diag_log format [
        "[OperationNimitz][%1] %2",
        missionNamespace getVariable ["ON_phase", "UNKNOWN"],
        _message
    ];
};

ON_fnc_recordEvent = {
    params [["_message", "", [""]]];
    private _events = missionNamespace getVariable ["ON_eventLog", []];
    _events pushBack [
        round time,
        missionNamespace getVariable ["ON_phase", "UNKNOWN"],
        _message
    ];
    if ((count _events) > 100) then {
        _events deleteAt 0;
    };
    missionNamespace setVariable ["ON_eventLog", _events];
    [_message] call ON_fnc_log;
};

ON_fnc_message = {
    params [
        ["_callsign", "NIMITZ", [""]],
        ["_message", "", [""]]
    ];
    systemChat format ["%1: %2", _callsign, _message];
    [format ["%1: %2", _callsign, _message]] call ON_fnc_recordEvent;
};

ON_fnc_setPhase = {
    params [["_newPhase", "", [""]]];
    private _oldPhase = missionNamespace getVariable ["ON_phase", "UNKNOWN"];

    if (_oldPhase isEqualTo _newPhase) exitWith {};

    private _allowedTransitions = [
        ["BRIEFING", "PREFLIGHT"],
        ["PREFLIGHT", "STARTUP"],
        ["STARTUP", "TAXI"],
        ["TAXI", "IN_FLIGHT"],
        ["IN_FLIGHT", "RTB"],
        ["RTB", "DEBRIEF"]
    ];

    private _validTransition = _newPhase isEqualTo "COMPLETE";
    if (!_validTransition) then {
        _validTransition = [_oldPhase, _newPhase] in _allowedTransitions;
    };

    if (!_validTransition) exitWith {
        [format ["Rejected invalid phase transition: %1 -> %2", _oldPhase, _newPhase]] call ON_fnc_log;
    };

    missionNamespace setVariable ["ON_phase", _newPhase];
    [format ["Phase transition: %1 -> %2", _oldPhase, _newPhase]] call ON_fnc_recordEvent;
};

ON_fnc_createTask = {
    params [
        ["_taskId", "", [""]],
        ["_title", "", [""]],
        ["_description", "", [""]],
        ["_destination", objNull]
    ];

    if (_taskId isEqualTo "") exitWith {
        ["Rejected task with empty ID."] call ON_fnc_log;
    };

    private _taskIds = missionNamespace getVariable ["ON_taskIds", []];
    if (_taskId in _taskIds) exitWith {
        [format ["Ignored duplicate task creation: %1", _taskId]] call ON_fnc_log;
    };

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

    _taskIds pushBack _taskId;
    missionNamespace setVariable ["ON_taskIds", _taskIds];
    [format ["Created task %1: %2", _taskId, _title]] call ON_fnc_recordEvent;
};

ON_fnc_setTaskState = {
    params [
        ["_taskId", "", [""]],
        ["_state", "ASSIGNED", [""]]
    ];

    private _taskIds = missionNamespace getVariable ["ON_taskIds", []];
    private _validStates = ["ASSIGNED", "SUCCEEDED", "FAILED", "CANCELED"];

    if !(_taskId in _taskIds) exitWith {
        [format ["Ignored state change for unknown task %1.", _taskId]] call ON_fnc_log;
    };
    if !(_state in _validStates) exitWith {
        [format ["Rejected invalid task state %1 for %2.", _state, _taskId]] call ON_fnc_log;
    };

    [_taskId, _state] call BIS_fnc_taskSetState;
    [format ["Task %1 set to %2", _taskId, _state]] call ON_fnc_recordEvent;
};

ON_fnc_formatDuration = {
    params [["_seconds", 0, [0]]];
    private _total = floor (_seconds max 0);
    private _hours = floor (_total / 3600);
    private _minutes = floor ((_total mod 3600) / 60);
    private _remaining = _total mod 60;
    private _minutesText = if (_minutes < 10) then { format ["0%1", _minutes] } else { str _minutes };
    private _secondsText = if (_remaining < 10) then { format ["0%1", _remaining] } else { str _remaining };
    format ["%1:%2:%3", _hours, _minutesText, _secondsText]
};

ON_fnc_endMission = {
    params [["_result", "ABORTED", [""]]];
    if ((missionNamespace getVariable ["ON_phase", ""]) isEqualTo "COMPLETE") exitWith {};

    if !(_result in ["SUCCESS", "ABORTED", "FAILED"]) then {
        _result = "FAILED";
    };

    missionNamespace setVariable ["ON_terminalPhase", missionNamespace getVariable ["ON_phase", "UNKNOWN"]];
    missionNamespace setVariable ["ON_missionResult", _result];
    ["COMPLETE"] call ON_fnc_setPhase;
    [format ["Sortie concluded with result %1.", _result]] call ON_fnc_recordEvent;
};

ON_fnc_validateSetup = {
    private _errors = [];
    private _aircraft = missionNamespace getVariable ["ON_playerAircraft", objNull];
    private _carrier = missionNamespace getVariable ["ON_carrier", objNull];
    private _marker = missionNamespace getVariable ["ON_casAreaMarker", "ON_mrk_CAS"];
    private _targetMarker = missionNamespace getVariable ["ON_casTargetMarker", "ON_mrk_CAS_TARGET"];

    if (isNull _aircraft) then {
        _errors pushBack "Required object ON_playerAircraft is missing.";
    };
    if (isNull _carrier) then {
        _errors pushBack "Required object ON_carrier is missing.";
    };
    if !(_marker in allMapMarkers) then {
        _errors pushBack format ["Required CAS area marker %1 is missing.", _marker];
    };
    if !(_targetMarker in allMapMarkers) then {
        _errors pushBack format ["Required CAS target marker %1 is missing.", _targetMarker];
    };

    missionNamespace setVariable ["ON_setupErrors", _errors];
    missionNamespace setVariable ["ON_setupValid", (count _errors) isEqualTo 0];

    if ((count _errors) > 0) then {
        {
            [format ["SETUP ERROR: %1", _x]] call ON_fnc_log;
        } forEach _errors;
        ["NIMITZ", "Mission setup is incomplete. Review the briefing and required Eden references before continuing."] call ON_fnc_message;
    } else {
        ["All required editor references are present."] call ON_fnc_recordEvent;
    };

    if (isNull (missionNamespace getVariable ["ON_wingman", objNull])) then {
        ["Optional AI wingman reference ON_wingman is not configured."] call ON_fnc_log;
    };
    if (isNull (missionNamespace getVariable ["ON_contactAircraft", objNull])) then {
        ["No optional scripted contact object is configured; CAS proceeds without scripted contact handling."] call ON_fnc_log;
    };

    (count _errors) isEqualTo 0
};

call compile preprocessFileLineNumbers "scripts\combat\spawnDirector.sqf";
[] execVM "scripts\combat\forcePackageController.sqf";
[] execVM "scripts\combat\alertController.sqf";
[] execVM "scripts\combat\reinforcementController.sqf";
[] execVM "scripts\combat\convoyController.sqf";

[] execVM "scripts\briefing\initBriefing.sqf";
[] execVM "scripts\flight\flightFlow.sqf";
[] execVM "scripts\combat\contactFramework.sqf";
[] execVM "scripts\support\supportController.sqf";
[] execVM "scripts\support\commandController.sqf";
[] execVM "scripts\core\telemetry.sqf";

[] call ON_fnc_validateSetup;
["Mission framework 0.6.0-dev initialized."] call ON_fnc_recordEvent;