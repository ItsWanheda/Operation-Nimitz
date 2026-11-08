/*
    Scripted mission radio support endpoints.
    Optional editor references: ON_awacs, ON_tanker, ON_deckCrew.
    ON_atc defaults to ON_carrier. These are status/comms helpers only: they do
    not spawn aircraft, create radar sensors, refuel, animate deck crew, or
    replace the installed carrier/aircraft mod procedures.
*/
waitUntil { !isNil "ON_fnc_message" && { !isNil "ON_fnc_recordEvent" } };

ON_fnc_supportRequest = {
    params [["_role", "", [""]]];

    private _variableName = switch (_role) do {
        case "AWACS": { "ON_awacs" };
        case "TANKER": { "ON_tanker" };
        case "ATC": { "ON_atc" };
        case "DECK": { "ON_deckCrew" };
        default { "" };
    };

    if (_variableName isEqualTo "") exitWith {
        ["Rejected unknown support role request."] call ON_fnc_log;
    };

    private _callsign = switch (_role) do {
        case "AWACS": { "AWACS" };
        case "TANKER": { "TANKER" };
        case "ATC": { "NIMITZ CONTROL" };
        case "DECK": { "DECK" };
        default { "SUPPORT" };
    };

    private _supportObject = missionNamespace getVariable [_variableName, objNull];
    if (isNull _supportObject) exitWith {
        [_callsign, "No verified support object is assigned. This scripted service is unavailable."] call ON_fnc_message;
    };
    if (!alive _supportObject) exitWith {
        [_callsign, "Support reference is not operational."] call ON_fnc_message;
    };

    switch (_role) do {
        case "AWACS": {
            private _contact = missionNamespace getVariable ["ON_contactAircraft", objNull];
            private _status = missionNamespace getVariable ["ON_contactStatus", "NONE"];
            if (isNull _contact) then {
                [_callsign, "No scripted contact object is configured; this is not a live radar picture."] call ON_fnc_message;
            } else {
                private _range = round ((vehicle player) distance2D _contact);
                [_callsign, format ["Mission contact record: %1. Approximate mission distance: %2 metres. This is scripted status, not sensor data.", _status, _range]] call ON_fnc_message;
            };
        };
        case "TANKER": {
            [_callsign, "Tanker reference confirmed. Rendezvous and refuelling must use verified aircraft/mod procedures; no refuelling logic is scripted."] call ON_fnc_message;
        };
        case "ATC": {
            [_callsign, "Carrier-control reference acknowledged. Actual taxi, launch, marshal, and recovery procedures remain dependent on the installed carrier/aircraft mods."] call ON_fnc_message;
        };
        case "DECK": {
            [_callsign, "Deck-crew reference confirmed. No deck-crew choreography or animated handling is scripted in this build."] call ON_fnc_message;
        };
    };

    [format ["Support status requested: %1", _role]] call ON_fnc_recordEvent;
};

private _aircraft = missionNamespace getVariable ["ON_playerAircraft", objNull];
private _carrier = missionNamespace getVariable ["ON_carrier", objNull];

if (!isNull _aircraft) then {
    _aircraft addAction [
        "<t color='#B6FF00'>Request AWACS contact picture</t>",
        { ["AWACS"] call ON_fnc_supportRequest; },
        nil, 1.5, true, true, "",
        "(missionNamespace getVariable ['ON_phase', '']) isEqualTo 'IN_FLIGHT'"
    ];

    _aircraft addAction [
        "<t color='#B6FF00'>Request tanker status</t>",
        { ["TANKER"] call ON_fnc_supportRequest; },
        nil, 1.5, true, true, "",
        "(missionNamespace getVariable ['ON_phase', '']) isEqualTo 'IN_FLIGHT'"
    ];
} else {
    ["Support aircraft actions not installed: ON_playerAircraft is missing."] call ON_fnc_log;
};

if (!isNull _carrier) then {
    _carrier addAction [
        "<t color='#B6FF00'>Request Nimitz control</t>",
        { ["ATC"] call ON_fnc_supportRequest; },
        nil, 1.5, true, true, "",
        "(_this distance _target) < 10"
    ];

    _carrier addAction [
        "<t color='#B6FF00'>Request deck crew status</t>",
        { ["DECK"] call ON_fnc_supportRequest; },
        nil, 1.5, true, true, "",
        "(_this distance _target) < 10"
    ];
} else {
    ["Carrier support actions not installed: ON_carrier is missing."] call ON_fnc_log;
};

["Scripted radio support actions installed."] call ON_fnc_recordEvent;