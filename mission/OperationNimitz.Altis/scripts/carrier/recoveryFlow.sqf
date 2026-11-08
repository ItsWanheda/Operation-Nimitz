/*
    Recovery monitor.
    This is a basic assigned-aircraft / grounded-state / speed / proximity
    gate, not an arresting-wire simulation.
*/
waitUntil { !isNil "ON_fnc_setPhase" };

private _carrier = missionNamespace getVariable ["ON_carrier", objNull];
private _assignedAircraft = missionNamespace getVariable ["ON_playerAircraft", objNull];

if (isNull _carrier) exitWith {
    ["Required editor object ON_carrier is missing. Recovery monitor stopped."] call ON_fnc_log;
    ["NIMITZ", "Carrier reference unavailable. Recovery cannot be evaluated."] call ON_fnc_message;
};
if (isNull _assignedAircraft) exitWith {
    ["Required editor object ON_playerAircraft is missing. Recovery monitor stopped."] call ON_fnc_log;
};

private _recovered = false;
while {
    (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "RTB"
    && { alive player }
} do {
    if (!alive _assignedAircraft) exitWith {
        ["FAILED"] call ON_fnc_endMission;
        ["NIMITZ", "Assigned aircraft is lost. Sortie terminated."] call ON_fnc_message;
    };

    private _currentAircraft = vehicle player;
    if (
        _currentAircraft isEqualTo _assignedAircraft
        && { isTouchingGround _assignedAircraft }
        && { abs (speed _assignedAircraft) < 25 }
        && { (_assignedAircraft distance2D _carrier) < 250 }
    ) exitWith {
        _recovered = true;
    };

    sleep 3;
};

if (_recovered && { (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "RTB" }) then {
    missionNamespace setVariable ["ON_metricRecoveryTime", time];
    ["ON_task_rtb", "SUCCEEDED"] call ON_fnc_setTaskState;
    ["DEBRIEF"] call ON_fnc_setPhase;
    ["NIMITZ", "JOKER 1-1, recovery area reached. Shut down and proceed on foot to the debrief station."] call ON_fnc_message;
    [] execVM "scripts\debrief\initDebrief.sqf";
};

["Recovery monitor stopped."] call ON_fnc_log;