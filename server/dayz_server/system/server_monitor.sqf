// DayZ Server Controlcenter Server Project

#include "\@dayzcc\addons\dayz_server_config.hpp"

// Initialize ---------------------------------------------------------------------------------------------------------

dayz_versionNo 			= getText(configFile >> "CfgMods" >> "DayZ" >> "version");
dayz_hiveVersionNo 		= getNumber(configFile >> "CfgMods" >> "DayZ" >> "hiveVersion");
dayz_serverVersionNo	= "5.9.0.0";
dayz_plusVersionNo		= null;

if (getText(configFile >> "CfgMods" >> "DayZ" >> "name") == "DayZ+") then {
	dayz_plusVersionNo == getNumber(configFile >> "CfgMods" >> "DayZ" >> "hiveVersion");
};

diag_log format ["SERVER: VERSION: CC %1", dayz_serverVersionNo];

if (dayz_plusVersionNo != null) then {
	diag_log format ["SERVER: DAYZ+ VERSION: %1, HIVE VERSION: %2", dayz_versionNo, dayz_hiveVersionNo];
} else {
	diag_log format ["SERVER: DAYZ VERSION: %1, HIVE VERSION: %2", dayz_versionNo, dayz_hiveVersionNo];
};

if ((count playableUnits == 0) and !isDedicated) then {
	isSinglePlayer = true;
	diag_log ("SERVER: SINGLEPLAYER DETECTED!");
};

diag_log ("SERVER: WORLD: " + str(worldName));
diag_log ("SERVER: INSTANCE: " + str(dayz_instance));

[] execVM "\z\addons\dayz_server\system\server_fps.sqf";

waitUntil { initialized };

diag_log ("HIVE: Starting ...");

// Fetch and spawn objects --------------------------------------------------------------------------------------------

diag_log ("HIVE: Fetching objects ...");

_key 		= format["CHILD:302:%1:", dayZ_instance];
_result 	= _key call server_hiveReadWrite;
_status 	= _result select 0;
_objects 	= [];
_count		= 0;
_countr 	= 0;

if (_status == "ObjectStreamStart") then {
	_val = _result select 1;
	for "_i" from 1 to _val do {
		_result = _key call server_hiveReadWrite;
		_status = _result select 0;
		_objects set [count _objects, _result];
		_count = _count + 1;
	};
	diag_log ("HIVE: Fetched " + str(_count) + " objects!");
};

{
	_countr 	= _countr + 1;
	_idKey 		= _x select 1;
	_type 		= _x select 2;
	_ownerID 	= _x select 3;
	_worldspace = _x select 4;
	_intentory 	= _x select 5;
	_hitPoints 	= _x select 6;
	_fuel 		= _x select 7;
	_damage 	= _x select 8;
	_dir 		= 0;
	_pos 		= [0,0,0];
	_wsDone 	= false;

	if (count _worldspace >= 2) then {
		_dir = _worldspace select 0;
		if (count (_worldspace select 1) == 3) then {
			_pos = _worldspace select 1;
			_wsDone = true;
		}
	};			
	if (!_wsDone) then {
		if (count _worldspace >= 1) then { _dir = _worldspace select 0; };
		_pos = [getMarkerPos "center", 0, 4000, 10, 0, 2000, 0] call BIS_fnc_findSafePos;
		if (count _pos < 3) then { _pos = [_pos select 0, _pos select 1, 0]; };
		diag_log ("DEBUG: Moved object " + str(_idKey) + " (" + _type + ") to " + str(_pos));
	};
	
	if (_damage < 1) then {
		diag_log ("DEBUG: Spawned: " + str(_idKey) + " " + _type);

		_object = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
		_object setVariable ["lastUpdate", time];
		_object setVariable ["ObjectID", _idKey, true];
		_object setVariable ["CharacterID", _ownerID, true];
		
		clearWeaponCargoGlobal  _object;
		clearMagazineCargoGlobal  _object;
		
		if (_object isKindOf "TentStorage") then {
			_pos set [2,0];
			_object setpos _pos;
			_object addMPEventHandler ["MPKilled", { _this call vehicle_handleServerKilled; }];
		};
		_object setdir _dir;
		_object setDamage _damage;
		
		if (count _intentory > 0) then {
			_objWpnTypes = (_intentory select 0) select 0;
			_objWpnQty = (_intentory select 0) select 1;
			_countr = 0;					
			{
				_isOK = isClass(configFile >> "CfgWeapons" >> _x);
				if (_isOK) then {
					_block = getNumber(configFile >> "CfgWeapons" >> _x >> "stopThis") == 1;
					if (!_block) then { _object addWeaponCargoGlobal [_x, _objWpnQty select _countr]; };
				};
				_countr = _countr + 1;
			} forEach _objWpnTypes; 
			_objWpnTypes = (_intentory select 1) select 0;
			_objWpnQty = (_intentory select 1) select 1;
			_countr = 0;
			{
				_isOK = isClass(configFile >> "CfgMagazines" >> _x);
				if (_isOK) then {
					_block = getNumber(configFile >> "CfgMagazines" >> _x >> "stopThis") == 1;
					if (!_block) then { _object addMagazineCargoGlobal [_x, _objWpnQty select _countr]; };
				};
				_countr = _countr + 1;
			} forEach _objWpnTypes;
			_objWpnTypes = (_intentory select 2) select 0;
			_objWpnQty = (_intentory select 2) select 1;
			_countr = 0;
			{
				_isOK = isClass(configFile >> "CfgVehicles" >> _x);
				if (_isOK) then {
					_block = getNumber(configFile >> "CfgVehicles" >> _x >> "stopThis") == 1;
					if (!_block) then { _object addBackpackCargoGlobal [_x, _objWpnQty select _countr]; };
				};
				_countr = _countr + 1;
			} forEach _objWpnTypes;
		};	

		if (_object isKindOf "AllVehicles") then {
			{
				_selection = _x select 0;
				_dam = _x select 1;
				if (_selection in dayZ_explosiveParts and _dam > 0.8) then { _dam = 0.8 };
				[_object,_selection,_dam] call object_setFixServer;
			} forEach _hitpoints;
			_object setvelocity [0,0,1];
			_object setFuel _fuel;
			_object call fnc_vehicleEventHandler;
		};

		dayz_serverObjectMonitor set [count dayz_serverObjectMonitor, _object];
	};
} forEach _objects;

