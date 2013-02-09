private ["_class", "_uid", "_charID", "_object", "_worldspace", "_key"];

_charID 		= _this select 0;
_object 		= _this select 1;
_worldspace 	= _this select 2;
_class 			= _this select 3;

if (!(_object isKindOf "Building")) exitWith { deleteVehicle _object; };

_uid = _worldspace call dayz_objectUID2;
_key = format ["CHILD:308:%1:%2:%3:%4:%5:", dayz_instance, _class, _charID, _worldspace, _uid];
_key call server_hiveWrite;
_object setVariable ["ObjectUID", _uid, true];

dayz_serverObjectMonitor set [count dayz_serverObjectMonitor, _object];