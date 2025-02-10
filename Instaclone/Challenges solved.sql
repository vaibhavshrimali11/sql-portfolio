-- 5 oldest users
SELECT * FROM users
ORDER BY created_at
LIMIT 5;

-- What day of week user register on , We have to create add campgain

SELECT TO_CHAR(created_at, 'Day') AS "day of week", COUNT(*) AS "total_registration"
FROM users
GROUP BY TO_CHAR(created_at, 'Day')
ORDER BY "total_registration" DESC;

-- We want to target our inactive users with an email campaign. Find users who never posted.
SELECT username
FROM users
LEFT JOIN photos p ON users.id = p.user_id
WHERE p.id IS NULL;

-- We are running a new contest to see who can get more likes on a single photo, Who Won?
SELECT u.username, p.id, p.image_url, COUNT(*) AS total_likes
FROM likes l
JOIN photos p ON p.id = l.photo_id
JOIN users u ON u.id = l.user_id
GROUP BY u.username, p.id, p.image_url
ORDER BY total_likes ASC
LIMIT 1;

-- How many times a average user post
SELECT ROUND((SELECT COUNT(*) FROM photos)/(SELECT COUNT(*) FROM users),2) AS Average_post;

--User ranking by posting higher to lower

SELECT u.username, COUNT(p.image_url) AS posts
FROM users u
JOIN photos p ON u.id = p.user_id
GROUP BY u.id
ORDER BY posts DESC;

-- Total posts by users
SELECT SUM(user_posts.total_posts_per_user)
FROM (SELECT users.username, COUNT(photos.image_url) AS total_posts_per_user
      FROM users
	  JOIN photos ON users.id = photos.user_id
	  GROUP BY users.id) AS user_posts;

-- total number of users who have posted at least one time

SELECT COUNT(DISTINCT(users.id)) AS total_number_of_users_with_posts
FROM users
JOIN photos ON users.id = photos.user_id;

/*A brand wants to know which hashtags to use in a post
What are the top 5 most commonly used hashtags?*/
SELECT tag_name, COUNT(tag_name) AS total
FROM tags
JOIN photo_tags ON tags.id = photo_tags.tag_id
GROUP BY tags.id
ORDER BY total DESC
LIMIT 5;

/*We have a small problem with bots on our site...
Find users who have liked every single photo on the site*/
SELECT users.id, users.username, COUNT(likes.user_id) AS total_likes_by_user
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id
HAVING COUNT(likes.user_id) = (SELECT COUNT(*) FROM photos);

/*We also have a problem with celebrities
Find users who have never commented on a photo*/
SELECT username, comment_text
FROM users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY users.id, comment_text
HAVING comment_text IS NULL;


SELECT COUNT(*) 
FROM (
    SELECT username
    FROM users
    LEFT JOIN comments ON users.id = comments.user_id
    GROUP BY users.id
    HAVING COUNT(comments.id) = 0
) AS total_number_of_users_without_comments;

