private ["_town", "_spot", "_buildings", "_list", "_size", "_numZeds", "_impt", "_position", "_buildings", "_tbuildings", "_numGroups", "_building", "_type"];

_town 		= _this;
_type 		= type _town;
_spot 		= objNull;
_buildings 	= [];
_list 		= [];
_numZeds 	= 2;
_impt 		= (importance _town);
_size 		= 50;

switch (_type) do {
	default {
		_numZeds = 3;
		_size = 40 * _impt;
	};
	case "NameCity": {
		_numZeds = 6;
		_size = 80 * _impt;
	};
	case "NameCityCapital": {
		_numZeds = 10;
		_size = 120 * _impt;
	};
};

_position 	= position _town;
_buildings 	= nearestObjects [_position, ["Building"], _size];
_tbuildings = count _buildings;
_numGroups 	= 0;
_i 			= 0;

/*
_markerstr	= createMarker["markername_" + (text _town),_position];
_markerstr setMarkerShape "ELLIPSE";
_markerstr setMarkerSize [_size, _size];
*/

_trigger = createTrigger ["EmptyDetector", _position];
_trigger setTriggerArea [dayz_zSpawnDistance, dayz_zSpawnDistance, 0, false];
_trigger setTriggerActivation ["WEST", "NOT PRESENT", false];
_trigger setTriggerStatements["this", format ["_id = [%1,%2,'%3'] spawn server_townDeZombify;", _position, _size, _type], ""];
_trigger setTriggerTimeout [60 * 10, 60 * 10, 60 * 10, true];

while {_numGroups < _numZeds and _i < _tbuildings} do {
	_building = _buildings call BIS_fnc_selectRandom;
	if (!isNull _building) then {
		_list = _building nearRoads 20;
		if (count _list > 0) then {
			_spot = _list call BIS_fnc_selectRandom;
			_nearMen = (position _spot) nearEntities [["Man"], 50];
			if (!isNull _spot and (count _nearMen == 0)) then {
				/*
				_marker = createMarker [(text _town) + "Marker2" + str(_i), position _spot];
				_marker setMarkerShape "ICON";
				_marker setMarkerType "DOT";
				_marker setMarkerColor "ColorBlue";
				_marker setMarkerText str(_i);
				*/
				_numGroups = _numGroups + 1;
				(position _spot) spawn dayz_spawnZombies;
			};
		};
	};
	_i = _i + 1;
	sleep 0.1;
};