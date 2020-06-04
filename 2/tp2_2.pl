:- include('povoamento2.pl').
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

% 6. Escolher o percurso mais rápido (usando critério da distância).

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

