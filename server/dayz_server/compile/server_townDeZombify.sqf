private ["_position", "_size", "_loot", "_zeds", "_groups", "_group"];

_position 	= _this select 0;
_size 		= _this select 1;
_type 		= _this select 2;
_town 		= nearestLocation [_position, _type];
_loot 		= nearestObjects [_position, ["WeaponHolder"], _size];
_zeds 		= _position nearEntities ["zZombie_Base",_size];
_groups 	= [];

{ deleteVehicle _x; } forEach _loot;

{
	if (!(isNull _group)) then {
		_group = group _x;
		if (!(_group in _groups)) then {_groups set [count _groups,_group];};
		_x setDamage 1;
	};
} forEach _zeds;

diag_log ("CLEANUP: Town Dezombified");

dayz_zombifiedTowns = dayz_zombifiedTowns - [_town];