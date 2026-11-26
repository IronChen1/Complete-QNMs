(* RN spectrum from the paper: ell=2,3 and hat_n=0,...,41 only.
   Load in Mathematica: Get["/path/to/plot_RN.wl"]
   Global plot:           RNPlot[]
   All overtones, ell=3:  RNPlot[3]
   One overtone, ell=2:   RNPlot[2,8]
   One overtone, both ell: RNPlot[{2,3},8]
   Selected overtones:    RNPlot[{3},{22,23}]
   Optional save: Export["overtone8.pdf", RNPlot[2,8]]
   Tabs hat_n_00,...,hat_n_41; columns ell,hat_n,Q,omega_re,omega_im.
   G=c=M=1, exp(-I omega t). Decimal text retains the stored digits;
   machine numbers are used only for visualization.
   Every saved family sample is plotted and connected in charge order,
   using the same Q colorbar for points and lines. Only the 75 finite-
   damping Q=1 family endpoints are included. Zero-frequency limits
   are not added as isolated Q=1 roots.
   Loading creates no output files. For batch use, set $RNNoAutoPlot=True
   before Get and call RNPlot explicitly.
*)
ClearAll[RNPlot,rnNumber,rnBin,rnColor,rnChargeLines];
rnDirectory = DirectoryName[$InputFileName];
rnFile = FileNameJoin[{rnDirectory,"RN_spectrum.xlsx"}];
rnSheets = Import[rnFile,{"XLSX","Data"}];
rnRaw = Flatten[Rest /@ rnSheets,1];
(* Conversion is for drawing only. The input XLSX is already sorted by exact Q. *)
rnNumber[x_?NumberQ] := N[x,MachinePrecision];
rnNumber[s_String] := N[ToExpression[StringReplace[s,{"e"->"*^","E"->"*^"}]],MachinePrecision];
rnData = Map[
  {Round[rnNumber[#[[1]]]],
   Round[rnNumber[#[[2]]]],
   rnNumber[#[[3]]],rnNumber[#[[4]]],-rnNumber[#[[5]]]}&,rnRaw];
If[!AllTrue[rnData,MemberQ[{2,3},#[[1]]] && IntegerQ[#[[2]]] && 0<=#[[2]]<=41&],
  Print["Workbook contains a root outside the paper indexed families."];Abort[]];
rnColors = RGBColor@@@{
 {0.3686,0.3098,0.6353},{0.2536,0.4588,0.7059},
 {0.2641,0.6091,0.7098},{0.4000,0.7608,0.6471},
 {0.5804,0.8314,0.6444},{0.7477,0.8980,0.6275},
 {0.9020,0.9608,0.5961},{0.9673,0.9869,0.6980},
 {0.9987,0.9595,0.6810},{0.9961,0.8784,0.5451},
 {0.9935,0.7477,0.4353},{0.9804,0.5974,0.3412},
 {0.9569,0.4275,0.2627},{0.8758,0.3046,0.2941},
 {0.7634,0.1634,0.2928},{0.6196,0.0039,0.2588}};
rnBin[q_?NumericQ] := Clip[1+Floor[16 q],{1,16}];
rnColor[q_?NumericQ] := rnColors[[rnBin[q]]];
rnBounds = N[Range[0,16]/16];
rnChargeLines[p_List] := Module[{a,b,q0,q1,cuts,t0,t1,result},
  result=Reap[
    Do[
      a=p[[i]]; b=p[[i+1]]; q0=a[[1]];q1=b[[1]];
      If[q1<q0,Return[$Failed]];
      If[q1===q0,
        Sow[{rnColor[q0],Line[{a[[2;;3]],b[[2;;3]]}]}],
        cuts=Join[{q0},Select[rnBounds,q0<#<q1&],{q1}];
        Do[
          t0=(cuts[[j]]-q0)/(q1-q0);t1=(cuts[[j+1]]-q0)/(q1-q0);
          Sow[{rnColor[(cuts[[j]]+cuts[[j+1]])/2],
            Line[{a[[2;;3]]+t0(b[[2;;3]]-a[[2;;3]]),
                  a[[2;;3]]+t1(b[[2;;3]]-a[[2;;3]])}]}],
          {j,Length[cuts]-1}]],
      {i,Length[p]-1}]
    ][[2]];
  If[result==={}, {},First[result]]
];
rnRow[graphs_List,widths_List,height_] := Graphics[
  MapIndexed[Inset[#1,{Total[Take[widths,First[#2]-1]],0},
    {Left,Bottom},{widths[[First[#2]]],height}]&,graphs],
  PlotRange->{{0,Total[widths]},{0,height}},
  ImageSize->{Total[widths],height},ImagePadding->0];

rnLegend[] := Graphics[
  Table[{rnColors[[k]],Rectangle[{0,(k-1)/16},{1,k/16}]},{k,16}],
  PlotRange->{{0,1},{0,1}},Frame->{{False,True},{False,False}},
  FrameTicks->{{None,Table[{N[q],NumberForm[N[q],{2,1}]},{q,0,1,1/5}]},{None,None}},
  PlotLabel->Style["Q",13],BaseStyle->{FontFamily->"Times New Roman",FontSize->11},
  AspectRatio->20,ImageSize->{55,530},ImagePadding->{{1,24},{0,25}}];
RNPlot[ellValues_List:{2,3},hatValues_:All,qRange_List:{0,1}] :=
 Module[{chosen,panels,rows,ns,lines,points,stars,labels,p,sub,ext,groups,
         xr,yr,dx,dy},
  chosen=Select[rnData,
    MemberQ[ellValues,#[[1]]] && qRange[[1]]<=#[[3]]<=qRange[[2]] &&
      (hatValues===All || MemberQ[hatValues,#[[2]]])&];
  If[chosen==={},Print["No samples match the selection."];Return[$Failed]];
  panels=Table[
    rows=Select[chosen,#[[1]]==ell&];
    If[rows==={},Graphics[Text["No samples"]], 
      ns=Sort[DeleteDuplicates[Cases[rows[[All,2]],_Integer]]];
      lines=Table[
        p=Select[rows,#[[2]]===n&][[All,{3,4,5}]];
        (* Preserve saved row order, including equal-charge evaluations. *)
        rnChargeLines[p],{n,ns}];
      (* SameQ avoids treating very near-extremal machine values as Q=1. *)
      sub=Select[rows,!(#[[3]]===1.)&];ext=Select[rows,#[[3]]===1.&];
      groups=GatherBy[sub,rnBin[#[[3]]]&];
      points=({rnColor[#[[1,3]]],PointSize[.003],Point[#[[All,{4,5}]]]}& /@ groups);
      stars=({rnColor[1],Text[Style["\[FivePointedStar]",14],#[[{4,5}]]]}& /@ ext);
      labels=If[Length[ns]<=8,Table[
        p=First[Select[rows,#[[2]]===n&]];
        Text[Style[Row[{Overscript["n","^"],"=",n}],10,Black],
              Offset[{7,7},p[[{4,5}]]],{-1,-1}],{n,ns}],{}];
      xr=MinMax[Append[rows[[All,4]],0]];
      yr=MinMax[rows[[All,5]]];
      dx=Max[.01,Subtract@@Reverse[xr]];dy=Max[.01,Subtract@@Reverse[yr]];
      rnRow[{
        Graphics[{{AbsoluteThickness[.7],lines},points,stars,labels},
          Frame->True,Axes->False,
          FrameLabel->{Style["Re(\[Omega])",14],Style["-Im(\[Omega])",14]},
          PlotLabel->Style[Row[{"\[ScriptL] = ",ell}],15],
          PlotRange->{xr+{-.06,.06}dx,yr+{-.025,.025}dy},
          GridLines->{{0},Automatic},GridLinesStyle->Directive[GrayLevel[.85],Thin],
          Epilog->{Gray,Dashed,Line[{{0,yr[[1]]-.025dy},{0,yr[[2]]+.025dy}}]},
          BaseStyle->{FontFamily->"Times New Roman",FontSize->11},
          ImageSize->490,AspectRatio->1.25,ImagePadding->{{58,12},{48,30}}],
        rnLegend[]},{490,55},650]
    ],{ell,DeleteDuplicates[ellValues]}];
  Print["Plotted ",Length[chosen]," saved samples, including ",
        Count[chosen,{_,_,1.|1,_,_}]," Q=1 roots."];
  rnRow[panels,ConstantArray[545,Length[panels]],650]
];
RNPlot[ell_Integer] := RNPlot[{ell},All];
RNPlot[ell_Integer,hat_Integer] := RNPlot[{ell},{hat}];
RNPlot[ells_List,hat_Integer] := RNPlot[ells,{hat}];
RNPlot[ell_Integer,hats_List] := RNPlot[{ell},hats];
If[!TrueQ[$RNNoAutoPlot],RNPlot[],Null]
