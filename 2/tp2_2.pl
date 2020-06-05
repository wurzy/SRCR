:- include('povoamento.pl').
:- include('adjacentes.pl').

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
%:- set_prolog_flag( unknown,fail ).

:- use_module(library(lists)).
:- use_module(library(statistics)).

%---------------------------------------------------------------------------------
% Predicado que verifica se 2 paragens são adjacentes
adjacentes(X,Y) :- adjacente(X,Y) ; adjacente(Y,X).

%---------------------------------------------------------------------------------

% 1. Calcular um trajeto entre dois pontos;

% ################################################### ALGORITMO NÃO-INFORMADO ###################################################

%---------------------------------------------------------------------------------
% Realiza-se a invocação de um breadth-first para resolver o problema.
caminho2(Inicio,Fim,Caminho) :-
    bfs([[Inicio]],Fim, CaminhoAux),
    reverse(CaminhoAux,Caminho). 

%---------------------------------------------------------------------------------
% Se estiver na paragem final termina. 
bfs([[Fim|Caminho]|_],Fim, [Fim|Caminho]).

%---------------------------------------------------------------------------------
% Se não, extende o caminho atual por todas as paragens que o conseguem fazer e coloca na fila de espera para serem verificados, reiterando pelos novos caminhos encontrados.
bfs([Caminho1|Caminhos], Fim, Caminho) :-
    extende(Caminho1, NovosCaminhos),
    append(Caminhos, NovosCaminhos, Caminhos1),
    bfs(Caminhos1, Fim, Caminho).

%---------------------------------------------------------------------------------
% Predicado que extende o caminho utilizando todas as paragens que não estejam dentro do caminho.
extende([Paragem|Caminho], NovosCaminhos) :-
    findall([Paragem2, Paragem|Caminho],(adjacentes(Paragem, Paragem2),\+ memberchk(Paragem2,[Paragem|Caminho])),NovosCaminhos),!.

extende(_,[]).
%---------------------------------------------------------------------------------
  
% ###############################################################################################################################

% ---------------------------------------------------- SUB-ALINEAS --------------------------------------------------------------

% 2. Selecionar apenas algumas das operadoras de transporte para um determinado percurso.
caminho2_2(Inicio,Fim,Operadoras,Caminho) :-
    paragem(_,_ ,Inicio, _, _, _, _, _, Op1, _, _, _),
    paragem(_,_ ,Fim, _, _, _, _, _, Op2, _, _, _),
    member(Op1, Operadoras),
    member(Op2, Operadoras),
    bfs2([[Inicio]],Fim, Operadoras,CaminhoAux),
    reverse(CaminhoAux,Caminho). 

%---------------------------------------------------------------------------------
% Se estiver na paragem final termina. 
bfs2([[Fim|Caminho]|_],Fim,_,[Fim|Caminho]).

%---------------------------------------------------------------------------------
% Se não, extende o caminho atual por todas as paragens que o conseguem fazer e coloca na fila de espera para serem verificados, reiterando pelos novos caminhos encontrados.
bfs2([Caminho1|Caminhos], Fim, Operadoras, Caminho) :-
    extende2(Caminho1, Operadoras, NovosCaminhos),
    append(Caminhos, NovosCaminhos, Caminhos1),
    bfs2(Caminhos1, Fim, Operadoras, Caminho).

%---------------------------------------------------------------------------------
% Predicado que extende o caminho utilizando todas as paragens que não estejam dentro do caminho, e que pertençam apenas às operadoras escolhidas.
extende2([Paragem|Caminho], Operadoras, NovosCaminhos) :-
    findall([Paragem2, Paragem|Caminho],(adjacentes(Paragem, Paragem2),\+ memberchk(Paragem2,[Paragem|Caminho]),
    paragem(_,_ ,Paragem2, _, _, _, _, _, Op1, _, _, _), member(Op1,Operadoras)),NovosCaminhos),!.

extende2(_,_,[]).
%---------------------------------------------------------------------------------

% 3. Excluir um ou mais operadores de transporte para o percurso;
caminho2_3(Inicio,Fim,Operadoras,Caminho) :-
    paragem(_,_ ,Inicio, _, _, _, _, _, Op1, _, _, _),
    paragem(_,_ ,Fim, _, _, _, _, _, Op2, _, _, _),
    \+ memberchk(Op1, Operadoras),
    \+ memberchk(Op2, Operadoras),
    bfs3([[Inicio]],Fim, Operadoras,CaminhoAux),
    reverse(CaminhoAux,Caminho). 

