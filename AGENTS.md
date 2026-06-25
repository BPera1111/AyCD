# Agent Instructions

## Architecture & Domain
This is a MATLAB / Simulink / Stateflow project simulating an STS Crane (Grúa STS) combined with a Python interface for virtual controller emulation.

## Execution & Initialization
- **Mandatory Initialization:** Before simulating or compiling any `.slx` model (e.g., `nivel_1.slx`), you **MUST** run the corresponding parameter script in MATLAB (e.g., `simulink/init_plant_parameters.m` or `guia/parametros.m`). Models will fail to run if workspace variables (like `i_lista`, `Hc`, `Wc`) are missing.
- **Python Joystick:** `joystick.py` is the entrypoint for input emulation and requires `pygame` and `vgamepad`.

## Modifying Stateflow Models (.slx)
The repository modifies Simulink `.slx` files (which are ZIP archives) in two ways: via MATLAB API scripts (`agregar_modo_auto.m`) and direct XML injection via Python (`crear_nivel1_claude.py`).

**CRITICAL QUIRKS for XML Injection:**
If you need to programmatically edit Stateflow XML inside an `.slx` file, you must adhere to the following undocumented Simulink constraints, or the model will crash/abort on load:
- **Order in `<Children>`:** Inside any state's `<Children>` block, all `<state>` elements **MUST** precede `<transition>` and `<junction>` elements.
- **Transitions:** Must be defined inside the `<Children>` block of their parent state.
- **Data Variables:** Must be defined at the chart level's `<Children>` block, *after* all states.
- **Subviewer ID:** The `<P Name="subviewer">` property for states and transitions refers to the Chart ID (e.g., `180`), not the immediate parent state ID.