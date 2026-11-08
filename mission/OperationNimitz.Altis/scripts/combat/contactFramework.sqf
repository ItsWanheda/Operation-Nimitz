/*
    Contact/ROE foundation only.
    No enemy units are spawned and no weapons are authorized in this build.
    Add verified AFR assets and sensor logic in a later implementation phase.
*/
ON_fnc_setContactStatus = {
    params [["_status", "NONE", [""]]];
    private _allowed = ["NONE", "UNKNOWN", "IDENTIFIED", "HOSTILE_CONFIRMED", "RESOLVED"];
    if !(_status in _allowed) exitWith {
        [format ["Rejected invalid contact state: %1", _status]] call ON_fnc_log;
    };
    missionNamespace setVariable ["ON_contactStatus", _status];
    [format ["Contact state changed to %1", _status]] call ON_fnc_log;
};

ON_fnc_canEngage = {
    (missionNamespace getVariable ["ON_contactStatus", "NONE"]) isEqualTo "HOSTILE_CONFIRMED"
};

["Contact state framework initialized. Engagement authorization remains disabled until verified ROE and contact logic are implemented."] call ON_fnc_log;