%---------------------------------------------------------------------------------
% Se estiver na paragem final termina. 
bfs3([[Fim|Caminho]|_],Fim,_,[Fim|Caminho]).

%---------------------------------------------------------------------------------
% Se não, extende o caminho atual por todas as paragens que o conseguem fazer e coloca na fila de espera para serem verificados, reiterando pelos novos caminhos encontrados.
bfs3([Caminho1|Caminhos], Fim, Operadoras, Caminho) :-
    extende3(Caminho1, Operadoras, NovosCaminhos),
    append(Caminhos, NovosCaminhos, Caminhos1),
    bfs3(Caminhos1, Fim, Operadoras, Caminho).
%---------------------------------------------------------------------------------
% Predicado que extende o caminho utilizando todas as paragens que não estejam dentro do caminho, e que pertençam apenas às operadoras escolhidas.
extende3([Paragem|Caminho], Operadoras, NovosCaminhos) :-
    findall([Paragem2, Paragem|Caminho],(adjacentes(Paragem, Paragem2),\+ memberchk(Paragem2,[Paragem|Caminho]),
    paragem(_,_ ,Paragem2, _, _, _, _, _, Op1, _, _, _),\+ memberchk(Op1, Operadoras)),NovosCaminhos),!.

extende3(_,_,[]).
%---------------------------------------------------------------------------------

% 4. Identificar quais as paragens com o maior número de carreiras num determinado percurso.

% Retorna o numero de carreiras cuja paragem está localizada
carreiras(Paragem,Total):-
    findall(Carreira, (paragem(Carreira,_,Paragem, _, _, _, _, _, _, _, _, _)),
    Lista),
    length(Lista,Total).

% Verifica para todas as paragens qual aquela que pertence ao maior número de carreiras e retorna-o.
calculaMax(T,Max):-
    maplist(carreiras, T, MaxAux),
    max_list(MaxAux, Max).
    
caminho2_4(Inicio,Fim,Maior) :-
    caminho2(Inicio,Fim,Caminho),
    calculaMax(Caminho,Maior).

% 5. Escolher o menor percurso (usando critério menor número de paragens).
% Predicado que calcula qual a menor lista num conjunto de listas.
lengths([],[]).
lengths([H|T], [LH|LengthsT]) :-
    length(H, LH),
    lengths(T, LengthsT).

tamanhoMenor(ListOfLists, Min) :-
    lengths(ListOfLists, Lengths),
    min_list(Lengths, Min).

menorLista(ListOfLists, Min) :-
    tamanhoMenor(ListOfLists, Len),
    member(Min, ListOfLists),
    length(Min, Len).

% -------------------------------------------------------------------------------------
menorCaminhoParagens(Inicio,Fim,Caminho):-
    findall(R,(caminho2(Inicio,Fim,R)),L),
    menorLista(L,Caminho).

% -------------------------------------------------------------------------------------
% 6. Escolher o percurso mais rápido (usando critério da distância).
% -------------------------------------------------------------------------------------
% Predicado que calcula a distancia euclideana entre 2 pontos 
d([P|Ps], [Q|Qs], D) :-
    soma_dif_sq(Ps, Qs, (P-Q)^2, R),
    D is sqrt(R).

soma_dif_sq([], [], V, V).
soma_dif_sq([P|Ps], [Q|Qs], V0, V+V0) :-
    soma_dif_sq(Ps, Qs, (P-Q)^2, V).

% -------------------------------------------------------------------------------------
% Predicado que guarda a lista de coordenadas de todas as paragens de um caminho
caminho2ListaPontos([],[]).

caminho2ListaPontos([H|T], [[P1,P2]|R]):-
    paragem(_,_ ,H, P1, P2, _, _, _, _, _, _, _),
    caminho2ListaPontos(T,R),
    !.

distCaminho(_,[],0).

distCaminho(Atual,[H|T],R):-
    d(Atual,H,Soma),
    distCaminho(H,T,Soma2),
    R is Soma + Soma2.

% -------------------------------------------------------------------------------------
% Predicado que calcula qual a menor lista num conjunto de listas.
dists([],[]).
dists([[[H1,H2]|R]|T], [LH|Dists]) :-
    distCaminho([H1,H2],[[H1,H2]|R],LH),
    dists(T, Dists).

distMenor(ListOfLists, Min) :-
    dists(ListOfLists, Lengths),
    min_list(Lengths, Min).

menorDistLista([[[H1,H2]|R]|T],[[H3,H4]|R2]) :-
    distMenor([[[H1,H2]|R]|T], Len),
    member([[H3,H4]|R2],[[[H1,H2]|R]|T]),
    distCaminho([H3,H4],[[H3,H4]|R2],Len).

