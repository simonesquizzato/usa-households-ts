library(fpp2)
library(zoo)
library(forecast)
library(tseries)
library(gridExtra)
library(lmtest)

married <- read.csv("married.csv")
married <- married[, c(2,3)]

married <- ts(married[,1], start = 1950)
married

#Analisi serie originale
autoplot(married)
ggAcf(married)
ggPacf(married)

#SD mean plot serie originale
window_size <- 5

mean_values <- sapply(seq(1, length(married) - window_size + 1, by = window_size), 
                      function(i) mean(married[i:(i + window_size - 1)]))
sd_values <- sapply(seq(1, length(married) - window_size + 1, by = window_size), 
                    function(i) sd(married[i:(i + window_size - 1)]))

plot(mean_values, sd_values, xlab = "Mean", ylab = "Standard Deviation", 
     main = "Mean-SD serie originale", pch = 16, col = "blue")
abline(lm(sd_values ~ mean_values), col = "red")


#Trasformata logaritmica
m_log <- BoxCox(married, lambda = 0)

window_size <- 5

mean_values <- sapply(seq(1, length(m_log) - window_size + 1, by = window_size), 
                      function(i) mean(m_log[i:(i + window_size - 1)]))
sd_values <- sapply(seq(1, length(m_log) - window_size + 1, by = window_size), 
                    function(i) sd(m_log[i:(i + window_size - 1)]))

plot(mean_values, sd_values, xlab = "Mean", ylab = "Standard Deviation", 
     main = "Mean-SD serie originale", pch = 16, col = "blue", ylim =c(-1.5, 1.5))
abline(lm(sd_values ~ mean_values), col = "red")


#Analisi serie trasformata
autoplot(m_log)
acf(m_log)
pacf(m_log)

#differenze prime
m_diff <- diff(m_log)
autoplot(m_diff)
ggAcf(m_diff)
ggPacf(m_diff)
adf.test(m_diff, alternative = "stationary")
Box.test(m_diff, type = "Box-Pierce")

#differenze seconde
m_diff_2 <- diff(m_diff)
autoplot(m_diff_2)
ggAcf(m_diff_2)
ggPacf(m_diff_2)
adf.test(m_diff_2, alternative = "stationary")
adf.test(m_diff_2, alternative = "stationary", k=10) #fake, datti fuoco
Box.test(m_diff_2)

#Modelli possibili
#ARIMA (2,2,1)
#ARIMA (1,2,2)

m1<- Arima(m_log, order = c(2,2,1))
m1
coeftest(m1)
summary(m1)
ggAcf(m1$residuals) + ylim(c(-1,1))
ggPacf(m1$residuals) + ylim(c(-1,1))
checkresiduals(m1$residuals)
jarque.bera.test(m1$residuals)
#l'analisi del modello ARIMA(2,2,1) fornisce diversi risultati ottimi per quanto 
#riguarda l'analisi dei residui, tuttavia dal test sulla significatività dei coefficienti
#si evince come l'unico coefficiente significativo sia quello MA(1).

m2<- Arima(m_log, order = c(1,2,2))
m2
coeftest(m2)
summary(m2)
ggAcf(m2$residuals) + ylim(c(-1,1))
ggPacf(m2$residuals) + ylim(c(-1,1))
checkresiduals(m2$residuals)
jarque.bera.test(m2$residuals)
#Dal modello ARIMA(1,2,2) si ottengono gli stessi risultati ottenuti in precedenza, 
#tuttavia, in questo caso, il coefficiente MA(1) è maggiore di 1, per cui il modello
#considerato è da scartare.

#Dato che nei due modelli precedenti si è notato come l'unico coefficiente significativo
#fosse quello MA(1), può esser utile valutare un modello ARIMA(0,2,1).
m3<- Arima(m_log, order= c(0,2,1))
m3
coeftest(m3)
autoplot(m3$residuals)
ggAcf(m3$residuals)
ggPacf(m3$residuals)
checkresiduals(m3$residuals)
jarque.bera.test(m3$residuals)
#i risultati ottenuti sembrano ottimi, normalità dei residui compresa.

#per un ulteriore conferma della bontà della scelta del modello:
auto.arima(m_log)


#ANALISI SUL TRAIN
N<- length(married)
train<- married[1:59]
test<- married[60:N]
#misure del train e test scelte a caso

train<- ts(train, start = 1950)
test<- ts(test, start = 2009)
autoplot(train)
ggAcf(train)
ggPacf(train)
adf.test(train)

window_size <- 5

mean_values <- sapply(seq(1, length(train) - window_size + 1, by = window_size), 
                      function(i) mean(train[i:(i + window_size - 1)]))
sd_values <- sapply(seq(1, length(train) - window_size + 1, by = window_size), 
                    function(i) sd(train[i:(i + window_size - 1)]))

plot(mean_values, sd_values, xlab = "Mean", ylab = "Standard Deviation", 
     main = "Mean-SD serie originale", pch = 16, col = "blue")
abline(lm(sd_values ~ mean_values), col = "red")

train_log<- BoxCox(train, lambda = 0)
autoplot(train_log)

#Mean-SD Plot
window_size <- 5

mean_values <- sapply(seq(1, length(train_log) - window_size + 1, by = window_size), 
                      function(i) mean(train_log[i:(i + window_size - 1)]))
sd_values <- sapply(seq(1, length(train_log) - window_size + 1, by = window_size), 
                    function(i) sd(train_log[i:(i + window_size - 1)]))

plot(mean_values, sd_values, xlab = "Mean", ylab = "Standard Deviation", 
     main = "Mean-SD serie originale", pch = 16, col = "blue", ylim = c(-0.5,0.5))
abline(lm(sd_values ~ mean_values), col = "red")

# Differenziazione della serie e identificazione grafica
adf.test(train_log)

train_diff<- diff(train_log)
autoplot(train_diff)
adf.test(train_diff)
ggAcf(train_diff)
ggPacf(train_diff)

train_diff_2<- diff(train_diff)
autoplot(train_diff_2)
adf.test(train_diff_2)
ggAcf(train_diff_2)
ggPacf(train_diff)

# Stima del modello
m1<- Arima(train, order = c(0,2,1), lambda = 0)
m1
coeftest(m1)
checkresiduals(m1$residuals)
jarque.bera.test(m1$residuals)

# Previsioni
pred1<- forecast(m1, h=length(test))
Ut1 <- accuracy(pred1, test)[2,"Theil's U"]
autoplot(train, series = "Training Set") + 
  autolayer(pred1, series = "Previsioni") + 
  autolayer(test, series = "Test Set") +
  labs(colour = "Serie") + ggtitle("Previsioni con modello ARIMA(0,2,1)")


pred2 <- forecast(naive(train, lambda = 0),test)
pred2

autoplot(train, series = "Training Set") + 
  autolayer(pred2, series = "Previsioni") + 
  autolayer(test, series = "Test Set") +
  labs(colour = "Serie") + ggtitle("Previsioni con metodo naive")

accuracy(pred2, test)

pred3 <- forecast(meanf(train, length(test)), lambda = 0)
pred3

autoplot(train, series = "Training Set") + 
  autolayer(pred3, series = "Previsioni") + 
  autolayer(test, series = "Test Set") +
  labs(colour = "Serie") + ggtitle("Previsioni con average method")


accuracy(pred3, test)
