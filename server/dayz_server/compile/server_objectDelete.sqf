private["_id", "_uid", "_key"];

_id 	= _this select 0;
_uid 	= _this select 1;

if (isServer) then {
	if (parseNumber _id > 0) then {
		_key = format["CHILD:304:%1:", _id];
		_key call server_hiveWrite;
		diag_log format["HIVE: Deleted object with ID %1", _id];
	} else  {
		_key = format["CHILD:310:%1:", _uid];
		_key call server_hiveWrite;
		diag_log format["HIVE: Deleted object with UID %1", _uid];
	};
};