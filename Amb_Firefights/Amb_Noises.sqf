// Add ambient firefights sounds for immersion
// due to being client-side, might generate different positions of firefight, firefight sounds and firefights occurence(One player might be playing sound and others not)

// insert this into initPlayerLocal -> [] execVM "PATH_TO_THE_SCRIPT\Amb_Firefights\Amb_Noises.sqf";
// Limited testing SP(Eden) and Dedicated(FASTER)

private _cpbSoundList = 
[
    "A3\Sounds_F\environment\ambient\battlefield\battlefield_firefight1.wss",
    "A3\Sounds_F\environment\ambient\battlefield\battlefield_firefight2.wss",
    "A3\Sounds_F\environment\ambient\battlefield\battlefield_firefight3.wss",
    "A3\Sounds_F\environment\ambient\battlefield\battlefield_firefight4.wss"
];

private _cpbTarget = player;
private _cpbSoundObject = player;
private _cpbMinDistance = 1600;
private _cpbMaxDistance = 1900;
private _cpbMedDistance = 1800;

while {true} do
{
	_waitTime = 90 + (random 240);
	sleep _waitTime;
    _dir = round (random 360);
    _dis = round (random [_cpbMinDistance,_cpbMedDistance,_cpbMaxDistance]);
    private _cpbSoundPosition = _cpbTarget getRelPos [_dis, _dir];

    playSound3D [_cpbSoundList call BIS_fnc_selectRandom, _cpbSoundObject, false, _cpbSoundPosition, 5, 1, 0];
};
