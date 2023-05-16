## Autoarima for demand estimation

This is a R markdown file containing a shiny app that allows the user to execute the auto.arima() function. Analogically, demand systems use supervised ML algorithms for prediction, using similar approach: capture historical information using interfaces with ERP system and then, generating the forecasts. 
There are many other techniques for estimation in the two most popular open sources softwares: R & Python. In this app I am using seasonal auto regressive integrated moving average model (SARIMA) for prediction. Theoretically time series model only uses past data to estimate future demand. 
If any other component is necessary for estimation, like historical prices, quality scale (e.g. Likert), etc. a different approach should be used (e.g. GLM models).
