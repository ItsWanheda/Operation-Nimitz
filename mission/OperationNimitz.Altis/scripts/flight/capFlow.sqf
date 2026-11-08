/*
    CAP station monitor.
    Requires an Eden marker named ON_mrk_CAP. It does not create enemy contacts:
    the hostile aircraft/unit classnames and behavior have not been verified.
*/
waitUntil { !isNil "ON_fnc_setPhase" };

private _marker = missionNamespace getVariable ["ON_capMarker", "ON_mrk_CAP"];
if ((markerType _marker) isEqualTo "") exitWith {
    ["CAP marker ON_mrk_CAP is missing. CAP monitor stopped; create the marker in Eden."] call ON_fnc_log;
    ["NIMITZ", "CAP station reference unavailable. Mission setup requires correction."] call ON_fnc_message;
};

private _radius = missionNamespace getVariable ["ON_capRadius", 1200];
private _requiredTime = missionNamespace getVariable ["ON_capDuration", 120];
private _stationTime = 0;
private _announced = false;

while { (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "IN_FLIGHT" } do {
    private _aircraft = vehicle player;
    private _insideStation = (player != _aircraft)
        && { (getPosATL _aircraft select 2) > 50 }
        && { (_aircraft distance2D (getMarkerPos _marker)) <= _radius };

    if (_insideStation) then {
        _stationTime = _stationTime + 5;
        if (!_announced) then {
            _announced = true;
            ["AWACS", "JOKER 1-1, CAP station reached. Maintain the assigned patrol area."] call ON_fnc_message;
        };
    } else {
        _stationTime = 0;
        _announced = false;
    };

    if (_stationTime >= _requiredTime) exitWith {
        ["ON_task_cap", "SUCCEEDED"] call ON_fnc_setTaskState;
        ["RTB"] call ON_fnc_setPhase;
        ["ON_task_rtb", "Return to the carrier and complete a safe recovery."] call ON_fnc_createTask;
        ["NIMITZ", "CAP period complete. JOKER 1-1, proceed RTB and report aboard after recovery."] call ON_fnc_message;
        [] execVM "scripts\\carrier\\recoveryFlow.sqf";
    };
    sleep 5;
};

["CAP station monitor stopped."] call ON_fnc_log;
