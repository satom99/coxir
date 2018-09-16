defmodule Coxir.Cache.Cache do
  @callback insert(cache :: Atom.t, data :: Tuple.t) :: Boolean.t
  @callback get(cache :: Atom.t, data :: Tuple.t) :: List.t
  @callback delete(cache :: Atom.t, data :: Tuple.t) :: Boolean.t
end
