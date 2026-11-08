/*
    Lightweight single-player sortie telemetry.
    This records mission time, airborne time, sampled vehicle travel distance,
    maximum altitude/speed, CAP time, and mission events. It does not claim to
    measure fuel, stores, damage, carrier-wire engagement, or flight-data-recorder
    values from the aircraft mod.
*/
waitUntil { !isNil "ON_fnc_endMission" };

private _lastVehicle = objNull;
private _lastPosition = [];

while {
    (missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "COMPLETE"
    && { alive player }
} do {
    private _currentVehicle = vehicle player;

    if (_currentVehicle isNotEqualTo player && { alive _currentVehicle }) then {
        private _position = getPosATL _currentVehicle;

        if (!isNull _lastVehicle && { _lastVehicle isEqualTo _currentVehicle } && { (count _lastPosition) isEqualTo 3 }) then {
            private _distance = _lastPosition distance2D _position;
            private _totalDistance = missionNamespace getVariable ["ON_metricVehicleDistance", 0];
            missionNamespace setVariable ["ON_metricVehicleDistance", _totalDistance + _distance];
        };

        private _altitude = _position select 2;
        private _maxAltitude = missionNamespace getVariable ["ON_metricMaxAltitude", 0];
        if (_altitude > _maxAltitude) then {
            missionNamespace setVariable ["ON_metricMaxAltitude", _altitude];
        };

        private _currentSpeed = abs (speed _currentVehicle);
        private _maxSpeed = missionNamespace getVariable ["ON_metricMaxSpeed", 0];
        if (_currentSpeed > _maxSpeed) then {
            missionNamespace setVariable ["ON_metricMaxSpeed", _currentSpeed];
        };

        if !(isTouchingGround _currentVehicle) then {
            private _flightSeconds = missionNamespace getVariable ["ON_metricFlightSeconds", 0];
            missionNamespace setVariable ["ON_metricFlightSeconds", _flightSeconds + 5];
        };

        _lastVehicle = _currentVehicle;
        _lastPosition = _position;
    } else {
        _lastVehicle = objNull;
        _lastPosition = [];
    };

    private _missionSeconds = floor (time - (missionNamespace getVariable ["ON_missionStartTime", time]));
    missionNamespace setVariable ["ON_metricMissionSeconds", _missionSeconds max 0];
    sleep 5;
};

if (!alive player && { (missionNamespace getVariable ["ON_phase", ""]) isNotEqualTo "COMPLETE" }) then {
    ["ABORTED"] call ON_fnc_endMission;
};