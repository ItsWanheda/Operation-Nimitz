/*
    Operation Nimitz mission bootstrap.

    All mod classnames and spawn placements are configured in:
      config/assetConfig.sqf

    Keep that configuration before mission initialization so spawned object
    references (ON_carrier, ON_playerAircraft, etc.) exist before setup checks.
*/
call compile preprocessFileLineNumbers "config\\assetConfig.sqf";
[] execVM "scripts\\core\\initMission.sqf";
