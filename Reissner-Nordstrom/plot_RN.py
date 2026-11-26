"""RN spectrum from the paper: ell=2,3 and hat_n=0,...,41 only.
Global plot:             python plot_RN.py
All overtones at ell=3:   python plot_RN.py --ell 3
One overtone at ell=2:    python plot_RN.py --ell 2 --n 8
One overtone, both ell:   python plot_RN.py --n 8
Selected overtones:      python plot_RN.py --ell 3 --n 22 23
Save instead of showing: append --save spectrum.pdf (or spectrum.png).
Python API: plot_rn(); plot_rn(2, 8); plot_rn((3,), [22, 23]).
Requires numpy and matplotlib. Reads the sibling RN_spectrum.xlsx.
Each hat_n_00,...,hat_n_41 tab has ell,hat_n,Q,omega_re,omega_im.
G=c=M=1; time dependence exp(-i*omega*t); plot damping is -Im(omega).
Decimal text preserves the stored digits; doubles are only for plotting.
All saved samples of the indexed families are retained, including negative
real frequencies. Only their 75 directly computed finite-damping endpoints
have Q=1 rows. The nine zero-frequency limits are not isolated Q=1 roots.
Points and charge-ordered lines use the same Q colorbar.
"""
from pathlib import Path
from decimal import Decimal
import argparse
from zipfile import ZipFile
from xml.etree import ElementTree as ET
import posixpath
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
from matplotlib.colors import ListedColormap, BoundaryNorm
from matplotlib.cm import ScalarMappable

COLORS = np.array([
    [0.3686,0.3098,0.6353],[0.2536,0.4588,0.7059],
    [0.2641,0.6091,0.7098],[0.4000,0.7608,0.6471],
    [0.5804,0.8314,0.6444],[0.7477,0.8980,0.6275],
    [0.9020,0.9608,0.5961],[0.9673,0.9869,0.6980],
    [0.9987,0.9595,0.6810],[0.9961,0.8784,0.5451],
    [0.9935,0.7477,0.4353],[0.9804,0.5974,0.3412],
    [0.9569,0.4275,0.2627],[0.8758,0.3046,0.2941],
    [0.7634,0.1634,0.2928],[0.6196,0.0039,0.2588]])
BOUNDS = np.linspace(0, 1, 17)
CMAP = ListedColormap(COLORS)
NORM = BoundaryNorm(BOUNDS, len(COLORS), clip=True)

def charge_segments(p):
    """Split only the drawn lines at color boundaries; do not create data samples."""
    segments, colors = [], []
    for a, b in zip(p[:-1], p[1:]):
        q0, q1 = a[0], b[0]
        if q1 < q0:
            raise ValueError("Charge order is not monotone")
        if q1 == q0:
            segments.append([a[1:], b[1:]])
            colors.append(COLORS[min(15, max(0, int(q0*16)))])
            continue
        cuts = np.r_[q0, BOUNDS[(BOUNDS > q0) & (BOUNDS < q1)], q1]
        for lo, hi in zip(cuts[:-1], cuts[1:]):
            t = (np.array([lo, hi]) - q0)/(q1-q0)
            segments.append(a[1:] + t[:, None]*(b[1:]-a[1:]))
            colors.append(COLORS[min(15, max(0, int((lo+hi)*8)))])
    return segments, colors

def read_sheets(hats=None):
    """Read selected XLSX tabs with the standard library; keep numeric text intact."""
    ns = {"s":"http://schemas.openxmlformats.org/spreadsheetml/2006/main",
          "r":"http://schemas.openxmlformats.org/officeDocument/2006/relationships"}
    filename = Path(__file__).with_name("RN_spectrum.xlsx")
    rows = []
    with ZipFile(filename) as z:
        shared = []
        if "xl/sharedStrings.xml" in z.namelist():
            for item in ET.fromstring(z.read("xl/sharedStrings.xml")).findall("s:si", ns):
                shared.append("".join(t.text or "" for t in item.findall(".//s:t", ns)))
        relationships = {r.attrib["Id"]:r.attrib["Target"] for r in
                         ET.fromstring(z.read("xl/_rels/workbook.xml.rels"))}
        book = ET.fromstring(z.read("xl/workbook.xml"))
        for sheet in book.findall("s:sheets/s:sheet", ns):
            name = sheet.attrib["name"]
            if name not in {f"hat_n_{n:02d}" for n in range(42)}:
                continue
            if hats is not None and name not in {f"hat_n_{n:02d}" for n in hats}:
                continue
            target = relationships[sheet.attrib["{"+ns["r"]+"}id"]]
            member = target.lstrip("/") if target.startswith("/") else posixpath.normpath("xl/"+target)
            data = []
            for row in ET.fromstring(z.read(member)).findall("s:sheetData/s:row", ns):
                fields = [""]*5
                for cell in row.findall("s:c", ns):
                    col = ord(cell.attrib["r"][0])-ord("A")
                    if not 0 <= col < 5:
                        continue
                    value = cell.find("s:v", ns)
                    if cell.attrib.get("t") == "inlineStr":
                        text = "".join(t.text or "" for t in cell.findall("s:is/s:t", ns))
                    elif value is None:
                        text = ""
                    elif cell.attrib.get("t") == "s":
                        text = shared[int(value.text)]
                    else:
                        text = value.text or ""
                    fields[col] = text
                if any(fields):
                    data.append(fields)
            if not data or data[0] != ["ell","hat_n","Q","omega_re","omega_im"]:
                raise ValueError(f"Unexpected header in {name}")
            rows.extend(dict(zip(data[0], r)) for r in data[1:])
    return rows

