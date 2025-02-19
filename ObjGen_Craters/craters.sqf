/* craters.sqf - Craters generator (Server-side) */
// Place down craters on the map as vehicles, replace by simple objects to keep performance, 
// During placement also cause damage = 1 in a 40m radius from the crater placed
// Limited testing in SP(Eden) and Dedicated(FASTER), performance is affected due to the sheer amount of objects placed
// Highly recommend using Arma 3 Simple Cleanup Concepts and Map Object Finder, open up the map and inspect needless objects for the mission
// Insert the object .p3d into Arma 3 Simple Cleanup Concepts and run server-side, getting some extra fps
// Example: in my winter mission i remove power lines, green hedges, little rocks, train tracks and other things which would be under snow/not present in the scenario
// Suggest also remove excessive objects(Like too much trash piles)

//                         ---- Links ----
// Arma 3 Simple Cleanup Concepts:  https://github.com/TenuredCLOUD/A3-Cleanup-concepts/tree/main
// Map Object Finder:               https://steamcommunity.com/sharedfiles/filedetails/?id=2613892572

// Uses vanilla craters, but you can change for other objects or craters in _repositionCraterTypes
// Random chance for each type of creators(small craters rarer) you can change here _selectCraterType
// Generates 4 craters for every 500m, can just change in the variables at start, CAREFUL with high counts
// There is a condition to not spawn them on water, but one or other might end up spawning anyway(Really small number, in Tanoa is around 5-8 total at max)
// insert this into init.sqf -> [] execVM "PATH_TO_THE_SCRIPT\craters.sqf";

