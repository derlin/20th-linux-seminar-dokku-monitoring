#!/usr/bin/env python3

import random
from time import sleep

import requests

BB_URL = "http://bbapi.dokku-dev.gdgfribourg.ch"
# BB_URL = "http://bbapi.dokku-demo.isc.heia-fr.ch"

BB_HEADERS = dict(
    bbuser='1',
    bbtoken='wr1'
)


def push_data(base_url):
    oid = random.randint(1, 2)
    data = dict(
        objectId=oid,
        token=f"012345678901234567890123456789a{oid}",
        value=random.randint(1, 100)
    )
    res = requests.post(f'{base_url}/objects/values', json=[data])
    print(f"pushed data: f{data}")
    return res


def get_data(base_url):
    res = requests.get(f'{base_url}/objects/{random.randint(1, 2)}/values/latest', headers=BB_HEADERS)
    if res.status_code == 200:
        print(f"got data: {res.text}")
    return res


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("-u", "--url", type=str, default=BB_URL, help="BBData API base URL")
    parser.add_argument("--interval", type=float, default=1.0, help="Pause between each requests, in seconds.")
    parser.add_argument("--read-ratio", type=int, default=50, help="Ratio between read and write (0-100).")
    args = parser.parse_args()

    if not 0 < args.read_ratio < 100:
        print(f"Error: read_ratio should be between 0 and 100, got {args.read_ratio}")

    rw = [get_data, push_data]

    while True:
        rw_index = int(random.randint(0, 100) >= args.read_ratio)
        res = rw[rw_index](args.url)
        if res.status_code != 200:
            print(f"An exception occurred: {res.status_code} {res.text}")
            exit(1)

        sleep(args.interval)
