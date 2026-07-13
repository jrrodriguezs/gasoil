#!/usr/bin/env python3
"""
Actualiza rutas compuestas en PostgreSQL segun el Excel Rutas_Desacopladas_Coordenadas V1.xlsx.
- Maracaibo siempre es el primer punto.
- Se agregan los puntos del Excel para cada Destino_original.
- destinosCount = cantidad total de puntos.
"""
import csv
import uuid
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

import openpyxl
import psycopg2

ROOT = Path(__file__).resolve().parent.parent
EXCEL_PATH = ROOT / 'Rutas_Desacopladas_Coordenadas V1.xlsx'
RUTA_CSV_PATH = ROOT / 'db' / 'data' / 'gas.app-Ruta.csv'
PUNTO_CSV_PATH = ROOT / 'db' / 'data' / 'gas.app-PuntoCoordenada.csv'

PG_CONFIG = {
    'host': 'localhost',
    'port': 5441,
    'user': 'postgres',
    'password': 'gas-db',
    'database': 'gas-db',
}

# Rutas indicadas por el usuario.
DESTINOS_LISTA = [
    'CD ARAGUA / SAN JOAQUIN', 'MERIDA CLIENTE', 'VIGIA / VALERA', 'SAN JOAQUIN / CABIMAS',
    'CD ARAGUA / CHIVACOA / VALENCIA', 'LOS POTOCOS / YARACUY', 'SAN JOAQUIN / LOS PUERTOS',
    'CHIVACOA / ARAGUA', 'MACIQUES / SAN JOAQUIN', 'VALENCIA / CHIVACOA', 'SAN JOAQUIN / CAUCAGUA / MCBO',
    'BARCELONA / CHIVACOA', 'LA VILLA / LOS PUERTOS', 'TRUJILLO / LA VILLA', 'TUREN / CLIENTE',
    'NUEVA LUCHA / SAN JOAQUIN', 'LOS PUERTOS / SAN JOAQUIN', 'CD ARAGUA / SAN JOAQUIN / MACHIQUES',
    'SAN JOAQUIN / MARACAIBO / VILLA DEL ROSARIO', 'SAN JOAQUIN / MACHIQUES', 'BACHAQUERO / SAN JOAQUIN / MACHIQUES',
    'CHIVACOA / PTO MCBO', 'NUEVA LUCHA SAN JOAQUIN', 'LA CONCEPCION / YARACUY', 'LA VILLA / YARACUY',
    'CHIVACOA / MORON / CABIMAS', 'LOS PUERTOS / VIGIA', 'LOS PUERTOS / PUNTO FIJO', 'MCBO SUR / SAN JOAQUIN',
    'LOS PUERTOS / YARACUY', 'CD ARAGUA / SAN JOAQUIN / LA VILLA', 'LA CONCEPCION / SAN JOAQUIN',
    'SAN JOAQUIN / CHIVACOA', 'PUNTO FIJO / MACHIQUES', 'BARCELONA / SAN JOAQUIN', 'CD ARAGUA / CHIVACOA',
    'LA VILLA / YARACUY / CHIVACOA', 'CHIVACOA / TURMERO', 'YARACUY / LA VILLA', 'LOS POTOCOS / CHIVACOA',
    'SAN JOAQUIN / CHIVACOA / MACHIQUES', 'CHIVACOA / TURMERO / CABIMAS', 'CHUTO / SAN JOAQUIN',
    'MENE MAUROA / YARACUY', 'SAN JOAQUIN / OCCICARGA', 'YAGUARA / CHIVACOA', 'VALENCIA / SAN JOAQUIN',
    'BEJUMA / SAN JOAQUIN', 'SAN JOAQUIN / POLAR 2 / SAN JOAQUIN', 'BARCELONA / CAUCAGUA / MCBO',
    'MACHIQUES / SAN JOAQUIN / MACHIQUES', 'LOS POTOCOS / SAN JOAQUIN', 'SAN JACINTO / SAN JOAQUIN / SAN JACINTO',
    'CHIVACOA / VALENCIA', 'VIGIA / LA VILLA', 'TRUJILLO / LA CONCEPCION', 'YARACUY / CHIVACOA',
    'CD ARAGUA / VALENCIA', 'MACHIQUES / SAN JOAQUIN', 'LA YAGUARA / VALENCIA / CHIVACOA', 'YAGUARA / YARACUY',
    'YARACUY / BARQUISIMETO', 'CHIVACOA / MORON', 'YAGUARA / VALENCIA', 'ARAPUEY CAJA SECA / LOS PUERTOS',
    'PTO CABELLO / TURMERO', 'VALENCIA / GUACARA', 'SAN JOAQUIN / NUEVA LUCHA', 'LA VILLA / LOS PUEROS',
    'LOS PUERTOS / PANAMERICANA', 'SAN JOAQUIN / LA VILLA', 'YAGUARA / SAN JOAQUIN', 'LA VILLA / TRUJILLO',
    'BARCELONA / CAUCAGUA', 'YARACUY / MACHIQUES'
]


