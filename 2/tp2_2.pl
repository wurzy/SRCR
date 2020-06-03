:- include('povoamento2.pl').
:- include('adjacentes.pl').

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
%:- set_prolog_flag( unknown,fail ).

:- use_module(library(lists)).
:- use_module(library(statistics)).

% ################################################### ALGORITMO NÃO-INFORMADO ###################################################
adjacentes(X,Y) :- adjacente(X,Y) ; adjacente(Y,X).

caminho2(Inicio,Fim,Caminho) :-
    bfs([[Inicio]],Fim, CaminhoAux),
    reverse(CaminhoAux,Caminho). 

% breadthfirst([Path1, Path2, ...], Solution). Solution is an extension to a goal of one of the paths.
  
bfs([[Fim|Caminho]|_],Fim, [Fim|Caminho]).

% If not, then extend this path by all possible edges, put these new paths on theend of the queue (Paths1) to check, and dobreadthfirst on this new collection ofpaths, Paths1:
bfs([Caminho1|Caminhos], Fim, Caminho) :-
    extende(Caminho1, NovosCaminhos),
    append(Caminhos, NovosCaminhos, Caminhos1),
    bfs(Caminhos1, Fim, Caminho).

% extend([N|Rest], NewPaths).Extend the path [N|Rest] using all edges through N that are not already on the path.This produces a list NewPaths.
% Predicado que extende 
extende([Paragem|Caminho], NovosCaminhos) :-
    findall([Paragem2, Paragem|Caminho],(adjacentes(Paragem, Paragem2),\+ memberchk(Paragem2,[Paragem|Caminho])),NovosCaminhos),!.

extende(_,[]).
  
% ###############################################################################################################################