# Load libraries
library(shiny)
library(shinythemes)
library(DT)
library(ggwordcloud)
library(ggplot2)
library(ggplot2movies)
library(dplyr)
library(rsconnect)

# Define UI for application 
ui <- fluidPage(
  # Application title
  theme = shinytheme("flatly"),
  titlePanel("Movie Explorer"),
  
  # Layout with sidebar and main content
  sidebarLayout(
    sidebarPanel(
      # Inputs for filtering
      textInput("titleInput", "Search Movie Title:", value = ""),
      
      # Add some space between the buttons
      br(),
      
      # Year Range Slider (No initial selection)
      sliderInput("yearInput", "Select Year Range:", min = 1900, max = 2022, value = c(1900, 2022), animate = TRUE),
      
      # Rating Range Slider (No initial selection)
      sliderInput("ratingInput", "Select Rating Range:", min = 0, max = 10, value = c(0, 10), animate = TRUE),
      
      # Multiple genre selection (no initial selection)
      checkboxGroupInput("genreInput", "Select Genres:", 
                         choices = c("Action", "Animation", "Comedy", "Drama", "Documentary", "Romance", "Short"), 
                         selected = NULL),
      
      # Checkbox to allow/exclude movies with missing budget values
      checkboxInput("excludeMissingBudget", "Exclude Movies with Missing Budget", value = FALSE),
      
      # Button to clear all settings
      actionButton("clearSettings", "Clear All Settings"),
      br(),  # Adds space between buttons
      br(),  # Adds space between buttons
      # Download button
      downloadButton("downloadData", "Download Filtered Data")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Movie Table", 
                 # Adding simple functionality description
                 h4("Movie Table Overview"), 
                 p("This tab displays a table of movies based on your selected filters. You can sort, filter, and explore details of each movie."), 
                 DTOutput("movieTable")),
        
        tabPanel("Word Cloud", 
                 h4("Word Cloud Overview"), 
                 p("This tab generates a word cloud from the titles and genres of the movies in your dataset. Larger words indicate higher frequency. (Need to wait for some seconds!)"), 
                 plotOutput("wordcloudPlot")),
        
        tabPanel("Genre Analysis", 
                 h4("Genre Analysis Overview"),
                 p("This tab presents a bar chart that shows the number of movies in each genre and their average rating. It provides insights into genre distribution."), 
                 plotOutput("genrePlot")),
        
        tabPanel("Budget vs Rating", 
                 h4("Budget vs Rating Overview"),
                 p("This tab shows a scatter plot comparing the budget of movies against their ratings. Movies with missing budget values can be excluded."), 
                 plotOutput("budgetRatingPlot")),
        
        tabPanel("Missing Budget Info", 
                 h4("Missing Budget Information"), 
                 p("This tab shows the number of movies with missing budget data. You can choose to exclude these movies from your analysis."), 
                 textOutput("missingBudgetInfo"))
      ),
      
    )
  )
)


# Define Server
server <- function(input, output, session) {
  
  # Preprocess data, reorganize 'genre'
  data <- ggplot2movies::movies %>%
    mutate(
      Genre = case_when(
        Action == 1 ~ "Action",
        Animation == 1 ~ "Animation",
        Comedy == 1 ~ "Comedy",
        Drama == 1 ~ "Drama",
        Documentary == 1 ~ "Documentary",
        Romance == 1 ~ "Romance",
        Short == 1 ~ "Short",
        TRUE ~ "Other"
      )
    )
  
  # Reactive function to filter data based on user inputs
  filteredData <- reactive({
    df <- data %>%
      filter(
        year >= input$yearInput[1] & year <= input$yearInput[2],
        rating >= input$ratingInput[1] & rating <= input$ratingInput[2]
      )
    
    # Title search filter
    if (input$titleInput != "") {
      df <- df %>% filter(grepl(input$titleInput, title, ignore.case = TRUE))
    }
    
    # Genre filter (allowing for multiple selections)
    if (length(input$genreInput) > 0) {
      df <- df %>% filter(Genre %in% input$genreInput)
    }
    
    # If user selects to exclude missing budget values, filter them out
    if (input$excludeMissingBudget) {
      df <- df %>% filter(!is.na(budget))
    }
    
    return(df)
  })
  
  # Render the interactive movie table
  output$movieTable <- renderDT({
    datatable(filteredData(), 
              filter = 'top', 
              options = list(pageLength = 10, scrollX = TRUE, autoWidth = TRUE))
  })
  
  # Render the word cloud
  output$wordcloudPlot <- renderPlot({
    data <- filteredData()
    keywords <- paste(data$title, data$Genre, collapse = " ")
    word_freq <- data.frame(table(unlist(strsplit(tolower(keywords), "\\W+"))))
    # Remove common stop words and filter out low-frequency words
    stopwords <- c("the", "and", "of", "a", "in", "to", "with", "for", "on", "at", "by", "an", "is", "or")
    word_freq <- word_freq[!(word_freq$Var1 %in% stopwords), ]
    # Keep top 100 words based on frequency
    word_freq <- word_freq[order(-word_freq$Freq), ][1:100, ]
    ggplot(word_freq, aes(label = Var1, size = Freq)) +
      geom_text_wordcloud_area() +
      scale_size_area(max_size = 50) + # set size for the most frequent word 
      theme_minimal() +
      labs(title = "Word Cloud of Movie Titles and Genres") +
      theme(
      plot.title = element_text(hjust = 0.5),  # Center the title
    )
  })
  
  # Render the genre analysis plot
  output$genrePlot <- renderPlot({
    genre_data <- filteredData() %>%
      group_by(Genre) %>%
      summarize(
        Count = n(),
        AvgRating = mean(rating, na.rm = TRUE)
      )
    ggplot(genre_data, aes(x = reorder(Genre, Count), y = Count, fill = AvgRating)) +
      geom_bar(stat = "identity", color = "black") +
      coord_flip() +
      labs(title = "Movie Genre Analysis", x = "Genre", y = "Count") +
      theme_minimal()
  })
  
  # Render the budget vs rating plot (scatter plot to show relationship)
  output$budgetRatingPlot <- renderPlot({
    data <- filteredData() %>% 
      filter(!is.na(budget))  # Only plot movies with valid budgets
    ggplot(data, aes(x = budget, y = rating)) +
      geom_point(aes(color = Genre), alpha = 0.7) +
      geom_smooth(method = "lm", se = FALSE, color = "red") +  # Add a linear regression line
      labs(title = "Budget vs Rating of Movies", x = "Budget (in millions)", y = "Rating") +
      theme_minimal() +
      theme(legend.position = "bottom")
  })
  
  # Render information about missing budget data
  output$missingBudgetInfo <- renderText({
    missing_count <- sum(is.na(data$budget))
    paste("There are", missing_count, "movies with missing budget data.")
  })
  
  # Download filtered data as a CSV file
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("filtered_movies_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(filteredData(), file, row.names = FALSE)
    }
  )
  
  # Clear all settings when the button is clicked
  observeEvent(input$clearSettings, {
    # Reset all inputs
    updateTextInput(session, "titleInput", value = "")
    updateSliderInput(session, "yearInput", value = c(1900, 2022))  
    updateSliderInput(session, "ratingInput", value = c(0, 10))  
    updateCheckboxGroupInput(session, "genreInput", selected = NULL)  
    updateCheckboxInput(session, "excludeMissingBudget", value = FALSE)  
    
    # Clear the filter and reset the table
    output$movieTable <- renderDT({
      datatable(data, filter = 'top', options = list(pageLength = 10, scrollX = TRUE, autoWidth = TRUE))
    })
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
