/*
 * Author: SilentSpike
 * Handles UI initialisation and destruction
 *
 * Public: No
 */

#include "script_component.hpp"

params ["_init"];

// Close map
openMap [false,false];

// Close any open dialogs
// TODO: Could this be unnecessary? Might have adverse side effects in certain situations
while {dialog} do {
    closeDialog 0;
};

// Note that init and destroy intentionally happen in reverse order
// Init: Vars > Display > UI Stuff
// Destroy: UI Stuff > Display > Vars
if (_init) then {
    // UI visibility tracking
    GVAR(uiVisible) = true;
    GVAR(uiHelpVisible) = true;
    GVAR(uiMapVisible) = true;
    GVAR(uiWidgetVisible) = true;

    // RMB tracking is used for follow camera mode
    GVAR(holdingRMB) = false;

    // List type is used for list updates and interaction
    GVAR(uiListType) = LIST_ENTITIES;

    // Highlighted map object is used for click and drawing events
    GVAR(uiMapHighlighted) = objNull;

    // Holds the current list data
    GVAR(curList) = [];

    // Cache view distance and set spectator default
    GVAR(oldViewDistance) = viewDistance;
    setViewDistance DEFAULT_VIEW_DISTANCE;

    // Create the display
    MAIN_DISPLAY createDisplay QGVAR(display);

    // Set the initial camera mode (could be pre-set)
    [GVAR(camMode)] call FUNC(cam_setCameraMode);

    // Initially hide map
    [] call FUNC(ui_toggleMap);

    // Initially fade the list
    [true] call FUNC(ui_fadeList);

    // Select the right camera button initially
    // TODO

    // Update the focus info widget initially
    [] call FUNC(ui_updateWidget);

    // Periodically update list and focus widget
    GVAR(uiPFH) = [{
        if (GVAR(uiListType) == LIST_ENTITIES) then {
            [] call FUNC(ui_updateListEntities);
        } else {
            [] call FUNC(ui_updateListLocations);
        };

        [] call FUNC(ui_updateWidget);
    }, 5] call CBA_fnc_addPerFrameHandler;
} else {
    // Stop updating the list and focus widget
    [GVAR(uiPFH)] call CBA_fnc_removePerFrameHandler;

    // Destroy the display
    SPEC_DISPLAY closeDisplay 1;

    // Stop tracking everything
    GVAR(uiForced)          = nil;
    GVAR(uiVisible)         = nil;
    GVAR(uiHelpVisible)     = nil;
    GVAR(uiMapVisible)      = nil;
    GVAR(uiWidgetVisible)   = nil;
    GVAR(holdingRMB)        = nil;
    GVAR(uiListType)        = nil;
    GVAR(uiMapHighlighted)  = nil;
    GVAR(curList)           = nil;

    // Reset view distance
    setViewDistance GVAR(oldViewDistance);
    GVAR(oldViewDistance) = nil;

    // Ensure chat is shown again
    showChat true;
};
