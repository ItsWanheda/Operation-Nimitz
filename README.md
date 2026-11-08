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
| F/A-18E/F Super Hornet 2020 (project target: single-seat F/A-18E) | [2131302796](https://steamcommunity.com/sharedfiles/filedetails/?id=2131302796) | Owner-supplied reference; Steam currently displays removed/incompatible notices; installability, E-variant classname and capabilities pending in-game verification |
| USMC 2026 | [3752331810](https://steamcommunity.com/sharedfiles/filedetails/?id=3752331810) | Owner-supplied reference; installed content, dependencies, classnames and compatibility pending in-game verification |
| USS Nimitz carrier | [643530417](https://steamcommunity.com/sharedfiles/filedetails/?id=643530417) | Owner-supplied candidate; Steam currently displays removed/incompatible notices; installation, CBA_A3 dependency and compatibility pending verification |

> **Workshop status checked 2026-11-08:** Steam's pages for the F/A-18E/F Super Hornet 2020 and USS Nimitz currently display removed-from-community and incompatible-with-Arma-3 notices. These are page-level warnings, not proof that an already-subscribed local copy cannot load; test the exact installed mod preset in ARMA 3 before treating either item as usable. The USMC 2026 item remains an owner-supplied reference; its installed contents and compatibility are unverified.

## Development approach

Mission work will be developed incrementally in Eden Editor with modular SQF, explicit task/trigger flow, and repeatable single-player testing. Changes should be developed on feature branches and reviewed before integration.

Start with the [mission-building checklist](docs/mission-building-checklist.md) for prerequisites, dependency verification, implementation order, testing, and release acceptance criteria.
