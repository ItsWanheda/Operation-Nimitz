/*
    AI wingman join-up controller.
    ON_wingman must reference an AI pilot unit already seated in its assigned
    aircraft. The controller does not spawn an aircraft or teleport/board AI.
*/
waitUntil { !isNil "ON_fnc_message" };

private _wingman = missionNamespace getVariable ["ON_wingman", objNull];
if (isNull _wingman) exitWith {
    missionNamespace setVariable ["ON_wingmanStatus", "NOT_CONFIGURED"];
    ["AI wingman reference ON_wingman is missing; join-up controller skipped."] call ON_fnc_log;
};

if (!alive _wingman) exitWith {
    missionNamespace setVariable ["ON_wingmanStatus", "LOST"];
    ["AI wingman is not alive; join-up controller skipped."] call ON_fnc_log;
};

private _wingmanAircraft = vehicle _wingman;
if (_wingmanAircraft isEqualTo _wingman) exitWith {
    missionNamespace setVariable ["ON_wingmanStatus", "NOT_MOUNTED"];
    ["ON_wingman is not seated in an aircraft. No automatic boarding or aircraft spawning is attempted."] call ON_fnc_log;
    ["JOKER 1-1", "Wingman aircraft reference is not ready. Continue the sortie without an AI join-up."] call ON_fnc_message;
};

private _wingmanGroup = group _wingman;
_wingmanGroup setBehaviour "AWARE";
_wingmanGroup setCombatMode "GREEN";
_wingmanGroup setSpeedMode "NORMAL";
_wingmanGroup setFormation "WEDGE";
_wingman doFollow player;
missionNamespace setVariable ["ON_wingmanStatus", "JOINING"];

["JOKER 1-2", "Rejoining JOKER 1-1. Weapons hold."] call ON_fnc_message;
["Wingman join-up order issued; AI group remains on hold-fire combat mode."] call ON_fnc_recordEvent;

private _joinedAnnounced = false;
private _lastFollowOrder = time;

while {
    (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "IN_FLIGHT"
    && { alive _wingman }
    && { alive player }
} do {
    private _playerAircraft = vehicle player;
    private _currentWingmanAircraft = vehicle _wingman;

    if (_playerAircraft isNotEqualTo player && { _currentWingmanAircraft isNotEqualTo _wingman }) then {
        private _separation = _playerAircraft distance _currentWingmanAircraft;

        if (_separation <= 500 && { !_joinedAnnounced }) then {
            _joinedAnnounced = true;
            missionNamespace setVariable ["ON_wingmanStatus", "JOINED"];
            ["JOKER 1-2", "Visual join-up complete. Holding formation."] call ON_fnc_message;
            [format ["Wingman joined at sampled separation %1 metres.", round _separation]] call ON_fnc_recordEvent;
        };

        if (_separation > 2500 && { (time - _lastFollowOrder) >= 30 }) then {
            _wingman doFollow player;
            _lastFollowOrder = time;
            missionNamespace setVariable ["ON_wingmanStatus", "JOINING"];
            ["JOKER 1-2", "Rejoining."] call ON_fnc_message;
        };
    };

    sleep 10;
};

if (!alive _wingman) then {
    missionNamespace setVariable ["ON_wingmanStatus", "LOST"];
    ["JOKER 1-1", "JOKER 1-2 is no longer available."] call ON_fnc_message;
};

["Wingman controller stopped."] call ON_fnc_log;