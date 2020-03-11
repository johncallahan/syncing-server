# Sessions specification

## Authentication workflow

### Current

1. The client performs a sign in request to the server. The `email` (identifier) and `password` are sent along this request.

1. The server issues a JWT, which is used to authenticate subsequent requests. The JWT is sent in the `Authorization` HTTP header.

1. The JWT can be used indefinitly to authenticate the user.

**Advantages:**
* *Stateless*: no session is created in the backend
* No cookies required
* Easy to implement and manage

**Disadvantages:**
* A token can be stolen or exposed, meaning that an unauthorized user can access privileged information
* Tokens can only be revoked by changing the `secret_key_base` on the server. Doing this will revoke ***ALL*** issued tokens

### Proposed

TBD

## Schema

The session store will consist of the following schema:

| Field      | Type         | Null | Key | Default | Extra |
|------------|--------------|------|-----|---------|-------|
| uuid       | varchar(36)  | NO   | PRI | NULL    |       |
| user_uuid  | varchar(255) | YES  | MUL | NULL    |       |
| user_agent | text         | YES  |     | NULL    |       |
| created_at | datetime     | NO   |     | NULL    |       |
| updated_at | datetime     | NO   | MUL | NULL    |       |

## Revokation

Sessions should be revoked when needed. Additional endpoints will be exposed to perform such actions:

| Method    | URL            | Params       | Description                                       |
|--------   |----------------|--------------|---------------------------------------------------|
|`POST`     | /auth/sign_out | *None*       | Terminates the current session.                   |
|`DELETE`   | /session       | **uuid**     | Revokes or deletes the specified session by UUID. |
|`DELETE`   | /sessions      | *None*       | Revokes all sessions, except the current one.     |

## Expiration

TBD

## Token types

- **JWT**: The token is used to represent "claims", that are transferred between two parties. The claims in a JWT are encoded as a JSON object.

- **Opaque Tokens**: These are random string which act as pointers to information that is held only by the system that issues them. Requires a database/cache lookup each time they are used. Also, a single token can easily revoked on demand.

## Client-side implications

TBD

## JWT migration

TBD