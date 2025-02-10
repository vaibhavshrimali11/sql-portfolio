--What are the top 5 most streamed songs in 2023?
SELECT track_name, artist_name, streams
FROM spotify_2023
ORDER BY streams DESC
LIMIT 5;

--How many unique artists contributed to the dataset?
SELECT COUNT(DISTINCT artist_name) AS unique_artists
FROM spotify_2023;
--What is the distribution of songs across different release years?
SELECT released_year, COUNT(*) AS song_count
FROM spotify_2023
GROUP BY released_year
ORDER BY released_year;

--Who are the top 10 artists based on popularity, and what are their tracks' average danceability and energy?
SELECT artist_name, 
       AVG(danceability_percent) AS avg_danceability, 
       AVG(energy_percent) AS avg_energy
FROM spotify_2023
GROUP BY artist_name
ORDER BY MAX(streams) DESC
LIMIT 10;
--What artists released the longest and the shortest songs?
(
    SELECT artist_name, track_name, bpm
    FROM spotify_2023
    ORDER BY bpm DESC
    LIMIT 1
)
UNION ALL
(
    SELECT artist_name, track_name, bpm
    FROM spotify_2023
    ORDER BY bpm ASC
    LIMIT 1
);
--  Song in the Highest Number of Spotify Playlists
SELECT track_name, artist_name, in_spotify_playlists
FROM spotify_2023
ORDER BY in_spotify_playlists DESC
LIMIT 1;

-- Correlation Between Streams and Presence in Spotify Charts
SELECT CORR(streams, in_spotify_charts) AS correlation
FROM spotify_2023;

--  Average BPM of Songs on Spotify
SELECT AVG(bpm) AS avg_bpm
FROM spotify_2023;

--  Average Danceability of the Top 15 Most Popular Songs
SELECT AVG(danceability_percent) AS avg_danceability
FROM (
    SELECT danceability_percent
    FROM spotify_2023
    ORDER BY streams DESC
    LIMIT 15
) AS top_songs;

--  Songs in Both Apple Music Charts & Spotify Charts
SELECT COUNT(*)
FROM spotify_2023
WHERE in_apple_charts > 0 AND in_spotify_charts > 0;

--  Do Apple Music Playlist Songs Have Higher Valence?
SELECT 
    AVG(valence_percent) FILTER (WHERE in_apple_playlists > 0) AS avg_valence_apple,
    AVG(valence_percent) FILTER (WHERE in_apple_playlists = 0) AS avg_valence_non_apple
FROM spotify_2023;

--  Trends in Songs on Deezer Charts by Release Month
SELECT released_month, COUNT(*) AS song_count
FROM spotify_2023
WHERE in_deezer_charts > 0
GROUP BY released_month
ORDER BY released_month;

--  Songs Common Between Deezer and Spotify Playlists
SELECT COUNT(*)
FROM spotify_2023
WHERE in_deezer_playlists::INTEGER > 0 AND in_spotify_playlists > 0;

--  Do Shazam Chart Songs Have Higher Danceability?
SELECT 
    AVG(danceability_percent) FILTER (WHERE in_shazam_charts::INTEGER > 0) AS avg_danceability_shazam,
    AVG(danceability_percent) FILTER (WHERE in_shazam_charts IS NULL OR in_shazam_charts = '0') AS avg_danceability_non_shazam
FROM spotify_2023;

--  Distribution of Speechiness Percentages for Shazam Chart Songs
SELECT speechiness_percent, COUNT(*) AS count
FROM spotify_2023
WHERE in_shazam_charts::INTEGER > 0
GROUP BY speechiness_percent
ORDER BY speechiness_percent;

--  Danceability Difference Between Major & Minor Modes
SELECT 
    mode, 
    AVG(danceability_percent) AS avg_danceability
FROM spotify_2023
GROUP BY mode;

--  Distribution of Acousticness by Key
SELECT key, 
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY acousticness_percent) AS median_acousticness
FROM spotify_2023
GROUP BY key
ORDER BY key;

--  Trends in Energy Levels Over the Years
SELECT released_year, AVG(energy_percent) AS avg_energy
FROM spotify_2023
GROUP BY released_year
ORDER BY released_year;

--  Most Common Song Keys in the Dataset
SELECT key, COUNT(*) AS count
FROM spotify_2023
GROUP BY key
ORDER BY count DESC
LIMIT 10;

--  Average Number of Artists Contributing to Chart Songs
SELECT AVG(artist_count) AS avg_artists
FROM spotify_2023
WHERE in_spotify_charts > 0 OR in_apple_charts > 0 OR in_deezer_charts > 0 OR in_shazam_charts::INTEGER > 0;

