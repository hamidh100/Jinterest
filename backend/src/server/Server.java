package server;

import database.DatabaseManager;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {
    private final int port;
    private final Router router;

    public Server(int port) throws IOException {
        this.port = port;
        this.router = new Router();
        DatabaseManager.load();
    }

    public void start() throws IOException {
        try (ServerSocket serverSocket = new ServerSocket(port)) {
            System.out.println("Jinterest server listening on port " + port);
            while (true) {
                Socket clientSocket = serverSocket.accept();
                Thread thread = new Thread(new ClientHandler(clientSocket, router));
                thread.start();
            }
        }
    }
}
