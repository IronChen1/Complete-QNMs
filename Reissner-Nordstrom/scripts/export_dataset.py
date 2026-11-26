"""Build a local RN data release from final manuscript inputs; never run a solver."""
import argparse, csv, hashlib, json, math, re, zipfile
from collections import Counter, defaultdict
from decimal import Decimal, localcontext
from pathlib import Path

ap=argparse.ArgumentParser()
ap.add_argument("--root", type=Path, required=True, help="Original RN project")
ap.add_argument("--output", type=Path, default=Path(__file__).resolve().parents[1])
args=ap.parse_args()
ROOT=args.root.resolve(); OUT=args.output.resolve()
OUT.mkdir(parents=True,exist_ok=True)
D=Decimal
ARCHIVE=zipfile.ZipFile(ROOT/"Code/numerical_history.zip")
ARCHIVE_NAMES=set(ARCHIVE.namelist())
SOURCES={}; CACHE={}; raw_index=defaultdict(list); amp_index=defaultdict(list)
def sval(v): return "" if v is None else str(v)
def encode(v):
    if isinstance(v,D): return str(v)
    raise TypeError(type(v))
def register(rel):
    rel=Path(rel).as_posix()
    if (ROOT/rel).exists():
        b=(ROOT/rel).read_bytes(); storage={}
    else:
        member=rel.removeprefix("Code/")
        b=ARCHIVE.read(member); storage={"archive":"Code/numerical_history.zip","member":member}
    sid="s"+hashlib.sha256(rel.encode()).hexdigest()[:12]
    SOURCES[sid]={"path":rel,"sha256":hashlib.sha256(b).hexdigest(),"bytes":len(b),**storage}
    return sid,b
def load(rel):
    rel=Path(rel).as_posix()
    if rel not in CACHE:
        sid,b=register(rel)
        CACHE[rel]=(sid,json.loads(b,parse_float=D))
    return CACHE[rel]
def dump(name,data):
    (OUT/name).write_text(json.dumps(data,ensure_ascii=False,indent=2,default=encode)+"\n",encoding="utf8")
def writecsv(name,fields,rows):
    with (OUT/name).open("w",encoding="utf8",newline="") as f:
        w=csv.DictWriter(f,fields,extrasaction="ignore",lineterminator="\n")
        w.writeheader(); w.writerows(rows)
def ref(sid,ptr): return {"source_id":sid,"source_record":ptr}
def key(ell,n,q,re_,im_):
    return int(ell),int(n),float(q),float(re_),float(im_)
def register_raw(ell,n,q,w,sid,ptr,record=None):
    if not isinstance(w,dict) or not all(k in w for k in ("re","im")): return
    if ell is None or n is None or q is None: return
    if int(ell) not in (2,3) or not 0<=int(n)<42: return
    if not all(isinstance(x,str) for x in (w["re"],w["im"])): return
    k=key(ell,n,q,w["re"],w["im"])
    if not 0<=k[2]<1 or not all(math.isfinite(x) for x in k[2:]): return
    item={"Q":sval(q),"omega_re":w["re"],"omega_im":w["im"],**ref(sid,ptr)}
    raw_index[k].append(item)
def walk(v,sid,ptr="",ell=None,n=None,q=None):
    if isinstance(v,list):
        for i,r in enumerate(v): walk(r,sid,ptr+"/"+str(i),ell,n,q)
    elif isinstance(v,dict):
        if v.get("accepted") is False or v.get("ok") is False: return
        ell=v.get("ell",ell); n=v.get("hat_n",n); q=v.get("Q",q)
        register_raw(ell,n,q,v.get("omega"),sid,ptr,v)
        b=v.get("excitation_factor",v.get("B"))
        if isinstance(b,dict) and ell is not None and n is not None and q is not None and all(k in b for k in ("re","im")):
            if all(isinstance(x,str) for x in (b["re"],b["im"])):
                amp_index[key(ell,n,q,b["re"],b["im"])].append({
                    "Q":sval(q),"B_re":b["re"],"B_im":b["im"],
                    "B_abs":v.get("abs_excitation",v.get("abs_B","")),
                    **ref(sid,ptr)})
        # Only known result containers; do not traverse predictors or seeds.
        for field in ("curves","nodes","high_charge_nodes","new_nodes","records","extensions","tests","midpoint","verified_inherited_nodes","inherited_anchor","inherited_anchors","chain_additions","results"):
            if field in v: walk(v[field],sid,ptr+"/"+field,ell,n,q)
def ingest(rel):
    if (ROOT/rel).exists() or rel.removeprefix("Code/") in ARCHIVE_NAMES:
        sid,v=load(rel);walk(v,sid)
        return sid,v
    return None,None

