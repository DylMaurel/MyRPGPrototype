# MyRPGPrototype

As the title of this repo suggests, this code establishes the foundation of a jrpg-style video game. This project is
coded completely in Lua with the LOVE2D game development framework. If someone wants to run this code, they must 
install LOVE2D.

I created this project in order to experiment with the challenging algorithms and design issues that come along with
video game programming. The goal of this project wasn't to create an original or entertaining game. Rather, I just
wanted to improve my programming skills.

Here's a summary of some notable features in the game:
- The player can move around a 2-D world.
- The player can press 'Enter' to start dialogue with an npc (this can include questions and responses).
- Walking in the game area below the starting area has a chance to trigger a combat state.
- Combat is turn-based, supporting two player-side entities and 1-4 enemy-side entities. Currently, combat is basic, with
entities only having a single attack, and damage calculations are simple and not left to chance.

