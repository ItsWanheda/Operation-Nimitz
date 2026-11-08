/*
    Contact identification and rules-of-engagement state model.
    Engagement authority is not inferred from proximity alone. A contact must
    be identified by the player and explicitly marked hostile in Eden first.
*/
ON_fnc_setContactStatus = {
    params [["_status", "NONE", [""]]];

    private _current = missionNamespace getVariable ["ON_contactStatus", "NONE"];
    private _validStates = ["NONE", "UNKNOWN", "IDENTIFIED", "HOSTILE_CONFIRMED", "RESOLVED"];
    private _allowedTransitions = [
        ["NONE", "UNKNOWN"],
        ["UNKNOWN", "IDENTIFIED"],
        ["UNKNOWN", "RESOLVED"],
        ["IDENTIFIED", "HOSTILE_CONFIRMED"],
        ["IDENTIFIED", "RESOLVED"],
        ["HOSTILE_CONFIRMED", "RESOLVED"]
    ];

    if !(_status in _validStates) exitWith {
        [format ["Rejected invalid contact state: %1", _status]] call ON_fnc_log;
    };
    if (_status isEqualTo _current) exitWith {};
    if !([_current, _status] in _allowedTransitions) exitWith {
        [format ["Rejected invalid contact transition: %1 -> %2", _current, _status]] call ON_fnc_log;
    };

    missionNamespace setVariable ["ON_contactStatus", _status];
    [format ["Contact state changed: %1 -> %2", _current, _status]] call ON_fnc_recordEvent;
};

ON_fnc_canEngage = {
    private _contact = missionNamespace getVariable ["ON_contactAircraft", objNull];
    (missionNamespace getVariable ["ON_contactStatus", "NONE"]) isEqualTo "HOSTILE_CONFIRMED"
        && { !isNull _contact }
        && { alive _contact }
        && { _contact getVariable ["ON_isHostile", false] }
};

["Contact state model initialized. No weapon release or automatic hostile engagement is scripted."] call ON_fnc_recordEvent;