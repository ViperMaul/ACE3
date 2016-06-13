/*
 * Author: Ir0n1E
 * put weapon into gunbag
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Target <OBJECT>
 *
 * Return Value:
 * Nothing
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit", "_target"];

private _weapon = primaryWeapon _unit;
private _gunbag = backpackContainer _target;

private _state = [_unit, _weapon] call EFUNC(common,getWeaponState);

/*
 * example return value _state
 * [["","","optic_Aco",""],["arifle_MX_GL_ACO_F","GL_3GL_F"],["30Rnd_65x39_caseless_mag","1Rnd_HE_Grenade_shell"],[30,1]]
 */

_state params ["_items", "", "_magazines", "_ammo"];

private _mass = [_weapon, _items, _magazines] call FUNC(calculateMass);

{
    _magazines set [_forEachIndex, [_x, _ammo select _forEachIndex]];
} forEach _magazines;

_unit removeWeapon _weapon;

// add virtual load
[_target, _gunbag, _mass] call EFUNC(movement,addLoadToUnitContainer);
_gunbag setVariable [QGVAR(gunbagWeapon), [_weapon, _items, _magazines], true];

// play sound
if (!isNil "ACE_Backpacks") then {
    [_target, _gunbag] call EFUNC(backpacks,backpackOpened);
};