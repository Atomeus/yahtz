# Yahtz

Hi, I'm Ethan. I built this game for my wife, who grew up playing Yahtzee constantly on a little handheld gaming device.

I thought a Yahtzee inspired dice game would be an easy place to start with some AI assisted coding. It was something familiar we could play around with and gradually make our own.

This project was made primarily with AI assisted coding using Codex and skills from Matt Pocock. I supplied the ideas and made the decisions using interviews and grilling sessions. Codex used those guidelines to write the code.

So far, my wife has had a blast playing it, which is about the best outcome I could ask for!

## The game

Yahtz takes familiar Yahtzee combinations and puts them on a 5 × 5 board. You roll five dice each turn, keep the ones you like, and arrange them to build scoring combinations across both rows and columns. Five turns fill the board.

Each game session also gets a "joker" that changes how you score. It also has events to work toward during the game. The idea is to give more choices during the game to incentivize good placement. There are also local high scores and color themes to unlock along the way!

## Building it

I hadn't done much game development with AI assistants before this. Rather than jumping straight from a vague idea to code, I used skills to have the assistant interview me about what I wanted. We worked out the game's language, rules, and architecture, then captured the decisions in Markdown specs and plans.

That gave me something to review and change before implementation, and gave both of us something to reference later without explaining everything again. My role has mostly been shaping the game, making decisions, and trying out what the agent builds. I was surprised by how easy it was to get something that looked decent and played well.

The game is written in Lua using [Usagi](https://usagiengine.com/), a small game engine written in Rust. If you've used LÖVE, the Lua scripting approach may feel familiar. Cross-platform support matters to me: I develop on Windows, and my wife uses a Mac. The goal is a little game she can play on her own computer.

This is still in development. I'm chipping away at it when I have time, mostly because it's fun.

## Run it yourself

You'll need Git and Usagi. You don't need to install Rust or Lua separately to run the game.

Install Usagi using the command for your system from its [official installation instructions](https://usagiengine.com/#install):

**Windows (PowerShell)**

```powershell
irm https://usagiengine.com/install.ps1 | iex
```

**macOS / Linux**

```sh
curl -fsSL https://usagiengine.com/install.sh | sh
```

Open a new terminal after installation if `usagi` isn't found. Then copy this repository's clone URL from GitHub's **Code** button and run:

```sh
git clone <repository-url> Yahtz
cd Yahtz
usagi run .
```

Replace `<repository-url>` with the URL you copied. If you'd like to tinker, run `usagi dev .` instead to reload changes as you edit.

Choose **Play now**, pick a joker, and start rolling. You can play with a mouse, keyboard, or gamepad. Open the pause menu with Escape / Start to see or remap controls and adjust sound. Progress saves automatically after choosing a joker and confirming each turn.

## A little more detail

Run the tests with:

```sh
usagi run test.lua
```

The test window closes when all suites pass. If something fails, it stays open and prints the error in the console.

The logical canvas is 480 × 270 pixels. Screens live in `screens/`, game rules in `game/`, and shared controls and drawing helpers in `ui/`. `main.lua` handles the engine lifecycle, saves, and screen transitions. More detailed gameplay and implementation notes are in [docs/gameplay-notes.md](docs/gameplay-notes.md).

Background music is _Vaporware_ by The Cynic Project, released under CC0. See [music credits](music/CREDITS.txt).
