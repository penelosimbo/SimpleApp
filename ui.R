library(shiny)

cars <- read.csv("cars.csv", na.strings = c("NA", "", "-"))
cars$Gears <- as.factor(cars$Gears)
cars$Cylinders <- as.factor(cars$Cylinders)
cars$Valves <- as.factor(cars$Valves)
cars$Euro.Emissions.Standard <- as.factor(cars$Euro.Emissions.Standard)

Brands = levels(cars$Brand)
Transmissions = levels(cars$Transmission)
    
shinyUI(fluidPage(

  # Application title
  titlePanel("Guess CO2 emission of your car"),
  p("Almost every state in the world enforced certain requirements to the level
    of motor vehicle emissions. Carmakers took those signals seriously and
    made great effort to meet the requirements. Almost any modern car
    is rather ecology friendly, though emissions level may vary dependent on
    certain parameters, such as engine power, transmission type or its class"),

  p("You may try to estimate what level of CO2 emissions would reach a car
    with certain parameters. You just have to select one or more parameters
    you want to include in a model, and set desired values."),

  p("Algorithm is very simple. It's just a plain linear model with various
    number of predictors of your choice. The data was obtained from the 
    parkers.co.uk database and consists of 65 records."),
  
  sidebarLayout(
    sidebarPanel(
        h3("Parameters"),
        p("Select one or more parameters to estimate emission level"),
        splitLayout(
            checkboxInput("brandCheck", ""),
            selectInput("brand", "Car brand", choices = Brands),
            cellWidths = c("10%", "90%")
        ),
        splitLayout(
            checkboxInput("topspeedCheck", ""),
            sliderInput("topspeed",
                  "Maximum speed (mph):",
                  min = 90,
                  max = 200,
                  step = 1,
                  value = 120),
            cellWidths = c("10%", "90%")
        ),
        splitLayout(
            checkboxInput("powerCheck", ""),
            sliderInput("power",
                    "Engine power (hp):",
                    min = 70,
                    max = 530,
                    step = 10,
                    value = 100),
            cellWidths = c("10%", "90%")
        ),
        splitLayout(
            checkboxInput("transCheck", ""),
            radioButtons("trans", "Transmission type", 
                     choices = Transmissions),
            cellWidths = c("10%", "90%")
        ),
        submitButton(text = "Let's guess!")
    ),

    mainPanel(
        h4("Estimated emissions level"),
        textOutput("co2Out", inline = FALSE),
        h4("Emission level as function of other parameters"),
        plotOutput("plotOut"),
        h4("Cars with similar emission level"),
        tableOutput("tableOut")
    )
  )
))
