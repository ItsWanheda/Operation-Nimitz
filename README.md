# Operation Nimitz

A single-player, full-MILSIM ARMA 3 naval aviation mission project.

## Project concept

The player flies as **JOKER 1-1**, a VFA-103 Jolly Rogers F/A-18E Super Hornet pilot operating from a carrier in the Altis theatre. AI-controlled elements provide wingman and supporting-aircraft roles.

The intended first sortie is a Combat Air Patrol (CAP): ready-room briefing, flight-deck preparation, startup and launch, patrol station, airborne tasking and contact handling, carrier recovery, and post-flight debrief.

## Project status

The repository is initialized. Mission requirements, dependency references, asset/classname verification, implementation phases, and acceptance criteria are tracked in the [mission-building checklist](docs/mission-building-checklist.md).

> **Verification rule:** Do not assume Workshop assets, classnames, mod features, carrier procedures, or compatibility. Record them as pending confirmation until tested in the installed ARMA 3 environment.

## Workshop references supplied for the project

| Dependency | Workshop ID | Status |
|---|---:|---|
| F/A-18E Super Hornet 2020 | [2131302796](https://steamcommunity.com/sharedfiles/filedetails/?id=2131302796) | Identified; exact classnames and capabilities pending in-game verification |
| USMC 2026 | [3752331810](https://steamcommunity.com/sharedfiles/filedetails/?id=3752331810) | Identified; required assets and classnames pending in-game verification |
| USS Nimitz carrier | [643530417](https://steamcommunity.com/sharedfiles/filedetails/?id=643530417) | Identified; Steam listing currently shows removed/incompatible notices; installability and compatibility pending verification |

## Mission framework status

The first SQF foundation is under development on [`feat/mission-system-foundation`](https://github.com/ItsWanheda/Operation-Nimitz/tree/feat/mission-system-foundation). It includes the initial briefing, mission phase/task helpers, player-confirmed flight-deck gates, CAP station timer, recovery check, contact-state scaffold, and debrief. It is **not yet a playable/exported mission**: an Eden-generated `mission.sqm`, verified editor assets/classnames, and in-game testing are still required. See [Mission Framework Foundation](docs/mission-framework.md).

## Development approach

Mission work will be developed incrementally in Eden Editor with modular SQF, explicit task/trigger flow, and repeatable single-player testing. Changes should be developed on feature branches and reviewed before integration.

Start with the [mission-building checklist](docs/mission-building-checklist.md) for prerequisites, dependency verification, implementation order, testing, and release acceptance criteria.
