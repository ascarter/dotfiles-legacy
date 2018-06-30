# Recipes

Recipes describe task for installing and uninstalling various forms of software. It is a flexible format using Yaml as the syntax. Task are declarative.

# Actions

Actions are in the `rakelib/actions` directory. Actions is a module that contains submodules as well. Each action takes an array of arguments directly from the recipe. This simple interface allows for adding numerous action definitons.

See each action for details.
