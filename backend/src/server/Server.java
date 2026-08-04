package server;

import database.DatabaseManager;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class Server {
    private static final int DEFAULT_PORT = 5050;
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

    public static void main(String[] args) {
        int port = DEFAULT_PORT;
        if (args.length > 1) {
            System.err.println("Usage: java server.Server [port]");
            System.exit(1);
        }
        if (args.length == 1) {
            try {
                port = Integer.parseInt(args[0]);
                if (port < 1 || port > 65535) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                System.err.println("Port must be an integer between 1 and 65535");
                System.exit(1);
            }
        }

        try {
            new Server(port).start();
        } catch (IOException e) {
            System.err.println("Could not start server: " + e.getMessage());
            System.exit(1);
        }
    }
}
