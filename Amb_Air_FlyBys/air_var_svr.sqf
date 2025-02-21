private _AmbiAir = {
    while {true} do {
        // _waitTime = 300 + (random 600);
        _waitTime = 10; // FOR TESTING PURPOSES
        sleep _waitTime;

        // Private variables on the server:
        private _heliClasses = ["RHS_Mi24P_vvsc", "RHS_Mi8AMT_vvsc", "RHS_Ka52_vvs", "rhs_mi28n_vvsc","rhs_ka60_c"];
        private _jetClasses = ["rhs_mig29s_vvs", "RHS_Su25SM_vvs","rhs_l159_CDF"];
        
        // Ensure there's at least one player
        if (count allPlayers == 0) exitWith {};

        // Select a random player
        private _randomPlayer = allPlayers select (floor (random (count allPlayers)));

        // Get a safe start position between 3000 and 4000 m away from the random player
        private _startPos = [_randomPlayer, 3000, 4000, 3, 0, 200, 0] call BIS_fnc_findSafePos;

        // Choose a random angle for the intermediate flyby point F
        private _angleForF = random 360;

        // Calculate F as a point up to 450 m from the player (i.e. the closest approach)
        private _distanceForF = round(random 450);
        private _F = (getPos _randomPlayer) getPos [_distanceForF, _angleForF];

        // Compute the end point E as the reflection of S over F:
        // E = 2*F - S
        private _endPos = _F vectorAdd (_F vectorDiff _startPos);

		private _vehicleClasses = [];
		
        // Decide whether to use helicopter or jet classes
        private _vehicleClasses;
        if ((random 1) < 0.5) then {
            _vehicleClasses = _heliClasses;
        } else {
            _vehicleClasses = _jetClasses;
        };

        // Vehicle 1: Choose a random class
        private _vehicleClass1 = _vehicleClasses select (floor (random (count _vehicleClasses)));

        // For variety, compute an offset route for a second vehicle
        private _startPos2 = _startPos getPos [175, _angleForF + 90];
        private _endPos2   = _endPos getPos [175, _angleForF + 90];
        private _vehicleClass2 = _vehicleClass1;

        // Set variables in the missionNamespace and broadcast them
        missionNamespace setVariable ["airParams1", [_startPos, _endPos, 100, "FULL", _vehicleClass1, west], true];
        missionNamespace setVariable ["airParams2", [_startPos2, _endPos2, 100, "FULL", _vehicleClass2, west], true];

        // Set air_done to true
        missionNamespace setVariable ["air_done", true, true];

        // Reset air_done to false after a short delay to allow clients to process
        sleep 5;
        missionNamespace setVariable ["air_done", nil, true];
    };
};

// Run the spawner on the server.
if (isServer) then {
    [] spawn _AmbiAir;
};
