(* Get["plot_qnm.wl"]; PlotKerrQNM[2,0]
   One overtone, all m; spin-colored scatter following main_figure_omega.m.
   Exact decimal text is parsed as a rational; only plotting uses N.
   No A_lm column is present. Unresolved blank endpoint frequencies are skipped. *)
$KerrWorkbook=FileNameJoin[{DirectoryName[$InputFileName],"Kerr_spectrum.xlsx"}];
Clear[KerrDecimal,PlotKerrQNM];
KerrDecimal[s_String]:=Module[{p,d,sg=1,t=s},
 If[!StringMatchQ[t,RegularExpression["[+-]?[0-9]+(?:\\.[0-9]*)?"]],Return[Missing["NotDecimal"]]];
 If[StringStartsQ[t,"-"],sg=-1];t=StringReplace[t,StartOfString~~("+"|"-")->""];
 p=StringSplit[t,"."];d=If[Length[p]==2,StringLength[p[[2]]],0];sg FromDigits[StringJoin[p]]/10^d
];
KerrDecimal[x_?NumberQ]:=x;
PlotKerrQNM[ell_Integer:2,n_Integer:0,output_:None]:=Module[{sheets,idx,raw,rows,valid,graphics,colors,fig,ms,rs,last},
 sheets=Import[$KerrWorkbook,"Sheets"];idx=First@FirstPosition[sheets,"hat_n_"<>IntegerString[n,10,2]];
 raw=Rest@Import[$KerrWorkbook,{"Data",idx}];rows=Select[raw,KerrDecimal[#[[1]]]==ell&];
 valid=Select[rows,Length[#]>=6&&NumberQ[KerrDecimal[#[[4]]]]&&NumberQ[KerrDecimal[#[[5]]]]&];
 If[Length[valid]<Length[rows],Print["Unresolved blank endpoint frequencies omitted."]];
 colors=(RGBColor[0,1-#,0.5+0.5#]&);graphics={};
 Do[rs=Select[valid,KerrDecimal[#[[2]]]==m&];
  Do[AppendTo[graphics,{colors[N[KerrDecimal[r[[6]]]]],PointSize[.004],Tooltip[Point[N[{KerrDecimal[r[[4]]],-KerrDecimal[r[[5]]]}]],Column[{"m="<>ToString[m],"Re="<>ToString[r[[4]]],"Im="<>ToString[r[[5]]],"a/M="<>ToString[r[[6]]],If[Length[r]>=7,r[[7]],""]}]]}],{r,rs}];
  If[Length[rs]>0,last=Last[rs];AppendTo[graphics,{Black,Text["m="<>ToString[m],N[{KerrDecimal[last[[4]]],-KerrDecimal[last[[5]]]}],{-1,-1}]}]],{m,-ell,ell}];
 fig=Legended[Graphics[graphics,Frame->True,FrameLabel->{"Re(M omega)","-Im(M omega)"},GridLines->Automatic,PlotRange->All,PlotRangePadding->Scaled[.08],ImageSize->900,BaseStyle->{FontFamily->"Times New Roman",FontSize->12},PlotLabel->Row[{"Kerr QNMs: ell=",ell,", n-hat=",n}]],BarLegend[{colors,{0,1}},LegendLabel->"a/M"]];
 If[StringQ[output],Export[output,fig]];fig
];
