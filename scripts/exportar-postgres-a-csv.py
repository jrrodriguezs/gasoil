#!/usr/bin/env python3
"""
Exporta las tablas gas_app_ruta y gas_app_puntocoordenada desde PostgreSQL
a los archivos CSV de seed data del proyecto.
"""
import csv
from datetime import datetime, timezone
from pathlib import Path

import psycopg2

ROOT = Path(__file__).resolve().parent.parent
RUTA_CSV_PATH = ROOT / 'db' / 'data' / 'gas.app-Ruta.csv'
PUNTO_CSV_PATH = ROOT / 'db' / 'data' / 'gas.app-PuntoCoordenada.csv'

PG_CONFIG = {
    'host': 'localhost',
    'port': 5441,
    'user': 'postgres',
    'password': 'gas-db',
    'database': 'gas-db',
}


def format_decimal(value):
    if value is None:
        return ''
    return str(value)


def format_timestamp(value):
    if value is None:
        return ''
    if isinstance(value, datetime):
        return value.strftime('%Y-%m-%dT%H:%M:%SZ')
    return str(value)


def exportar_ruta(cur):
    cur.execute('''
        SELECT id, destino, origen, latitudorigen, longitudorigen,
               distanciakm, latitud, longitud, destinoscount
        FROM gas_app_ruta
        ORDER BY destino, id
    ''')
    rows = cur.fetchall()

    fieldnames = [
        'ID', 'destino', 'origen', 'latitudOrigen', 'longitudOrigen',
        'distanciaKm', 'latitud', 'longitud', 'destinosCount'
    ]

    with open(RUTA_CSV_PATH, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({
                'ID': row[0],
                'destino': row[1],
                'origen': row[2],
                'latitudOrigen': format_decimal(row[3]),
                'longitudOrigen': format_decimal(row[4]),
                'distanciaKm': format_decimal(row[5]),
                'latitud': format_decimal(row[6]),
                'longitud': format_decimal(row[7]),
                'destinosCount': row[8] if row[8] is not None else '',
            })

    print(f'Exportadas {len(rows)} rutas a {RUTA_CSV_PATH}')


def exportar_puntos(cur):
    cur.execute('''
        SELECT id, orden, latitud, longitud, descripcion, ruta_id, createdat
        FROM gas_app_puntocoordenada
        ORDER BY ruta_id, orden, id
    ''')
    rows = cur.fetchall()

    fieldnames = ['ID', 'orden', 'latitud', 'longitud', 'descripcion', 'ruta_ID', 'createdAt']

    with open(PUNTO_CSV_PATH, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({
                'ID': row[0],
                'orden': row[1] if row[1] is not None else '',
                'latitud': format_decimal(row[2]),
                'longitud': format_decimal(row[3]),
                'descripcion': row[4],
                'ruta_ID': row[5],
                'createdAt': format_timestamp(row[6]),
            })

    print(f'Exportados {len(rows)} puntos a {PUNTO_CSV_PATH}')


def main():
    conn = psycopg2.connect(**PG_CONFIG)
    cur = conn.cursor()
    try:
        exportar_ruta(cur)
        exportar_puntos(cur)
    finally:
        cur.close()
        conn.close()
    print('Exportacion completada.')


if __name__ == '__main__':
    main()
