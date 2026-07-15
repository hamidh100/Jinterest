import server.Server;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.nio.charset.StandardCharsets;

public class TestClient {

    public static void main(String[] args) throws Exception {
        final int PORT = 5599;
        Server server = new Server(PORT);
        Thread serverThread = new Thread(() -> {
            try {
                server.start();
            } catch (Exception e) {
                System.err.println("Server failed: " + e.getMessage());
            }
        });
        serverThread.start();

        try (Socket socket = new Socket("localhost", PORT);
             PrintWriter out = new PrintWriter(
                     socket.getOutputStream(), true, StandardCharsets.UTF_8);
             BufferedReader in = new BufferedReader(
                     new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8))) {

            String request = "{\"method\":\"GET\",\"route\":\"ping\",\"payload\":{}}";
            System.out.println("-> " + request);
            out.println(request);
            System.out.println("<- " + in.readLine());
        }
    }
}
