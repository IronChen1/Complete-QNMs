"""Validate the RN export against saved figure inputs and high precision endpoint records."""
import csv, hashlib, json, math, zipfile
from collections import Counter,defaultdict
from decimal import Decimal as D, localcontext
from pathlib import Path
import argparse
p=argparse.ArgumentParser();p.add_argument("--root",type=Path,required=True);p.add_argument("--dataset",type=Path,default=Path(__file__).resolve().parents[1]);a=p.parse_args()
out=a.dataset; root=a.root
def table(n):return list(csv.DictReader((out/n).open(encoding="utf8")))
s=table("spectrum.csv");f=table("families.csv");near=table("near_extremal.csv");ex=table("excitation.csv");u=table("extremal_unconventional.csv")
plot=json.loads((root/"Code/research_revision_20261118/spectrum_figure_review/figure_layout/summary_data.json").read_bytes())
idx={(x["ell"],x["hat_n"]):x for x in plot["families"]}
group=defaultdict(list)
for r in s:
 k=int(r["ell"]),int(r["hat_n"]); group[k].append(r)
 old=idx[k]["points"][int(r["plot_order"])-1]
 assert (float(r["Q"]),float(r["omega_re"]),-float(r["omega_im"]))==tuple(old)
 assert 0<=D(r["Q"])<1 and D(r["omega_im"])<0
 assert all(D(r[k]).is_finite() for k in ("Q","omega_re","omega_im"))
for k,rr in group.items():
 assert len(rr)==len(idx[k]["points"])
 assert [int(r["sample_order"]) for r in rr]==list(range(1,len(rr)+1))
 assert [D(r["Q"]) for r in rr]==sorted(D(r["Q"]) for r in rr)
 assert {int(r["plot_order"]) for r in rr}==set(range(1,len(rr)+1))
assert set(group)=={(l,n) for l in (2,3) for n in range(42)}
assert Counter(r["endpoint_kind"] for r in f)=={"finite_damping_QNM":75,"zero_frequency_limit":9}
zero_expected={(2,6),(2,8),(3,21),(3,22),(3,24),(3,25),(3,26),(3,27),(3,28)}
assert {(int(r["ell"]),int(r["hat_n"])) for r in f if r["endpoint_kind"]=="zero_frequency_limit"}==zero_expected
strict=json.loads((root/"Code/extremal_RN_single_end_20261112/results/verified_inventory.json").read_bytes())["records"]
for r in f:
 if r["endpoint_kind"]=="zero_frequency_limit":assert D(r["limit_omega_re"])==D(r["limit_omega_im"])==0;continue
 sr=strict[int(r["source_record"].split("/")[-1])]
 assert r["limit_omega_re"]==sr["omega"]["re"] and r["limit_omega_im"]==sr["omega"]["im"]
 assert sr["accepted"]
with localcontext() as ctx:
 ctx.prec=200
 for r in ex:
  mag=(D(r["B_re"])**2+D(r["B_im"])**2).sqrt()
  assert mag>0 and abs(D(r["B_abs"])-mag)/mag<D("2e-14")
 for r in near:
  if r["sample_role"]!="latest_finite_damping":continue
  end=next(z for z in f if z["ell"]==r["ell"] and z["hat_n"]==r["hat_n"])
  dist=((D(r["omega_re"])-D(end["limit_omega_re"]))**2+(D(r["omega_im"])-D(end["limit_omega_im"]))**2).sqrt()
  assert abs(dist-D(r["distance_to_extremal"]))/dist<D("1e-12"), (r["ell"],r["hat_n"],str(dist),r["distance_to_extremal"],str(abs(dist-D(r["distance_to_extremal"]))/dist))
assert len(u)==2 and all(not r["hat_n"] and r["parent_assignment"]=="unassigned" and r["Q"]=="1" for r in u)
sources=json.loads((out/"sources.json").read_bytes())
with zipfile.ZipFile(root/"Code/numerical_history.zip") as archive:
 for sid,r in sources.items():
  data=archive.read(r["member"]) if "archive" in r else (root/r["path"]).read_bytes()
  assert hashlib.sha256(data).hexdigest()==r["sha256"]
for rows in (s,f,near,ex,u):
 assert all(r["source_id"] in sources for r in rows)
# Reconstruct every resonance sample in the final complex panels.
reference=json.loads((root/"Code/research_revision_20261118/results_restructure/excitation_reference/reference_plot_data.json").read_bytes())
dpair=json.loads((root/"Code/research_revision_20261118/comprehensive_review/figures/pair_D_plot_data.json").read_bytes())
expected=[]
for w in reference["windows"]:
 for m in reference["modes"]:
  if m["hat_n"] in w["hats"]:
   for r in m["points"]:
    if w["q"][0]-1e-12<=r[0]<=w["q"][1]+1e-12:expected.append((w["id"],m["hat_n"],*r[:3]))
for m in dpair["modes"]:
 for r in m["points"]:expected.append(("D",m["hat"],*r[:3]))
actual=[(r["window"],int(r["hat_n"]),float(r["Q"]),float(r["B_re"]),float(r["B_im"])) for r in ex if r["window"]!="zero_frequency"]
assert Counter(actual)==Counter(expected)
report={"passed":True,"frequency_rows":len(s),"families":len(f),"near_extremal_rows":len(near),"excitation_rows":len(ex),"source_files_hashed":len(sources),
"negative_real_samples_preserved":sum(D(r["omega_re"])<0 for r in s),
"checks":["All final spectrum samples retained and round-trip to their saved plot values","Charge order and family labels","75 finite endpoints and 9 zero-frequency limits","High-precision endpoint distances","Complex excitation values and magnitudes","All final resonance samples retained","Unconventional roots remain unassigned","Source checksums"],
"scope":"Export and consistency checks only; no new numerical root solves and no new frequency error certification."}
(out/"validation.json").write_text(json.dumps(report,indent=2)+"\n",encoding="utf8")
print(json.dumps(report))
