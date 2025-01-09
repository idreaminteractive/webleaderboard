-- name: ListUsers :many 
SELECT
    *
FROM
    user;

-- name: GetUserById :one 
SELECT
    id,
    email
FROM
    user
WHERE
    id = ?;

-- name: GetAnotherOne :one 
Select
    email,
    created_at
from
    user
where
    id = 1;