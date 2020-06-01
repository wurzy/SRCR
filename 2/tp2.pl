:- include('povoamento.pl').

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

:- use_module(library(lists)).

% criarCaminho(1,183,791,C).
% carreirasAdjacentesCarreira(1,Lista); true.
% paragem\([0-9]+, [0-9]+, 183,              183: 1,7,10,12,13,15

% ------------------------------------------------ PREDICADOS AUXILIARES -------------------------------------------------------------
%-----------------------------------------------------------------------------
% Retorna a lista de carreiras a que uma paragem pertence.
carreirasAdjacentes(Paragem,Lista):-
    findall(Carreira, (paragem(Carreira,_,Paragem, _, _, _, _, _, _, _, _, _)),
    Lista).

%-----------------------------------------------------------------------------
% Retorna a lista de carreiras adjacentes a uma determinada carreira.
carreirasAdjacentesCarreiraAux([], []).

carreirasAdjacentesCarreiraAux([Paragem|Paragens],[Lista1|Lista]):-
    carreirasAdjacentes(Paragem,Lista1),
    carreirasAdjacentesCarreiraAux(Paragens,Lista).

carreirasAdjacentesCarreira(Carreira, Lista):-
    findall(Paragem, (paragem(Carreira,_,Paragem, _, _, _, _, _, _, _, _, _)),Paragens),
    carreirasAdjacentesCarreiraAux(Paragens,Lista).

%-----------------------------------------------------------------------------
% Retorna a lista de elementos um Inicio e um Fim na mesma carreira.
criarCaminho(_,Fim,Fim,[Fim]):- !.

criarCaminho(Carreira,Inicio,Fim,[Inicio|Caminho]):-
    paragem(Carreira,Id1, Inicio, _, _, _, _, _, _, _, _, _),
    Id2 is Id1 + 1,
    paragem(Carreira,Id2, Adjacente, _, _, _, _, _, _, _, _, _),
    criarCaminho(Carreira, Adjacente, Fim, Caminho).

%-----------------------------------------------------------------------------
% Verifica se um elemento duma lista pertence a outra lista
verificaMatriz([], _):- false.

verificaMatriz([L1|_], Matriz):-
    verificaLista(L1,Matriz), !.

verificaMatriz([_|L2], Matriz):-
    verificaMatriz(L2,Matriz).

%-----------------------------------------------------------------------------
% Verifica se um elemento duma matriz pertence a outra
verificaMatriz([], _):- false.

verificaMatriz([L1|_], Matriz):-
    verificaLista(L1,Matriz), !.

verificaMatriz([_|L2], Matriz):-
    verificaMatriz(L2,Matriz).
% ------------------------------------------------------ RESOLUÇÃO -------------------------------------------------------------------

%-----------------------------------------------------------------------------
% Predicado que cria um caminho entre duas paragens, se a carreira for igual.
caminho(Inicio,Fim,_,Caminho):-
    paragem(Carreira,_, Inicio, _, _, _, _, _, _, _, _, _),
    paragem(Carreira,_ ,Fim, _, _, _, _, _, _, _, _, _),
    criarCaminho(Carreira,Inicio,Fim,Caminho),
    !.
%-----------------------------------------------------------------------------

caminho(Inicio,Fim,Historico,Caminho):-
    paragem(Carreira1,_, Inicio, _, _, _, _, _, _, _, _, _),
    paragem(Carreira2,_ ,Fim, _, _, _, _, _, _, _, _, _),
    carreirasAdjacentes(Carreira1,Adjs1),
    carreirasAdjacentes(Carreira2,Adjs2)