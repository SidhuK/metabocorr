library(shiny)
library(RColorBrewer)
library(corrplot)

# Define UI for application that draws a heatmap
ui <- fluidPage(
    titlePanel(
        title = div(h3(
            "MetaboCorr"
        ), h5("A R/Shiny based app for visualizing metabolomics data through Correlation Plots")),
        windowTitle = "MetaboCorr"
    ),
    # Add CSS stylesheet
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    sidebarPanel(
        h3("Data Input"),
        fileInput(
            "file",
            "Choose CSV File",
            accept = c(
                "text/csv",
                "text/comma-separated-values,text/plain",
                ".csv"
            )
        ),
        h3("Correlation Plot Parameters"),
        tags$hr(),
        checkboxInput(
            "header",
            "My Data Contains a Header",
            TRUE
        ),
        h4("Plot Settings"),
        selectInput(
            "type",
            "Choose the type of Plot",
            c(
                Lower = "lower",
                Upper = "upper",
                Full = "full"
            )
        ),
        h4("Cell Types"),
        selectInput(
            "method",
            "Choose the type of Cell",
            c(
                Circle = "circle",
                Square = "square",
                Ellipse = "ellipse",
                Number = "number",
                Shade = "shade",
                Color = "color",
                Pie = "pie"
            )
        ),
        h4("Clustering"),
        selectInput(
            "order",
            "Choose the type of Clustering",
            c(
                Original = "original",
                AOE = "AOE",
                FPC = "FPC",
                Hclust = "hclust",
                Alphabet = "alphabet"
            )
        ),
        h4("Add Number of Rectangles"),
        sliderInput(
            "addrect",
            "Add Rectangular outline to similar parts of the plot",
            min = 1,
            max = 10,
            value = 1
        ),
        h4("Get the Plot"),
        actionButton(
            "get_heatmap",
            "Generate Heatmap",
            class = "btn btn-primary btn-block"
        )
    ),
    mainPanel(
        tabsetPanel(
            tabPanel(
                h2("Instructions"),
                h2("Instructions"),
                h3("About"),
                p(
                    "The MetaboCorr application provides an elegant solution for visualizing
           small to medium sized metabolomics output data by presenting a correlation plot for a set of compounds.
            The input data must adhere to specific formatting requirements, with a header
            row and the first column reserved for compound names. The heatmap is generated
             using the highly customizable 'corrplot' library in R, enabling the user to tinker with the
              output through the available sidebar options."
                ),
                p("Once generated, the plot can be saved to a PNG file by right-clicking on the image and selecting
      'Save Image As...' or by utilizing the convenient 'Download Image' button within the 'Correlation Plot' tab.
      The user-supplied data can be viewed in its raw form in the 'Data' tab for added transparency."),
                p("The MetaboCorr app is hosted on both shinyapps.io and GitHub,
       providing access through a web-based platform or by downloading and
       running the app locally through RStudio/VSCode or IDE of your choice. The application can be accessed on
       shinyapps.io at https://karatsidhu.shinyapps.io/metabocorr/ and on
       GitHub at https://github.com/sidhuk/metabocorr/."),
                h3("Useful Links"),
                helpText(a("ShinyApps", href = "https://karat.shinyapps.io/metabocorr/", target = "_blank")),
                helpText(a("GitHub Repository", href = "https://github.com/sidhuk/metabocorr/", target = "_blank")),
                helpText(a("Sample Data", href = "https://github.com/SidhuK/metabocorr/blob/main/metabolites.csv", target = "_blank")),
                h3("Steps to Generate the plot"),
                p("1. Navigate to the 'Data Input' area on the left."),
                p("2. Prepare the csv file in acceptable format and click upload."),
                p("3. Select the options for the plot from the sidebar.")
            ),
            tabPanel(
                h2("Correlation Plot"),
                fluidRow(column(
                    8,
                    plotOutput("themap",
                        width = "1000px",
                        height = "1500px"
                    ),
                    downloadButton(outputId = "download", label = "Download Plot", class = "btn btn-primary btn-block")
                ))
            ),
            tabPanel(
                h2("Data Table"),
                fluidRow(column(
                    8,
                    tableOutput("tbl")
                ))
            )
        )
    ),
    tags$footer(HTML("<footer class='page-footer'> © 2023 Copyright:
                           <a href='https://github.com/SidhuK'> Karat Sidhu</a>
                           </footer>"))
)

server <- function(input, output, session) {
    df <- reactive({
        inFile <- input$file
        if (is.null(inFile)) {
            return(NULL)
        }
        tbl <- read.csv(inFile$datapath, header = input$header)
        return(tbl)
    })



    # Generate the table output

    output$tbl <- renderTable({
        df()
    })


    # Create a reactive expression to generate the heatmap data

    data <- eventReactive(input$get_heatmap, {
        mat <- as.matrix(df()[-1])
        row.names(mat) <- df()$compound
        mat[is.na(mat)] <- 0
        mat <- cor(t(mat))
        mat
    })


    # Code to generate the heatmap from the options selected
    output$themap <- renderPlot({
        corrplot(
            data(),
            type = input$type,
            col = brewer.pal(n = 8, name = "RdYlBu"),
            method = input$method,
            addgrid.col = "darkgray", outline = T,
            tl.cex = 1,
            tl.col = "black",
            order = input$order,
            addrect = input$addrect
        )
    })


    # Download button code to save the heatmap as a PNG file
    output$download <- downloadHandler(
        filename = function() {
            paste0("metabocorr", Sys.Date(), ".png")
        },
        content = function(file) {
            # Save the plot as a PNG file
            png(file,
                width = 1500,
                height = 2000,
                units = "px"
            )

            # Generate the plot
            corrplot(
                data(),
                type = input$type,
                col = brewer.pal(n = 8, name = "RdYlBu"),
                method = input$method,
                addgrid.col = "darkgray", outline = T,
                tl.cex = 1,
                tl.col = "black",
                order = input$order,
                addrect = input$addrect
            )

            # Close the PNG file
            dev.off()
        }
    )
}


# Run the application
shinyApp(ui, server)
