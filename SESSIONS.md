# Sessions specification

## Authentication workflow

### **Current**

1. The client performs a sign in request to the server. The `email` (identifier) and `password` are sent along this request.

1. The server issues a JWT, which is used to authenticate subsequent requests. The JWT is sent in the `Authorization` HTTP header.

1. The JWT can be used indefinitly to authenticate the user. No session is stored in the server.

**Advantages:**
* **Stateless**: no session is created in the backend
* No cookies required
* Easy to implement and manage

**Disadvantages:**
* A token can be stolen or exposed, meaning that an unauthorized user can access privileged information
* Tokens can only be revoked by changing the `secret_key_base` on the server. Doing this will revoke ***ALL*** issued tokens

### **Proposed**

1. We'll issue a `token` that represents the initiated session by the user. We could use another HTTP Header different than the `Authorization` header. This way, we can determine if the client is using the old authentication scheme or not.

## Schema

The session store will consist of the following schema:

| Field      | Type         | Null | Key | Default | Extra |
|------------|--------------|------|-----|---------|-------|
| uuid       | varchar(36)  | NO   | PRI | NULL    |       |
| user_uuid  | varchar(255) | No   | MUL | NULL    |       |
| user_agent | text         | YES  |     | NULL    |       |
| created_at | datetime     | NO   |     | NULL    |       |
| updated_at | datetime     | NO   | MUL | NULL    |       |

A cached session store is not necessarily required, but one can be used in the future. For now, this will just be a table within our database.

## Revokation

Sessions should be revoked when needed. Additional endpoints will be exposed to perform such actions:

| Method    | URL            | Params       | Description                                       |
|--------   |----------------|--------------|---------------------------------------------------|
|`POST`     | /auth/sign_out | *None*       | Terminates the current session.                   |
|`DELETE`   | /session       | **uuid**     | Revokes or deletes the specified session by UUID. |
|`DELETE`   | /sessions      | *None*       | Revokes all sessions, except the current one.     |

## Expiration

Sessions should expire after a period of inactivity. This is for best security practices.

`Long-lived sessions` are a good choice for our use case, because it can build a better user experience than expiring sessions for a short idle-timeout.

## Token types

- **JWT**: The token is used to represent "claims", that are transferred between two parties. The claims in a JWT are encoded as a JSON object.
  A JWT contains "claims", which can be anything from [Registered Claims](https://tools.ietf.org/html/rfc7519#section-4.1), [Public Claims](https://tools.ietf.org/html/rfc7519#section-4.2), and [Private Claims](https://tools.ietf.org/html/rfc7519#section-4.3).

  Our current implementation of JWT uses 2 private claims: `user_uuid` and `pw_hash`.

  The JSON object looks like the following:

  ```
  {
    "user_uuid": "<the user's uuid>",
    "pw_hash": "<a SHA256 hash of the user's encrypted password>
  }
  ```

  Then, this JSON object is cryptographically signed with the server's `secret_key_base` and a token is obtained:

  `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`

  In short, JWTs are good for `authentication` because:

  > - When the server receives a JWT, it can validate that it is legitimate and trust that the user is whoever the token says they are.
  > - The server can validate this token locally without making any network requests, talking to a database, etc. This can potentially make session management faster because instead of needing to load the user from a database (or cache) on every request, you just need to run a small bit of local code. This is probably the single biggest reason people like using JWTs: they are stateless.
---

- **Opaque Tokens**: These are random string which act as pointers to information that is held only by the system that issues them. Requires a database/cache lookup each time they are used. Also, a single token can easily revoked on demand.

## Client-side implications

Any new changes to the authentication scheme will have to be adapted to be used on the client side and must co-exist with old client versions.

## Migration from JWT

How are we going to migrate from JWT?

  The following proposals were formulated:
  - If a valid JWT is provided, we'll create a new session for it. The JWT will be checked to see if there are no other sessions linked to the same. Finally, we'll return the new `token` that we'll be used to authenticate all following requests.

  - This will allow both old and new versions of the client to co-exist.