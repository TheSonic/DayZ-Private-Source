private ["_characterID", "_minutes", "_newObject", "_playerID", "_key", "_playerName", "_playerID", "_myGroup", "_group", "_victim", "_killer", "_weapon", "_message", "_distance","_loc_message","_victimName","_killerName"];

#include "\@dayzcc\addons\dayz_server_config.hpp"

_victim removeAllEventHandlers "MPHit";

_characterID 	= _this select 0;
_minutes 		= _this select 1;
_newObject 		= _this select 2;
_playerID 		= _this select 3;
_playerName 	= _this select 4;
_victim 		= _this select 2;
_victimName 	= _victim getVariable ["bodyName", "nil"];
_killer 		= _victim getVariable ["AttackedBy", "nil"];
_killerName 	= _victim getVariable ["AttackedByName", "nil"];

if (KillMsgs) then {
	if (_killerName != "nil") then
	{
		_weapon = _victim getVariable ["AttackedByWeapon", "nil"];
		_distance = _victim getVariable ["AttackedFromDistance", "nil"];

		if (_victimName == _killerName) then 
		{
			_message = format ["%1 killed himself", _victimName];
			_loc_message = format ["PLAYER: KILL: %1 killed himself", _victimName];
		}
		else 
		{
			//_message = format ["%1 was killed by %2 with weapon %3", _victimName, _killerName, _weapon];
			_message = format ["%1 was killed by %2", _victimName, _killerName];
			_loc_message = format ["PLAYER: KILL: %1 was killed by %2 with weapon %3 from %4m", _victimName, _killerName, _weapon, _distance];
		};

		diag_log _loc_message;
		
		if (KillMsgsIngame) then {
			[nil, nil, rspawn, [_killer, _message], { (_this select 0) globalChat (_this select 1) }] call RE;
		};

		// Cleanup
		_victim setVariable ["AttackedBy", "nil", true];
		_victim setVariable ["AttackedByName", "nil", true];
		_victim setVariable ["AttackedByWeapon", "nil", true];
		_victim setVariable ["AttackedFromDistance", "nil", true];
	};
};

dayz_disco = dayz_disco - [_playerID];
_newObject setVariable ["processedDeath", time];

if (typeName _minutes == "STRING") then {
	_minutes = parseNumber _minutes;
};

if (_characterID != "0") then {
	_key = format ["CHILD:202:%1:%2:", _characterID, _minutes];
	_key call server_hiveWrite;
} else {
	deleteVehicle _newObject;
};