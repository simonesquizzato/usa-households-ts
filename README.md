# 👨‍👩‍👧 USA Households: analisi della serie storica
### Famiglie sposate con figli minorenni negli Stati Uniti (1950–2019)

Analisi e previsione della serie storica annuale del **numero di famiglie con coppie sposate e figli minorenni** negli Stati Uniti, secondo l'approccio **Box-Jenkins**: studio della stazionarietà, trasformazione di Box-Cox, differenziazione, identificazione e stima di un modello **ARIMA**, diagnostica dei residui e confronto delle performance previsive con metodi benchmark.

Progetto del corso di **Analisi delle Serie Storiche**
Laurea Magistrale in Scienze Statistiche per la Finanza · Università degli Studi di Salerno · A.A. 2024/2025

---

## 📑 Indice

- [Dataset](#-dataset)
- [Metodologia](#-metodologia)
- [Risultati](#-risultati)
- [Struttura del repository](#-struttura-del-repository)
- [Come riprodurre l'analisi](#-come-riprodurre-lanalisi)
- [Limiti e sviluppi futuri](#-limiti-e-sviluppi-futuri)
- [Team](#-team)

---

## 🗄️ Dataset

| Caratteristica | Valore |
|---|---|
| Fonte | [Kaggle – Family Households With Married Couples Data](https://www.kaggle.com/datasets/census/family-households-with-married-couples-data) (U.S. Census Bureau) |
| Variabile | Numero di famiglie con coppia sposata e figli minorenni (in migliaia) |
| Frequenza | Annuale |
| Periodo analizzato | 1950 – 2019 (70 osservazioni) |
| File | `married.csv` |

Il dataset originale di Kaggle è stato **ridotto al periodo 1950–2019**, dove il 2019 è l'ultima osservazione disponibile.

La serie cresce rapidamente fino ai primi anni '70, oscilla attorno a 24–26 milioni di famiglie fino al 2007 e scende in modo marcato dopo il 2008.

---

## 🔬 Metodologia

### 1. Analisi esplorativa e stazionarietà
- **Time-series plot**, **ACF** e **PACF** della serie originale. Le ACF decrescono lentamente, segno di un trend e quindi di non stazionarietà in media.
- **Mean-SD plot** su finestre di 5 anni, per verificare la stazionarietà in varianza.

### 2. Stabilizzazione della varianza
Si applica la trasformazione di **Box-Cox**:

$$Y_t = \begin{cases} \dfrac{X_t^\lambda - 1}{\lambda} & \lambda \neq 0 \\ \log(X_t) & \lambda = 0 \end{cases}$$

Con $\lambda = 0$ (trasformata logaritmica) i punti del Mean-SD plot si dispongono lungo una retta parallela all'asse delle ascisse: la varianza è stabilizzata.

### 3. Rimozione del trend
| Serie | ADF test (statistica) | p-value | Esito |
|---|---|---|---|
| Log, differenze prime | −2.837 | 0.235 | Non stazionaria |
| Log, differenze seconde | −6.474 | 0.01 | ✅ Stazionaria |

L'ordine di integrazione scelto è quindi **d = 2**.

### 4. Identificazione e stima del modello
Dalle ACF/PACF della serie differenziata due volte risulta significativa la sola autocorrelazione al lag 1. Sono stati confrontati tre modelli candidati:

| Modello | Esito |
|---|---|
| ARIMA(2,2,1) | Residui buoni, ma solo il coefficiente MA(1) è significativo |
| ARIMA(1,2,2) | Coefficiente MA(1) > 1: viola l'invertibilità, scartato |
| **ARIMA(0,2,1)** | ✅ Modello selezionato, confermato da `auto.arima()` |

### 5. Diagnostica dei residui
- TS plot dei residui distribuito attorno a zero.
- ACF dei residui interamente entro le bande di confidenza.
- **Jarque-Bera test** per la normalità.

### 6. Valutazione previsiva
- **Training set**: 1950–2008 (59 osservazioni, circa 85%)
- **Test set**: 2009–2019 (11 osservazioni, circa 15%)
- Confronto di ARIMA(0,2,1) con i metodi **mean**, **naive** e **drift** tramite RMSE, MAE e MAPE.

---

## 📊 Risultati

### Modello stimato: ARIMA(0,2,1) sulla serie logaritmica

$$(1 - B)^2 \log(X_t) = (1 + \theta_1 B)\,\varepsilon_t$$

| Parametro | Stima | Std. Error | z value | p-value |
|---|---|---|---|---|
| MA(1) $\theta_1$ | **−0.783** | 0.072 | −10.906 | < 2.2e-16 |

| σ² | Log-likelihood | AIC | AICc | BIC |
|---|---|---|---|---|
| 0.000144 | 204.94 | −405.87 | −405.69 | −401.44 |

Il coefficiente MA(1) è fortemente significativo e minore di 1 in valore assoluto, quindi il processo è **invertibile**.

**Residui**
- Nessuna autocorrelazione significativa: il modello cattura la struttura della serie.
- Jarque-Bera: χ² = 5.785, p-value = **0.055**. La normalità dei residui è al limite della soglia del 5%, quindi non si può concludere con certezza in un senso o nell'altro.

### Performance previsive sul test set (2009–2019)

| Metodo | RMSE | MAE | MAPE (%) |
|---|---|---|---|
| **ARIMA(0,2,1)** | 473.39 | **388.20** | **1.62** |
| Mean | **466.09** | 418.93 | 1.74 |
| Naive | 1195.57 | 1113.20 | 4.66 |
| Drift | 1939.23 | 1799.52 | 7.54 |

- ARIMA(0,2,1) supera nettamente i metodi **naive** e **drift** su tutte le misure.
- Il **mean method** ottiene risultati simili: RMSE leggermente più basso, MAE e MAPE più alti. Il modello ARIMA resta preferibile perché descrive anche la dinamica della serie.
- Gli intervalli di previsione si allargano all'aumentare dell'orizzonte, come atteso per un processo integrato di ordine 2.

---

## 📁 Struttura del repository

```
usa-households-ts/
├── usa-households.R             # Script completo dell'analisi
├── married.csv                  # Serie storica 1950–2019
├── households-tsa-report.pdf    # Report completo del progetto
└── README.md
```

---

## ▶️ Come riprodurre l'analisi

**Requisiti:** R ≥ 4.0

1. **Clona il repository**
   ```bash
   git clone https://github.com/simonesquizzato/usa-households-ts.git
   cd usa-households-ts
   ```

2. **Installa i pacchetti R**
   ```r
   install.packages(c("fpp2", "zoo", "forecast", "tseries", "gridExtra", "lmtest"))
   ```

3. **Esegui l'analisi**
   ```r
   source("usa-households.R")
   ```

| Pacchetto | Utilizzo |
|---|---|
| `fpp2` / `forecast` | Grafici (`autoplot`, `ggAcf`), `Arima`, `auto.arima`, `forecast`, metodi benchmark, `accuracy` |
| `tseries` | Augmented Dickey-Fuller test, Jarque-Bera test |
| `lmtest` | Test di significatività dei coefficienti (`coeftest`) |
| `zoo`, `gridExtra` | Utility per serie storiche e composizione dei grafici |

---

## 🚧 Limiti e sviluppi futuri

- **Serie breve**: 70 osservazioni annuali, e solo 11 nel test set, limitano la potenza dei test e l'affidabilità del confronto previsivo.
- **Break strutturale**: il calo dopo il 2008 suggerisce un cambiamento di regime. Test come Chow o Bai-Perron, oppure variabili di intervento, potrebbero modellarlo esplicitamente.
- **d = 2**: una doppia differenziazione rischia l'over-differencing. Il fatto che θ₁ ≈ −0.78 non sia vicino a −1 è rassicurante, ma vale la pena confrontare anche modelli con d = 1 più un trend deterministico.
- **Validazione**: una time-series cross-validation (`tsCV`) darebbe una stima più robusta dell'errore previsivo rispetto a un singolo split.
- **Modelli alternativi**: exponential smoothing (ETS), modelli state-space o dati aggiornati oltre il 2019.

---

## 👥 Team

| Nome | GitHub |
|---|---|
| Cristian Avagnano | |
| Giuseppe Saviano | |
| Simone Squizzato | [@simonesquizzato](https://github.com/simonesquizzato) |

---

*Progetto realizzato a scopo didattico per il corso di Analisi delle Serie Storiche – Università degli Studi di Salerno.*
