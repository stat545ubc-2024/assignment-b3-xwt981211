# Movie Explorer Shiny App

## Description
The Movie Explorer app allows users to filter and explore a collection of movies based on various criteria such as title, genre, rating, and year range. It also includes visualizations such as word clouds of movie titles, genre analysis, and budget vs rating plots. The app is designed to help users better explore a collection of movies from the `ggplot2movies` dataset and easier to find movies that interest them.

## Shiny App Link
You can access the deployed app here: [Link to the Shiny App](https://xuwt1211.shinyapps.io/movieexplorer/)

## Features
The app includes the following interactive features:

### 1. **Filters and Search**
   Users can filter movies based on multiple criteria:
   
   - **Search by Movie Title**: A text input field allows users to search for movies by their title.
   - **Year Range Filter**: Users can select a range of years using a slider to filter movies based on their release year.
   - **Rating Range Filter**: A slider allows users to filter movies based on their rating. Users can select a range of ratings from 0 to 10.
   - **Genre Filter**: Users can filter movies by genre using check-boxes. Available genres include Action, Animation, Comedy, Drama, Documentary, Romance, and Short.
   - **Budgets Mising Value Filter**: Users can ignore movies which do not have value in 'budget' column by selecting ' Exclude Movies with Missing Budget'.
   
### 2. **Movie Table**
   An interactive table displays the filtered movie data. Users can sort the table by various columns (e.g., title, year, rating) and view details of the movies in the table. The table also allows users to download the filtered data as a CSV file.

### 3. **Word Cloud of Movie Titles and Genres**
   A word cloud visualizes the most frequent words in movie titles and genres. Users can observe which words and genres appear most often in the dataset, with larger words representing higher frequency.

### 4. **Genre Analysis Plot**
   A bar chart provides insights into the distribution of movies across different genres, with color-coding based on the average rating for each genre.

### 5. **Budgets vs Rating Analysis**
   A scatter plot shows the relationship between movie budgets and ratings. This visualization helps users understand if there is any correlation between a movie's budget and its average rating. **Note**: Movies with missing `budget` values are excluded from this analysis to avoid misleading results.
   
### 6. **Download Filtered Data**
   Users can download the table of filtered movies as a CSV file. The CSV will include only the movies that match the selected filters (e.g., title, year, rating, and genre). This feature allows users to take the data offline for further analysis or use.

## Instructions
1. Use the filters in the sidebar to select the movie title, year range, rating range, genre and ignoring missing value for 'budget'.
2. View the interactive movie table, word cloud, genre analysis, and budget vs rating plots in the main panel.
3. Click "Clear All Settings" to reset all filter settings.
4. Download the filtered movie data as a CSV file by clicking "Download Filtered Data".

## Dataset

This dataset is publicly available via the `ggplot2movies` package, which is part of the `ggplot2` ecosystem. You can access the full dataset and more details in the [ggplot2movies package documentation](https://rdrr.io/cran/ggplot2movies/). This dataset contains information about movies, including attributes such as:

- `title`: The title of the movie.
- `year`: The year the movie was released.
- `length`: The duration of the movie in minutes.
- `budget`: The budget of the movie (some values may be missing).
- `rating`: The rating of the movie.
- `votes`: The number of votes the movie has received.
- `r1`, `r2`, ..., `r10`: Ratings or reviews from different sources.
- `mpaa`: The MPAA rating of the movie (e.g., G, PG, PG-13, R).
- Genre columns: Binary columns indicating whether the movie belongs to a specific genre (e.g., Action, Animation, Comedy, etc.).

### Source

The `ggplot2movies` dataset can be accessed as follows:

```r
library(ggplot2movies)
data(movies)

```



