%% The first 42 QNMs for the gravitational perturbations of the Schwarzschild BH.
%% Visualization program
clc;clear;
%%　Load data　
load('s2l2_Sch.mat')
%% The first column of data represents the qnm frequency,
% the second column is the angular separation constant, 
% and the third column is the number of overtones.
figure
fig1 = plot( real(s2l2_Sch(:,1)),-imag(s2l2_Sch(:,1)),"ob",'MarkerFaceColor','r','Markersize',6);
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('-$\Im(\omega)$','Interpreter','latex'); % LaTeX
set(gca,'FontName','Times New Roman','FontSize',12) %设置全部字体
shading interp;
grid on
dtt = fig1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(3).Label = '$\ell = 2$';
dtt.FontSize = 7.2;
datatip(fig1,'DataIndex', 9,'Location','southwest');
datatip(fig1,'DataIndex', 10,'Location','northwest');

hold on
fig1 = plot( -real(s2l2_Sch(:,1)),-imag(s2l2_Sch(:,1)),"ob",'MarkerFaceColor','r','Markersize',6);
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('-$\Im(\omega)$','Interpreter','latex'); % LaTeX
set(gca,'FontName','Times New Roman','FontSize',12) %设置全部字体
shading interp;
grid on
dtt = fig1.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(3).Label = '$\ell = 2$';
dtt.FontSize = 7.2;
datatip(fig1,'DataIndex', 9,'Location','southeast');


%% 
load('s2l3_Sch.mat')

hold on
fig2 = plot( real(s2l3_Sch(:,1)),-imag(s2l3_Sch(:,1)),"sr",'MarkerFaceColor','blue','Markersize',7);
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('-$\Im(\omega)$','Interpreter','latex'); % LaTeX
set(gca,'FontName','Times New Roman','FontSize',12) %设置全部字体
shading interp;
grid on
dtt = fig2.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(3).Label = '$\ell = 3$';
dtt.FontSize = 7.2;
datatip(fig2,'DataIndex', 41,'Location','southwest');
datatip(fig2,'DataIndex', 42,'Location','northwest');
yLimits = get(gca, 'YLim');
line([0 0], yLimits, 'Color', 'k', 'LineStyle', '--', 'HandleVisibility', 'off');
hold on
fig2 = plot( -real(s2l3_Sch(:,1)),-imag(s2l3_Sch(:,1)),"sr",'MarkerFaceColor','blue','Markersize',7);
xlabel('$\Re(\omega)$','Interpreter','latex');
ylabel('-$\Im(\omega)$','Interpreter','latex'); % LaTeX
set(gca,'FontName','Times New Roman','FontSize',12) %设置全部字体
shading interp;
grid on
dtt = fig2.DataTipTemplate;
dtt.Interpreter = 'latex'; 
dtt.DataTipRows(1).Label = '$\Re(\omega)=$';
dtt.DataTipRows(2).Label = '$-\Im(\omega)=$';
dtt.DataTipRows(3).Label = '$\ell = 3$';
dtt.FontSize = 7.2;
datatip(fig2,'DataIndex', 41,'Location','northeast');
yLimits = get(gca, 'YLim');


xlim([-0.63 0.63])
ylim([-0.02 11])
legend1 = legend('$\ell = 2$','$ \ell = 3 $','Location','northeast');
set(legend1,'Interpreter','latex')
