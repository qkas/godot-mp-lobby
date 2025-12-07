# Godot + Flask Matchmaking Lobby

This is a minimal peer-to-peer multiplayer lobby system built with the [Godot](https://godotengine.org/) game engine and a lightweight Flask backend.

The system allows players to **host** and **join** multiplayer sessions using short join codes, without needing to exchange IP addresses. The host's machine uses **UPnP** to open the required port, enabling connections across networks.

## Features

- Simple join-code based matchmaking
- UPnP port forwarding for external hosting
- Flask backend for lobby code registration and resolution
- Asynchronous networking logic using `await`
- Modular Godot client with clean autoload architecture
- UI for hosting, joining, and viewing synchronized players

## Getting Started

### 1. Set Up the Flask Matchmaking Server

You can run the backend locally or deploy it on a free platform like [PythonAnywhere](https://www.pythonanywhere.com/).

To set it up:
Copy the code from the file `matchmaker-main.py` into the your Flask server's `main.py` file.

The server will expose two endpoints:
- `/register` – Host sends a POST request to receive a join code.
- `/resolve` – Client sends a GET request with the code to resolve it to an IP address.

### 2. Update the Godot Client

In the `MultiplayerManager` autoload script, set your server’s address:

```gdscript
const MATCHMAKING_SERVER_URL: String = "https://your-matchmaking-server.com"
```

Replace the placeholder with the actual URL of your hosted Flask server.

### 3. Enable UPnP (Port Forwarding)

- For external connections to work, UPnP must be **enabled in your router settings**.
- If UPnP is unavailable or disabled, the host will only support LAN connections.

### 4. Run the Godot Client

Open the project in the [Godot Engine](https://godotengine.org/download), and run multiple instances to simulate multiple players. Use the UI to host or join games with generated lobby codes.

## Testing

- Host a game using the "Host" tab – a 4-digit join code will be displayed and copied to clipboard.
- On another device or instance, input the code in the "Join" tab and connect.

## License

MIT License
