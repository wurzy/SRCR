:- include('povoamento.pl').
:- include('adjacentes.pl').

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
%:- set_prolog_flag( unknown,fail ).

:- use_module(library(lists)).
:- use_module(library(statistics)).

% ------------------------------------------------ PREDICADOS AUXILIARES -------------------------------------------------------------
%-----------------------------------------------------------------------------
% Remove elementos repetidos de uma lista
remrep([],[]).
remrep([H|T],C) :- member(H,T),!, remrep(T,C).
remrep([H|T],[H|C]) :- remrep(T,C).

removehead([_|T], T).

%-----------------------------------------------------------------------------
% Retorna a lista de carreiras a que uma paragem pertence.
carreirasAdjacentes(Carreira1,Paragem,Lista):-
    findall(Carreira, (paragem(Carreira,_,Paragem, _, _, _, _, _, _, _, _, _), Carreira1 \= Carreira),
    Lista).

%-----------------------------------------------------------------------------
% Retorna a lista de carreiras adjacentes a uma determinada carreira.
carreirasAdjacentesCarreiraAux(_, [], []).

carreirasAdjacentesCarreiraAux(Carreira,[Paragem|Paragens],[Lista1|Lista]):-
    carreirasAdjacentes(Carreira,Paragem,Lista1),
    carreirasAdjacentesCarreiraAux(Carreira,Paragens,Lista).

carreirasAdjacentesCarreira(Carreira, Lista):-
    findall(Paragem, (paragem(Carreira,_,Paragem, _, _, _, _, _, _, _, _, _)),Paragens),
    carreirasAdjacentesCarreiraAux(Carreira,Paragens,Lista).

%-----------------------------------------------------------------------------
% Retorna a lista de elementos um Inicio e um Fim na mesma carreira.
criarCaminho(_,Fim,Fim,[Fim]):- !.

criarCaminho(Carreira,Inicio,Fim,[Inicio|Caminho]):-
    paragem(Carreira,Id1, Inicio, _, _, _, _, _, _, _, _, _),
    paragem(Carreira,IdAux, Fim, _, _, _, _, _, _, _, _, _),
    Id1 < IdAux,
    Id2 is Id1 + 1,
    paragem(Carreira,Id2, Adjacente, _, _, _, _, _, _, _, _, _),
    criarCaminho(Carreira, Adjacente, Fim, Caminho).

criarCaminho(Carreira,Inicio,Fim,[Inicio|Caminho]):-
    paragem(Carreira,Id1, Inicio, _, _, _, _, _, _, _, _, _),
    paragem(Carreira,IdAux, Fim, _, _, _, _, _, _, _, _, _),
    Id1 > IdAux,
    Id2 is Id1 - 1,
    paragem(Carreira,Id2, Adjacente, _, _, _, _, _, _, _, _, _),
    criarCaminho(Carreira, Adjacente, Fim, Caminho).

%-----------------------------------------------------------------------------
% Retorna todos os elementos comuns a ambas as matrizes.
verificaMatrizAux([], _, []).

verificaMatrizAux(_, [], []).

verificaMatrizAux([L1|Resto],X, [L1|Res]):-
    member(L1, X),
    verificaMatrizAux(Resto,X,Res), !.
    
verificaMatrizAux([_|R],X, Res):-
    verificaMatrizAux(R,X,Res),
    !.

verificaMatriz(X,Y,Res):-
    flatten(X,F1),
    flatten(Y,F2),
    verificaMatrizAux(F1,F2,Res).

%-----------------------------------------------------------------------------
% Verifica se lista tem elementos repetidos.
temRepetidos(L) :-
    sort(L, S),
    length(L, X),
    length(S, Y),
    X > Y.
    
% ------------------------------------------------------ RESOLUÇÃO -------------------------------------------------------------------
% ###################################################### ALGORITMO INFORMADO #########################################################
%-----------------------------------------------------------------------------
% Predicado que cria um caminho entre duas paragens, se a carreira for igual.
caminho(Inicio,Fim,Caminho):-
    paragem(Carreira,_, Inicio, _, _, _, _, _, _, _, _, _),
    paragem(Carreira,_ ,Fim, _, _, _, _, _, _, _, _, _),
    criarCaminho(Carreira,Inicio,Fim,Caminho),
    !.

%-----------------------------------------------------------------------------
% Predicado que testa se as paragens são isoladas
caminho(_,Fim,_):-
    paragem(Carreira2,_ ,Fim, _, _, _, _, _, _, _, _, _),
    carreirasAdjacentesCarreira(Carreira2,Adjs2),
    flatten(Adjs2,Help), 
    length(Help,0), % é uma carreira totalmente isolada
    !,fail.  

caminho(Inicio,_,_):-
    paragem(Carreira1,_, Inicio, _, _, _, _, _, _, _, _, _),
    carreirasAdjacentesCarreira(Carreira1,Adjs),
    flatten(Adjs,Help), 
    length(Help,0), % é uma carreira totalmente isolada
    !,fail.  

