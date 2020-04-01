%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Funções Auxiliares

:- dynamic data/3.

% Comprimento de uma lista
comprimento(S,N) :- length(S,N).

% Verifica se um elemento pertence a uma lista
pertence(X,[X|_]).
pertence(X,[_|T]) :- pertence(X,T).

% Tipo de procedimento válido
tipoProcedimento('Ajuste Direto').
tipoProcedimento('Consulta Previa').
tipoProcedimento('Concurso Publico').

% Tipo de contrato válido por ajuste direto
tipoContrato('Aquisicao').
tipoContrato('Locacao de Bens Moveis').
tipoContrato('Aquisicao de Servicos').

% Verifica se uma data é válida
dataValida(data(D,M,A)) :- (pertence(M,[1,3,5,7,8,10,12]), D >= 1, D =< 31);
                           (pertence(M,[4,6,9,11]), D >= 1, D =< 30);
                           (M = 2, (mod(A,4) =:= 0, D >= 1, D =< 29);
                                   (D >= 1, D =< 28)).

% Prazo de vigência até 1 ano, inclusivé, a contar da decisão de adjudicação
%prazo(Data,Prazo)
prazo(data(DD,MD,AD),data(DP,MP,AP)) :- (AD = AP, (MD < MP; (MD = MP, DD =< DP)));
                                        (AD < AP, (MD > MP; (MD = MP, DD >= DP))).

% Valor acumulado dos contratos celebrados no ano D ou nos dois anteriores
valorAcumulado([contrato(_,_,_,_,_,VC,_,_,DC)|T],D,V) :- DC =< D, DC >= D-2, valorAcumulado(T,D,V1), V1 is V+VC.
valorAcumulado([_|T],D,V) :- valorAcumulado(T,D,V).