R12="Code/research_revision_20261112/"
R17="Code/research_revision_20261117/"
R18="Code/research_revision_20261118/"
PAPER="LaTeX/PRD_submission_20261120/RN_complete_analytic_continuation.tex"
register(PAPER)
SPLOT=R18+"spectrum_figure_review/figure_layout/summary_data.json"
psid,plot=load(SPLOT)
ss,span=load("Code/research_revision_20261113/span_separated_20261113/span_jobs.json")
ingest(R12+"full_charge80_stable_20261112/full_charge_curves.json")
segment_files=set()
for ji,j in enumerate(span):
    if j["kind"]=="detail": continue
    for pi,p in enumerate(j["parents"]):
        for si,s in enumerate(p["segments"]):
            for i,(q,w) in enumerate(zip(s.get("raw_Q_decimal",[]),s.get("raw_omega_decimal",[]))):
                register_raw(j["ell"],p["hat_n"],q,w,ss,f"/{ji}/parents/{pi}/segments/{si}/raw_omega_decimal/{i}")
            path=s.get("source","").replace("\\","/")
            if "/Code/" in path: path="Code/"+path.split("/Code/",1)[1]
            if path.startswith("Code/") and path.endswith(".json") and not path.endswith("plot_manifest.json"):segment_files.add(path)
for rel in sorted(segment_files):
    ingest(rel)

# Restore decimal records from the archived inputs of the retained segments.
sid,extension=load("Code/research_revision_20261113/four_per_group/verified_extensions.json")
for source in extension["sources"]:
    rel="Code/"+source["path"].replace(chr(92),"/").split("/Code/",1)[1]
    if "strict_positive_companions" not in rel: ingest(rel)
for rel in [
    R17+"holistic_followup/numerics/edge_results.json",
    R17+"multimode_revision/numerics/ell3_hat23_legacy_endpoint_samples.json",
    R17+"multimode_revision/numerics/coarse_arc_refinement_graphs.json",
    R17+"multimode_revision/numerics/repair_graphs.json"]:
    ingest(rel)

for nm in ["broad_final","origin_final","excitation_jobs_results","common_jobs_results","density_results","edge_jobs_results"]:
    ingest(R17+"integrated_revision/"+nm+".json")
for nm in ["excitation_results","midpoint_excitation_results","center_excitation_results","density_results","outer_results"]:
    ingest(R17+"holistic_followup/numerics/"+nm+".json")
ingest(R17+"multimode_revision/numerics/common_q_final.json")
for p in sorted((ROOT/(R18+"comprehensive_review/figures/D_amplitudes")).glob("*.json")):
    ingest(p.relative_to(ROOT).as_posix())
sid,server=load(R17+"unified_endpoint80/paper_update/server_records.json")
for tag,rows in server["monodromy_records"].items():
    ell,n=map(int,re.fullmatch(r"l(\d+)_n(\d+)",tag).groups())
    walk(rows,sid,"/monodromy_records/"+tag,ell,n)
sid,b=register(R17+"unified_endpoint80/paper_update/zero_ell2_hat6_accepted_nodes.jsonl")
for i,line in enumerate(b.decode().splitlines()):
    if line.strip():walk(json.loads(line,parse_float=D),sid,f"line:{i+1}",2,6)
for p in sorted((ROOT/(R17+"unified_endpoint80/server_pilot_results")).glob("pilot_*.json")):
    ingest(p.relative_to(ROOT).as_posix())
# Paired excitation audit stores frequencies/factors under explicit a/b fields.
asid,audit=load(R17+"excitation_audit80/summary.json")
for ci,c in enumerate(audit["cases"]):
    for pi,p in enumerate(c["points"]):
        for n,suffix in zip(c["hats"],("a","b")):
            ptr=f"/cases/{ci}/points/{pi}"
            register_raw(c["ell"],n,p["Q"],p["omega_"+suffix],asid,ptr+"/omega_"+suffix)
            b=p.get("B_"+suffix)
            if isinstance(b,dict) and all(isinstance(x,str) for x in (b["re"],b["im"])):
                amp_index[key(c["ell"],n,p["Q"],b["re"],b["im"])].append({
                    "Q":sval(p["Q"]),"B_re":b["re"],"B_im":b["im"],"B_abs":"","source_id":asid,"source_record":ptr+"/B_"+suffix})
endsid,raw=register(R17+"unified_endpoint80/paper_update/latest_finite_endpoints.csv")
ends=list(csv.DictReader(raw.decode().splitlines()))
for i,r in enumerate(ends):
    register_raw(r["ell"],r["hat_n"],r["Q"],{"re":r["omega_re"],"im":r["omega_im"]},endsid,f"row:{i+2}")

def best(items):
    # Prefer a preserved decimal record, deterministically; length is not an accuracy claim.
    return max(items,key=lambda r:(sum(len(sval(r.get(k))) for k in ("Q","omega_re","omega_im","B_re","B_im")),r["source_id"],r["source_record"]))
