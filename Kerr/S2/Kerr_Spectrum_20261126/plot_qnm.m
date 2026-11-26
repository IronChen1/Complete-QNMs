%% Visualization program for mode frequencies
clc; clear;
ell = 2;
overtone = 30; % The modifiable overtones range from 0 to 41.

%% Import XLSX into the variable layout used by the original plotting code
base = fileparts(mfilename('fullpath'));
file = fullfile(base,'Kerr_spectrum.xlsx');
opts = detectImportOptions(file,'Sheet',sprintf('hat_n_%02d',overtone),'TextType','string');
opts = setvartype(opts,opts.VariableNames,'string');
T = readtable(file,opts);
assert(ismember(ell,[2 3]),'ell must be 2 or 3.');
for import_m = -ell:ell
    R = T(str2double(T.ell)==ell & str2double(T.m)==import_m,:);
    valid = ~ismissing(R.qnm_re) & ~ismissing(R.qnm_im) & strlength(R.qnm_re)>0 & strlength(R.qnm_im)>0;
    if any(~valid)
        warning('ell=%d, m=%d, n=%d: unresolved endpoint frequencies are omitted.',ell,import_m,overtone);
    end
    R = R(valid,:);
    % Stored row order retains the exact-decimal spin ordering.
    % Conversion to double occurs only for plotting, not in the workbook.
    omega = complex(str2double(R.qnm_re),str2double(R.qnm_im));
    spin = str2double(R.a_over_M);
    % Column 2 is unused by the frequency plot. A_lm is not in this workbook.
    importedValues = [omega, complex(nan(height(R),1),nan(height(R),1)), spin];
    if import_m < 0
        importedName = sprintf('s2n%dl%dmf%d_Kerr',overtone,ell,abs(import_m));
    else
        importedName = sprintf('s2n%dl%dm%d_Kerr',overtone,ell,import_m);
    end
    eval([importedName,' = importedValues;']);
end

switch ell
case 2
%% m = 2
IterationValue = eval(['s2n', num2str(overtone), 'l2m2_Kerr']);
m = 2;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
figure
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');


%% m = -2
IterationValue = eval(['s2n', num2str(overtone), 'l2mf2_Kerr']);
m = -2;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');

%% m = 1
IterationValue = eval(['s2n', num2str(overtone), 'l2m1_Kerr']);
m = 1;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');

%% m = -1
IterationValue = eval(['s2n', num2str(overtone), 'l2mf1_Kerr']);
m = -1;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');

%% m = 0
IterationValue = eval(['s2n', num2str(overtone), 'l2m0_Kerr']);
m = 0;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');
hold on
yLimits = get(gca, 'YLim'); 
line([0 0], yLimits, 'Color', 'k', 'LineStyle', '--'); 

case 3
%% m = 3
IterationValue = eval(['s2n', num2str(overtone), 'l3m3_Kerr']);
m = 3;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
figure
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
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
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
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
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
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
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
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
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
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
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');

%% m = 0

% overtone = 39; 
IterationValue = eval(['s2n', num2str(overtone), 'l3m0_Kerr']);
m = 0;
TipName = ['$\{\ell m \hat{n}\}= \{',num2str(ell),',',num2str(m),',', num2str(overtone), '\}$'];
S1 = ones(size(IterationValue,1),1);
hold on
scatter1 = scatter(real(IterationValue(:,1)),-imag(IterationValue(:,1)),S1*5,IterationValue(:,3),'filled'); 
 set(gca, 'FontName', 'Times New Roman', 'FontSize', 12); % , 'FontSize', 10
shading interp;
grid on
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('$-\Im(\omega)$','Interpreter','latex'); % LaTeX
c = colorbar;
colormap(flipud(colormap('winter')));
c.Label.Interpreter ='latex';
c.Label.String ='$a$';
dtt = scatter1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(4).Label = '$a=$';
dtt.DataTipRows(3) = [];
dtt.DataTipRows(4) = TipName;
datatip(scatter1,'DataIndex',size(IterationValue,1),'Location','southwest');
hold on
yLimits = get(gca, 'YLim'); 
line([0 0], yLimits, 'Color', 'k', 'LineStyle', '--'); 

end
