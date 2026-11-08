# Operation Nimitz

A single-player, full-MILSIM ARMA 3 naval aviation mission project.

## Project concept

The player flies as **JOKER 1-1**, a VFA-103 Jolly Rogers F/A-18E Super Hornet pilot operating from a carrier in the Altis theatre. AI-controlled elements provide wingman and supporting-aircraft roles.

The intended first sortie is a Combat Air Patrol (CAP): ready-room briefing, flight-deck preparation, startup and launch, patrol station, airborne tasking and contact handling, carrier recovery, and post-flight debrief.

## Project status

This repository is being initialized. Mission requirements, verified mod dependencies, asset/classname records, implementation phases, and acceptance criteria will be maintained in the project documentation.

> **Verification rule:** Do not assume Workshop assets, classnames, mod features, carrier procedures, or compatibility. Record them as pending confirmation until tested in the installed ARMA 3 environment.

## Confirmed Workshop references

| Dependency | Workshop ID | Status |
|---|---:|---|
| F/A-18E Super Hornet 2020 | [2131302796](https://steamcommunity.com/sharedfiles/filedetails/?id=2131302796) | Identified; exact classnames and capabilities pending in-game verification |
| USMC 2026 | [3752331810](https://steamcommunity.com/sharedfiles/filedetails/?id=3752331810) | Identified; required assets and classnames pending in-game verification |
| USS Nimitz carrier | Not yet identified | Pending selection and compatibility verification |

## Development approach

Mission work will be developed incrementally in Eden Editor with modular SQF, explicit task/trigger flow, and repeatable single-player testing. Changes should be developed on feature branches and reviewed before integration.

See the mission-building checklist in the documentation once the planning branch is published.
