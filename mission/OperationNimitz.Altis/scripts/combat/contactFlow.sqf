/*
    Scripted single-contact training flow.
    ON_contactAircraft must reference an editor-placed asset selected from the
    installed mod. It is not spawned here. Detection is a mission-distance gate,
    not a simulated radar or sensor model.
*/
waitUntil { !isNil "ON_fnc_setContactStatus" && { !isNil "ON_fnc_createTask" } };

private _playerAircraft = missionNamespace getVariable ["ON_playerAircraft", objNull];
private _contact = missionNamespace getVariable ["ON_contactAircraft", objNull];

if (isNull _playerAircraft) exitWith {
    ["Contact flow skipped: ON_playerAircraft is missing."] call ON_fnc_log;
};
if (isNull _contact) exitWith {
    ["Contact flow skipped: no ON_contactAircraft editor reference is configured."] call ON_fnc_log;
};

private _identifyRange = missionNamespace getVariable ["ON_contactIdentificationRange", 2500];
private _detectionRange = missionNamespace getVariable ["ON_contactDetectionRange", 8000];

_playerAircraft addAction [
    "<t color='#B6FF00'>Report visual identification complete</t>",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _contactTarget = missionNamespace getVariable ["ON_contactAircraft", objNull];
        private _range = missionNamespace getVariable ["ON_contactIdentificationRange", 2500];

        if (isNull _contactTarget || { !alive _contactTarget }) exitWith {
            ["JOKER 1-1", "Contact is no longer available for visual identification."] call ON_fnc_message;
        };
        if ((missionNamespace getVariable ["ON_contactStatus", "NONE"]) isNotEqualTo "UNKNOWN") exitWith {};
        if ((vehicle _caller) isNotEqualTo _target) exitWith {};
        if (((vehicle _caller) distance2D _contactTarget) > _range) exitWith {
            ["JOKER 1-1", "Close the range before reporting visual identification."] call ON_fnc_message;
        };

        ["IDENTIFIED"] call ON_fnc_setContactStatus;
        ["ON_task_contact", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["ON_task_contact_roe", "Contact classification and ROE", "Review the contact and apply the briefed rules of engagement. Declare hostile only when the configured contact is verified hostile.", _contactTarget] call ON_fnc_createTask;
        ["AWACS", "JOKER 1-1, contact identification reported. Confirm classification under the briefed ROE."] call ON_fnc_message;
    },
    nil, 1.5, true, true, "",
    "((missionNamespace getVariable ['ON_contactStatus', 'NONE']) isEqualTo 'UNKNOWN') && { (vehicle _this) isEqualTo _target } && { alive (missionNamespace getVariable ['ON_contactAircraft', objNull]) } && { (vehicle _this) distance2D (missionNamespace getVariable ['ON_contactAircraft', objNull]) <= (missionNamespace getVariable ['ON_contactIdentificationRange', 2500]) }"
];

_playerAircraft addAction [
    "<t color='#B6FF00'>Declare contact hostile under ROE</t>",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _contactTarget = missionNamespace getVariable ["ON_contactAircraft", objNull];

        if (isNull _contactTarget || { !alive _contactTarget }) exitWith {};
        if ((missionNamespace getVariable ["ON_contactStatus", "NONE"]) isNotEqualTo "IDENTIFIED") exitWith {};
        if !(_contactTarget getVariable ["ON_isHostile", false]) exitWith {
            ["JOKER 1-1", "Hostile declaration denied: the editor contact is not marked as verified hostile."] call ON_fnc_message;
        };

        ["HOSTILE_CONFIRMED"] call ON_fnc_setContactStatus;
        ["ON_task_contact_roe", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["ON_task_intercept", "Intercept confirmed hostile", "Maintain the intercept and act only within the confirmed rules of engagement. No scripted weapon release is provided.", _contactTarget] call ON_fnc_createTask;
        ["JOKER 1-1", "Hostile status confirmed under the mission ROE. Weapons employment remains under player control."] call ON_fnc_message;
    },
    nil, 1.5, true, true, "",
    "((missionNamespace getVariable ['ON_contactStatus', 'NONE']) isEqualTo 'IDENTIFIED') && { ((missionNamespace getVariable ['ON_contactAircraft', objNull]) getVariable ['ON_isHostile', false]) }"
];

