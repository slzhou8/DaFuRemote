# RustDesk Client Custom Server Bootstrap

This repo now supports bootstrapping the client to your own RustDesk server from a local JSON file.

## How it works

On startup, the client will look for one of these files:

- `custom_server.json`
- `rustdesk_custom_server.json`

Search order:

1. Path from env `RUSTDESK_CUSTOM_SERVER_CONFIG`
2. The executable directory
3. The current working directory

If found, the client loads the file and initializes these local options when they are still empty:

- `custom-rendezvous-server`
- `api-server`
- `relay-server`
- `key`

This means a clean client install can connect to your own self-hosted stack out of the box.

## Example

Copy `custom_server.example.json` to `custom_server.json` and change it to your server:

```json
{
  "host": "your-domain.com:21116",
  "api": "https://your-domain.com:21114",
  "relay": "your-domain.com:21117",
  "key": ""
}
```

## Notes

- Existing user-configured server settings are not overwritten.
- For production, replace `127.0.0.1` with your real domain or public IP.
- If you want clients to pick up a new server after a previous bootstrap, clear the saved server settings first.
