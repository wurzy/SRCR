:- include('povoamento.pl').

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

:- dynamic caminho/4.

% criarCaminho(1,183,791,C).

criarCaminho(_,Fim,Fim,[Fim]).

criarCaminho(Paragem1,Inicio,Fim,[Inicio|Caminho]):-
    paragem(Paragem1,Id1, Inicio, _, _, _, _, _, _, _, _, _),
    Id2 is Id1 + 1,
    paragem(Paragem1,Id2, Adjacente, _, _, _, _, _, _, _, _, _),
    criarCaminho(Paragem1, Adjacente, Fim, Caminho).

caminho(Inicio,Fim,_,Caminho):-
    paragem(Paragem1,_, Inicio, _, _, _, _, _, _, _, _, _),
    paragem(Paragem1,_ ,Fim, _, _, _, _, _, _, _, _, _),
    criarCaminho(Paragem1,Inicio,Fim,Caminho).