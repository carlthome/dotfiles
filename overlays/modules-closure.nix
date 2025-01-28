{ ... }:

final: prev: {
  makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
}
