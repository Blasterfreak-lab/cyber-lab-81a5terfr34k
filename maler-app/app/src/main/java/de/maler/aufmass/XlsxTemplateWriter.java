package de.maler.aufmass;

import android.content.Context;

import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

final class XlsxTemplateWriter {
    private XlsxTemplateWriter() {}

    static byte[] build(Context context, Map<String, String> in, Map<String, String> sp) throws Exception {
        double area = v(in, "B4"), perimeter = v(in, "B5"), height = v(in, "B6"), openings = v(in, "B7");
        int coats = Math.max(1, (int) v(in, "B8"));

        double holes=v(sp,"B5"), cracks=v(sp,"B6"), acrylicLm=v(sp,"B7"), point=v(sp,"B8"), q2=v(sp,"B9"), q3=v(sp,"B10"), q4=v(sp,"B11");
        double wallJoint=v(sp,"B15"), ceilingJoint=v(sp,"B16"), breakout=v(sp,"B17"), armStrip=v(sp,"B18"), armArea=v(sp,"B19"), q3Repair=v(sp,"B20"), q4Repair=v(sp,"B21");
        String quality = sp.get("B25") == null ? "Q3" : sp.get("B25");

        double spHours = holes*.06 + cracks*.12 + acrylicLm*.08 + point*.40 + q2*.45 + q3*.65 + q4*.90
                + wallJoint*.25 + ceilingJoint*.30 + breakout*.75 + armStrip*.12 + armArea*.20 + q3Repair*.65 + q4Repair*.90;
        double fineKg = holes*.03 + cracks*.08 + point*.70 + q2*1.00 + q3*1.20 + q4*1.50
                + wallJoint*.15 + ceilingJoint*.20 + breakout*.25 + armStrip*.10 + armArea*.10 + q3Repair*1.20 + q4Repair*1.50;
        double acrylicCart = acrylicLm*.03;
        double repairKg = wallJoint*1.50 + ceilingJoint*2.00 + breakout*5.00;
        double armM2 = armStrip*.25 + armArea*1.10;
        double spMaterial = packs(fineKg,10)*28 + packs(repairKg,25)*20 + packs(armM2,10)*20 + packs(acrylicCart,1)*3.5 + (spHours>0?12:0);

        double wallGross = perimeter*height;
        double wallNet = Math.max(0, wallGross-openings);
        double paintArea = area+wallNet;
        double paintLiters = paintArea*coats/6.0*1.10;
        double primerLiters = paintArea/8.0*1.10;
        double paintCost = packs(paintLiters,10)*39.95;
        double primerCost = packs(primerLiters,10)*14.95;
        double fleeceCost = packs(area*1.10,50)*29.25;
        double materialCost = paintCost + primerCost + fleeceCost + 12.00 + 14.58 + spMaterial;
        double laborHours = 18.0 + spHours;
        double laborCost = laborHours*30.0;
        double direct = materialCost+laborCost+45+25+20;
        double overhead = direct*.15;
        double self = direct+overhead;
        double profit = self*.12;
        double net = self+profit;
        double vat = net*.19;
        double gross = net+vat;

        Object[][] inputs = {
                {"Maler-Kalkulation – Eingaben", "Wert", "Einheit"},
                {"Grundfläche", area, "m²"}, {"Raumumfang", perimeter, "m"}, {"Raumhöhe", height, "m"},
                {"Fenster/Türen Abzug", openings, "m²"}, {"Anzahl Anstriche", coats, "x"},
                {"Farb-Ergiebigkeit", 6, "m²/L"}, {"Farbreserve", 10, "%"}, {"Interner Lohnkostensatz", 30, "€/h"},
                {"Gemeinkosten", 15, "%"}, {"Gewinn", 12, "%"}, {"MwSt.", 19, "%"},
                {"Anfahrt/Fahrzeug",45,"€"},{"Werkzeugverschleiß",25,"€"},{"Entsorgung/Reserve",20,"€"}
        };

        Object[][] materials = {
                {"Material", "Bedarf", "Einheit", "Kosten €"},
                {"Innenfarbe weiß", paintLiters, "L", paintCost}, {"Tiefgrund", primerLiters, "L", primerCost},
                {"Abdeckvlies", area*1.10, "m²", fleeceCost}, {"Malerkrepp",4,"Rollen",12.0},
                {"Folie mit Klebeband",2,"Rollen",14.58},{"Spachtel-/Sanierungsmaterial",1,"Pauschale",spMaterial},
                {"Material gesamt", "", "", materialCost}
        };

        Object[][] labor = {
                {"Leistung","Stunden","Interner Satz €","Kosten €"},
                {"Abdecken / Abkleben",3,30,90},{"Spachtel-/Sanierungsarbeiten",spHours,30,spHours*30},
                {"Grundieren / Vorarbeiten",2,30,60},{"1. Anstrich",5,30,150},{"2. Anstrich",5,30,150},
                {"Abkleben entfernen / Reinigung",3,30,90},{"Arbeitszeit gesamt",laborHours,"",laborCost}
        };

        Object[][] result = {
                {"Angebotskalkulation – Ergebnis","Wert","Einheit"},{"Wandfläche brutto",wallGross,"m²"},
                {"Wandfläche netto",wallNet,"m²"},{"Deckenfläche",area,"m²"},{"Streichfläche gesamt",paintArea,"m²"},
                {"Farbbedarf inkl. Reserve",paintLiters,"L"},{"Materialkosten",materialCost,"€"},{"Arbeitsstunden",laborHours,"h"},
                {"Arbeitskosten intern",laborCost,"€"},{"Direkte Kosten",direct,"€"},{"Gemeinkosten",overhead,"€"},
                {"Selbstkosten",self,"€"},{"Gewinn",profit,"€"},{"Angebot netto",net,"€"},{"MwSt.",vat,"€"},
                {"Kundenpreis brutto",gross,"€"},{"Netto je m² Streichfläche",paintArea>0?net/paintArea:0,"€/m²"},
                {"Effektiver Netto-Stundensatz",laborHours>0?net/laborHours:0,"€/h"},{"Geplante Endqualität",quality,""}
        };

        Object[][] spackle = {
                {"Spachtelarbeiten – Detailkalkulation","Menge","Einheit","Zeit/Einheit h","Arbeitsstunden"},
                {"Bohr-/Dübellöcher",holes,"Stück",.06,holes*.06},{"Risse / kleine Schadstellen",cracks,"lfm",.12,cracks*.12},
                {"Acrylfugen / Anschlüsse",acrylicLm,"lfm",.08,acrylicLm*.08},{"Punktuelle Flächenspachtelung",point,"m²",.40,point*.40},
                {"Vollflächig Q2",q2,"m²",.45,q2*.45},{"Vollflächig Q3",q3,"m²",.65,q3*.65},{"Vollflächig Q4",q4,"m²",.90,q4*.90},
                {"Sanierung nach entfernten Zwischenwänden","","","",""},
                {"Ehemaliger Wandanschluss – grob schließen",wallJoint,"lfm",.25,wallJoint*.25},
                {"Ehemaliger Deckenanschluss – grob schließen",ceilingJoint,"lfm",.30,ceilingJoint*.30},
                {"Größere Putz-/Ausbruchstellen",breakout,"m²",.75,breakout*.75},
                {"Armierungsstreifen über Materialübergängen",armStrip,"lfm",.12,armStrip*.12},
                {"Armierungsgewebe flächig",armArea,"m²",.20,armArea*.20},
                {"Q3-Endspachtelung betroffene Flächen",q3Repair,"m²",.65,q3Repair*.65},
                {"Q4-Endspachtelung betroffene Flächen",q4Repair,"m²",.90,q4Repair*.90},
                {"Gesamt Arbeitszeit",spHours,"h","",""},{"Feinspachtel Bedarf",fineKg,"kg","",""},
                {"Reparaturputz Bedarf",repairKg,"kg","",""},{"Armierungsgewebe Bedarf",armM2,"m²","",""},
                {"Acryl Bedarf",acrylicCart,"Kart.","",""},{"Materialkosten",spMaterial,"€","",""},{"Geplante Endqualität",quality,"","",""}
        };

        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        try (ZipOutputStream z = new ZipOutputStream(bytes)) {
            put(z,"[Content_Types].xml", contentTypes());
            put(z,"_rels/.rels", rootRels());
            put(z,"xl/workbook.xml", workbook());
            put(z,"xl/_rels/workbook.xml.rels", workbookRels());
            put(z,"xl/styles.xml", styles());
            put(z,"xl/worksheets/sheet1.xml", sheet(inputs));
            put(z,"xl/worksheets/sheet2.xml", sheet(materials));
            put(z,"xl/worksheets/sheet3.xml", sheet(labor));
            put(z,"xl/worksheets/sheet4.xml", sheet(result));
            put(z,"xl/worksheets/sheet5.xml", sheet(spackle));
        }
        return bytes.toByteArray();
    }

