private ["_victim", "_attacker", "_weapon", "_distance", "_message"];

#include "\@dayzcc\addons\dayz_server_config.hpp"

_victim 	= _this select 0;
_attacker 	= _this select 1;

if (!isPlayer _victim || !isPlayer _attacker) exitWith {};
if ((name _victim) == (name _attacker)) exitWith {};

_weapon = weaponState _attacker;

if (_weapon select 0 == "Throw") then  {
	_weapon = _weapon select 3;
} else {
	_weapon = _weapon select 0;
};

_distance = _victim distance _attacker;

if (HitMsgs) then {
	diag_log format ["PLAYER: HIT: %1 was hit by %2 with %3 from %4m", _victim, _attacker, _weapon, _distance];
	
	if (HitMsgsIngame) then {
		_message = format ["%1 was hit by %2", _victim, _attacker];
		
		[nil, nil, rspawn, [_victim, _message], { (_this select 0) globalChat (_this select 1) }] call RE;
	};
};

_victim setVariable ["AttackedBy", _attacker, true];
_victim setVariable ["AttackedByName", (name _attacker), true];
_victim setVariable ["AttackedByWeapon", _weapon, true];
_victim setVariable ["AttackedFromDistance", _distance, true];