% -------------------------------------------------------------------------------------
menorCaminhoDist(Inicio,Fim,Caminho):-
    findall(R,(caminho2(Inicio,Fim,R)),L),
    maplist(caminho2ListaPontos, L, LPontos),
    menorDistLista(LPontos,Pontos),
    member(Caminho,L),
    caminho2ListaPontos(Caminho,Pontos).

% -------------------------------------------------------------------------------------

% 7. Escolher o percurso que passe apenas por abrigos com publicidade.
caminho2_7(Inicio,Fim,Caminho) :-
    paragem(_,_ ,Inicio, _, _, _, _, 'Yes', _, _, _, _),
    paragem(_,_ ,Fim, _, _, _, _, 'Yes', _, _, _, _),
    bfs7([[Inicio]],Fim,CaminhoAux),
    reverse(CaminhoAux,Caminho). 

%---------------------------------------------------------------------------------
% Se estiver na paragem final termina. 
bfs7([[Fim|Caminho]|_],Fim,[Fim|Caminho]).

%---------------------------------------------------------------------------------
% Se não, extende o caminho atual por todas as paragens que o conseguem fazer e coloca na fila de espera para serem verificados, reiterando pelos novos caminhos encontrados.
bfs7([Caminho1|Caminhos], Fim, Caminho) :-
    extende7(Caminho1,NovosCaminhos),
    append(Caminhos, NovosCaminhos, Caminhos1),
    bfs7(Caminhos1, Fim, Caminho).
%---------------------------------------------------------------------------------
% Predicado que extende o caminho utilizando todas as paragens que não estejam dentro do caminho, e que pertençam apenas às operadoras escolhidas.
extende7([Paragem|Caminho], NovosCaminhos) :-
    findall([Paragem2, Paragem|Caminho],(adjacentes(Paragem, Paragem2),\+ memberchk(Paragem2,[Paragem|Caminho]),
    paragem(_,_ ,Paragem2, _, _, _, _, 'Yes', _, _, _, _)),NovosCaminhos),!.

extende7(_,[]).
%---------------------------------------------------------------------------------

% 8. Escolher o percurso que passe apenas por paragens abrigadas.

caminho2_8(Inicio,Fim,Caminho) :-
    paragem(_,_ ,Inicio, _, _, _, Tipo, _, _, _, _, _),
    paragem(_,_ ,Fim, _, _, _, Tipo2, _, _, _, _, _),
    Tipo \= 'Sem Abrigo',
    Tipo2 \= 'Sem Abrigo',
    bfs8([[Inicio]],Fim,CaminhoAux),
    reverse(CaminhoAux,Caminho). 

%---------------------------------------------------------------------------------
% Se estiver na paragem final termina. 
bfs8([[Fim|Caminho]|_],Fim,[Fim|Caminho]).

%---------------------------------------------------------------------------------
% Se não, extende o caminho atual por todas as paragens que o conseguem fazer e coloca na fila de espera para serem verificados, reiterando pelos novos caminhos encontrados.
bfs8([Caminho1|Caminhos], Fim, Caminho) :-
    extende8(Caminho1,NovosCaminhos),
    append(Caminhos, NovosCaminhos, Caminhos1),
    bfs8(Caminhos1, Fim, Caminho).
%---------------------------------------------------------------------------------
% Predicado que extende o caminho utilizando todas as paragens que não estejam dentro do caminho, e que pertençam apenas às operadoras escolhidas.
extende8([Paragem|Caminho], NovosCaminhos) :-
    findall([Paragem2, Paragem|Caminho],(adjacentes(Paragem, Paragem2),\+ memberchk(Paragem2,[Paragem|Caminho]),
    paragem(_,_ ,Paragem2, _, _, _, Tipo, _, _, _, _, _), Tipo \= 'Sem Abrigo'),NovosCaminhos),!.

extende8(_,[]).

% 9. Escolher um ou mais pontos intermédios por onde o percurso deverá passar.
removehead([_|T], T).
removeLast(L, T):- reverse(L,Rev),removehead(Rev,Rem), reverse(Rem,T).

caminho2_9(Inicio,Fim,[],Caminho):-caminho2(Inicio,Fim,Caminho).

caminho2_9(Inicio,Fim,[Intermedio|T],Caminho) :-
    caminho2(Inicio,Intermedio,Parcial1),
    removeLast(Parcial1,Parcial),
    caminho2_9(Intermedio,Fim,T,X),
    append(Parcial,X,Caminho).

