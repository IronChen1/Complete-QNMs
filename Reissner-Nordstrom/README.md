# RN spectrum data / RN 光谱数据

2026-11-26 数据集，范围为 ell = 2, 3、hat_n = 0,...,41。采用 CSV 保存数值，JSON 说明字段、约定与来源。

## 文件内容 / Contents

| 文件 | 行数 | 内容 |
| --- | ---: | --- |
| spectrum.csv | 68,167 | 全部最终绘图样点，按模族和电荷排序 |
| families.csv | 84 | 模族编号和极端极限：75 个有限阻尼根、9 个零频极限 |
| near_extremal.csv | 151 | 有限阻尼模族的最后样点及零频模族的已接受样点 |
| extremal_unconventional.csv | 2 | 非常规页上的严格极端根，母模编号未指定 |
| excitation.csv | 820 | 四组共振对的 744 个样点及零频模族的 76 个样点 |

metadata.json describes columns and conventions; sources.json lists input hashes and locations; inventory.json gives counts and charge windows; validation.json records completed consistency checks.

## 物理约定 / Conventions

- G = c = M = 1; Q is dimensionless charge. Frequencies are M times physical frequency.
- Time dependence is exp(-i omega t). omega_im is **signed Im(omega)**, negative for damped modes; the positive damping axis is -omega_im.
- hat_n follows the inherited manuscript label; do not relabel by instantaneous damping.
- B_re, B_im, B_abs represent mathscr{B} = B_ref/(2 omega d_omega B_inc), in the axial master-field normalization.
- Real-frequency sign alone does not identify the Riemann sheet.

零频模族仍保留编号和近极端数值。families.csv 中的 zero_frequency_limit 表示 Q 趋于 1 的极限，不是一次在 Q = 1 求得的孤立零频根。另列的两个非常规页极端根尚未指定史瓦西母模，hat_n 留空。轴向代数特殊的全透射模未混入这些 QNM 表。

## 精度与来源 / Precision and provenance

All 68,167 final spectrum-input rows are retained. Decimal frequency strings were recovered for 65,275 rows by exact matching of family, charge and binary64 frequency components. The remaining 2,892 preserve their saved plotting values. No extra digits were invented. This labels storage precision, not certified significant figures.

source_kind identifies 66,219 own-method points and 1,948 comparison points retained in the final plot input. Comparison records remain labeled separately; they are not used as an accuracy certificate for the own-method results.

全部 820 条激发因子的复数分量都已恢复保存的小数字符串。B_abs_origin 区分原来保存的幅值和由复数分量计算的幅值。近极端表中的 distance_to_extremal 由原始小数频率重新计算，不能当作求根误差。

source_id links to sources.json. source_record identifies a JSON pointer, a one-based CSV row (including header), or a one-based JSONL line. For raw_omega_decimal pointers, Q is the corresponding entry in raw_Q_decimal. Some originals are members of Code/numerical_history.zip; exported CSV files are usable without the archive.

## 读取 / Reading

先把数值列读成字符串，再按需要转为任意精度数值。自动读成 double 后再保存，会舍入原有小数位。数学上的精确有理数表示的是保存的十进制文本，不表示物理频率精确无误。

### Python

```python
import csv
from decimal import Decimal, localcontext
with open('spectrum.csv', encoding='utf-8', newline='') as f:
    rows = list(csv.DictReader(f))
with localcontext() as ctx:
    ctx.prec = 180
    q = Decimal(rows[0]['Q'])
    wr = Decimal(rows[0]['omega_re'])
    wi = Decimal(rows[0]['omega_im'])
```

scripts/read_csv.py provides a runnable standard-library example.

### MATLAB

```matlab
opts = detectImportOptions('spectrum.csv', 'TextType', 'string');
opts = setvartype(opts, opts.VariableNames, 'string');
T = readtable('spectrum.csv', opts);
% Convert to double for plotting only; retain T for stored digits.
q_plot = str2double(T.Q);
wr_plot = str2double(T.omega_re);
wi_plot = str2double(T.omega_im);
% With Symbolic Math Toolbox: wr_exact = str2sym(T.omega_re);
```

### Wolfram Language

```wolfram
rows = Import["spectrum.csv", "CSV", "Numeric" -> False];
header = First[rows];
data = AssociationThread[header, #] & /@ Rest[rows];
(* Keep the decimal strings; no machine conversion is needed to inspect them. *)
data[[1]]["omega_re"]
```

## 画图 / Plotting

Group by ell and hat_n; connect adjacent rows in sample_order. Use the same Q color scale for points and segments. Preserve the real-frequency sign, all points and unequal charge spacing. Equal-Q records remain in saved plot_order. Connecting segments are graphical guides, not additional computed frequencies.

## 重建 / Rebuilding

These commands require the original project and numerical archive. Reading the CSV does not.

```text
python scripts/export_dataset.py --root "D:/Desktop/Chen-Manuscripts/8-RN-QNM"
python scripts/validate_dataset.py --root "D:/Desktop/Chen-Manuscripts/8-RN-QNM"
```

Validation checks retained samples, signs, charge order, family limits, complex amplitudes and source hashes. It does not run the numerical solver.
