// Keydown Function by Pwnoz0r, VS_Shiva and Crosire

fnc_keyDown = 
{
	private ["_handled", "_dikCode", "_shiftKey", "_ctrlKey", "_altKey"];

	_dikCode 	= _this select 1;
	_shiftKey 	= _this select 2;
	_ctrlKey 	= _this select 3;
	_altKey 	= _this select 4;
	_handled 	= false;

	if (!_ctrlKey && !_shiftKey && !_altKey) then
	{
		if (_dikCode == 28) then
		{
			handle = [] execVM "gcam\gcam.sqf";
			_handled = true;
		};
	};
	
	_handled;
};