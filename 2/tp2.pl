:- include('povoamento.pl').

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

:- dynamic caminho/4.

% criarCaminho(1,183,791,C).

% Retorna a lista de elementos um Inicio e um Fim na mesma carreira.
criarCaminho(_,Fim,Fim,[Fim]).

criarCaminho(Carreira,Inicio,Fim,[Inicio|Caminho]):-
    paragem(Carreira,Id1, Inicio, _, _, _, _, _, _, _, _, _),
    Id2 is Id1 + 1,
    paragem(Carreira,Id2, Adjacente, _, _, _, _, _, _, _, _, _),
    criarCaminho(Carreira, Adjacente, Fim, Caminho).

% Predicado que cria um caminho entre duas paragens, se a carreira for igual.
caminho(Inicio,Fim,_,Caminho):-
    paragem(Carreira,_, Inicio, _, _, _, _, _, _, _, _, _),
    paragem(Carreira,_ ,Fim, _, _, _, _, _, _, _, _, _),
    criarCaminho(Carreira,Inicio,Fim,Caminho).