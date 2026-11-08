/*
    Sortie debrief with measured mission telemetry.
    Fuel, weapons, damage, hook engagement, and aircraft-specific recorder data
    are intentionally omitted until reliable mod data sources are verified.
*/
waitUntil { !isNil "ON_fnc_endMission" };

private _carrier = missionNamespace getVariable ["ON_carrier", objNull];
if (isNull _carrier) exitWith {
    ["Cannot install debrief action: ON_carrier is missing."] call ON_fnc_log;
};

["ON_task_debrief", "Post-flight debrief", "Shut down the aircraft, leave the cockpit, and complete the post-flight debrief at the carrier.", _carrier] call ON_fnc_createTask;

_carrier addAction [
    "<t color='#B6FF00'>Complete post-flight debrief</t>",
    {
        params ["_target", "_caller", "_actionId"];

        if ((missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "DEBRIEF") exitWith {};
        if ((vehicle _caller) isNotEqualTo _caller) exitWith {
            ["NIMITZ", "Exit the aircraft before reporting to the debrief station."] call ON_fnc_message;
        };
        if (missionNamespace getVariable ["ON_debriefShown", false]) exitWith {};

        missionNamespace setVariable ["ON_debriefShown", true];
        ["ON_task_debrief", "SUCCEEDED"] call ON_fnc_setTaskState;

        private _result = "SUCCESS";
        private _terminalPhase = missionNamespace getVariable ["ON_phase", "DEBRIEF"];
        private _missionSeconds = floor (time - (missionNamespace getVariable ["ON_missionStartTime", time]));
        private _flightSeconds = missionNamespace getVariable ["ON_metricFlightSeconds", 0];
        private _casSeconds = missionNamespace getVariable ["ON_metricCasTime", 0];
        private _distance = round (missionNamespace getVariable ["ON_metricVehicleDistance", 0]);
        private _maxAltitude = round (missionNamespace getVariable ["ON_metricMaxAltitude", 0]);
        private _maxSpeed = round (missionNamespace getVariable ["ON_metricMaxSpeed", 0]);
        private _contactStatus = missionNamespace getVariable ["ON_contactStatus", "NONE"];
        private _wingmanStatus = missionNamespace getVariable ["ON_wingmanStatus", "WAITING"];
        private _eventCount = count (missionNamespace getVariable ["ON_eventLog", []]);

        ["SUCCESS"] call ON_fnc_endMission;

        hint parseText format [
            "<t size='1.3'>OPERATION NIMITZ — SORTIE DEBRIEF</t><br/><br/>Flight: JOKER 1-1<br/>Result: %1<br/>Last operational phase: %2<br/>Contact state: %3<br/>Wingman: %4<br/><br/><t underline='1'>Measured mission data</t><br/>Mission duration: %5<br/>Airborne time: %6<br/>CAS area time: %7<br/>Sampled vehicle travel: %8 m<br/>Maximum altitude: %9 m<br/>Maximum sampled speed: %10 km/h<br/>Recorded events: %11<br/><br/>Fuel, stores, damage, hook engagement, and aircraft recorder data are not available from this framework.",
            missionNamespace getVariable ["ON_missionResult", _result],
            _terminalPhase,
            _contactStatus,
            _wingmanStatus,
            [_missionSeconds] call ON_fnc_formatDuration,
            [_flightSeconds] call ON_fnc_formatDuration,
            [_casSeconds] call ON_fnc_formatDuration,
            _distance,
            _maxAltitude,
            _maxSpeed,
            _eventCount
        ];
    },
    nil, 1.5, true, true, "",
    "(_this distance _target) < 8 && { (vehicle _this) isEqualTo _this } && { (missionNamespace getVariable ['ON_phase', '']) isEqualTo 'DEBRIEF' }"
];

["NIMITZ", "Debrief station is available. Exit the aircraft and report when ready."] call ON_fnc_message;
["Debrief interaction installed on the carrier."] call ON_fnc_recordEvent;