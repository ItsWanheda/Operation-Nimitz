/*
    CAP station monitor.
    Requires an Eden marker named ON_mrk_CAP. Time on station is accumulated
    while airborne and within the configured radius. Once the timer is met it
    remains satisfied; if a scripted contact is unresolved, RTB is held while
    the player completes contact handling.
*/
waitUntil { !isNil "ON_fnc_setPhase" };

private _marker = missionNamespace getVariable ["ON_capMarker", "ON_mrk_CAP"];
if !(_marker in allMapMarkers) exitWith {
    ["CAP marker is missing. CAP monitor stopped; create the marker in Eden."] call ON_fnc_log;
    ["NIMITZ", "CAP station reference unavailable. Mission setup requires correction."] call ON_fnc_message;
};

private _radius = missionNamespace getVariable ["ON_capRadius", 1200];
private _requiredTime = missionNamespace getVariable ["ON_capDuration", 120];
private _stationTime = 0;
private _announced = false;
private _capTimerSatisfied = false;
private _capComplete = false;
private _contactHoldAnnounced = false;

while {
    (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "IN_FLIGHT"
    && { !_capComplete }
} do {
    if (!_capTimerSatisfied) then {
        private _aircraft = vehicle player;
        private _insideStation = (
            player isNotEqualTo _aircraft
            && { alive _aircraft }
            && { !(isTouchingGround _aircraft) }
            && { (getPosATL _aircraft select 2) > 50 }
            && { (_aircraft distance2D (getMarkerPos _marker)) <= _radius }
        );

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

        missionNamespace setVariable ["ON_metricCapTime", _stationTime];

        if (_stationTime >= _requiredTime) then {
            _capTimerSatisfied = true;
            ["CAP on-station timer satisfied."] call ON_fnc_recordEvent;
        };
    };

    if (_capTimerSatisfied) then {
        private _contactStatus = missionNamespace getVariable ["ON_contactStatus", "NONE"];
        private _contactPending = _contactStatus in ["UNKNOWN", "IDENTIFIED", "HOSTILE_CONFIRMED"];

        if (!_contactPending) then {
            _capComplete = true;
        } else {
            if (!_contactHoldAnnounced) then {
                _contactHoldAnnounced = true;
                ["AWACS", "CAP timer satisfied. An active contact remains unresolved; complete contact handling before RTB."] call ON_fnc_message;
            };
        };
    };

    sleep 5;
};

if (_capComplete && { (missionNamespace getVariable ["ON_phase", ""]) isEqualTo "IN_FLIGHT" }) then {
    ["ON_task_cap", "SUCCEEDED"] call ON_fnc_setTaskState;
    ["RTB"] call ON_fnc_setPhase;
    ["ON_task_rtb", "Return to the carrier, recover in the assigned aircraft, shut down, and proceed to the debrief station."] call ON_fnc_createTask;
    ["NIMITZ", "CAP and contact tasking complete. JOKER 1-1, proceed RTB."] call ON_fnc_message;
    [] execVM "scripts\carrier\recoveryFlow.sqf";
};

["CAP station monitor stopped."] call ON_fnc_log;