%-----------------------------------------------------------------------------
% Predicado que cria um caminho entre duas paragens, se tiver um ponto de junção comum
caminho(Inicio,Fim,Caminho):-
    paragem(Carreira1,_, Inicio, _, _, _, _, _, _, _, _, _),
    paragem(Carreira2,_ ,Fim, _, _, _, _, _, _, _, _, _),
    %carreirasAdjacentesCarreira(Carreira1,Adjs1),
    carreirasAdjacentesCarreira(Carreira2,Adjs2),
    %verificaMatriz(Adjs1,Adjs2,Comuns), % procura as carreiras adjacentes comuns
    flatten(Adjs2,Help), 
    member(Carreira1,Help), % procura se a carreira original está nas atingiveis pela carreira que contem o no final
    paragem(Carreira1,_,Escolhido, _, _, _, _, _, _, _, _, _), % vou buscar esse comum
    paragem(Carreira2,_,Escolhido, _, _, _, _, _, _, _, _, _), % vou buscar esse comum
    criarCaminho(Carreira1, Inicio, Escolhido, Resultante1),
    criarCaminho(Carreira2, Escolhido, Fim, Resultante2x), % fica aqui com um elemento a mais, tira-se
    removehead(Resultante2x,Resultante2),
    append(Resultante1, Resultante2, Caminho).

%-----------------------------------------------------------------------------
% Predicado que cria um caminho entre duas paragens, se tiverem alguma carreira em comum intermédia
caminho(Inicio,Fim,Caminho):-
    paragem(Carreira1,_, Inicio, _, _, _, _, _, _, _, _, _),
    paragem(Carreira2,_ ,Fim, _, _, _, _, _, _, _, _, _),
    carreirasAdjacentesCarreira(Carreira1,Adjs1),
    carreirasAdjacentesCarreira(Carreira2,Adjs2),
    verificaMatriz(Adjs1,Adjs2,Comuns), % procura as carreiras adjacentes comuns
    member(Comum,Comuns), % retira um elemento comum
    %\+ memberchk(Comum, Historico),
    paragem(Comum, _, Escolhido, _, _, _, _, _, _, _, _, _), % 
    paragem(Carreira1, _, Escolhido, _, _, _, _, _, _, _, _, _), % 
    paragem(Comum, _, Escolhido2, _, _, _, _, _, _, _, _, _), % 
    paragem(Carreira2, _, Escolhido2, _, _, _, _, _, _, _, _, _), % 
    %caminho(Inicio,Escolhido,Historico,Resultante1),
    %caminho(Escolhido,Escolhido2,Historico,Resultante2),
    %caminho(Escolhido2,Fim,Historico,Resultante3),
    criarCaminho(Carreira1,Inicio,Escolhido, Resultante1),
    criarCaminho(Comum,Escolhido,Escolhido2, Resultante2),
    criarCaminho(Carreira2,Escolhido2,Fim, Resultante3),
    append(Resultante1, Resultante2, CaminhoAux),
    append(CaminhoAux, Resultante3, Caminho).

%-----------------------------------------------------------------------------
% Predicado que cria um caminho entre duas paragens não antigíveis pela informação acima, usando a paragem terminal
caminho(Inicio,Fim,Caminho):-
    caminho(Inicio,178,CAux),
    caminho(178,Fim,C2),
    append(CAux,C2,Caminho).

% ###############################################################################################################################

% ---------------------------------------------------- SUB-ALINEAS --------------------------------------------------------------

% 2. Selecionar apenas algumas das operadoras de transporte para um determinado percurso.

% -------------------------------------------------------------------------------------
% 3. Excluir um ou mais operadores de transporte para o percurso.

% -------------------------------------------------------------------------------------
% 4. Identificar quais as paragens com o maior número de carreiras num determinado percurso.
carreiras(Paragem,Total):-
    findall(Carreira, (paragem(Carreira,_,Paragem, _, _, _, _, _, _, _, _, _)),
    Lista),
    length(Lista,Total).

% Verifica para todas as paragens qual aquela que pertence ao maior número de carreiras e retorna-o.
calculaMax(T,Max):-
    maplist(carreiras, T, MaxAux),
    max_list(MaxAux, Max).

caminho_4(Inicio,Fim,Maior) :-
    caminho(Inicio,Fim,Caminho),
    calculaMax(Caminho,Maior).

% -------------------------------------------------------------------------------------
% 5. Escolher o menor percurso (usando critério menor número de paragens).

% -------------------------------------------------------------------------------------
% 6. Escolher o percurso mais rápido (usando critério da distância).

% -------------------------------------------------------------------------------------
% 7. Escolher o percurso que passe apenas por abrigos com publicidade.

% -------------------------------------------------------------------------------------
% 8. Escolher o percurso que passe apenas por paragens abrigadas.

% -------------------------------------------------------------------------------------
% 9. Escolher um ou mais pontos intermédios por onde o percurso deverá passar.
removeLast(L, T):- reverse(L,Rev),removehead(Rev,Rem), reverse(Rem,T).

caminho_9(Inicio,Fim,[],Caminho):-caminho(Inicio,Fim,Caminho).

caminho_9(Inicio,Fim,[Intermedio|T],Caminho) :-
    caminho(Inicio,Intermedio,Parcial1),
    removeLast(Parcial1,Parcial),
    caminho_9(Intermedio,Fim,T,X),
    append(Parcial,X,Caminho).