// Fetch and spawn buildings ------------------------------------------------------------------------------------------

diag_log ("HIVE: Fetching custom buildings ...");

_key 		= format ["CHILD:999:select b.class_name, ib.worldspace from instance_building ib join building b on ib.building_id = b.id where ib.instance_id = ?:[%1]:", dayZ_instance];
_result 	= _key call server_hiveReadWrite;
_status 	= _result select 0;
_count 	= 0;

if (_status == "ObjectStreamStart") then {
	_val = _result select 1;
	for "_i" from 1 to _val do {
		_result = _key call server_hiveReadWrite;
		_status = _result select 0;
		_pos = call compile (_result select 1);
		_dir = _pos select 0;
		_pos = _pos select 1;
		_building = createVehicle [_result select 0, _pos, [], 0, "CAN_COLLIDE"];
		_building setDir _dir;
		_count = _count + 1;
	};
	diag_log ("HIVE: Fetched " + str(_count) + " buildings!");
};

// Get and set the time -----------------------------------------------------------------------------------------------

_key 		= "CHILD:307:";
_result 	= _key call server_hiveReadWrite;
_outcome 	= _result select 0;
if (_outcome == "PASS") then {
	_date = _result select 1; 
	if (isDedicated) then { ["dayzSetDate", _date] call broadcastRpcCallAll; };
	diag_log ("SERVER: Local Time set to " + str(_date));
};

// Finish initialization ----------------------------------------------------------------------------------------------

createCenter civilian;

if (isDedicated) then {
	endLoadingScreen;
	_id = [] execFSM "\z\addons\dayz_server\system\server_cleanup.fsm";
};

allowConnection = true;

// Spawn crashsites and wrecks ----------------------------------------------------------------------------------------

if (SpawnHelis && worldName != "namalsk") then {
	_count = 5;
	#ifdef SpawnHelisCount
	_count = SpawnHelisCount;
	#endif

	[["UH60Wreck_DZ", "UH1Wreck_DZ"], ["Military", "HeliCrash", "MilitarySpecial"], _count, (50 * 60), (15 * 60), 0.75, 'center', 4000, true, false] spawn server_spawnWreck;
};
if (SpawnWrecks) then {
	_count = 18;
	#ifdef SpawnWrecksCount
	_count = SpawnWrecksCount;
	#endif

	[["MV22Wreck", "LADAWreck", "BMP2Wreck", "MH60Wreck", "C130JWreck", "Mi24Wreck", "UralWreck", "HMMWVWreck", "T72Wreck"], ["Residential", "Industrial", "Military", "Farm", "Supermarket", "Hospital"], _count, (50 * 60), (15 * 60), 0.75, 'center', 4000, false, false] spawn server_spawnWreck;

	if (dayz_plusversionNo != null) then {
		[["UH60Wreck_DZ", "UH1Wreck_DZ"], ["UH60Crash", "UH1YCrash"], 4, (50 * 60), (15 * 60), 0.75, 'center', 4000, true, false] spawn server_spawnWreck;
	};
};
if (SpawnCare) then {
	_count = 4;
	#ifdef SpawnCareCount
	_count = SpawnCareCount;
	#endif

	[["Misc_cargo_cont_net1", "Misc_cargo_cont_net2", "Misc_cargo_cont_net3"], ["Residential", "Industrial", "Military", "Farm", "Supermarket", "Hospital"], _count, (50 * 60), (15 * 60), 0.75, 'center', 4000, false, false] spawn server_spawnWreck;
};
if (worldName == "namalsk") then {
	[["Land_mi8_crashed", "Land_wreck_c130j_ep1", "Misc_cargo_cont_net1"], ["HeliCrashNamalsk", "HospitalNamalsk"], _count, (50 * 60), (15 * 60), 0.75, 'center', 4000, false, false] spawn server_spawnWreck;
};