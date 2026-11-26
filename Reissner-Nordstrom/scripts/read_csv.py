"""Read an RN CSV without losing stored decimal characters."""
import argparse,csv
from decimal import Decimal,localcontext
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument("csv_file",type=Path);a=p.parse_args()
with a.csv_file.open(encoding="utf8",newline="") as f:
    rows=list(csv.DictReader(f))
print("rows:",len(rows))
if rows:
    with localcontext() as ctx:
        ctx.prec=200
        for field in ("Q","omega_re","omega_im","B_re","B_im"):
            if rows[0].get(field):print(field,Decimal(rows[0][field]))
