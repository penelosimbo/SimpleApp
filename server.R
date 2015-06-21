library(shiny)
library(ggplot2)

# Here we are loading our data and building a model. The code below will 
# be executed only once at server's start.

cars <- read.csv("cars.csv", na.strings = c("NA", "", "-"))
cars$Gears <- as.factor(cars$Gears)
cars$Cylinders <- as.factor(cars$Cylinders)
cars$Valves <- as.factor(cars$Valves)
cars$Euro.Emissions.Standard <- as.factor(cars$Euro.Emissions.Standard)

build.lm <- function(outcome = "CO2.Emissions", predictors = NULL) {
    lm.expr <- "lm(CO2.Emissions ~ "
    if (is.null(predictors) | length(predictors) == 0) return(NULL)
    for (i in 1:length(predictors))
        if (i != 1)
            lm.expr <- paste(lm.expr, predictors[i], sep = " + ")
        else
            lm.expr <- paste(lm.expr, predictors[i], sep = "")
        lm.expr <- paste(lm.expr, ", data = cars)", sep = "")
        eval(parse(text = lm.expr))
}

build.predict <- function(model = "fit", predictors = NULL) {
    predict.expr <- paste("predict(", model, ", newdata = data.frame(", sep = "")
    if (is.null(predictors) | length(predictors) == 0) return(NULL)
    for (i in 1:length(predictors))
        if (i != 1)
            predict.expr <- paste(predict.expr, ", ", predictors[i], sep = "")
        else
            predict.expr <- paste(predict.expr, predictors[i], sep = "")
        predict.expr <- paste(predict.expr, "))", sep = "")
        predict.expr
}

shinyServer(function(input, output) {
    
    co2 <- function(){
        validate(need(input$brandCheck | input$topspeedCheck | 
                          input$powerCheck | input$transCheck, 
                      message = "You should check at least one parameter.", label = ""))
        predictors <- character()
        if (input$brandCheck) predictors <- c(predictors, "Brand")
        if (input$topspeedCheck) predictors <- c(predictors, "Top.Speed")
        if (input$powerCheck) predictors <- c(predictors, "Power.Output")
        if (input$transCheck) predictors <- c(predictors, "Transmission")
        
        fit <- build.lm(predictors = predictors)
        
        predictors <- character()
        if (input$brandCheck) predictors <- c(predictors, paste("Brand = '", input$brand, "'", sep = ""))
        if (input$topspeedCheck) predictors <- c(predictors, paste("Top.Speed = ", input$topspeed, sep = ""))
        if (input$powerCheck) predictors <- c(predictors, paste("Power.Output = ", input$power, sep = ""))
        if (input$transCheck) predictors <- c(predictors, paste("Transmission = '", input$trans, "'", sep = ""))
        round(eval(parse(text = build.predict(predictors = predictors))), 1)
    }
    
    output$co2Out <- renderText(paste(co2(), "g/km"))
    
    output$plotOut <- renderPlot({
        validate(need(input$brandCheck | input$topspeedCheck | 
                          input$powerCheck | input$transCheck, 
                      message = "", label = ""))
        
        plot.expr <- "qplot(data = cars, y = CO2.Emissions, "
        
        if (input$powerCheck)
            plot.expr <- paste0(plot.expr, "x = Power.Output")
        else{
            if (input$topspeedCheck)
                plot.expr <- paste0(plot.expr, "x = Top.Speed")
            else
                if (input$brandCheck)
                    plot.expr <- paste0(plot.expr, "x = Brand")
                else
                    plot.expr <- paste0(plot.expr, "x = Transmission")
        }
        if (input$brandCheck)
            plot.expr <- paste0(plot.expr, ", color = Brand")
        if (input$transCheck)
            plot.expr <- paste0(plot.expr, ", facets = .~Transmission")
        plot.expr <- paste0(plot.expr, ")")
        if (input$topspeedCheck)
            plot.expr <- paste0(plot.expr, "+ geom_point(aes(size = Top.Speed))")
        eval(parse(text = plot.expr))
    })
    
    output$tableOut <- renderTable({
          co2.cache <- co2()
        select.expr <- paste0("cars[cars$CO2.Emissions > ", co2.cache - 5,
        " & cars$CO2.Emissions <", co2.cache + 5, ", c('Brand', 'Model.Name', 'CO2.Emissions')]")
        select.expr
        eval(parse(text = select.expr))
  })
})