spectrum=[]; counts=Counter()
for fi,f in enumerate(plot["families"]):
    cmp={tuple(map(float,p)) for p in f["comparison"]}
    temp=[]
    for j,p in enumerate(f["points"]):
        q,wr,damping=p
        k=key(f["ell"],f["hat_n"],q,wr,-damping)
        fallback={"Q":sval(q),"omega_re":sval(wr),"omega_im":sval(-damping),**ref(psid,f"/families/{fi}/points/{j}")}
        src=best(raw_index[k]) if raw_index[k] else fallback
        row={"ell":f["ell"],"hat_n":f["hat_n"],"plot_order":j+1,**src,
             "source_kind":"comparison" if tuple(map(float,p)) in cmp else "own_method",
             "precision_origin":"stored_decimal_string" if raw_index[k] else "plot_numeric_value"}
        assert key(row["ell"],row["hat_n"],row["Q"],row["omega_re"],row["omega_im"])==k
        temp.append(row);counts[row["precision_origin"]]+=1;counts[row["source_kind"]]+=1
    temp.sort(key=lambda r:(D(r["Q"]),r["plot_order"]))
    for i,r in enumerate(temp):r["sample_order"]=i+1
    spectrum.extend(temp)
fields=["ell","hat_n","sample_order","Q","omega_re","omega_im","source_kind","precision_origin","source_id","source_record","plot_order"]
writecsv("spectrum.csv",fields,spectrum)
assert len(spectrum)==sum(len(f["points"]) for f in plot["families"])
assert {(r["ell"],r["hat_n"]) for r in spectrum}=={(ell,n) for ell in (2,3) for n in range(42)}

strictsid,strict=load("Code/extremal_RN_single_end_20261112/results/verified_inventory.json")
accepted={(r["ell"],r["source"]):(i,r) for i,r in enumerate(strict["records"]) if r["accepted"]}
zeroid,zero=load(R17+"integrated_revision/origin_final.json")
zero=[(i,r) for i,r in enumerate(zero) if r["accepted"]]
zero_keys={(r["ell"],r["hat_n"]) for i,r in zero}
finite_keys={(int(r["ell"]),int(r["hat_n"])) for r in ends}
assert len(finite_keys)==75 and len(zero_keys)==9 and not finite_keys&zero_keys
assert finite_keys|zero_keys=={(ell,n) for ell in (2,3) for n in range(42)}
endpoint_by_family={(int(r["ell"]),int(r["hat_n"])):(i,r) for i,r in enumerate(ends)}
origin_by_family=defaultdict(list)
for i,r in zero: origin_by_family[(r["ell"],r["hat_n"])].append((i,r))
family=[];near=[]
for ell,n in sorted(finite_keys|zero_keys):
    if (ell,n) in finite_keys:
        i,e=endpoint_by_family[(ell,n)]
        si,s=accepted[(ell,e["strict_root_source"])]
        family.append(dict(ell=ell,hat_n=n,endpoint_kind="finite_damping_QNM",limit_omega_re=s["omega"]["re"],limit_omega_im=s["omega"]["im"],max_sampled_Q=e["Q"],
            max_check_amplitude=s["max_check_amplitude"],max_setting_shift=s["max_setting_shift"],working_digits=s["working_digits"],**ref(strictsid,f"/records/{si}")))
        with localcontext() as ctx:
            ctx.prec=100
            delta_re=D(e["omega_re"])-D(s["omega"]["re"])
            delta_im=D(e["omega_im"])-D(s["omega"]["im"])
            distance=str((delta_re**2+delta_im**2).sqrt())
        near.append(dict(ell=ell,hat_n=n,Q=e["Q"],omega_re=e["omega_re"],omega_im=e["omega_im"],sample_role="latest_finite_damping",distance_to_extremal=distance,**ref(endsid,f"row:{i+2}")))
    else:
        entries=origin_by_family[(ell,n)]
        family.append(dict(ell=ell,hat_n=n,endpoint_kind="zero_frequency_limit",limit_omega_re="0",limit_omega_im="0",max_sampled_Q=max((r["Q"] for i,r in entries),key=D),**ref(zeroid,"/")))
        for i,r in entries:
            w=r["runs"][0]["omega"]
            near.append(dict(ell=ell,hat_n=n,Q=r["Q"],omega_re=w["re"],omega_im=w["im"],sample_role="zero_frequency_family",distance_to_extremal="",**ref(zeroid,f"/{i}/runs/0/omega")))
for r in family:
    points=[p for p in spectrum if p["ell"]==r["ell"] and p["hat_n"]==r["hat_n"]]
    r["samples"]=len(points);r["min_sampled_Q"]=min((p["Q"] for p in points),key=D)
