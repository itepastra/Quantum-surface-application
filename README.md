# About

Qubit Quilt is an application to explore surface codes and other Quantum Error Correction concepts.

# Installation

The easiest way to play with Qubit Quilt is to go to [our website](https://qubit-quilt.nl).
If you want higher performance, or to run the application locally, you need to get an executable.
These may or may not be found somewhere on the website, once we add them.

# Development

To help develop the game you need a custom godot build, the source of which you can download [here](https://github.com/itepastra/godot).
This custom build is necessary because it contains the custom module `qec`.
Once you've downloaded the source, you should follow the instructions for compiling godot from source found [here](https://docs.godotengine.org/en/stable/engine_details/development/compiling/index.html).
After you have this compiled version of godot, use it to open the project `qubit-quilt/project.godot` and you should be able to view everything.
While we don't promise to continue development on this repository, we do welcome PR's and will review them.

## Nix

The other way to develop is to use the nix package manager on a linux device, and then you can use `nix develop` from inside the cloned repository to enter a shell with the correct godot version and use `nix build` to compile the site completely.
