/*
    Operation Nimitz — convoy health and reaction monitor.

    Convoys are created by spawnDirector.sqf. This controller monitors the
    recorded vehicles and applies the reaction configured in each convoy row:
      CONTINUE       keep following the route after damage/loss.
      HALT_ON_DAMAGE stop the convoy when any vehicle reaches damageThreshold.
      HALT_ON_LOSS   stop the convoy when any vehicle is destroyed.

    Checkpoint pauses and escort-role assignment are applied by spawnDirector.
    This is scripted convoy control, not advanced tactical AI or ambush logic.
*/

waitUntil {
    !isNil "ON_fnc_message"
    && { !isNil "ON_fnc_log" }
    && { missionNamespace getVariable ["ON_convoyDirectorReady", false] }
};

private _records = missionNamespace getVariable ["ON_convoyRecords", []];
private _statusMap = createHashMap;
missionNamespace setVariable ["ON_convoyStatus", _statusMap];

{
    _x params ["_convoyId", "_vehicles", "_group", "_reactionMode", "_damageThreshold"];

    _statusMap set [_convoyId, "MOVING"];
    [_x] spawn {
        params ["_record"];
        _record params [
            "_id",
            "_convoyVehicles",
            "_convoyGroup",
            "_reaction",
            "_threshold"
        ];

        private _reacted = false;
        while {
            !_reacted
            && { (missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "COMPLETE" }
            && { ({ alive _x } count _convoyVehicles) > 0 }
        } do {
            private _lost = ({ !alive _x } count _convoyVehicles) > 0;
            private _damaged = (_convoyVehicles findIf {
                alive _x && { damage _x >= _threshold }
            }) >= 0;

            private _shouldHalt = (
                (_reaction isEqualTo "HALT_ON_LOSS" && _lost)
                || { _reaction isEqualTo "HALT_ON_DAMAGE" && _damaged }
            );

            if (_shouldHalt) then {
                {
                    if (alive _x) then {
                        { doStop _x; } forEach (crew _x);
                    };
                } forEach _convoyVehicles;

                _convoyGroup setCombatMode "YELLOW";
                _reacted = true;
                private _status = if (_lost) then { "HALTED_AFTER_VEHICLE_LOSS" } else { "HALTED_AFTER_DAMAGE" };
                private _stateMap = missionNamespace getVariable ["ON_convoyStatus", createHashMap];
                _stateMap set [_id, _status];

                ["NIMITZ CONTROL", format ["Convoy %1 has halted under its configured %2 reaction.", _id, _reaction]] call ON_fnc_message;
                [format ["Convoy '%1' halted: reaction %2; vehicle loss %3; damage threshold reached %4.", _id, _reaction, _lost, _damaged]] call ON_fnc_recordEvent;
            } else {
                sleep 3;
            };
        };

        if (!_reacted) then {
            private _stateMap = missionNamespace getVariable ["ON_convoyStatus", createHashMap];
            private _state = if (({ alive _x } count _convoyVehicles) isEqualTo 0) then { "DESTROYED" } else { "MONITORING_COMPLETE" };
            _stateMap set [_id, _state];
        };
    };
} forEach _records;

["Convoy monitor initialized."] call ON_fnc_recordEvent;
