/*
    Minimal AI wingman join-up controller.
    ON_wingman must reference the AI pilot unit, not its aircraft vehicle.
    Flight model, formation quality, and carrier deck behavior require in-game tests.
*/
waitUntil { !isNil "ON_fnc_message" };

private _wingman = missionNamespace getVariable ["ON_wingman", objNull];
if (isNull _wingman) exitWith {
    ["AI wingman reference ON_wingman is missing; join-up controller skipped."] call ON_fnc_log;
};

if (!alive _wingman) exitWith {
    ["AI wingman is not alive; join-up controller skipped."] call ON_fnc_log;
};

private _wingmanGroup = group _wingman;
_wingmanGroup setBehaviour "AWARE";
_wingmanGroup setCombatMode "YELLOW";
_wingmanGroup setSpeedMode "NORMAL";
_wingmanGroup setFormation "WEDGE";
_wingman doFollow player;

["JOKER 1-2", "Rejoining JOKER 1-1."] call ON_fnc_message;
["Wingman join-up order issued. Verify formation and spacing in-game."] call ON_fnc_log;