if (isServer) then {

    // Parameters
    private _centerPos = [worldSize / 2, worldSize / 2, 0];  // Center of the map
    private _width = worldSize;   // Full map width (x-axis)
    private _height = worldSize;  // Full map height (y-axis)
    private _chunkSize = 500;     // 500m chunk size

    // Calculate total chunks
    private _chunksX = ceil (_width / _chunkSize);
    private _chunksY = ceil (_height / _chunkSize);
    private _totalChunks = _chunksX * _chunksY;

    // Total craters: 4 per chunk
    private _totalCraters = _totalChunks * 4;
    private _craterIndex = 0;  // Counter for craters

    // Calculate number of chunks across the map (for the 6x8 km area)
    private _chunksX = _width / _chunkSize;  // Number of chunks along the width
    private _chunksY = _height / _chunkSize;  // Number of chunks along the height
    private _totalChunks = _chunksX * _chunksY;  // Total number of chunks
    private _craterCountPerChunk = ceil(_totalCraters / _totalChunks);  // Distribute craters evenly across chunks

    // Crater types that should be repositioned if placed inside a building or object
    private _repositionCraterTypes = ["Land_ShellCrater_02_small_F", "CraterLong", "CraterLong_02_F"];

    // Function to check if the crater is placed too close to buildings or objects
    private _isCraterBlocked = {
        params ["_pos", "_radius", "_minDistance"];

        // Check for buildings, large objects, or trees within the radius
        private _nearbyObjects = nearestObjects [_pos, [], _radius];

        // Ensure the crater is at least _minDistance away from any object
        private _isBlocked = false;
        {
            if ((getPosATL _x distance _pos) < _minDistance) then {
                _isBlocked = true;
            };
        } forEach _nearbyObjects;

        _isBlocked
    };

    // Function to reposition the crater until it's in a valid location
    private _getValidCraterPosition = {
        params ["_chunkX", "_chunkY", "_chunkSize", "_craterType", "_repositionRadius"];

        private _validPos = [_chunkX + (random _chunkSize), _chunkY + (random _chunkSize), 0];

        // Keep generating new positions until it's at least 3m away from buildings/objects
        while {[_validPos, _repositionRadius, 3] call _isCraterBlocked} do {
            _validPos = [_chunkX + (random _chunkSize), _chunkY + (random _chunkSize), 0];
        };

        _validPos
    };

    // Function to select a crater type based on the probabilities provided
    private _selectCraterType = {
        private _randomVal = random 100;

        if (_randomVal < 60) then {
            "Land_ShellCrater_02_small_F"  // 60% chance
        } else {
            if (_randomVal < 90) then {
                "Land_ShellCrater_02_large_F"  // 30% chance
            } else {
                if (_randomVal < 95) then {
                    "CraterLong"  // 5% chance
                } else {
                    "CraterLong_02_F"  // 5% chance
                };
            };
        };
    };

    // Function to damage objects and replace them with simple objects
    private _damageBuilding = {
        params ["_building"];

        // Apply damage to the building
        _building allowDamage true;
        _building setDamage [1,false];

        // Get the position, direction, and orientation for the simple object
        private _buildingPos = getPosATL _building;
        private _buildingDir = getDir _building;
        private _buildingModel = getModelInfo _building select 1;

        // Delete the original building
        deleteVehicle _building;

        // Create the building as a simple object with the same position, direction, and model
        private _simpleBuilding = createSimpleObject [_buildingModel, _buildingPos];
        _simpleBuilding setDir _buildingDir;  // Set the original direction
    };

    // Process each chunk and place craters
    private _processChunk = {
        params ["_chunkX", "_chunkY", "_chunkSize", "_craterCount"];

        for "_i" from 1 to _craterCount do {
            private _xPos = _chunkX + (random _chunkSize);
            private _yPos = _chunkY + (random _chunkSize);
            private _pos = [_xPos, _yPos, 0];  // Base position (z=0)

            if (surfaceIsWater _pos) then {
                // Skip water areas
                break;
            };

            // Select a crater type using the probability function
            private _craterType = call _selectCraterType;

            // Handle repositioning for specific craters if they're blocked by a building/object
            if (_craterType in _repositionCraterTypes) then {
                _pos = [_chunkX, _chunkY, _chunkSize, _craterType, 6] call _getValidCraterPosition;  // 6m radius check, at least 3m away
            };

            // Determine the ground height at the position using getTerrainHeight.
            private _groundHeight = getTerrainHeight _pos;
            // Raise slightly to avoid clipping (e.g., 0.1m above ground)
            private _raisedPos = [_pos select 0, _pos select 1, _groundHeight + 0.1];

            // Create the crater as a vehicle for initial processing
            private _crater = _craterType createVehicle _raisedPos;

            // --- Compute terrain normal at the raised position for the vehicle ---
            private _delta = 5;
            private _base = _raisedPos;
            private _p1 = [(_base select 0) + _delta, (_base select 1), getTerrainHeight [(_base select 0) + _delta, (_base select 1), 0] + 0.1];
            private _p2 = [(_base select 0), (_base select 1) + _delta, getTerrainHeight [(_base select 0), (_base select 1) + _delta, 0] + 0.1];
            private _v1 = _p1 vectorDiff _base;
            private _v2 = _p2 vectorDiff _base;
            private _normal = _v1 vectorCrossProduct _v2;
            _normal = vectorNormalized _normal;

            // Derive a randomized forward vector perpendicular to _normal
            private _baseFwd = [0, 0, 0];
            if (abs (_normal select 2) < 0.99) then {
                _baseFwd = [0,0,1] vectorCrossProduct _normal;
            } else {
                _baseFwd = [1,0,0];
            };
            _baseFwd = vectorNormalized _baseFwd;
            private _theta = (random 360) * (3.14159265 / 180);  // Convert degrees to radians
			private _cosTheta = cos _theta;
			private _sinTheta = sin _theta;
			private _fwd = ((_baseFwd vectorMultiply _cosTheta) vectorAdd ((_normal vectorCrossProduct _baseFwd) vectorMultiply _sinTheta)) vectorAdd (_normal vectorMultiply (((_normal select 0) * (_baseFwd select 0) + (_normal select 1) * (_baseFwd select 1) + (_normal select 2) * (_baseFwd select 2)) * (1 - _cosTheta)));
            _fwd = vectorNormalized _fwd;

            // Set the vehicle's orientation to match the terrain
            _crater setVectorDirAndUp [_fwd, _normal];
            _crater allowDamage false;
            _crater enableSimulationGlobal false;
            _crater enableSimulation false;

            // Get the world position of the vehicle (which may be adjusted by the engine)
            private _craterPos = getPosWorld _crater;
            private _craterModel = getModelInfo _crater select 1;

            // Damage nearby buildings/objects
            private _nearbyBuildings = nearestTerrainObjects [_crater, [], 40];
            private _nearbyObjects_Dmg = nearestObjects [_crater, [], 40];
            private _nearbyThings = _nearbyObjects_Dmg + _nearbyBuildings;
            {
                [_x] call _damageBuilding;
            } forEach _nearbyThings;

            // Delete the original vehicle
            deleteVehicle _crater;

            // --- Recalculate orientation for the final simple crater ---
            private _groundHeightCrater = getTerrainHeight _craterPos;
            private _simpleCraterPos = [_craterPos select 0, _craterPos select 1, _groundHeightCrater + 0.1];

            // Optionally, re-sample terrain normal at the final position
            private _base2 = _simpleCraterPos;
			private _p1b = [(_base2 select 0) + _delta, (_base2 select 1), getTerrainHeight [(_base2 select 0) + _delta, (_base2 select 1), 0] + 0.1];
            private _p2b = [(_base2 select 0), (_base2 select 1) + _delta, getTerrainHeight [(_base2 select 0), (_base2 select 1) + _delta, 0] + 0.1];
            private _v1b = _p1b vectorDiff _base2;
            private _v2b = _p2b vectorDiff _base2;
            private _normal2 = _v1b vectorCrossProduct _v2b;  // Corrected line with correct syntax
            _normal2 = vectorNormalized _normal2;

            // Randomize a forward vector again if desired (or reuse _fwd)
			private _baseFwd2 = [0, 0, 0];
            if (abs (_normal2 select 2) < 0.99) then {
                _baseFwd2 = [0,0,1] vectorCrossProduct _normal2;  // Corrected line with correct syntax
            } else {
                _baseFwd2 = [1,0,0];
            };
            _baseFwd2 = vectorNormalized _baseFwd2;
            private _theta2 = (random 360) * (3.14159265/180);
            private _cosTheta2 = cos _theta2;
			private _sinTheta2 = sin _theta2;
			private _fwd2 = ((_baseFwd2 vectorMultiply _cosTheta2) vectorAdd ((_normal2 vectorCrossProduct _baseFwd2) vectorMultiply _sinTheta2)) vectorAdd (_normal2 vectorMultiply (((_normal2 select 0) * (_baseFwd2 select 0) + (_normal2 select 1) * (_baseFwd2 select 1) + (_normal2 select 2) * (_baseFwd2 select 2)) * (1 - _cosTheta2)));
			_fwd2 = vectorNormalized _fwd2;

            // Create the crater as a simple object with the computed orientation
            private _simpleCrater = createSimpleObject [_craterModel, _simpleCraterPos];
            _simpleCrater setVectorDirAndUp [_fwd2, _normal2];
        };
    };

    // Iterate over all chunks
    for "_chunkX" from (_centerPos select 0) - (_width / 2) to (_centerPos select 0) + (_width / 2) step _chunkSize do {
        for "_chunkY" from (_centerPos select 1) - (_height / 2) to (_centerPos select 1) + (_height / 2) step _chunkSize do {
            [_chunkX, _chunkY, _chunkSize, _craterCountPerChunk] call _processChunk;
            sleep 0.05;  // Reduce load on the system
        };
    };
    
    missionNamespace setVariable ["craters_done", true];
};
