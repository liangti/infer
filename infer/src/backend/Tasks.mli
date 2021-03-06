(*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open! IStd

type ('a, 'b) doer = 'a -> 'b option

val run_sequentially : f:('a, 'b) doer -> 'a list -> unit
(** Run the tasks sequentially *)

val fork_protect : f:('a -> 'b) -> 'a -> 'b
(** does the bookkeeping necessary to safely execute an infer function [f] after a call to fork(2) *)

(** A runner accepts new tasks repeatedly for parallel execution *)
module Runner : sig
  type ('work, 'final, 'result) t

  val create :
       jobs:int
    -> f:('work, 'result) doer
    -> child_epilogue:(unit -> 'final)
    -> tasks:(unit -> ('work, 'result) ProcessPool.TaskGenerator.t)
    -> ('work, 'final, 'result) t
  (** Create a runner running [jobs] jobs in parallel *)

  val run : (_, 'final, _) t -> 'final option Array.t
  (** Start the given tasks with the runner and wait until completion *)
end
