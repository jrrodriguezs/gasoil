#!/usr/bin/env python3
"""
Actualiza registros de Ruta y PuntoCoordenada en PostgreSQL segun datos del Excel Rutas.xlsx.
- Marca destinosCount = 2 en las rutas indicadas.
- Agrega 2 puntos por ruta:
    1) Maracaibo (coordenadas fijas)
    2) Destino segun el Excel.
"""
import csv
import uuid
from datetime import datetime, timezone
from pathlib import Path

import openpyxl
import psycopg2

ROOT = Path(__file__).resolve().parent.parent
EXCEL_PATH = ROOT / 'Rutas.xlsx'
RUTA_CSV_PATH = ROOT / 'db' / 'data' / 'gas.app-Ruta.csv'
PUNTO_CSV_PATH = ROOT / 'db' / 'data' / 'gas.app-PuntoCoordenada.csv'

PG_CONFIG = {
    'host': 'localhost',
    'port': 5441,
    'user': 'postgres',
    'password': 'gas-db',
    'database': 'gas-db',
}

# Lista exacta de destinos provista por el usuario.
DESTINOS_LISTA = [
    'CHIVACOA', 'CUMANA', 'LA YAGUARA', 'VALERA', 'MERIDA CLIENTE',
    'PUNTO FIJO', 'LA VILLA CLIENTE', 'SAN JOAQUIN', 'CD ARAGUA',
    'CHURUGUARA', 'CORO', 'BARQUISIMETO', 'SAN JOAQUIN', 'BARINAS',
    'YARACUY', 'GUANARE', 'ACARIGUA', 'TARATARA FALCON', 'YACACUY',
    'BARCELONA', 'LOS POTOCOS', 'YAGUARA', 'TRUJILLO', 'PTO FIJO',
    'TACHIRA', 'MACHIQUES', 'SANTA BARBARA', 'DABAJURO', 'MERIDA',
    'VIGIA', 'LA VILLA', 'ARAPUEY', 'VALENCIA', 'POTOCOS'
]


def leer_excel():
    """Devuelve diccionario: destino -> (latitud, longitud)."""
    wb = openpyxl.load_workbook(EXCEL_PATH)
    ws = wb.active
    datos = {}
    for row in ws.iter_rows(min_row=2, values_only=True):
        if not row or row[0] is None:
            continue
        destino = str(row[0]).strip()
        latitud = float(row[1]) if row[1] is not None else None
        longitud = float(row[2]) if row[2] is not None else None
        datos[destino] = (latitud, longitud)
    return datos


def actualizar_postgres(destinos_unicos, datos_excel):
    conn = psycopg2.connect(**PG_CONFIG)
    cur = conn.cursor()

    try:
        # Obtener IDs de rutas a actualizar (PostgreSQL usa 'destino').
        cur.execute(
            "SELECT id, destino FROM gas_app_ruta WHERE destino IN %s",
            (tuple(destinos_unicos),),
        )
        rutas = cur.fetchall()

        ruta_ids = [r[0] for r in rutas]
        now = datetime.now(timezone.utc)
        puntos_a_insertar = []

        for ruta_id, destino in rutas:
            lat, lon = datos_excel[destino]
            puntos_a_insertar.append((
                str(uuid.uuid4()), 0, 10.548921, -71.636708, 'Maracaibo',
                ruta_id, now, 'anonymous', now, 'anonymous'
            ))
            puntos_a_insertar.append((
                str(uuid.uuid4()), 1, lat, lon, destino,
                ruta_id, now, 'anonymous', now, 'anonymous'
            ))

        # Eliminar puntos existentes de estas rutas para evitar duplicados.
        if ruta_ids:
            cur.execute(
                "DELETE FROM gas_app_puntocoordenada WHERE ruta_id IN %s",
                (tuple(ruta_ids),),
            )
            print(f'Puntos eliminados previamente: {cur.rowcount}')

        # Actualizar destinosCount.
        cur.execute(
            "UPDATE gas_app_ruta SET destinoscount = 2 WHERE id IN %s",
            (tuple(ruta_ids),),
        )
        print(f'Rutas actualizadas en PostgreSQL: {cur.rowcount}')

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

        conn.commit()
    except Exception as e:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()

    return rutas


def actualizar_csv_ruta(rutas_actualizadas):
    rutas_set = {r[1] for r in rutas_actualizadas}

    with open(RUTA_CSV_PATH, 'r', newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames or []
        rows = list(reader)

    if 'destinosCount' not in fieldnames:
        fieldnames.append('destinosCount')

    for row in rows:
        if row.get('destino', '').strip() in rutas_set:
            row['destinosCount'] = '2'
        else:
            row['destinosCount'] = row.get('destinosCount', '')

    with open(RUTA_CSV_PATH, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f'CSV Ruta actualizado: {len([r for r in rows if r.get("destino", "").strip() in rutas_set])} registros con destinosCount=2')


def actualizar_csv_puntos(rutas_actualizadas, datos_excel):
    """Agrega los puntos al CSV de seed data usando los IDs del CSV de rutas."""
    destinos_set = {r[1] for r in rutas_actualizadas}

    with open(PUNTO_CSV_PATH, 'r', newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames or []
        existing = list(reader)

    now = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
    nuevos_puntos = []

    # Iterar directamente sobre las filas del CSV de rutas para no duplicar puntos.
    with open(RUTA_CSV_PATH, 'r', newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            destino = row.get('destino', '').strip()
            if destino not in destinos_set:
                continue
            ruta_id = row['ID']
            lat, lon = datos_excel[destino]
            nuevos_puntos.append({
                'ID': str(uuid.uuid4()),
                'orden': '0',
                'latitud': '10.548921',
                'longitud': '-71.636708',
                'descripcion': 'Maracaibo',
                'ruta_ID': ruta_id,
                'createdAt': now,
            })
            nuevos_puntos.append({
                'ID': str(uuid.uuid4()),
                'orden': '1',
                'latitud': str(lat),
                'longitud': str(lon),
                'descripcion': destino,
                'ruta_ID': ruta_id,
                'createdAt': now,
            })

    if 'orden' not in fieldnames:
        fieldnames.insert(1, 'orden')
    if 'createdAt' not in fieldnames:
        fieldnames.append('createdAt')

    for row in existing:
        for col in fieldnames:
            if col not in row:
                row[col] = ''
    for row in nuevos_puntos:
        for col in fieldnames:
            if col not in row:
                row[col] = ''

    with open(PUNTO_CSV_PATH, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(existing + nuevos_puntos)

    print(f'CSV PuntoCoordenada actualizado: {len(nuevos_puntos)} puntos nuevos')


def main():
    datos_excel = leer_excel()
    destinos_unicos = list(dict.fromkeys(DESTINOS_LISTA))

    faltantes = [d for d in destinos_unicos if d not in datos_excel]
    if faltantes:
        raise ValueError(f'Destinos no encontrados en el Excel: {faltantes}')

    rutas_actualizadas = actualizar_postgres(destinos_unicos, datos_excel)
    actualizar_csv_ruta(rutas_actualizadas)
    actualizar_csv_puntos(rutas_actualizadas, datos_excel)

    print('Actualizacion completada.')


if __name__ == '__main__':
    main()
