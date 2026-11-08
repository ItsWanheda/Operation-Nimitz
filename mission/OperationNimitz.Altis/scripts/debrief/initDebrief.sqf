/*
    Basic sortie debrief.
*/
waitUntil { !isNil "ON_fnc_endMission" };

private _carrier = missionNamespace getVariable ["ON_carrier", objNull];
if (isNull _carrier) exitWith {
    ["Cannot install debrief action: ON_carrier is missing."] call ON_fnc_log;
};

_carrier addAction [
    "<t color='#B6FF00'>Complete post-flight debrief</t>",
    {
        params ["_target", "_caller", "_actionId"];
        if ((missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "DEBRIEF") exitWith {};
        ["ON_task_debrief", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["SUCCESS"] call ON_fnc_endMission;
        hint parseText format [
            "<t size='1.3'>OPERATION NIMITZ — DEBRIEF</t><br/><br/>Flight: JOKER 1-1<br/>Result: %1<br/>Final phase: %2<br/>Contact state: %3<br/><br/>This initial build records mission phase and contact state only. Detailed fuel, stores, damage, and flight telemetry are not yet implemented.",
            missionNamespace getVariable ["ON_missionResult", "UNSET"],
            missionNamespace getVariable ["ON_phase", "UNKNOWN"],
            missionNamespace getVariable ["ON_contactStatus", "NONE"]
        ];
    },
    nil, 1.5, true, true, "", "(_this distance _target) < 8"
];

["ON_task_debrief", "Complete shutdown and post-flight debrief at the carrier."] call ON_fnc_createTask;
["NIMITZ", "Debrief station is available on the carrier."] call ON_fnc_message;
