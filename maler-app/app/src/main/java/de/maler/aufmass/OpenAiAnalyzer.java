package de.maler.aufmass;

import android.graphics.Bitmap;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

final class OpenAiAnalyzer {
    private static final String ANALYZE_URL = "https://homeserver.tail8694ff.ts.net/analyze-photo";
    private static final String CALCULATE_URL = "https://homeserver.tail8694ff.ts.net/calculate-quantities";

    private OpenAiAnalyzer() {}

    static JSONObject analyze(Bitmap source) throws Exception {
        Bitmap image = downscale(source, 1600);
        ByteArrayOutputStream imageBytes = new ByteArrayOutputStream();
        image.compress(Bitmap.CompressFormat.JPEG, 82, imageBytes);
        byte[] jpeg = imageBytes.toByteArray();

        String boundary = "----MalerKiBoundary" + System.currentTimeMillis();
        HttpURLConnection con = (HttpURLConnection) new URL(ANALYZE_URL).openConnection();
        con.setRequestMethod("POST");
        con.setConnectTimeout(20000);
        con.setReadTimeout(180000);
        con.setDoOutput(true);
        con.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
        con.setRequestProperty("Accept", "application/json");

        try (OutputStream out = con.getOutputStream()) {
            out.write(("--" + boundary + "\r\n").getBytes(StandardCharsets.UTF_8));
            out.write("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n".getBytes(StandardCharsets.UTF_8));
            out.write("Content-Type: image/jpeg\r\n\r\n".getBytes(StandardCharsets.UTF_8));
            out.write(jpeg);
            out.write("\r\n".getBytes(StandardCharsets.UTF_8));
            out.write(("--" + boundary + "--\r\n").getBytes(StandardCharsets.UTF_8));
        }

        JSONObject root = readJsonResponse(con, "Maler-KI Bildanalyse");
        if (!"ok".equals(root.optString("status")) || !root.has("analysis")) {
            throw new Exception("Unerwartete Antwort der Maler-KI Bildanalyse.");
        }
        return root.getJSONObject("analysis");
    }

    static JSONObject calculateQuantities(JSONObject measurements) throws Exception {
        HttpURLConnection con = (HttpURLConnection) new URL(CALCULATE_URL).openConnection();
        con.setRequestMethod("POST");
        con.setConnectTimeout(20000);
        con.setReadTimeout(60000);
        con.setDoOutput(true);
        con.setRequestProperty("Content-Type", "application/json; charset=utf-8");
        con.setRequestProperty("Accept", "application/json");

        byte[] body = measurements.toString().getBytes(StandardCharsets.UTF_8);
        con.setFixedLengthStreamingMode(body.length);
        try (OutputStream out = con.getOutputStream()) {
            out.write(body);
        }

        JSONObject root = readJsonResponse(con, "Maler-KI Mengenberechnung");
        if (!"ok".equals(root.optString("status")) || !root.has("quantities")) {
            throw new Exception("Unerwartete Antwort der Maler-KI Mengenberechnung.");
        }
        return root.getJSONObject("quantities");
    }

    private static JSONObject readJsonResponse(HttpURLConnection con, String label) throws Exception {
        int code = con.getResponseCode();
        InputStream stream = code >= 200 && code < 300 ? con.getInputStream() : con.getErrorStream();
        String response = new String(readAll(stream), StandardCharsets.UTF_8);
        if (code < 200 || code >= 300) {
            throw new Exception(label + " " + code + ": " + response);
        }
        return new JSONObject(response);
    }

    private static byte[] readAll(InputStream in) throws Exception {
        if (in == null) return new byte[0];
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] buffer = new byte[8192];
        int n;
        while ((n = in.read(buffer)) != -1) out.write(buffer, 0, n);
        return out.toByteArray();
    }

    private static Bitmap downscale(Bitmap source, int maxSide) {
        int w = source.getWidth(), h = source.getHeight();
        int largest = Math.max(w, h);
        if (largest <= maxSide) return source;
        float f = maxSide / (float) largest;
        return Bitmap.createScaledBitmap(source, Math.round(w * f), Math.round(h * f), true);
    }
}