--  Danceability Based on Number of Artists
SELECT artist_count, AVG(danceability_percent) AS avg_danceability
FROM spotify_2023
GROUP BY artist_count
ORDER BY artist_count;

--  Valence Percentage Trends Over 2023 Months
SELECT released_month, AVG(valence_percent) AS avg_valence
FROM spotify_2023
WHERE released_year = 2023
GROUP BY released_month
ORDER BY released_month;

--  Trends in Song Keys Over the Years
SELECT released_year, key, COUNT(*) AS count
FROM spotify_2023
GROUP BY released_year, key
ORDER BY released_year, count DESC;

--  Songs with a Significant Presence Across All Platforms
SELECT track_name, artist_name
FROM spotify_2023
WHERE in_spotify_playlists > 0 
AND in_apple_playlists > 0 
AND in_deezer_playlists::INTEGER > 0 
AND in_shazam_charts::INTEGER > 0;

--  Distribution of Streams vs. Presence on Apple Music Charts
SELECT 
    in_apple_charts,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY streams) AS median_streams
FROM spotify_2023
GROUP BY in_apple_charts
ORDER BY in_apple_charts;

--  Correlation Between BPM and Danceability
SELECT CORR(bpm, danceability_percent) AS bpm_danceability_corr
FROM spotify_2023;

--  Correlation Between Liveness and Acousticness
SELECT CORR(liveness_percent, acousticness_percent) AS liveness_acousticness_corr
FROM spotify_2023;

--  Do High Valence Songs Have More Streams?
SELECT CORR(valence_percent, streams) AS valence_streams_corr
FROM spotify_2023;

--  Relationship Between Spotify Playlists and Apple Music Charts
SELECT CORR(in_spotify_playlists, in_apple_charts) AS playlist_chart_corr
FROM spotify_2023;

--  Distribution of Key and Mode Combinations
SELECT key, mode, COUNT(*) AS count
FROM spotify_2023
GROUP BY key, mode
ORDER BY count DESC;

--  Speechiness Variation Across Apple Music Playlists
SELECT in_apple_playlists, 
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY speechiness_percent) AS median_speechiness
FROM spotify_2023
GROUP BY in_apple_playlists
ORDER BY in_apple_playlists;

--  Patterns in Release Days of Charting Songs
SELECT released_day, COUNT(*) AS song_count
FROM spotify_2023
WHERE in_spotify_charts > 0 OR in_apple_charts > 0 OR in_deezer_charts > 0 OR in_shazam_charts::INTEGER > 0
GROUP BY released_day
ORDER BY released_day;

--  Correlation Between Instrumentalness and Energy
SELECT CORR(instrumentalness_percent, energy_percent) AS instrumentalness_energy_corr
FROM spotify_2023;

--  Detect Outliers in Various Features
SELECT track_name, artist_name, bpm, danceability_percent, energy_percent, acousticness_percent, instrumentalness_percent
FROM spotify_2023
WHERE bpm > (SELECT AVG(bpm) + 2 * STDDEV(bpm) FROM spotify_2023) 
   OR bpm < (SELECT AVG(bpm) - 2 * STDDEV(bpm) FROM spotify_2023)
   OR danceability_percent > (SELECT AVG(danceability_percent) + 2 * STDDEV(danceability_percent) FROM spotify_2023)
   OR energy_percent > (SELECT AVG(energy_percent) + 2 * STDDEV(energy_percent) FROM spotify_2023)
   OR acousticness_percent > (SELECT AVG(acousticness_percent) + 2 * STDDEV(acousticness_percent) FROM spotify_2023);

--  Table with Popularity Rankings for Each Song Key
SELECT key, 
       RANK() OVER (ORDER BY COUNT(*) DESC) AS popularity_rank,
       COUNT(*) AS song_count
FROM spotify_2023
GROUP BY key
ORDER BY popularity_rank;

--  Compare Most Popular Keys vs. Keys in Top 50 Songs
SELECT key, COUNT(*) AS total_count,
       SUM(CASE WHEN streams > (SELECT MIN(streams) FROM (SELECT streams FROM spotify_2023 ORDER BY streams DESC LIMIT 50) AS top50) THEN 1 ELSE 0 END) AS top_50_count
FROM spotify_2023
GROUP BY key
ORDER BY top_50_count DESC;

--  Identify Top Artists Based on Popularity
SELECT artist_name, 
       AVG(streams) AS avg_popularity,
       CASE 
           WHEN AVG(streams) >= 90 THEN 'Top Artist'
           ELSE 'Regular Artist'
       END AS artist_category
FROM spotify_2023
GROUP BY artist_name
HAVING AVG(streams) >= 90
ORDER BY avg_popularity DESC;


