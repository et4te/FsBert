#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------
abstract ErlangTerm

abstract ErlSmallInteger <: ErlangTerm
abstract ErlInteger      <: ErlangTerm
abstract ErlFloat        <: ErlangTerm
abstract ErlAtom         <: ErlangTerm
abstract ErlSmallTuple   <: ErlangTerm
abstract ErlLargeTuple   <: ErlangTerm
abstract ErlNil          <: ErlangTerm
abstract ErlString       <: ErlangTerm
abstract ErlList         <: ErlangTerm
abstract ErlBinary       <: ErlangTerm
abstract ErlSmallBigInt  <: ErlangTerm
abstract ErlLargeBigInt  <: ErlangTerm
