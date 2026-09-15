package de.maler.aufmass;

import android.content.Context;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

final class XlsxTemplateWriter {
    private XlsxTemplateWriter() {}

    static byte[] build(Context context, Map<String, String> inputs, Map<String, String> spachtel) throws Exception {
        byte[] template;
        try (InputStream in = context.getAssets().open("Maler_Kalkulation_Vorlage.xlsx")) {
            template = readAll(in);
        }
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try (ZipInputStream zin = new ZipInputStream(new ByteArrayInputStream(template)); ZipOutputStream zout = new ZipOutputStream(out)) {
            ZipEntry e;
            while ((e = zin.getNextEntry()) != null) {
                byte[] data = readAll(zin);
                String name = e.getName();
                if ("xl/worksheets/sheet1.xml".equals(name)) {
                    String xml = new String(data, java.nio.charset.StandardCharsets.UTF_8); xml = patch(xml, inputs); data = xml.getBytes(java.nio.charset.StandardCharsets.UTF_8);
                } else if ("xl/worksheets/sheet5.xml".equals(name)) {
                    String xml = new String(data, java.nio.charset.StandardCharsets.UTF_8); xml = patch(xml, spachtel); data = xml.getBytes(java.nio.charset.StandardCharsets.UTF_8);
                } else if ("xl/workbook.xml".equals(name)) {
                    String xml = new String(data, java.nio.charset.StandardCharsets.UTF_8);
                    if (!xml.contains("calcPr")) xml = xml.replace("</x:workbook>", "<x:calcPr calcMode=\"auto\" fullCalcOnLoad=\"1\" forceFullCalc=\"1\"/></x:workbook>");
                    data = xml.getBytes(java.nio.charset.StandardCharsets.UTF_8);
                }
                ZipEntry n = new ZipEntry(name); n.setTime(e.getTime()); zout.putNextEntry(n); zout.write(data); zout.closeEntry(); zin.closeEntry();
            }
        }
        return out.toByteArray();
    }

    private static String patch(String xml, Map<String, String> values) {
        for (Map.Entry<String, String> entry : values.entrySet()) {
            String cell = Pattern.quote(entry.getKey()); String value = escapeXml(entry.getValue());
            Pattern p = Pattern.compile("(<x:c[^>]*\\sr=\\\"" + cell + "\\\"[^>]*>.*?<x:v>)(.*?)(</x:v>.*?</x:c>)", Pattern.DOTALL);
            Matcher m = p.matcher(xml);
            if (m.find()) xml = m.replaceFirst(Matcher.quoteReplacement(m.group(1) + value + m.group(3)));
        }
        return xml;
    }

    static Map<String, String> basicInputMap(double area, double perimeter, double height, double openings, int coats) {
        Map<String, String> m = new HashMap<>(); m.put("B4", num(area)); m.put("B5", num(perimeter)); m.put("B6", num(height)); m.put("B7", num(openings)); m.put("B8", Integer.toString(coats)); return m;
    }
    static String num(double v) { if (Math.rint(v) == v) return Long.toString((long) v); return Double.toString(v); }
    private static String escapeXml(String s) { return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"); }
    private static byte[] readAll(InputStream in) throws Exception { ByteArrayOutputStream b = new ByteArrayOutputStream(); byte[] buf = new byte[8192]; int n; while ((n = in.read(buf)) != -1) b.write(buf, 0, n); return b.toByteArray(); }
}