def plot_rn(ells=(2, 3), hats=None, q_range=(0, 1)):
    if isinstance(ells, (int, np.integer)):
        ells = (int(ells),)
    if isinstance(hats, (int, np.integer)):
        hats = [int(hats)]
    ells = tuple(dict.fromkeys(ells))
    if not ells or any(e not in (2, 3) for e in ells):
        raise ValueError("ell must be 2 or 3")
    if hats is not None and (not hats or any(n not in range(42) for n in hats)):
        raise ValueError("hat_n must lie in 0,...,41")
    if not 0 <= q_range[0] <= q_range[1] <= 1:
        raise ValueError("Require 0 <= Qmin <= Qmax <= 1")
    raw = read_sheets(hats)
    if any(r["ell"] not in ("2", "3") or not r["hat_n"]
           or int(r["hat_n"]) not in range(42) for r in raw):
        raise ValueError("Workbook contains a root outside the paper's indexed families")
    selected = [
        r for r in raw if int(r["ell"]) in ells
        and Decimal(str(q_range[0])) <= Decimal(r["Q"]) <= Decimal(str(q_range[1]))
        and (hats is None or (r["hat_n"] and int(r["hat_n"]) in hats))
    ]
    if not selected:
        raise ValueError("No samples match the requested selection")
    fig, axes = plt.subplots(1, len(ells), figsize=(6.4*len(ells), 8.2),
                             squeeze=False, layout="constrained")
    for ax, ell in zip(axes[0], ells):
        rows = [r for r in selected if int(r["ell"]) == ell]
        if not rows:
            ax.set_title(rf"$\ell={ell}$ (no samples)")
            continue
        ns = sorted({int(r["hat_n"]) for r in rows if r["hat_n"]})
        for n in ns:
            branch = sorted((r for r in rows if r["hat_n"] and int(r["hat_n"]) == n),
                            key=lambda r: Decimal(r["Q"]))
            pts = np.array([[float(r["Q"]),float(r["omega_re"]),-float(r["omega_im"])]
                            for r in branch])
            segments, colors = charge_segments(pts)
            if segments:
                ax.add_collection(LineCollection(segments, colors=colors, linewidths=0.7, zorder=1))
            if len(ns) <= 8:
                ax.annotate(rf"$\hat n={n}$", (pts[0,1],pts[0,2]),
                            xytext=(4,4),textcoords="offset points", fontsize=10)
        # Scatter every saved sample of the selected overtone families.
        pts = np.array([[float(r["Q"]),float(r["omega_re"]),-float(r["omega_im"])]
                        for r in rows])
        sub = pts[:,0] < 1
        ax.scatter(pts[sub,1],pts[sub,2],c=pts[sub,0],cmap=CMAP,norm=NORM,
                   s=3.5,edgecolors="none",zorder=2)
        if (~sub).any():
            ax.scatter(pts[~sub,1],pts[~sub,2],c=pts[~sub,0],cmap=CMAP,norm=NORM,
                       marker="*",s=55,edgecolors="black",linewidths=0.4,zorder=3)
        ax.axvline(0,color="0.55",ls="--",lw=0.65,zorder=0)
        ax.autoscale_view()
        ax.margins(x=0.06,y=0.025)
        ax.grid(color="0.88",lw=0.5)
        ax.set_xlabel(r"$\Re(\omega)$",fontsize=13)
        ax.set_ylabel(r"$-\Im(\omega)$",fontsize=13)
        ax.set_title(rf"$\ell={ell}$",fontsize=14)
        fig.colorbar(ScalarMappable(norm=NORM,cmap=CMAP),ax=ax,
                     boundaries=BOUNDS,ticks=np.linspace(0,1,6),fraction=0.035,pad=0.025,aspect=40,label=r"$Q$")
    print(f"Plotted {len(selected)} saved samples, including {sum(r['Q']=='1' for r in selected)} Q=1 roots.")
    return fig

if __name__ == "__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--ell",nargs="+",type=int,choices=[2,3],default=[2,3])
    p.add_argument("--n",nargs="+",type=int,default=None,help="Overtone family indices; omit to plot all.")
    p.add_argument("--qmin",type=float,default=0)
    p.add_argument("--qmax",type=float,default=1)
    p.add_argument("--save",type=Path,help="Optional output image or PDF; no files are written by default.")
    a=p.parse_args()
    if not 0 <= a.qmin <= a.qmax <= 1:p.error("Require 0 <= qmin <= qmax <= 1")
    if a.n is not None and any(n<0 or n>41 for n in a.n):p.error("hat_n must lie in 0,...,41")
    fig=plot_rn(tuple(dict.fromkeys(a.ell)),a.n,(a.qmin,a.qmax))
    if a.save:
        fig.savefig(a.save,dpi=220)
        plt.close(fig)
    else:
        plt.show()
