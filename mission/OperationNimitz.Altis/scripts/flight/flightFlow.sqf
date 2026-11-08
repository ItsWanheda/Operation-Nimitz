/*
    Flight-deck progression gates.
    These record player confirmation of real procedures; they do NOT simulate
    aircraft startup, taxi, catapult, or carrier systems.
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
        if ((vehicle _caller) isNotEqualTo _caller) exitWith {
            ["JOKER 1-1", "Exit the aircraft and begin the external preflight inspection."] call ON_fnc_message;
        };

        ["ON_task_briefing", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["PREFLIGHT"] call ON_fnc_setPhase;
        ["ON_task_preflight", "Inspect the aircraft using the installed mod's supported procedures. Return to the aircraft when the inspection is complete.", _target] call ON_fnc_createTask;
        ["JOKER 1-1", "Preflight inspection started. Complete the checks and report when ready."] call ON_fnc_message;
    },
    nil, 1.5, true, true, "",
    "(_this distance _target) < 6 && { (vehicle _this) isEqualTo _this } && { (missionNamespace getVariable ['ON_phase', '']) isEqualTo 'BRIEFING' }"
];

_aircraft addAction [
    "<t color='#B6FF00'>Report preflight inspection complete</t>",
    {
        params ["_target", "_caller", "_actionId"];
        if ((missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "PREFLIGHT") exitWith {};
        if ((vehicle _caller) isNotEqualTo _caller) exitWith {};

        ["ON_task_preflight", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["STARTUP"] call ON_fnc_setPhase;
        ["ON_task_startup", "Board the assigned aircraft, complete the mod-supported engine-start procedure and required checks, then report ready.", _target] call ON_fnc_createTask;
        ["JOKER 1-1", "Preflight complete. Board the aircraft and begin the verified engine-start procedure."] call ON_fnc_message;
    },
    nil, 1.5, true, true, "",
    "(_this distance _target) < 6 && { (vehicle _this) isEqualTo _this } && { (missionNamespace getVariable ['ON_phase', '']) isEqualTo 'PREFLIGHT' }"
];

_aircraft addAction [
    "<t color='#B6FF00'>Report engine start and checks complete</t>",
    {
        params ["_target", "_caller", "_actionId"];
        if ((missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "STARTUP") exitWith {};
        if ((vehicle _caller) isNotEqualTo _target || { !(isEngineOn _target) }) exitWith {
            ["JOKER 1-1", "Startup report unavailable until you are aboard the assigned aircraft with the engine running."] call ON_fnc_message;
        };

        ["ON_task_startup", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["TAXI"] call ON_fnc_setPhase;
        ["ON_task_taxi", "Request and complete the installed carrier/aircraft mod's taxi and launch procedure. Report launch only after becoming airborne.", _target] call ON_fnc_createTask;
        ["NIMITZ", "Startup reported. Request taxi and launch clearance using the verified carrier procedure."] call ON_fnc_message;
    },
    nil, 1.5, true, true, "",
    "(_this distance _target) < 6 && { (vehicle _this) isEqualTo _target } && { isEngineOn _target } && { (missionNamespace getVariable ['ON_phase', '']) isEqualTo 'STARTUP' }"
];

_aircraft addAction [
    "<t color='#B6FF00'>Report taxi and launch complete</t>",
    {
        params ["_target", "_caller", "_actionId"];
        if ((missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "TAXI") exitWith {};
        if ((vehicle _caller) isNotEqualTo _target || { isTouchingGround _target } || { (getPosATL _target select 2) < 50 }) exitWith {
            ["JOKER 1-1", "Launch report requires the assigned aircraft to be airborne above 50 metres."] call ON_fnc_message;
        };

        private _marker = missionNamespace getVariable ["ON_capMarker", "ON_mrk_CAP"];
        if !(_marker in allMapMarkers) exitWith {
            ["NIMITZ", "CAP marker is missing. RTB progression is blocked until mission setup is corrected."] call ON_fnc_message;
        };

        ["ON_task_taxi", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["IN_FLIGHT"] call ON_fnc_setPhase;
        ["ON_task_cap", "Join JOKER 1-2 if available and proceed to the designated CAP station. Hold the station for the required period and resolve any scripted contact.", getMarkerPos _marker] call ON_fnc_createTask;
        ["NIMITZ", "Launch confirmed. JOKER 1-1, proceed to the CAP station."] call ON_fnc_message;

        [] execVM "scripts\ai\wingmanController.sqf";
        [] execVM "scripts\flight\capFlow.sqf";
        [] execVM "scripts\combat\contactFlow.sqf";
    },
    nil, 1.5, true, true, "",
    "(_this distance _target) < 6 && { (vehicle _this) isEqualTo _target } && { !(isTouchingGround _target) } && { (getPosATL _target select 2) >= 50 } && { (missionNamespace getVariable ['ON_phase', '']) isEqualTo 'TAXI' }"
];

["Flight progression actions installed on ON_playerAircraft."] call ON_fnc_recordEvent;