def leer_excel():
    """Devuelve diccionario: Destino_original -> lista de (descripcion, latitud, longitud)."""
    wb = openpyxl.load_workbook(EXCEL_PATH)
    ws = wb.active
    datos = defaultdict(list)
    for row in ws.iter_rows(min_row=2, values_only=True):
        if row[0] is None:
            continue
        original = str(row[0]).strip()
        destino = str(row[1]).strip()
        latitud = float(row[2]) if row[2] is not None else None
        longitud = float(row[3]) if row[3] is not None else None
        datos[original].append((destino, latitud, longitud))
    return datos


def actualizar_postgres(destinos_unicos, datos_excel):
    conn = psycopg2.connect(**PG_CONFIG)
    cur = conn.cursor()

    try:
        # Obtener IDs de rutas a actualizar.
        cur.execute(
            "SELECT id, destino FROM gas_app_ruta WHERE destino IN %s",
            (tuple(destinos_unicos),),
        )
        rutas = cur.fetchall()

        ruta_ids = [r[0] for r in rutas]
        now = datetime.now(timezone.utc)
        puntos_a_insertar = []
        destinos_count_map = {}

        for ruta_id, destino in rutas:
            puntos = [('Maracaibo', 10.548921, -71.636708)]
            for desc, lat, lon in datos_excel.get(destino, []):
                puntos.append((desc, lat, lon))

            destinos_count_map[ruta_id] = len(puntos)

            for idx, (desc, lat, lon) in enumerate(puntos):
                puntos_a_insertar.append((
                    str(uuid.uuid4()), idx, lat, lon, desc,
                    ruta_id, now, 'anonymous', now, 'anonymous'
                ))

        # Eliminar puntos existentes de estas rutas para evitar duplicados.
        if ruta_ids:
            cur.execute(
                "DELETE FROM gas_app_puntocoordenada WHERE ruta_id IN %s",
                (tuple(ruta_ids),),
            )
            print(f'Puntos eliminados previamente: {cur.rowcount}')

        # Actualizar destinosCount por cada ruta.
        for ruta_id, count in destinos_count_map.items():
            cur.execute(
                "UPDATE gas_app_ruta SET destinoscount = %s WHERE id = %s",
                (count, ruta_id),
            )
        print(f'Rutas actualizadas en PostgreSQL: {len(rutas)}')

        # Insertar nuevos puntos.
        cur.executemany(
            """
            INSERT INTO gas_app_puntocoordenada
            (id, orden, latitud, longitud, descripcion, ruta_id, createdat, createdby, modifiedat, modifiedby)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            puntos_a_insertar,
        )
        print(f'Puntos insertados en PostgreSQL: {len(puntos_a_insertar)}')

        # Resumen
        print('\nResumen por ruta:')
        for ruta_id, destino in rutas:
            count = destinos_count_map[ruta_id]
            print(f'  {destino}: {count} puntos')

        conn.commit()
    except Exception as e:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()

    return rutas


def exportar_csvs():
    """Regenera los CSV de seed data desde PostgreSQL."""
    conn = psycopg2.connect(**PG_CONFIG)
    cur = conn.cursor()
    try:
        # Ruta
        cur.execute('''
            SELECT id, destino, origen, latitudorigen, longitudorigen,
                   distanciakm, latitud, longitud, destinoscount
            FROM gas_app_ruta
            ORDER BY destino, id
        ''')
        rows = cur.fetchall()
        with open(RUTA_CSV_PATH, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['ID', 'destino', 'origen', 'latitudOrigen', 'longitudOrigen',
                             'distanciaKm', 'latitud', 'longitud', 'destinosCount'])
            for row in rows:
                writer.writerow([
                    row[0], row[1], row[2],
                    row[3] if row[3] is not None else '',
                    row[4] if row[4] is not None else '',
                    row[5] if row[5] is not None else '',
                    row[6] if row[6] is not None else '',
                    row[7] if row[7] is not None else '',
                    row[8] if row[8] is not None else '',
                ])
        print(f'\nCSV Ruta exportado: {len(rows)} registros')

        # Puntos
        cur.execute('''
            SELECT id, orden, latitud, longitud, descripcion, ruta_id, createdat
            FROM gas_app_puntocoordenada
            ORDER BY ruta_id, orden, id
        ''')
        rows = cur.fetchall()
        with open(PUNTO_CSV_PATH, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['ID', 'orden', 'latitud', 'longitud', 'descripcion', 'ruta_ID', 'createdAt'])
            for row in rows:
                writer.writerow([
                    row[0],
                    row[1] if row[1] is not None else '',
                    row[2] if row[2] is not None else '',
                    row[3] if row[3] is not None else '',
                    row[4],
                    row[5],
                    row[6].strftime('%Y-%m-%dT%H:%M:%SZ') if row[6] else '',
                ])
        print(f'CSV Puntos exportado: {len(rows)} registros')
    finally:
        cur.close()
        conn.close()


def main():
    datos_excel = leer_excel()
    destinos_unicos = list(dict.fromkeys(DESTINOS_LISTA))

    faltantes = [d for d in destinos_unicos if d not in datos_excel]
    if faltantes:
        raise ValueError(f'Destinos no encontrados en el Excel: {faltantes}')

    actualizar_postgres(destinos_unicos, datos_excel)
    exportar_csvs()

    print('\nActualizacion completada.')


if __name__ == '__main__':
    main()
