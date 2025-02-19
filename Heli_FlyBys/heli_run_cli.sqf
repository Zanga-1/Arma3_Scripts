/* heli_ambient_client.sqf - Ambient Helicopter Spawner (Client-side) */

runHeliFlyby = {
    while {true} do {
        // Wait until the server has set helis_done
        waitUntil { missionNamespace getVariable ["helis_done", false] };

        // Retrieve variables from the missionNamespace
        private _params1 = missionNamespace getVariable ["heliParams1", []];
        private _params2 = missionNamespace getVariable ["heliParams2", []];

        // Check if the parameters are defined
        if ((count _params1) > 0) then {
            // Unpack the arrays into separate variables
            private _startPos1 = _params1 select 0;
            private _endPos1 = _params1 select 1;
            private _height1 = _params1 select 2;
            private _speed1 = _params1 select 3;
            private _heliClass1 = _params1 select 4;
            private _side1 = _params1 select 5;

            // Run BIS_fnc_ambientFlyby with the unpacked variables
            [_startPos1, _endPos1, _height1, _speed1, _heliClass1, _side1] call BIS_fnc_ambientFlyby;
        };

        if ((count _params2) > 0) then {
            // Unpack the arrays into separate variables
            private _startPos2 = _params2 select 0;
            private _endPos2 = _params2 select 1;
            private _height2 = _params2 select 2;
            private _speed2 = _params2 select 3;
            private _heliClass2 = _params2 select 4;
            private _side2 = _params2 select 5;

            // Run BIS_fnc_ambientFlyby with the unpacked variables
            [_startPos2, _endPos2, _height2, _speed2, _heliClass2, _side2] call BIS_fnc_ambientFlyby;
        };

        // Wait for helis_done to be deleted before the next iteration
        waitUntil { isNil { missionNamespace getVariable "helis_done" } };
    };
};

// Register the function globally
[] spawn runHeliFlyby;
