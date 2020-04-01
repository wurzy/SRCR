%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

% Sistema de representação de conhecimento e raciocínio com capacidade
% para caracterizar um universo de discurso na área da contratação pública
% para a realização de contratos para a prestação de serviços

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
%:- set_prolog_flag( unknown,fail ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

%:- op( 1100,xfy,'??' ).
%:- op(900,xfy,'::').
:- dynamic adjudicante/4.
:- dynamic adjudicataria/4.
:- dynamic contrato/9.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Carregar predicados do ficheiro no qual é guardado o estado
:- include('povoamento.pl').

:- include('funcAux.pl').
%:- include('identificacoes.pl').
%:- include('stateControl.pl').
%:- include('calculoDeCustos.pl').

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Invariantes Estruturais e Referenciais

% Adjudicantes

% Id único e intransponível
% para o id de um certo adjudicante, o espaço de soluções é R e só possui um elemento
+adjudicante(Id,_,_,_) :- (solucoes(Id, adjudicante(Id,_,_,_), R),
                             comprimento(R,1)).

% NIF único e intransponível
% para o nif de um certo adjudicante, o espaço de soluções é R e só possui um elemento
+adjudicante(_,_,NIF,_) :- (solucoes(NIF, adjudicante(_,_,NIF,_), R),
                             comprimento(R,1)).

% Adjudicatárias

% Id único e intransponível
% para o id de uma certa adjudicatária, o espaço de soluções é R e só possui um elemento
+adjudicataria(Id,_,_,_) :- (solucoes(Id, adjudicataria(Id,_,_,_), R),
                             comprimento(R,1)).

% NIF único e intransponível
% para o nif de uma certa adjudicatária, o espaço de soluções é R e só possui um elemento
+adjudicataria(_,_,NIF,_) :- (solucoes(NIF, adjudicataria(_,_,NIF,_), R),
                             comprimento(R,1)).


% Contratos

% Tipo de procedimento válido
+contrato(_,_,_,T,_,_,P,_,D) :- tipoProcedimento(T), dataValida(P), dataValida(D).

% Condições de contrato por ajuste direto
+contrato(_,_,TC,TP,_,V,P,_,D) :- TP = 'Ajuste Direto',
                                  V =< 5000,
                                  tipoContrato(TC),
                                  prazoUmAno(P,D).

% Regra dos 3 anos válida para todos os contratos
contrato(IdAd,IdAda,TC,_,_,_,_,_,D) :- (solucoes((IdAd,IdAda,TC,D), contrato(IdAd,IdAda,TC,_,_,_,_,_), R),
                                        valorAcumulado(R,D,V), V <= 75000).