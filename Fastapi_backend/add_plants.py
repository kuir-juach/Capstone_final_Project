import sqlite3

conn = sqlite3.connect('leafsense.db')
cursor = conn.cursor()

# Create plant_info table
cursor.execute('''
    CREATE TABLE IF NOT EXISTS plant_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plant_name TEXT UNIQUE NOT NULL,
        medicinal_values TEXT,
        preparations TEXT,
        dosage_guidance TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
''')

# Insert Neem
cursor.execute('''
    INSERT OR REPLACE INTO plant_info 
    (plant_name, medicinal_values, preparations, dosage_guidance)
    VALUES (?, ?, ?, ?)
''', ('Neem', 
      'Antibacterial, Antifungal, Antiviral, Anti-inflammatory, Antimalarial (traditional use), and Topical wound-healing properties.',
      '''1. Decoction (drink): Boil 10–15 fresh neem leaves in 500 ml of water until reduced by half. Strain and allow to cool. Drink small amounts. Used traditionally for general internal cleansing and fevers.
2. Topical paste: Grind fresh leaves into a paste and apply directly to the affected skin area for cuts, sores, or insect bites. Rinse after a short period if irritation occurs. Test on a small skin patch first to check for sensitivity.
3. Neem oil (external use): Use commercially prepared neem oil or an infused oil for massage or scalp applications. Do not ingest pure neem oil. Useful against lice and some skin conditions; dilute before skin use.''',
      '''General advice: Traditional uses vary. Dosages differ by preparation. Only follow guidance from a qualified practitioner.
Traditional examples:
• Decoction (traditional): small cup (≈50–100 ml) once daily or as advised by an herbalist.
• Topical: apply paste to area 1–2 times daily as needed.
Contraindications: Avoid ingestion during pregnancy or breastfeeding. Not recommended for infants or small children without medical advice. People with liver disease or on medication should consult a doctor.
Safety note: High doses or prolonged internal use can be harmful. This is educational/traditional information, not medical advice.
Note: For personalized treatment or further guidance, please book a one-on-one consultation with our doctors through the app.'''))

# Insert Betle
cursor.execute('''
    INSERT OR REPLACE INTO plant_info 
    (plant_name, medicinal_values, preparations, dosage_guidance)
    VALUES (?, ?, ?, ?)
''', ('Betle',
      'Digestive aid, Antimicrobial, Anti-inflammatory, Oral hygiene benefits, and Wound healing.',
      '''1. Betle leaf decoction: Boil 3–4 fresh betle leaves in 300 ml of water for 10 minutes. Strain and let cool before drinking. Used to improve digestion and reduce bad breath.
2. Topical application: Crush fresh betle leaves and apply the juice to wounds or skin irritations. Traditionally used for minor cuts and fungal infections.
3. Mouth rinse: Soak a few betle leaves in warm water, strain, and use as a natural mouthwash. Helps freshen breath and maintain oral hygiene.''',
      '''General advice: Betle is traditionally used in small amounts. Excessive use may cause irritation.
Traditional examples:
• Decoction: 50–100 ml once daily after meals.
• Topical: apply leaf juice 1–2 times daily as needed.
Contraindications: Avoid excessive chewing as it may irritate the mouth lining. Not recommended for people with mouth ulcers or at risk of oral cancer.
Safety note: Safe in small quantities for traditional use. Avoid combining with tobacco or lime.
Note: For personalized treatment or further guidance, please book a one-on-one consultation with our doctors through the app.'''))

# Insert Sinensis
cursor.execute('''
    INSERT OR REPLACE INTO plant_info 
    (plant_name, medicinal_values, preparations, dosage_guidance)
    VALUES (?, ?, ?, ?)
''', ('sinensis',
      'Rich in antioxidants, Supports heart health, Enhances metabolism, Improves mental alertness, and May lower the risk of chronic diseases.',
      '''1. Green tea infusion: Steep 1 teaspoon of dried green tea leaves in hot water (80°C) for 2–3 minutes. Strain before drinking. Commonly used for general well-being and detoxification.
2. Topical compress: Soak a cloth in cooled brewed green tea and apply to tired eyes or minor skin irritations. Used to reduce puffiness and soothe skin.''',
      '''General advice: Can be consumed daily in moderate amounts.
Traditional examples:
• 1–2 cups per day for general wellness.
• Topical compress: 10–15 minutes on affected area.
Contraindications: Avoid excessive consumption due to caffeine. Not advised for people with insomnia or stomach ulcers.
Safety note: Safe for daily use in moderation. Avoid high doses of green tea extract supplements.
Note: For personalized treatment or further guidance, please book a one-on-one consultation with our doctors through the app.'''))

conn.commit()
conn.close()
print("Plant information added successfully!")