# Sessions specification

## Server-side implications

- A new API version will be created: `20200115`
- Sessions should include the API version they were created with. This way we can deny sessions for a given API version if we detect a vulnerability with that version in the future
- Sessions are created **only** on Sign In and/or Registration
- For API version `20200115`:
  - If a JWT is provided whose account version is `<= 003`, then the request should *succeed*
- For API version `20190520` and `20200115`:
  - If a JWT is provided whose account version is `>= 004`, then the request should *fail*

## Client-side implications

- [Clients send the API version](https://github.com/standardnotes/snjs/blob/64e4e65c7660b9758e7b59547223cd4deb808c56/lib/services/api/api_service.js#L14) whenever they make a request
- The API version for the `004` client will be `20200115`
- The `004` client will implement the Sessions feature according to the documentation

---

## Schema

The session store will consist of the following schema:

| Field      | Type         | Null | Key | Default | Extra |
|------------|--------------|------|-----|---------|-------|
| uuid       | varchar(36)  | NO   | PRI | NULL    |       |
| version    | varchar(50)  | NO   |     | NULL    |       |
| user_uuid  | varchar(255) | No   | MUL | NULL    |       |
| user_agent | text         | YES  |     | NULL    |       |
| created_at | datetime     | NO   |     | NULL    |       |
| updated_at | datetime     | NO   | MUL | NULL    |       |

A cached session store is not necessarily required, but one can be used in the future. For now, this will just be a table within our database.

---
## Revokation

Sessions should be revoked when needed. Additional endpoints will be exposed to perform such actions:

| Method    | URL            | Params       | Description                                       |
|--------   |----------------|--------------|---------------------------------------------------|
|`POST`     | /auth/sign_out | *None*       | Terminates the current session.                   |
|`DELETE`   | /session       | **uuid**     | Revokes or deletes the specified session by UUID. |
|`DELETE`   | /sessions      | *None*       | Revokes all sessions, except the current one.     |

---

## Expiration

Sessions should expire after a period of inactivity. This is for best security practices.

`Long-lived sessions` are a good choice for our use case, because it can build a better user experience than expiring sessions for a short idle-timeout.

---

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

  *This is the token type that is used for account version `<= 003`*

- **Opaque Tokens**: These are random string which act as pointers to information that is held only by the system that issues them. Requires a database/cache lookup each time they are used. Also, a single token can easily revoked on demand.

  *This is the token type that is used for account version `>= 004`*