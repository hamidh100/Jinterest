package server;

import database.DatabaseManager;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class Server {
    private final int port;
    private final Router router;
    private final ExecutorService clientPool;

    public Server(int port) throws IOException {
        this.port = port;
        this.router = new Router();
        this.clientPool = Executors.newFixedThreadPool(8);
        DatabaseManager.load();
    }

    public void start() throws IOException {
        try (ServerSocket serverSocket = new ServerSocket(port)) {
            System.out.println("Jinterest server listening on port " + port);
            while (true) {
                Socket clientSocket = serverSocket.accept();
                clientSocket.setSoTimeout(60000);
                clientPool.submit(new ClientHandler(clientSocket, router));
            }
        } finally {
            clientPool.shutdown();
        }
    }
}
