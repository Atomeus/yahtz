# Yahtz

A small spatial dice game for Usagi 1.2.0. Run `usagi dev` from this directory (or `usagi run .`). The logical canvas is 480 x 270 pixels.

Choose a joker, then fill the 5 x 5 board over five turns. Each turn starts with five dice and allows two rerolls. Click dice to hold them, then choose **Place dice** to end rolling permanently. Select an unplaced die and an empty board cell. The next unplaced die is selected automatically. Click a die placed this turn to pick it up again. Earlier turns stay fixed.

Two single-use **Adjustments** change the selected unplaced die by one within 1..6 during placement. **Undo** reverses placements and Adjustments before confirmation. Confirm after placing all five dice. The preview shows every newly completed line, joker bonus and resulting total; **Prev / Next** pages through longer previews.

Mouse controls cover every action. Keyboard and gamepad direction actions move the highlighted focus between dice, cells and buttons. Action 1 activates the focused control, action 2 undoes, and action 3 speeds through score resolution. The current mapped buttons appear at the bottom of the table. Open the built-in pause menu with Escape / Start to inspect or remap controls. No gameplay controls use raw keyboard keys.

Each complete row and column pays once, using its highest-value qualifying category. Straights ignore spatial order. Score events appear in sequence; **Speed through** skips the wait, while **Earlier / Later** lets you inspect the complete event history on the results screen. **Play again** begins a fresh board and joker choice.

Use **Motion** to switch between short dice bounces and reduced motion. Both preserve all scoring information. Dry dice clacks and rising score tones use generated WAV assets; sound volume is available in the pause menu.

The game saves automatically when choosing a joker and confirming a turn. Returning during an unfinished turn restores its original dice and consumables, discarding unconfirmed rerolls, placements and Adjustments. Repeating the same actions produces the same dice. A completed board resumes at its results screen. Motion preference and score history are saved too.

Run the domain tests with `python tools/test.py` (requires `lupa`) if that test runner is present in your checkout.
