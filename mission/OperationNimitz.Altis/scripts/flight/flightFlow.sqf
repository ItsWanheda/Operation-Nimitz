/*
    Flight-deck progression gates.
    These actions record player confirmation; they do NOT simulate aircraft
    startup, taxi, catapult, or carrier systems. Those remain mod-dependent.
*/
waitUntil { !isNil "ON_fnc_setPhase" };

private _aircraft = missionNamespace getVariable ["ON_playerAircraft", objNull];
if (isNull _aircraft) exitWith {
    ["Required editor object ON_playerAircraft is missing. Flight actions not installed."] call ON_fnc_log;
    ["NIMITZ", "Mission setup warning: assigned aircraft reference is missing."] call ON_fnc_message;
};

_aircraft addAction [
    "<t color='#B6FF00'>Begin preflight inspection</t>",
    {
        params ["_target", "_caller", "_actionId"];
        if ((missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "BRIEFING") exitWith {};
        ["ON_task_briefing", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["PREFLIGHT"] call ON_fnc_setPhase;
        ["ON_task_preflight", "Complete the aircraft inspection using the procedures supported by the installed aircraft mod, then return here and report completion.", _target] call ON_fnc_createTask;
        ["JOKER 1-1", "Preflight inspection started. Complete your checks and report when ready."] call ON_fnc_message;
    },
    nil, 1.5, true, true, "", "(_this distance _target) < 6"
];

_aircraft addAction [
    "<t color='#B6FF00'>Report preflight inspection complete</t>",
    {
        params ["_target", "_caller", "_actionId"];
        if ((missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "PREFLIGHT") exitWith {};
        ["ON_task_preflight", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["STARTUP"] call ON_fnc_setPhase;
        ["ON_task_startup", "Complete the aircraft mod's verified engine-start and required checks, then report completion.", _target] call ON_fnc_createTask;
        ["JOKER 1-1", "Preflight complete. Begin the verified engine-start procedure."] call ON_fnc_message;
    },
    nil, 1.5, true, true, "", "(_this distance _target) < 6"
];

_aircraft addAction [
    "<t color='#B6FF00'>Report engine start and checks complete</t>",
    {
        params ["_target", "_caller", "_actionId"];
        if ((missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "STARTUP") exitWith {};
        ["ON_task_startup", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["TAXI"] call ON_fnc_setPhase;
        ["ON_task_taxi", "Request and complete the verified carrier taxi/catapult procedure. Use the next action only after reaching the launch point.", _target] call ON_fnc_createTask;
        ["NIMITZ", "Startup complete. Request taxi and launch clearance."] call ON_fnc_message;
    },
    nil, 1.5, true, true, "", "(_this distance _target) < 6"
];

_aircraft addAction [
    "<t color='#B6FF00'>Report taxi and launch complete</t>",
    {
        params ["_target", "_caller", "_actionId"];
        if ((missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "TAXI") exitWith {};
        ["ON_task_taxi", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["IN_FLIGHT"] call ON_fnc_setPhase;
        ["ON_task_cap", "Join JOKER 1-2 if available and proceed to the designated CAP station. Hold the station for the required on-station period.", getMarkerPos (missionNamespace getVariable ["ON_capMarker", "ON_mrk_CAP"])] call ON_fnc_createTask;
        ["NIMITZ", "Launch reported. JOKER 1-1, proceed to the CAP station."] call ON_fnc_message;
        [] execVM "scripts\flight\capFlow.sqf";
    },
    nil, 1.5, true, true, "", "(_this distance _target) < 6"
];

["Flight progression actions installed on ON_playerAircraft."] call ON_fnc_log;
