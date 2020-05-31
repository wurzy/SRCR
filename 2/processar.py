# %%
import pandas as pd 
import numpy as np 
import os.path

def isNumber(x):
    if not x.strip().replace('-', '').replace('+', '').replace('.', '').isdigit():
        return False
    try:
         float(x)
    except ValueError:
         return False
    return True

def csv2predicado(id):
    df = pd.read_csv("./CSV/carreira_" + str(id) + ".csv", encoding='utf-8')

    df.dropna(inplace=True) # remove as entradas nulas, inplace significa para nao gerar um objeto novo mas aplicar ao df

    nome = "povoamento.pl"
    if os.path.exists(nome):
        modo = 'a'
    else:
        modo = 'w'
    f = open(nome,modo,encoding='utf-8')    

    print("\n%% CARREIRA " + str(id) + "\n", file = f)
    count = 1
    for i in range(len(df)):
        predicado = 'paragem(' + str(id) + ", " + str(count) + ", "
        for j in range(11):
            if(j!=7):
                valor = str(df.iloc[i,j])
                if not isNumber(valor): # se nao for um float/int
                    valor = '\'' + valor + '\''
                predicado = predicado + valor + ", "
        predicado = predicado[:-2]    
        predicado += ').'
        print(predicado,file=f)    
        count += 1
       
def ler_Todos():
    for i in range(777):
        if os.path.isfile("./CSV/carreira_" + str(i) + ".csv"):
            csv2predicado(i)

ler_Todos()


# %%
