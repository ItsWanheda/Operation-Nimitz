# Operation Nimitz

A single-player, full-MILSIM ARMA 3 naval aviation mission project.

## Project concept

The player flies as **JOKER 1-1**, a VFA-103 Jolly Rogers F/A-18F Super Hornet pilot operating from a carrier in the Altis theatre. AI-controlled elements provide wingman and supporting-aircraft roles.

The intended first sortie is a Close Air Support (CAS): ready-room briefing, flight-deck preparation, startup and launch, patrol station, scripted contact handling, carrier recovery, and post-flight debrief.

## Project status

The repository contains the initial SQF mission framework, currently at **0.4.0-dev** on the feature branch. Implemented mission logic includes phase-gated flight progression, AI wingman follow/hold-fire behavior, CAS area timing and marker-driven enemy deployment, player-confirmed contact identification and ROE, optional scripted support status calls, sampled sortie telemetry, setup validation, and a debrief summary.

**This is not yet a playable/exported mission.** An Eden-generated mission.sqm, verified editor assets/classnames, and in-game RPT testing are still required.

> **Verification rule:** Do not assume Workshop assets, classnames, mod features, carrier procedures, or compatibility. Record them as pending confirmation until tested in the installed ARMA 3 environment.

## Workshop references supplied for the project

| Dependency | Workshop ID | Status |
|---|---:|---|
| F/A-18F Super Hornet 2020 | [2131302796](https://steamcommunity.com/sharedfiles/filedetails/?id=2131302796) | Identified; exact classnames and capabilities pending in-game verification |
| USMC 2026 | [3752331810](https://steamcommunity.com/sharedfiles/filedetails/?id=3752331810) | Identified; required assets and classnames pending in-game verification |
| USS Nimitz carrier | [643530417](https://steamcommunity.com/sharedfiles/filedetails/?id=643530417) | Identified; Steam listing currently shows removed/incompatible notices; installability and compatibility pending verification |

## Mission framework

- [Mission Framework](docs/mission-framework.md) — architecture, configuration, editor references, implemented behavior, and limitations.
- [Manual Asset and Classname Configuration](docs/asset-classname-config.md) — one place to enter every mod classname and configure marker-based deployments.
- [Eden Setup and Test Guide](docs/testing-guide.md) — setup steps, first-preview checks, and regression scenarios.
- [Mission Building Checklist](docs/mission-building-checklist.md) — dependency verification, asset selection, implementation phases, and acceptance criteria.

Mission source lives in mission/OperationNimitz.Altis. Development continues on the existing feat/mission-system-foundation branch; main is not modified.

## Development approach

Mission work is developed incrementally in Eden Editor with modular SQF and repeatable single-player testing. Classnames, mod capabilities, and carrier-specific procedures must be verified from the installed dependencies before they are integrated into the scenario.