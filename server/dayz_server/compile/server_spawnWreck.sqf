private ["_position", "_num", "_config", "_itemType", "_itemChance", "_weights", "_index", "_iArray", "_crashModel", "_lootTable", "_lootDrops", "_frequency", "_variance", "_spawnChance", "_spawnMarker", "_spawnRadius", "_spawnFire", "_permanentFire", "_crashName"];

_crashModels 		= _this select 0;
_lootTables 		= _this select 1;
_lootDrops 			= _this select 2;
_frequency 			= _this select 3;
_variance 			= _this select 4;
_spawnChance 		= _this select 5;
_spawnMarker 		= _this select 6;
_spawnRadius 		= _this select 7;
_spawnFire 			= _this select 8;
_fadeFire 			= _this select 9;

diag_log ("DEBUG: Spawning logic for " + str(_crashModel) + " started");

while {true} do {
	private ["_timeAdjust", "_timeToSpawn", "_spawnRoll", "_crash", "_hasAdjustment", "_newHeight", "_adjustedPos"];
	
	// Get random model from input array
	_crashModel = _crashModels call BIS_fnc_selectRandom;
	
	// Get random loot type from input array
	_lootTable = _lootTables call BIS_fnc_selectRandom;

	_timeAdjust = round(random(_variance * 2) - _variance);
	_timeToSpawn = time + _frequency + _timeAdjust;

	while {time < _timeToSpawn} do {
		sleep 5;
	};

	if (random 1 <= _spawnChance) then {
		_position = [getMarkerPos _spawnMarker, 0, _spawnRadius, 10, 0, 2000, 0] call BIS_fnc_findSafePos;

		diag_log ("DEBUG: Spawning a " + str(_crashModel) + " at " + str(_position) + " with loot type " + str(_lootTable) + " and " + str(_lootDrops) + " total loot drops");

		// Create wreck vehicle object
		_crash = createVehicle [_crashModel, _position, [], 0, "CAN_COLLIDE"];
		// Randomize the direction the wreck is facing
		_crash setDir round(random 360);

		// Optional define on how high above the ground the object should spawn
		_config = configFile >> "CfgVehicles" >> _crashModel >> "heightAdjustment";
		_hasAdjustment = isNumber(_config);
		_newHeight = 0;
		if (_hasAdjustment) then { _newHeight = getNumber(_config); };
		_adjustedPos = [(_position select 0), (_position select 1), _newHeight];
		_crash setPos _adjustedPos;

		dayz_serverObjectMonitor set [count dayz_serverObjectMonitor, _crash];

		_crash setVariable ["ObjectID", 1, true];

		if (_spawnFire) then {
			["dayzFire", [_crash, 2, time, false, _fadeFire]] call broadcastRpcCallAll;
			_crash setvariable ["fadeFire", _fadeFire, true];
		};

		_num 			= _lootDrops;
		_itemTypes 		= [] + getArray (configFile >> "CfgBuildingLoot" >> _lootTable >> "itemType");
		_index 			= dayz_CBLCounts find (count _itemTypes);
		_weights 		= dayz_CBLChances select _index;
		_cntWeights 	= count _weights;

		for "_x" from 1 to _num do {
			_index = floor(random _cntWeights);
			_index = _weights select _index;
			_itemType = _itemTypes select _index;
			[_itemType select 0, _itemType select 1, _position, 5] call spawn_loot;

			_nearby = _position nearObjects ["ReammoBox", sizeOf(_crashModel)];
			{
				_x setVariable ["permaLoot", true];
			} forEach _nearBy;
		};
	};
};