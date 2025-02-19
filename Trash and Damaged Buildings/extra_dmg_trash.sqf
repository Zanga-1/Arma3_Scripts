// *** ALL credits to Crub and his Simple Apocalypse Environment ***
// Check out the original script: https://steamcommunity.com/sharedfiles/filedetails/?id=3197087607
// this is a heavily modified version of it and with lots of parts excluded from the original to my personal use

// uses RHS and CUP Terrains CORE assets, but you can change and customize the _wreckClassNames(Wrecks) and _classNames(Trash) to whatever other objects you like
// changes made based on Tanoa, might have to add classes in "forEach nearestTerrainObjects" on other maps
// insert this into init.sqf -> [] execVM "PATH_TO_THE_SCRIPT\extra_dmg_trash.sqf";

if (isServer) then {
    hint "Damaging objects...";
    diag_log "Damaging objects...";

    // Parameters
    private _centerPos = [worldSize / 2, worldSize / 2, 0];  // Center of the map
    private _width = worldSize;  // Full map width (x-axis)
    private _height = worldSize;  // Full map height (y-axis)
    private _chunkSize = 500;  // 500m chunk size

    // Calculate total chunks
    private _chunksX = ceil (_width / _chunkSize);
    private _chunksY = ceil (_height / _chunkSize);
    private _totalChunks = _chunksX * _chunksY;
    private _craterIndex = 0;  // Counter for craters

    // Apply additional damage to terrain objects
    {
        _pos = getPos _x;
        if (!(isObjectHidden _x) && {damage _x < 0.8}) then {
            _x setDamage [(0.8 + (random 0.3)), false];
        };
		
		sleep 0.0001;
    } forEach nearestTerrainObjects [_centerPos, ["CHAPEL", "CHURCH","FENCE","FUELSTATION","HOSPITAL","HOUSE","LIGHTHOUSE","POWERSOLAR","POWERWAVE","POWERWIND","TOURISM","TRANSMITTER","TRANSMITTER","WALL","WATERTOWER"], _width, false];
    
	diag_log "Placing trash/wrecks...";

    // Function to create simple objects
    ZSC_fnc_createSimpleObject = {
        params ["_className", "_position", "_direction"];
        _info = [_className] call BIS_fnc_simpleObjectData;
        _path = (_info select 1);
        _obj = _className createVehicleLocal _position;
        _obj setDir _direction;
        _pos = getPosWorld _obj;
        _vectorDirUp = [vectorDir _obj, vectorUp _obj];
        deleteVehicle _obj;
        _simpleObj = createSimpleObject [_path, _pos];
        _simpleObj setVectorDirAndUp _vectorDirUp;
        _simpleObj
    };

    // Road debris class names
    private _wreckClassNames = [
        "Land_Wreck_BMP2_F", "Land_Wreck_BRDM2_F", "Land_Wreck_Car_F", "Land_Wreck_Car2_F",
        "Land_Wreck_Car3_F", "Land_Wreck_CarDismantled_F", "Land_Wreck_HMMWV_F", "Land_Wreck_Hunter_F",
        "Land_Wreck_Offroad_F", "Land_Wreck_Skodovka_F", "Land_Wreck_T72_hull_F", "Land_Wreck_Truck_dropside_F",
        "Land_Wreck_Truck_F", "Land_Wreck_UAZ_F", "Land_Wreck_Ural_F", "Land_Wreck_Van_F",
        "Land_Bulldozer_01_wreck_F", "Land_Excavator_01_wreck_F", "Land_V3S_wreck_F", "Land_TrailerCistern_wreck_F", "rhs_mig29sWreck",
		"Land_ScrapHeap_1_F", "Land_ScrapHeap_2_F","Land_Scrap_MRAP_01_F","Land_rhs_tu95_wreck","Mass_grave","M113Wreck","LADAWreck","HMMWVWreck","JeepWreck1",
		"hiluxWreck","datsun02Wreck","datsun01Wreck","Fort_Barricade_EP1","Hhedgehog_concreteBig","CampEast_EP1","Land_Barricade_01_10m_F","Land_DragonsTeeth_01_4x2_old_F","RoadBarrier_long","Land_Mil_House_ruins",
		"Wire","ACE_ConcertinaWire","Fort_RazorWire", "Land_HBarrier_5_F", "Land_Mil_WallBig_debris_F", "Land_CncBarrierMedium4_F","PlasticBarrier_02_grey_F","PlasticBarrier_02_yellow_F",
		"Land_PlasticBarrier_02_F","Land_HBarrierWall6_F"
    ];

    private _classNames = [
        "Land_Cargo40_china_color_V1_ruins_F", "Land_Cargo40_military_ruins_F", "Land_Cargo20_china_color_V1_ruins_F",
        "Land_Fortress_01_bricks_v1_F", "Land_Fortress_01_bricks_v2_F","Land_WoodenShelter_01_ruins_F",
		"Land_HistoricalPlaneWreck_02_rear_F", "Land_HistoricalPlaneWreck_02_wing_right_F",
        "Land_HistoricalPlaneWreck_02_wing_left_F", "Land_HistoricalPlaneDebris_01_F", "Land_HistoricalPlaneDebris_02_F",
        "Land_HistoricalPlaneDebris_03_F", "Land_HistoricalPlaneDebris_04_F", "Land_GarbageBags_F",
        "Land_GarbageBarrel_02_buried_F", "Land_GarbagePallet_F", "Land_LuggageHeap_03_F",
        "Land_GarbageHeap_03_F", "Land_GarbageHeap_04_F", "Land_JunkPile_F", "Land_Tyres_F",
        "Land_Cages_F", "Land_CratesWooden_F", "Land_Bodybag_01_black_F", "MedicalGarbage_01_5x5_v1_F",
        "Land_Stretcher_01_olive_F", "Land_RefuelingHose_01_F",
        "Land_Pallets_F", "Land_IronPipes_F", "Land_TimberPile_01_F", "Land_PaperBox_01_open_empty_F",
        "Land_FoodSacks_01_cargo_brown_idap_F", "rhs_casing_122mm",
        "Land_BarrelTrash_grey_F", "Land_WoodenCrate_01_stack_x3_F", "Land_Cargo10_military_green_F",
        "rhs_Wreck_T80u_turret_F","Land_Campfire_F",
		"Land_WoodenLog_F","Land_WoodPile_F","Land_TentDome_F","Land_TentA_F","Land_Pallets_stack_F","Land_WoodPile_04_F","Land_HumanSkeleton_F","Land_HumanSkull_F",
		"Land_PaperBox_01_small_destroyed_white_IDAP_F","Land_PaperBox_01_small_destroyed_brown_F","Land_Garbage_square3_F","Land_GarbageHeap_02_F","Land_GarbageHeap_01_F","Lantern_01_red_F",
		"Land_WoodenCart_F","Land_Bodybag_01_white_F","MetalBarrel_burning_F","Misc_concrete_High","Land_Misc_Garb_Square_EP1","Land_tires_EP1",
		"AmmoCrates_NoInteractive_Large","AmmoCrates_NoInteractive_Medium","CUP_hromada_beden_dekorativniX","Wooden_barrels","Misc_cargo_cont_net2","Land_Wheel_cart_EP1","snowman","CUP_Winter_obj_fort_rampart_ep1","CUP_Winter_obj_misc_FallenSpruce",
		"CUP_Winter_obj_misc_FallenTree1","Body","Land_DeerSkeleton_full_01_F","Land_WoodenWindBreak_01_F","Land_Grave_rocks_F","Land_Brana02_ruins","Land_MobileRadar_01_radar_ruins_F"
    ];

    // Spawn wrecks and ruins on roads
    {
        _pos = getPos _x;
        private _chance = 8;
        private _rdm = round random _chance;
        if (_rdm == _chance) then {
            private _offsetPos = [
                (_pos select 0) + (random 15 - 7.5),
                (_pos select 1) + (random 15 - 7.5),
                _pos select 2
            ];
            _obj = [selectRandom _wreckClassNames, _offsetPos, (round random 360)] call ZSC_fnc_createSimpleObject;
			
            _obj setVariable ["deleteMe", true];
			sleep 0.0001;
        };
	} forEach (_centerPos nearRoads _width);

	{
		_pos = getPos _x;
        private _chance = 3;
        private _rdm = round random _chance;
        if (_rdm == _chance) then {
            private _offsetPos = [
                (_pos select 0) + (random 50 - 25),
                (_pos select 1) + (random 50 - 25),
                _pos select 2
            ];
            _obj = [selectRandom _classNames, _offsetPos, (round random 360)] call ZSC_fnc_createSimpleObject;
            _obj setVariable ["deleteMe", true];
			
			sleep 0.0001;
        };
    } forEach (_centerPos nearRoads _width);

    hint "Placing heli wrecks...";
    diag_log "Placing heli wrecks...";

    // Spawn helicopter wrecks on all helipads
    private _classNames = ["Land_Mi8_wreck_F", "Land_rhs_mi28_wreck2"];
    {
        _pos = getPos _x;
        _obj = [selectRandom _classNames, _pos, (round random 360)] call ZSC_fnc_createSimpleObject;
        _obj setVariable ["deleteMe", true];
		
		sleep 0.0001;
    } forEach ([0, 0, 0] nearObjects ["HeliH", _width]);

    hint "Extra damage and heli wrecks done!!!";
    diag_log "Extra damage and heli wrecks done!!!";

    missionNamespace setVariable ["extra_dmg_trash_done", true];
};