    static Map<String, String> basicInputMap(double area, double perimeter, double height, double openings, int coats) {
        Map<String,String> m=new HashMap<>(); m.put("B4",num(area));m.put("B5",num(perimeter));m.put("B6",num(height));m.put("B7",num(openings));m.put("B8",Integer.toString(coats));return m;
    }
    static String num(double x){return Math.rint(x)==x?Long.toString((long)x):Double.toString(x);}
    private static double v(Map<String,String> m,String k){try{return Double.parseDouble(m.get(k).replace(',','.'));}catch(Exception e){return 0;}}
    private static int packs(double need,double pack){return need<=0?0:(int)Math.ceil(need/pack);}

    private static void put(ZipOutputStream z,String name,String text)throws Exception{z.putNextEntry(new ZipEntry(name));z.write(text.getBytes(StandardCharsets.UTF_8));z.closeEntry();}
    private static String esc(String s){return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");}
    private static String col(int n){StringBuilder s=new StringBuilder();while(n>0){n--;s.insert(0,(char)('A'+n%26));n/=26;}return s.toString();}
    private static String sheet(Object[][] rows){StringBuilder s=new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\"><sheetViews><sheetView workbookViewId=\"0\"/></sheetViews><sheetFormatPr defaultRowHeight=\"15\"/><cols><col min=\"1\" max=\"1\" width=\"42\" customWidth=\"1\"/><col min=\"2\" max=\"5\" width=\"18\" customWidth=\"1\"/></cols><sheetData>");
        for(int r=0;r<rows.length;r++){s.append("<row r=\"").append(r+1).append("\">");for(int c=0;c<rows[r].length;c++){Object o=rows[r][c];if(o==null)continue;String ref=col(c+1)+(r+1);if(o instanceof Number){s.append("<c r=\"").append(ref).append("\"><v>").append(String.format(Locale.US,"%.4f",((Number)o).doubleValue())).append("</v></c>");}else{s.append("<c r=\"").append(ref).append("\" t=\"inlineStr\"><is><t>").append(esc(String.valueOf(o))).append("</t></is></c>");}}s.append("</row>");}return s.append("</sheetData></worksheet>").toString();}
    private static String workbook(){return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"><sheets><sheet name=\"Eingaben\" sheetId=\"1\" r:id=\"rId1\"/><sheet name=\"Material\" sheetId=\"2\" r:id=\"rId2\"/><sheet name=\"Arbeitszeit\" sheetId=\"3\" r:id=\"rId3\"/><sheet name=\"Ergebnis\" sheetId=\"4\" r:id=\"rId4\"/><sheet name=\"Spachtelarbeiten\" sheetId=\"5\" r:id=\"rId5\"/></sheets></workbook>";}
    private static String workbookRels(){return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/><Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet2.xml\"/><Relationship Id=\"rId3\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet3.xml\"/><Relationship Id=\"rId4\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet4.xml\"/><Relationship Id=\"rId5\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet5.xml\"/><Relationship Id=\"rId6\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/></Relationships>";}
    private static String rootRels(){return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/></Relationships>";}
    private static String styles(){return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><styleSheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\"><fonts count=\"1\"><font><sz val=\"11\"/><name val=\"Calibri\"/></font></fonts><fills count=\"2\"><fill><patternFill patternType=\"none\"/></fill><fill><patternFill patternType=\"gray125\"/></fill></fills><borders count=\"1\"><border/></borders><cellStyleXfs count=\"1\"><xf/></cellStyleXfs><cellXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\"/></cellXfs></styleSheet>";}
    private static String contentTypes(){return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/><Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/><Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/><Override PartName=\"/xl/worksheets/sheet2.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/><Override PartName=\"/xl/worksheets/sheet3.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/><Override PartName=\"/xl/worksheets/sheet4.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/><Override PartName=\"/xl/worksheets/sheet5.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/></Types>";}
}
