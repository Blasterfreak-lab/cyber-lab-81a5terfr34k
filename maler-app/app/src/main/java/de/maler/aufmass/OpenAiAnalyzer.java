package de.maler.aufmass;

import android.graphics.Bitmap;
import android.util.Base64;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;

final class OpenAiAnalyzer {
    private OpenAiAnalyzer() {}

    static JSONObject analyze(Bitmap source, String apiKey, String model) throws Exception {
        Bitmap image = downscale(source, 1600);
        ByteArrayOutputStream imageBytes = new ByteArrayOutputStream();
        image.compress(Bitmap.CompressFormat.JPEG, 82, imageBytes);
        String b64 = Base64.encodeToString(imageBytes.toByteArray(), Base64.NO_WRAP);

        String prompt = "Du bist ein Aufmaß-Assistent für Malerarbeiten im Innenbereich. " +
                "Analysiere das Foto nur auf sichtbar ableitbare Maler- und Spachtelarbeiten. " +
                "Erfinde keine exakten Raummaße. Exakte Meter- oder Quadratmeterwerte nur dann schätzen, " +
                "wenn im Bild eine belastbare Referenz erkennbar ist; sonst null. Erkenne insbesondere " +
                "Bohr-/Dübellöcher, sichtbare Risse, Acrylfugen/Anschlüsse, punktuelle Spachtelflächen, " +
                "ehemalige Wandanschlüsse, ehemalige Deckenanschlüsse, Putz-/Ausbruchstellen, " +
                "Armierungsbedarf und eine sinnvolle Endqualität Q2/Q3/Q4. Bei zusammengelegten Räumen " +
                "mit sichtbaren ehemaligen Wandanschlüssen ist Q3 meist sinnvoll; Q4 nur bei erkennbar " +
                "kritischem Streiflicht bzw. sehr hoher Glätteanforderung. Antworte ausschließlich mit " +
                "einem JSON-Objekt ohne Markdown. Schlüssel: confidence (0..1), notes (String), " +
                "bohrloecher_stueck, risse_lfm, acrylfugen_lfm, punktuell_m2, wandanschluss_lfm, " +
                "deckenanschluss_lfm, ausbruch_m2, armierungsstreifen_lfm, armierung_flaechig_m2, " +
                "q2_m2, q3_m2, q4_m2, qualitaet (Q2|Q3|Q4). Werte, die nicht zuverlässig aus dem " +
                "Foto ableitbar sind, als null ausgeben.";

        JSONObject body = new JSONObject();
        body.put("model", model == null || model.trim().isEmpty() ? "gpt-5.4-mini" : model.trim());
        JSONArray input = new JSONArray();
        JSONObject msg = new JSONObject(); msg.put("role", "user");
        JSONArray content = new JSONArray();
        content.put(new JSONObject().put("type", "input_text").put("text", prompt));
        content.put(new JSONObject().put("type", "input_image").put("image_url", "data:image/jpeg;base64," + b64));
        msg.put("content", content); input.put(msg); body.put("input", input); body.put("max_output_tokens", 1200);

        HttpURLConnection con = (HttpURLConnection) new URL("https://api.openai.com/v1/responses").openConnection();
        con.setRequestMethod("POST"); con.setConnectTimeout(20000); con.setReadTimeout(60000); con.setDoOutput(true);
        con.setRequestProperty("Content-Type", "application/json"); con.setRequestProperty("Authorization", "Bearer " + apiKey.trim());
        con.getOutputStream().write(body.toString().getBytes(StandardCharsets.UTF_8));

        int code = con.getResponseCode();
        InputStream stream = code >= 200 && code < 300 ? con.getInputStream() : con.getErrorStream();
        String response = new String(readAll(stream), StandardCharsets.UTF_8);
        if (code < 200 || code >= 300) throw new Exception("API " + code + ": " + response);

        JSONObject root = new JSONObject(response);
        String text = findOutputText(root);
        if (text == null) throw new Exception("Keine Textantwort in der API-Antwort gefunden.");
        text = text.trim();
        if (text.startsWith("```")) { int first = text.indexOf('\n'); int last = text.lastIndexOf("```"); if (first >= 0 && last > first) text = text.substring(first + 1, last).trim(); }
        return new JSONObject(text);
    }

    private static String findOutputText(Object obj) throws Exception {
        if (obj instanceof JSONObject) {
            JSONObject jo = (JSONObject) obj;
            if (jo.has("type") && "output_text".equals(jo.optString("type")) && jo.has("text")) return jo.optString("text");
            Iterator<String> keys = jo.keys();
            while (keys.hasNext()) { String r = findOutputText(jo.get(keys.next())); if (r != null && !r.trim().isEmpty()) return r; }
        } else if (obj instanceof JSONArray) {
            JSONArray ja = (JSONArray) obj;
            for (int i = 0; i < ja.length(); i++) { String r = findOutputText(ja.get(i)); if (r != null && !r.trim().isEmpty()) return r; }
        }
        return null;
    }

    private static byte[] readAll(InputStream in) throws Exception { ByteArrayOutputStream out = new ByteArrayOutputStream(); byte[] buffer = new byte[8192]; int n; while ((n = in.read(buffer)) != -1) out.write(buffer, 0, n); return out.toByteArray(); }
    private static Bitmap downscale(Bitmap source, int maxSide) { int w = source.getWidth(), h = source.getHeight(); int largest = Math.max(w, h); if (largest <= maxSide) return source; float f = maxSide / (float) largest; return Bitmap.createScaledBitmap(source, Math.round(w * f), Math.round(h * f), true); }
}
