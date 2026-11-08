/*
    Basic CAS objective monitor.
    Requires ON_mrk_CAS and ON_mrk_CAS_TARGET markers. Enemy groups/vehicles
    are deployed by spawnDirector from separately configured spawn markers.
    This is a mission objective monitor, not a simulated JTAC laser/designator.
*/
waitUntil { !isNil "ON_fnc_setPhase" };

private _areaMarker = missionNamespace getVariable ["ON_casAreaMarker", "ON_mrk_CAS"];
private _targetMarker = missionNamespace getVariable ["ON_casTargetMarker", "ON_mrk_CAS_TARGET"];

if !(_areaMarker in allMapMarkers && { _targetMarker in allMapMarkers }) exitWith {
    ["CAS area or target marker missing. CAS flow stopped; add ON_mrk_CAS and ON_mrk_CAS_TARGET."] call ON_fnc_log;
    ["NIMITZ", "CAS tasking unavailable: mission markers are incomplete."] call ON_fnc_message;
};

private _areaPosition = getMarkerPos _areaMarker;
private _targetPosition = getMarkerPos _targetMarker;
private _areaRadius = missionNamespace getVariable ["ON_casAreaRadius", 2500];
private _targetRadius = missionNamespace getVariable ["ON_casTargetRadius", 500];
private _timeOnStation = missionNamespace getVariable ["ON_casTimeRequired", 60];
private _elapsed = 0;
private _announced = false;

["ON_task_cas", "Proceed to the assigned CAS area, establish the target area, and engage only positively identified hostile elements under the mission ROE. Report the area clear after verifying the target area.", _targetPosition] call ON_fnc_createTask;

while { (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "IN_FLIGHT" } do {
    private _aircraft = vehicle player;
    private _inside = (
        _aircraft isNotEqualTo player
        && { alive _aircraft }
        && { !(isTouchingGround _aircraft) }
        && { (_aircraft distance2D _areaPosition) <= _areaRadius }
    );

    if (_inside) then {
        _elapsed = _elapsed + 5;
        if (!_announced) then {
            _announced = true;
            ["JTAC", "JOKER 1-1, you are in the assigned CAS area. Confirm target identification and follow ROE."] call ON_fnc_message;
        };
    } else {
        _elapsed = 0;
        _announced = false;
    };

    missionNamespace setVariable ["ON_metricCasTime", _elapsed];

    if (_elapsed >= _timeOnStation) exitWith {};
    sleep 5;
};

if ((missionNamespace getVariable ["ON_phase", ""]) isEqualTo "IN_FLIGHT" && { _elapsed >= _timeOnStation }) then {
    missionNamespace setVariable ["ON_casAreaEstablished", true];
    ["CAS area established; player must verify target effects and report area clear."] call ON_fnc_recordEvent;
    ["JTAC", "CAS time-on-station requirement met. Assess the target area; do not report clear until hostile objectives are confirmed neutralized."] call ON_fnc_message;

    private _reportAction = player addAction [
        "<t color='#B6FF00'>Report CAS target area clear</t>",
        {
            params ["_target", "_caller", "_actionId"];
            private _targetPos = getMarkerPos (missionNamespace getVariable ["ON_casTargetMarker", "ON_mrk_CAS_TARGET"]);
            private _radius = missionNamespace getVariable ["ON_casTargetRadius", 500];
            private _enemySide = missionNamespace getVariable ["ON_enemySide", east];
            private _remaining = allUnits select {
                alive _x
                && { side group _x isEqualTo _enemySide }
                && { (_x distance2D _targetPos) <= _radius }
            };
            if (_remaining isNotEqualTo []) exitWith {
                ["JTAC", format ["%1 hostile ground unit(s) remain in the target area. Continue assessment.", count _remaining]] call ON_fnc_message;
            };
            ["ON_task_cas", "SUCCEEDED"] call ON_fnc_setTaskState;
            missionNamespace setVariable ["ON_casAreaClear", true];
            ["JTAC", "Target area reported clear. JOKER 1-1, proceed to carrier recovery."] call ON_fnc_message;
            ["CAS target area reported clear by player; no hostile EAST units remain in the target radius."] call ON_fnc_recordEvent;
            ["RTB"] call ON_fnc_setPhase;
            ["ON_task_rtb", "Return to the carrier, recover in the assigned aircraft, shut down, and proceed to debrief.", missionNamespace getVariable ["ON_carrier", objNull]] call ON_fnc_createTask;
            [] execVM "scripts\carrier\recoveryFlow.sqf";
            _target removeAction _actionId;
        },
        nil, 1.5, true, true, "",
        "missionNamespace getVariable ['ON_casAreaEstablished', false] && { (missionNamespace getVariable ['ON_phase', '']) isEqualTo 'IN_FLIGHT' }"
    ];
};

["CAS flow monitor stopped."] call ON_fnc_log;