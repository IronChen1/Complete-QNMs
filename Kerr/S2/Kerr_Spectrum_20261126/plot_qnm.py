"""Kerr spectrum from XLSX. Python standard library only.
python plot_qnm.py --ell 2 --n 0
One overtone, all m, spin-colored scatter as in main_figure_omega.m.
Original cell strings remain intact; floats are used only for SVG coordinates.
endpoint_type distinguishes calculated roots, limiting values and unresolved rows.
The workbook contains omega, not A_lm; angular plots require angular data.
"""
from pathlib import Path
import argparse,zipfile,xml.etree.ElementTree as ET,html
NS={'s':'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
def read_sheet(path,name):
 with zipfile.ZipFile(path) as z:
  strings=[]
  if 'xl/sharedStrings.xml' in z.namelist():strings=[''.join(t.text or '' for t in x.iter('{'+NS['s']+'}t')) for x in ET.fromstring(z.read('xl/sharedStrings.xml'))]
  rel={r.get('Id'):r.get('Target') for r in ET.fromstring(z.read('xl/_rels/workbook.xml.rels'))}
  sheets=ET.fromstring(z.read('xl/workbook.xml')).find('s:sheets',NS)
  sheet=next(s for s in sheets if s.get('name')==name)
  target=rel[sheet.get('{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id')];target=target.lstrip('/') if target.startswith('/') else 'xl/'+target
  rows=[]
  for row in ET.fromstring(z.read(target)).findall('s:sheetData/s:row',NS):
   vals=['']*7
   for c in row:
    j=ord(c.get('r')[0])-65
    if j>=7:continue
    v=c.find('s:v',NS);s=v.text if v is not None else ''.join(t.text or '' for t in c.iter('{'+NS['s']+'}t'))
    vals[j]=strings[int(s)] if c.get('t')=='s' else (s or '')
   rows.append(vals)
  return [dict(zip(rows[0],r)) for r in rows[1:]]
def main():
 p=argparse.ArgumentParser();p.add_argument('--ell',type=int,choices=[2,3],default=2);p.add_argument('--n',type=int,choices=range(42),default=0);p.add_argument('--m',type=int);p.add_argument('--workbook',type=Path,default=Path(__file__).with_name('Kerr_spectrum.xlsx'));p.add_argument('--output',type=Path);a=p.parse_args()
 rows=[r for r in read_sheet(a.workbook,f'hat_n_{a.n:02d}') if int(r['ell'])==a.ell and (a.m is None or int(r['m'])==a.m)]
 missing=[r for r in rows if not r['qnm_re'] or not r['qnm_im']];rows=[r for r in rows if r['qnm_re'] and r['qnm_im']]
 if not rows:raise SystemExit('No frequencies stored for this selection')
 xs=[float(r['qnm_re']) for r in rows];ys=[-float(r['qnm_im']) for r in rows];xmin,xmax=min(xs),max(xs);ymin,ymax=min(ys),max(ys);dx=max(xmax-xmin,1e-6);dy=max(ymax-ymin,1e-6);xmin-=dx*.08;xmax+=dx*.08;ymin-=dy*.08;ymax+=dy*.08
 X=lambda x:85+(x-xmin)/(xmax-xmin)*900;Y=lambda y:620-(y-ymin)/(ymax-ymin)*540
 color=lambda t:f'rgb(0,{round(255*(1-t))},{round(255*(.5+.5*t))})'
 svg=['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1120 720" style="background:white;font:17px Times New Roman;width:100%">']
 def text(x,y,s,extra=''):svg.append(f'<text x="{x}" y="{y}" {extra}>{html.escape(s)}</text>')
 text(85,35,f'Kerr QNMs: ell={a.ell}, hat_n={a.n}')
 for i in range(6):
  x=xmin+(xmax-xmin)*i/5;y=ymin+(ymax-ymin)*i/5
  svg.append(f'<path d="M {X(x)} 80 V 620 M 85 {Y(y)} H 985" stroke="#ddd"/>');text(X(x),648,f'{x:.5g}','text-anchor="middle"');text(76,Y(y)+5,f'{y:.5g}','text-anchor="end"')
 for r in rows:
  t=float(r['a_over_M']);tip='; '.join(k+'='+v for k,v in r.items());svg.append(f'<circle cx="{X(float(r["qnm_re"]))}" cy="{Y(-float(r["qnm_im"]))}" r="{3.5 if r["a_over_M"]=="1" else 1.5}" fill="{color(t)}"><title>{html.escape(tip)}</title></circle>')
 for m in sorted({r['m'] for r in rows},key=int):
  r=[r for r in rows if r['m']==m][-1];text(X(float(r['qnm_re']))+6,Y(-float(r['qnm_im']))-7,'m='+m)
 for i in range(100):svg.append(f'<rect x="1010" y="{615-i*5.4}" width="18" height="6" fill="{color(i/99)}"/>')
 text(1040,88,'1');text(1040,620,'0');text(1005,655,'a/M');text(535,690,'Re(M omega)','text-anchor="middle"');text(0,0,'-Im(M omega)','transform="translate(25,350) rotate(-90)" text-anchor="middle"');svg.append('</svg>')
 warning=f'{len(missing)} endpoint frequencies unresolved; blank rows are omitted.' if missing else ''
 dest=a.output or Path(__file__).with_name(f'kerr_l{a.ell}_n{a.n:02d}.html');dest.write_text('<!doctype html><meta charset="utf-8"><title>Kerr QNMs</title><p>Hover over points for all stored digits and endpoint_type. '+warning+'</p>'+''.join(svg),encoding='utf8');print(dest)
if __name__=='__main__':main()