writecsv("families.csv",["ell","hat_n","endpoint_kind","limit_omega_re","limit_omega_im","min_sampled_Q","max_sampled_Q","samples","max_check_amplitude","max_setting_shift","working_digits","source_id","source_record"],family)
near.sort(key=lambda r:(r["ell"],r["hat_n"],D(r["Q"])))
writecsv("near_extremal.csv",["ell","hat_n","Q","omega_re","omega_im","sample_role","distance_to_extremal","source_id","source_record"],near)
nsid,negative=load(R18+"comprehensive_review/strict/scientific_audit.json")
extra=[]
for i,r in enumerate(negative["strict_negative"]):
    extra.append(dict(ell=int(r["ell"].replace("ell","")),hat_n="",Q="1",omega_re=r["omega"]["re"],omega_im=r["omega"]["im"],
        sheet="unconventional",parent_assignment="unassigned",max_incoming_amplitude_on_sheet=sval(r["upper_contour_max_Binc"]),incoming_amplitude_other_contour=sval(r["reflected_contour_Binc_abs"]),**ref(nsid,f"/strict_negative/{i}")))
writecsv("extremal_unconventional.csv",["ell","hat_n","Q","omega_re","omega_im","sheet","parent_assignment","max_incoming_amplitude_on_sheet","incoming_amplitude_other_contour","source_id","source_record"],extra)

rsid,reference=load(R18+"results_restructure/excitation_reference/reference_plot_data.json")
dsid,dpair=load(R18+"comprehensive_review/figures/pair_D_plot_data.json")
exc=[];windows=[]
def add_amplitude(ell,n,window,p,sid,ptr):
    q,br,bi=p[:3]
    k=key(ell,n,q,br,bi)
    if amp_index[k]:
        row=best(amp_index[k]).copy();precision="stored_decimal_string"
    else:
        row=dict(Q=sval(q),B_re=sval(br),B_im=sval(bi),B_abs=sval(p[3]) if len(p)>3 else "",**ref(sid,ptr));precision="plot_numeric_value"
    if not row["B_abs"]:
        with localcontext() as ctx:
            ctx.prec=80 if precision=="stored_decimal_string" else 17
            row["B_abs"]=str((D(row["B_re"])**2+D(row["B_im"])**2).sqrt())
        abs_origin="derived_from_components"
    else: abs_origin="stored_value"
    assert key(ell,n,row["Q"],row["B_re"],row["B_im"])==k
    exc.append(dict(ell=ell,hat_n=n,window=window,precision_origin=precision,B_abs_origin=abs_origin,**row))
for win in reference["windows"]:
    windows.append(dict(id=win["id"],ell=3,hat_n=win["hats"],Q_min=sval(win["q"][0]),Q_max=sval(win["q"][1])))
    for mi,m in enumerate(reference["modes"]):
        if m["hat_n"] not in win["hats"]:continue
        for pi,p in enumerate(m["points"]):
            if float(win["q"][0])-1e-12<=float(p[0])<=float(win["q"][1])+1e-12:
                add_amplitude(3,m["hat_n"],win["id"],p,rsid,f"/modes/{mi}/points/{pi}")
windows.append(dict(id="D",ell=3,hat_n=[27,28],Q_min=sval(dpair["window"][0]),Q_max=sval(dpair["window"][1])))
for mi,m in enumerate(dpair["modes"]):
    for pi,p in enumerate(m["points"]):add_amplitude(3,m["hat"],"D",p,dsid,f"/modes/{mi}/points/{pi}")
for i,r in zero:
    b=r["excitation_factor"]
    exc.append(dict(ell=r["ell"],hat_n=r["hat_n"],window="zero_frequency",Q=r["Q"],B_re=b["re"],B_im=b["im"],B_abs=r["abs_excitation"],precision_origin="stored_decimal_string",B_abs_origin="stored_value",**ref(zeroid,f"/{i}")))
exc.sort(key=lambda r:(r["ell"],r["hat_n"],r["window"],D(r["Q"])))
writecsv("excitation.csv",["ell","hat_n","window","Q","B_re","B_im","B_abs","B_abs_origin","precision_origin","source_id","source_record"],exc)
dump("sources.json",SOURCES)
result={"families":len(family),"frequency_samples":len(spectrum),"frequency_precision":dict(counts),"finite_damping_limits":75,"zero_frequency_limits":9,
        "near_extremal_samples":len(near),"unconventional_Q1_roots":len(extra),"excitation_samples":len(exc),"excitation_precision":dict(Counter(r["precision_origin"] for r in exc)),
        "resonance_windows":windows,"new_root_solves":0,"publication":"local only"}
dump("inventory.json",result)
print(json.dumps(result,default=encode))