_playerAircraft addAction [
    "<t color='#B6FF00'>Report contact non-hostile / resolved</t>",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _contactTarget = missionNamespace getVariable ["ON_contactAircraft", objNull];

        if (isNull _contactTarget || { !alive _contactTarget }) exitWith {};
        if ((missionNamespace getVariable ["ON_contactStatus", "NONE"]) isNotEqualTo "IDENTIFIED") exitWith {};
        if (_contactTarget getVariable ["ON_isHostile", false]) exitWith {};
        if ((vehicle _caller) distance2D _contactTarget > (missionNamespace getVariable ["ON_contactIdentificationRange", 2500])) exitWith {};

        ["RESOLVED"] call ON_fnc_setContactStatus;
        ["ON_task_contact_roe", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["JOKER 1-1", "Contact reported non-hostile. Continue the assigned CAP."] call ON_fnc_message;
    },
    nil, 1.5, true, true, "",
    "((missionNamespace getVariable ['ON_contactStatus', 'NONE']) isEqualTo 'IDENTIFIED') && { !((missionNamespace getVariable ['ON_contactAircraft', objNull]) getVariable ['ON_isHostile', false]) } && { (vehicle _this) isEqualTo _target } && { (vehicle _this) distance2D (missionNamespace getVariable ['ON_contactAircraft', objNull]) <= (missionNamespace getVariable ['ON_contactIdentificationRange', 2500]) }"
];

_playerAircraft addAction [
    "<t color='#B6FF00'>Report hostile contact resolved / out of area</t>",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _contactTarget = missionNamespace getVariable ["ON_contactAircraft", objNull];

        if ((missionNamespace getVariable ["ON_contactStatus", "NONE"]) isNotEqualTo "HOSTILE_CONFIRMED") exitWith {};
        if (!isNull _contactTarget && { alive _contactTarget } && { (vehicle _caller) distance2D _contactTarget <= (missionNamespace getVariable ["ON_contactDetectionRange", 8000]) }) exitWith {
            ["JOKER 1-1", "Contact remains in the assigned area. Continue monitoring and follow the ROE."] call ON_fnc_message;
        };

        ["RESOLVED"] call ON_fnc_setContactStatus;
        ["ON_task_intercept", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["JOKER 1-1", "Contact is no longer active in the assigned area. Resume the CAP task."] call ON_fnc_message;
    },
    nil, 1.5, true, true, "",
    "((missionNamespace getVariable ['ON_contactStatus', 'NONE']) isEqualTo 'HOSTILE_CONFIRMED') && { (vehicle _this) isEqualTo _target } && { isNull (missionNamespace getVariable ['ON_contactAircraft', objNull]) || { !alive (missionNamespace getVariable ['ON_contactAircraft', objNull]) } || { (vehicle _this) distance2D (missionNamespace getVariable ['ON_contactAircraft', objNull]) > (missionNamespace getVariable ['ON_contactDetectionRange', 8000]) } }"
];

private _detected = false;
while {
    (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "IN_FLIGHT"
    && { (missionNamespace getVariable ["ON_contactStatus", "NONE"]) isEqualTo "NONE" }
} do {
    private _currentAircraft = vehicle player;
    if (
        _currentAircraft isNotEqualTo player
        && { alive _currentAircraft }
        && { !(isTouchingGround _currentAircraft) }
        && { alive _contact }
        && { (_currentAircraft distance2D _contact) <= _detectionRange }
    ) exitWith {
        _detected = true;
    };
    sleep 5;
};

if (_detected && { (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "IN_FLIGHT" }) then {
    ["UNKNOWN"] call ON_fnc_setContactStatus;
    ["ON_task_contact", "Investigate contact", "Investigate the scripted contact. Close to visual-identification range and report the classification.", _contact] call ON_fnc_createTask;
    ["AWACS", "JOKER 1-1, scripted contact detected in the patrol area. Investigate and report identification."] call ON_fnc_message;
};

while {
    (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "IN_FLIGHT"
    && { (missionNamespace getVariable ["ON_contactStatus", "NONE"]) in ["UNKNOWN", "IDENTIFIED", "HOSTILE_CONFIRMED"] }
} do {
    if (
        isNull _contact
        || { !alive _contact }
    ) exitWith {
        private _status = missionNamespace getVariable ["ON_contactStatus", "NONE"];
        if (_status isEqualTo "HOSTILE_CONFIRMED") then {
            ["RESOLVED"] call ON_fnc_setContactStatus;
            ["ON_task_intercept", "SUCCEEDED"] call ON_fnc_setTaskState;
        } else {
            ["RESOLVED"] call ON_fnc_setContactStatus;
            ["ON_task_contact", "SUCCEEDED"] call ON_fnc_setTaskState;
            ["JOKER 1-1", "Contact lost before hostile confirmation. No engagement authority was granted."] call ON_fnc_message;
        };
    };
    sleep 5;
};

["Contact flow monitor stopped."] call ON_fnc_log;