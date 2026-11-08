/*
    Briefing and initial task setup.
*/
waitUntil { !isNil "ON_fnc_createTask" };

player createDiaryRecord ["Diary", [
    "Communications",
    "<font face='PuristaMedium'>JOKER 1-1</font><br/>Flight: JOKER 1-1 / JOKER 1-2<br/>Carrier control: NIMITZ<br/>AWACS: callsign and capability pending verification.<br/><br/>This initial build uses on-screen radio-style messages. A dedicated radio mod is not assumed."
]];

player createDiaryRecord ["Diary", [
    "Rules of Engagement",
    "Identify all contacts before escalation. No scripted weapons release or automatic hostile engagement is implemented in this foundation build. Follow the mission briefing and do not engage unidentified traffic."
]];

player createDiaryRecord ["Diary", [
    "Situation",
    "VFA-103 Jolly Rogers is operating from a carrier in the Altis theatre. JOKER 1-1 is assigned a single-player Combat Air Patrol with AI support elements planned. Exact threat intelligence and supporting-unit capabilities remain subject to mission implementation and in-game verification."
]];

player createDiaryRecord ["Diary", [
    "Mission",
    "Conduct the ready-room brief, inspect and prepare the assigned F/A-18E, complete the verified startup and launch procedure, join the flight, establish the CAP station, respond to authorized tasking, and recover to the carrier."
]];

["ON_task_briefing", "Review mission briefing", "Review the situation, route, communications plan, and rules of engagement. Then proceed to your assigned aircraft.", objNull] call ON_fnc_createTask;
["NIMITZ", "JOKER 1-1, review the brief and proceed to your aircraft when ready."] call ON_fnc_message;
