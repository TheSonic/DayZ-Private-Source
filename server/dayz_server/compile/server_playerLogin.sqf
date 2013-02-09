private ["_botActive", "_int", "_newModel", "_doLoop", "_wait", "_hiveVer", "_isHiveOk", "_playerID", "_playerObj", "_randomSpot", "_publishTo", "_primary", "_secondary", "_key", "_result", "_charID", "_playerObj", "_playerName", "_finished", "_spawnPos", "_spawnDir", "_items", "_counter", "_magazines", "_weapons", "_group", "_backpack", "_worldspace", "_direction", "_newUnit", "_score", "_position", "_isNew", "_inventory", "_backpack", "_medical", "_survival", "_stats", "_state"];

#include "\@dayzcc\addons\dayz_server_config.hpp"

_playerID 		= _this select 0;
_playerObj 		= _this select 1;
_playerName 	= name _playerObj;
_worldspace 	= [];

if (_playerName == '__SERVER__' || _playerID == '' || local player) exitWith {};

diag_log ("PLAYER: LOGIN STARTING: " + _playerName + " [" + _playerID + "]");

if (count _this > 2) then {
	dayz_players = dayz_players - [_this select 2];
};

// Statistics
_inventory 		= [];
_backpack 		= [];
_items 			= [];
_magazines 		= [];
_weapons 		= [];
_medicalStats 	= [];
_survival 		= [0,0,0];
_tent 			= [];
_state 			= [];
_direction 		= 0;
_model 			= "";
_newUnit 		= objNull;
_botActive 		= false;

if (_playerID == "") then {
	_playerID = getPlayerUID _playerObj;
};

if ((_playerID == "") or (isNil "_playerID")) exitWith {
	diag_log ("PLAYER: LOGIN FAILED: No Player ID");
};

// Connection Attempt
_doLoop = 0;
while {_doLoop < 5} do {
	_key = format["CHILD:101:%1:%2:%3:", _playerID, dayZ_instance, _playerName];
	_primary = _key call server_hiveReadWrite;
	if (count _primary > 0) then { if ((_primary select 0) != "ERROR") then { _doLoop = 9; }; };
	_doLoop = _doLoop + 1;
};

if (isNull _playerObj or !isPlayer _playerObj) exitWith {
	diag_log ("PLAYER: LOGIN FAILED: Player Object Null");
};

if ((_primary select 0) == "ERROR") exitWith {
	diag_log ("PLAYER: LOGIN FAILED: Player Data Error");
};

// Process request
_newPlayer 		= _primary select 1;
_isNew 			= count _primary < 6;
_charID 		= _primary select 2;
_randomSpot 	= false;
_hiveVer 		= 0;

if (!_isNew) then {
	// Set character variables
	_inventory 	= _primary select 4;
	_backpack 	= _primary select 5;
	_survival 	= _primary select 6;
	_model 		= _primary select 7;
	_hiveVer 	= _primary select 8;
	
	if (CheckCustInv && _model == "") then {
		_key = format ["CHILD:999:select replace(cl.`inventory`, '""', '""""') inventory, replace(cl.`backpack`, '""', '""""') backpack, replace(coalesce(cl.`model`, 'Survivor2_DZ'), '""', '""""') model from `cust_loadout` cl join `cust_loadout_profile` clp on clp.`cust_loadout_id` = cl.`id` where clp.`unique_id` = '%1':[]:", _playerID];
		_result = _key call server_hiveReadWrite;
		_status = _result select 0;

		if (_status == "CustomStreamStart") then {
			if ((_result select 1) > 0) then {
				_result 	= _key call server_hiveReadWrite;
				_inventory 	= call compile (_result select 0);
				_backpack 	= call compile (_result select 1);
				_model 		= call compile (_result select 2);
				diag_log ("PLAYER: CUSTOM INVENTORY LOADED: " + str(_inventory));
			};
		};
	};
	
	if (CheckModel) then {
		if (!(_model in ["SurvivorW2_DZ", "Survivor2_DZ", "Survivor3_DZ", "Survivor2_1DZ", "Survivor2_2DZ", "Survivor2_3DZ", "Survivor3_DZ", "Survivor4_DZ", "Survivor4_1DZ", "Survivor4_2DZ", "Survivor4_3DZ", "Survivor8_DZ", "Survivor8_1DZ", "Survivor8_2DZ", "Survivor8_3DZ", "Sniper1_DZ", "Soldier1_DZ", "Camo1_DZ", "Bandit1_DZ", "BanditW1_DZ", "Bandit_S_DZ", "Bandit1_1DZ", "Bandit1_2DZ", "Bandit1_3DZ", "Bandit1_3_1DZ", "Bandit1_3_2DZ", "Bandit2_1DZ", "Bandit2_2DZ", "Bandit2_3DZ", "Bandit2_4DZ", "Bandit2_5DZ", "Bandit3_1", "Hero1_1DZ", "Hero1_2DZ", "Hero1_3DZ", "Hero1_4DZ", "Hero1_5DZ", "Hero1_6DZ", "Hero1_7DZ", "Hero2_1DZ", "Hero2_2DZ", "Hero2_3DZ", "Hero2_4DZ", "Hero2_5DZ", "Hero3_1DZ", "Hero3_2DZ", "Hero3_3DZ", "Hero3_4DZ", "Hero3_5DZ", "Hero3_6DZ", "Hero2_10DZ", "Rocket_DZ", "CamoWinter_DZN", "CamoWinterW_DZN", "Sniper1W_DZN", "pzn_dz_Contractor1_BAF", "pzn_dz_Contractor2_BAF", "pzn_dz_Contractor3_BAF", "Net_DZ", "Camo2_DZ", "Camo3_DZ", "Camo4_DZ ", "Camo5_DZ", "Santa1_DZ", "Beard_DZ", "Dimitry_DZ", "Alexej_DZ", "Stanislav_DZ", "Czech_Norris", "SG_IRA_Soldier_CO_DZ"])) then {
			diag_log ("PLAYER: INVALID MODEL: " + str(_model));
			_model = "Survivor2_DZ";
		};
	};
} else {
	_model 		= _primary select 3;
	_hiveVer 	= _primary select 4;
	
	if (isNil "_model") then {
		_model = "Survivor2_DZ";
	} else {
		if (_model == "") then { _model = "Survivor2_DZ"; };
	};

	// Record initial inventory
	_config 	= (configFile >> "CfgSurvival" >> "Inventory" >> "Default");
	_mags 		= getArray (_config >> "magazines");
	_wpns 		= getArray (_config >> "weapons");
	_bcpk 		= getText (_config >> "backpack");
	_randomSpot = true;

	_key = format["CHILD:203:%1:%2:%3:", _charID, [_wpns, _mags], [_bcpk, [], []]];
	_key call server_hiveWrite;
};

diag_log ("PLAYER: LOGIN LOADED: " + _playerName + " [" + typeOf _playerObj + "]");

_isHiveOk = false;
if (_hiveVer >= dayz_hiveVersionNo) then { _isHiveOk = true; };

dayzPlayerLogin = [_charID, _inventory, _backpack, _survival, _isNew, dayz_versionNo, _model, _isHiveOk, _newPlayer];
if (worldName == "namalsk") then { dayzPlayerLogin = [_charID, _inventory, _backpack, _survival, _isNew, dayz_versionNo, getText(configFile >> "CfgMods" >> "nc_dzn" >> "version"), _model, _isHiveOk, _newPlayer]; };

(owner _playerObj) publicVariableClient "dayzPlayerLogin";