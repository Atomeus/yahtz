# Yahtz

A small spatial dice game for Usagi 1.2.0. Run `usagi dev` from this directory (or `usagi run .`). The logical canvas is 480 x 270 pixels.

The main menu shows the five highest local scores. Choose **Play now**, choose a joker, then fill the 5 x 5 board over five turns. Each turn starts with five dice and allows two rerolls. Click dice to hold them, then choose **Place dice** to end rolling early; the final roll enters placement automatically. Select an unplaced die and an empty board cell. The next unplaced die is selected automatically. Click a die placed this turn to pick it up again. Earlier turns stay fixed. The tray marks dice READY or PLACED during placement; placed dice appear as dark silhouettes.

Two single-use **Adjustments** change the selected unplaced die by one within 1..6 during placement. **Undo** reverses placements and Adjustments before confirmation. Confirm after placing all five dice. The preview shows every newly completed line, joker bonus and resulting total; **Prev / Next** pages through longer previews.

Mouse controls cover every action. Keyboard and gamepad direction actions move the highlighted focus between dice, cells and buttons. Action 1 activates the focused control, action 2 undoes, and action 3 speeds through score resolution. The current mapped buttons appear at the bottom of the table. Open the built-in pause menu with Escape / Start to inspect or remap controls. No gameplay controls use raw keyboard keys.

The board labels rows R1?R5 and columns C1?C5. Ledger entries spell out the matching Row or Col, category or joker bonus, and points; new entries also record their turn (T1?T5). During scoring, the matching board label is highlighted. Each complete row and column pays once, using its highest-value qualifying category. Straights ignore spatial order. Score events appear in sequence and count the displayed total up as each line and bonus pays; **Speed through** skips the wait, while **Earlier / Later** lets you inspect the complete event history on the results screen. **Main menu** returns to the leaderboard; **Play now** begins a fresh board and joker choice. Existing boards remain available through **Continue** or **View results**.

Use **Motion** on the main menu to switch between short dice bounces and reduced motion. Both preserve all scoring information. Dry dice clacks and rising score tones use generated WAV assets; sound volume is available in the pause menu.

The game saves automatically when choosing a joker and confirming a turn. Returning during an unfinished turn restores its original dice and consumables, discarding unconfirmed rerolls, placements and Adjustments. Repeating the same actions produces the same dice. A completed board resumes at its results screen. Motion preference and score history are saved too.

Run all tests with `usagi run test.lua`. It prints each result and closes automatically when all suites pass. On failure, the window stays open and the console shows the error. No Python or separate Lua installation is required.

Completed boards that qualify for the top five offer optional name entry using an on-screen keyboard, accessible with mouse or remappable direction/select actions. Names allow up to 12 letters, digits, or spaces; a blank name saves as PLAYER. Save score records the play once, or Skip dismisses the offer. Scores persist across boards and restarts. Equal scores keep the earlier entry first; when five entries exist, a new score must beat fifth place.

## Code organization

The engine entry point coordinates initialization, persistence, and screen transitions.
Screen behavior and rendering live together in screens/main_menu.lua,
screens/name_entry.lua, screens/joker_selection.lua, and screens/game.lua.
Shared button activation and directional focus live in ui/controls.lua; drawing
and sound helpers live in ui/drawing.lua. Joker presentation data lives in
game/jokers.lua; shared row/column ID decoding lives in game/lines.lua. Scoring, game sessions, and high-score ranking remain separate
domain modules.

Run `usagi run test.lua` to execute the domain suites and the application
lifecycle integration test. The latter simulates input and persistence through
the engine callbacks; visual rendering and physical gamepad behavior still
require a check in Usagi.

## Color themes

Choose **Colors** from the main menu to select Classic Table, Midnight,
Plum Velvet, or Golden Hour. All four are available immediately. The preview
shows the selected table, dice, and score colors; selection saves automatically.
The choice applies across menus, gameplay, name entry, and score animation.
Older or unknown saved theme IDs fall back to Classic.

Themes use only the engine's default palette, with dark surfaces, readable
text, dark pips on light dice, and visible focus outlines. Contrast tests
verify text and pip pairs at 4.5:1 or higher and control borders/focus at
3:1 or higher against the default palette. Future score-based unlocks are
tracked separately; this proof of concept has no locked themes.

During a board, use **Colors** in the header, then **Back to game**.
Changing colors preserves held dice, rerolls, unconfirmed placements,
Adjustments, undo history, and the selected die. Scoring animation pauses
while the Colors screen is open and continues when returning. Theme choices
still save using the existing turn-boundary persistence rules.

The in-game header aligns **Colors** with the clickable active joker name.
Select the joker name to read its rules and an example, then **Back to game**
(or the undo/back action) to close. Scoring pauses while reading. The Motion
preference is available on the main menu, keeping gameplay controls focused
on the board.

On the placement-feedback experiment, hover an empty cell with a selected READY
die, or move directional focus onto it, to outline its row and column. **IF PLACED**
shows the hypothetical completed lines and resulting total, including dice already
arranged this turn. The question-mark die is tentative; selecting the cell places
it. Moving keyboard/gamepad focus takes over from a stationary mouse pointer.

Confirmed lines sweep across rows or down columns, then send their points toward
the total. Each line pays its base category before its joker bonus; the joker name
is outlined during its contribution. Thrifty has a separate unused-roll label.
A row-and-column payout gets a shared announcement while each contribution resolves
separately. Reduced motion uses static cell outlines, payout labels, and immediate
per-event totals. **Speed through** still finishes the entire sequence immediately.

Background music is Vaporware by The Cynic Project (CC0; see music/CREDITS.txt).
It loops continuously across screens at 16% track volume, gently ducking to 8%
during gameplay score payouts. The pause menu music slider adjusts or mutes it
independently of sound effects.

Choose **Credits** at the bottom right of the main menu for the music attribution,
CC0 license, and engine credit. Select **Main menu** or use the back action to return.

Menu and labeled control activation plays a short generated click, including
keyboard/gamepad selection. Disabled controls stay silent; board cells and dice
keep their existing gameplay sounds. The pause-menu SFX slider controls both.
