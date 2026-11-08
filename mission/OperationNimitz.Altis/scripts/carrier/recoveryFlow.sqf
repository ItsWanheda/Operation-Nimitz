/*
    Recovery monitor.
    This is a basic proximity/grounded-state gate, not an arresting-wire
    simulation. Actual hook/cable behavior must be verified with the selected mods.
*/
waitUntil { !isNil "ON_fnc_setPhase" };

private _carrier = missionNamespace getVariable ["ON_carrier", objNull];
if (isNull _carrier) exitWith {
    ["Required editor object ON_carrier is missing. Recovery monitor stopped."] call ON_fnc_log;
    ["NIMITZ", "Carrier reference unavailable. Recovery cannot be evaluated."] call ON_fnc_message;
};

private _recovered = false;
while { (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "RTB" } do {
    private _aircraft = vehicle player;
    if ((player != _aircraft)
        && { isTouchingGround _aircraft }
        && { speed _aircraft < 25 }
        && { (_aircraft distance2D _carrier) < 250 }) exitWith {
        _recovered = true;
    };
    sleep 3;
};

if (_recovered) then {
    ["ON_task_rtb", "SUCCEEDED"] call ON_fnc_setTaskState;
    ["DEBRIEF"] call ON_fnc_setPhase;
    ["NIMITZ", "JOKER 1-1, recovery area reached. Complete shutdown and report for debrief."] call ON_fnc_message;
    [] execVM "scripts\\debrief\\initDebrief.sqf";
};

["Recovery monitor stopped."] call ON_fnc_log;
