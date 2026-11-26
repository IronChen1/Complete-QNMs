clc; clear;
load('KerrQNM_l3.mat')
ell = 3;
overtone = 0; % The modifiable overtones range from 0 to 41.
% %% The first column of data represents the qnm frequency,
% the second column is the angular separation constant, 
% and the third column is the rotation parameters from 0 to 0.999.
% The naming of the data is: 
% s2n0l3m1_Kerr.mat represents the QNM dataset of Kerr, with overtone = 0, ell = 3, and m = 1.
% s2n0l3mf1_Kerr.mat represents the QNM dataset of Kerr, with overtone = 0, ell = 3, and m = -1.


%The QNMs of any overtones have and only have 2ell + 1 sequences.
%% m = 3
IterationValue = eval(['s2n', num2str(overtone), 'l3m3_Kerr']);
m = 3;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
figure
scatter1 = scatter(real(IterationValue(:,2)),-imag(IterationValue(:,2)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(A_{\ell m})$','Interpreter','latex');
ylabel('$-\Im(A_{\ell m})$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(A_{\ell m})=$';
dtt.DataTipRows(2).Label = '$-\Im(A_{\ell m})=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');


%% m = -3
IterationValue = eval(['s2n', num2str(overtone), 'l3mf3_Kerr']);
m = -3;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,2)),-imag(IterationValue(:,2)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(A_{\ell m})$','Interpreter','latex');
ylabel('$-\Im(A_{\ell m})$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(A_{\ell m})=$';
dtt.DataTipRows(2).Label = '$-\Im(A_{\ell m})=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');




%% m = 2
IterationValue = eval(['s2n', num2str(overtone), 'l3m2_Kerr']);
m = 2;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,2)),imag(IterationValue(:,2)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(A_{\ell m})$','Interpreter','latex');
ylabel('$\Im(A_{\ell m})$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(A_{\ell m})=$';
dtt.DataTipRows(2).Label = '$\Im(A_{\ell m})=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');


%% m = -2
IterationValue = eval(['s2n', num2str(overtone), 'l3mf2_Kerr']);
m = -2;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,2)),imag(IterationValue(:,2)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(A_{\ell m})$','Interpreter','latex');
ylabel('$\Im(A_{\ell m})$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(A_{\ell m})=$';
dtt.DataTipRows(2).Label = '$\Im(A_{\ell m})=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');

%% m = 1
IterationValue = eval(['s2n', num2str(overtone), 'l3m1_Kerr']);
m = 1;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,2)),imag(IterationValue(:,2)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(A_{\ell m})$','Interpreter','latex');
ylabel('$\Im(A_{\ell m})$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(A_{\ell m})=$';
dtt.DataTipRows(2).Label = '$\Im(A_{\ell m})=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');

%% m = -1
IterationValue = eval(['s2n', num2str(overtone), 'l3mf1_Kerr']);
m = -1;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,2)),imag(IterationValue(:,2)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(A_{\ell m})$','Interpreter','latex');
ylabel('$\Im(A_{\ell m})$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(A_{\ell m})=$';
dtt.DataTipRows(2).Label = '$\Im(A_{\ell m})=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');

%% m = 0
IterationValue = eval(['s2n', num2str(overtone), 'l3m0_Kerr']);
m = 0;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,2)),imag(IterationValue(:,2)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(A_{\ell m})$','Interpreter','latex');
ylabel('$\Im(A_{\ell m})$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(A_{\ell m})=$';
dtt.DataTipRows(2).Label = '$\Im(A_{\ell m})=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');
hold on
yLimits = get(gca, 'YLim'); 
line([10 10], yLimits, 'Color', 'k', 'LineStyle', '--'); 
